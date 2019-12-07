#!/bin/bash

#set -x

NUM_REQUESTS=${NUM_REQUESTS:-2000}
CONCURRENCY=${CONCURRENCY:-40}
VERBOSITY='-v 0'
HOST=${HOST:-http://localhost:8080}

# this is pvc (tmp/data) and git repo (performanceresults)
OUT_DIR=/tmp/data/performanceresults/`date +%Y-%m-%d-%H-%M-%S`
mkdir -p ${OUT_DIR}

bold=$(tput bold)
normal=$(tput sgr0)

echo "${bold}GET 200 camel/hello?name=mike${normal}"

ab ${VERBOSITY} -n ${NUM_REQUESTS} -c ${CONCURRENCY} -g ${OUT_DIR}/get-hello-200.out "${HOST}/camel/hello?name=mike" 2>&1 | tee ${OUT_DIR}/get-hello-200.ab &

echo "${bold}GET 200 camel/bonjour?name=mike${normal}"

ab ${VERBOSITY} -n ${NUM_REQUESTS} -c ${CONCURRENCY} -g ${OUT_DIR}/get-bonjour-200.out "${HOST}/camel/bonjour?name=mike" 2>&1 | tee ${OUT_DIR}/get-bonjour-200.ab &

echo "waiting for tests to finish ..."
wait

# generate plot data
cd ${OUT_DIR}
ls *.out | sed -e "s/.out//" > list
for i in `cat list` ; do
   sed -e "s/INPUTFILE/$i/" -e "s/OUTPUTFILE/$i/" \
   /home/mike/git/ibmmq-tomcat-camel/performance/plot.gnu | gnuplot
done
rm list

exit 0
