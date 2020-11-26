#!/bin/bash

#set -x

NUM_REQUESTS=${NUM_REQUESTS:-5000}
CONCURRENCY=${CONCURRENCY:-20}
OPTIONS='-v 0 -k -r -s 120'
HOST=${HOST:-http://localhost:8080}

SCRIPT_DIR=$(cd $(dirname $0);pwd)

# this is pvc (tmp/data) and git repo (performanceresults)
OUT_DIR=/tmp/data/performanceresults/`date +%Y-%m-%d-%H-%M-%S`
mkdir -p ${OUT_DIR}

bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}GET 200 camel/hello?name=mike${normal}"

ab ${OPTIONS} -n ${NUM_REQUESTS} -c ${CONCURRENCY} -g ${OUT_DIR}/get-hello-200.out "${HOST}/camel/hello?name=mike" 2>&1 | tee ${OUT_DIR}/get-hello-200.ab &

echo "${bold}GET 200 camel/bonjour?name=mike${normal}"

ab ${OPTIONS} -n ${NUM_REQUESTS} -c ${CONCURRENCY} -g ${OUT_DIR}/get-bonjour-200.out "${HOST}/camel/bonjour?name=mike" 2>&1 | tee ${OUT_DIR}/get-bonjour-200.ab &

echo "waiting for tests to finish ..."
wait

# generate plot data
cd ${OUT_DIR}
ls *.out | sed -e "s/.out//" > list
for i in `cat list` ; do
   sed -e "s/INPUTFILE/$i/" -e "s/OUTPUTFILE/$i/" \
   ${SCRIPT_DIR}/plot.gnu | gnuplot
done
rm list

exit 0
