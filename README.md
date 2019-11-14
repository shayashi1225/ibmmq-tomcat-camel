## ibmmq-tomcat

Run IBM MQ
```
docker volume create mqm
docker run -p1414:1414 -p9443:9443 --env LICENSE=accept --env MQ_QMGR_NAME=QMGR1 --volume mqm:/mnt/mqm ibmcom/mq:9
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

