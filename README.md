## ibmmq-tomcat

Run IBM MQ

Docker
```
docker volume create mqm1
docker run -p1414:1414 -p9443:9443 --env LICENSE=accept --env MQ_QMGR_NAME=QMGR1 --volume mqm1:/mnt/mqm ibmcom/mq:9
```

```
docker volume create mqm2
docker run -p1415:1414 -p10443:9443 --env LICENSE=accept --env MQ_QMGR_NAME=QMGR1 --volume mqm2:/mnt/mqm ibmcom/mq:9
```

Login IBM MQ WebConsole
```
https://localhost:9443/ibmmq/console/
admin / passw0rd
```

Clone this repo and build
```
cd ~/git/ibmmq-tomcat-camel
./buildrun.sh
```

Test sending a message to `DEV.QUEUE.1` - browse to:

```
http://localhost:8080/camel/hello?name=mike
```

Performance testing
```
~/bin/run-scaled.sh /usr/bin/jconsole &

# run test
cd performance$ 
./performance-test.sh

# view graphs and results stored here
/tmp/data/performanceresults
```

Connect to tomcat on `localhost:9999` in jconsole.

