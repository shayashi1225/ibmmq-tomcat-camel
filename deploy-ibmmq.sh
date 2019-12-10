#!/usr/bin/env bash

QMGRNO=${QMGRNO:-4}

for x in {1..$QMGRNO}; do

APP_NAME=qmgr$x

cat <<EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
    name: mq-secret
type: Opaque
data:
    adminPassword: cGFzc3cwcmQ=
---
apiVersion: v1
kind: ImageStream
metadata:
  labels:
    app: ${APP_NAME}
    app.kubernetes.io/instance: ${APP_NAME}
  name: ${APP_NAME}
spec:
  lookupPolicy:
    local: false
  tags:
  - from:
      kind: DockerImage
      name: ibmcom/mq:9.1.3.0-r3
    importPolicy: {}
    name: latest
    referencePolicy:
      type: Source
---
apiVersion: apps.openshift.io/v1
kind: DeploymentConfig
metadata:
  labels:
    app: ${APP_NAME}
    app.kubernetes.io/instance: ${APP_NAME}
  name: ${APP_NAME}
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    app: ${APP_NAME}
    deploymentconfig: ${APP_NAME}
  strategy:
    activeDeadlineSeconds: 21600
    resources: {}
    rollingParams:
      intervalSeconds: 1
      maxSurge: 25%
      maxUnavailable: 25%
      timeoutSeconds: 600
      updatePeriodSeconds: 1
    type: Rolling
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: ${APP_NAME}
        deploymentconfig: ${APP_NAME}
    spec:
      containers:
      - env:
        - name: LICENSE
          value: accept
        - name: MQ_QMGR_NAME
          value: QMGR1
        - name: MQ_MULTI_INSTANCE
          value: "false"
        - name: LOG_FORMAT
          value: basic
        - name: MQ_ENABLE_METRICS
          value: "true"
        - name: DEBUG
          value: "false"
        - name: MQ_EPHEMERAL_PREFIX
          value: /run/mqm
        - name: MQ_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              key: adminPassword
              name: mq-secret
        image: ''
        imagePullPolicy: Always
        livenessProbe:
          exec:
            command:
            - chkmqhealthy
          failureThreshold: 1
          initialDelaySeconds: 60
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 5
        name: ${APP_NAME}
        ports:
        - containerPort: 1414
          protocol: TCP
        - containerPort: 9443
          protocol: TCP
        - containerPort: 9157
          protocol: TCP
        readinessProbe:
          exec:
            command:
            - chkmqready
          failureThreshold: 1
          initialDelaySeconds: 10
          periodSeconds: 5
          successThreshold: 1
          timeoutSeconds: 3
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
          requests:
            cpu: 500m
            memory: 512Mi
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          runAsNonRoot: true
          runAsUser: 888
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /mnt/mqm
          name: mqm-data
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext:
        fsGroup: 888
      terminationGracePeriodSeconds: 30
      volumes:
      - name: mqm-data
        persistentVolumeClaim:
          claimName: ${APP_NAME}
  test: false
  triggers:
  - type: ConfigChange
  - imageChangeParams:
      automatic: true
      containerNames:
      - ${APP_NAME}
      from:
        kind: ImageStreamTag
        name: ${APP_NAME}:latest
    type: ImageChange
---
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: "2019-12-05T01:58:42Z"
  labels:
    app: ${APP_NAME}
  name: ${APP_NAME}
spec:
  ports:
  - name: console-https
    port: 9443
    protocol: TCP
    targetPort: 9443
  - name: qmgr
    port: 1414
    protocol: TCP
    targetPort: 1414
  selector:
    app: ${APP_NAME}
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: ${APP_NAME}
spec:
  port:
    targetPort: 9443
  subdomain: ""
  tls:
    termination: passthrough
  to:
    kind: Service
    name: ${APP_NAME}
    weight: 100
  wildcardPolicy: None
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  finalizers:
  - kubernetes.io/pvc-protection
  name: ${APP_NAME}
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: gp2
  volumeMode: Filesystem
EOF

done

