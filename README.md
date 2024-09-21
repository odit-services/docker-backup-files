# docker-backup-files

Docker image to periodically backup files to S3 (tested with AWS S3, Minio and Wasabi).

## Docker Image

The docker image is available on the GitHub Container Registry:

```shell
docker pull ghcr.io/odit-services/docker-backup-files:latest
```

## Usage

### Docker Compose

```yaml
services:
  minio:
    image: quay.io/minio/minio
    restart: always
    volumes:
      - data1-1:/data1
    ports:
      - 9000:9000
      - 9001:9001
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

  backup:
    image: ghcr.io/odit-services/docker-backup-files:latest
    volumes:
      - /data2-2:/data
    logging:
      options:
        max-size: "100k"
        max-file: "3"
    environment:
      STORAGE_ENDPOINT: minio:9000
      STORAGE_BUCKET: test
      STORAGE_REGION: test
      STORAGE_PATH: backup
      STORAGE_SSL: "false"
      STORAGE_INSECURE_SKIP_VERIFY: "false"
      STORAGE_RETENTION: 7
      ACCESS_KEY_ID: minioadmin
      SECRET_ACCESS_KEY: minioadmin
      
      TIME_SCHEDULE: "@daily"
```

### Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo
  namespace: project-dana-menden
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
        - name: demo
          image: nginx:latest
          volumeMounts:
            - mountPath: /usr/share/nginx/html
              name: data
        - name: backup
          image: ghcr.io/odit-services/docker-backup-files:latest
          volumeMounts:
            - mountPath: /data
              name: data
              readOnly: true
          envFrom:
            - secretRef:
                name: backup-settings
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: demo
      restartPolicy: Always
```

## Envionment Variables

### Storage Section

* ACCESS_KEY_ID - Minio or AWS S3 ACCESS Key ID
* SECRET_ACCESS_KEY - Minio or AWS S3 SECRET ACCESS Key
* STORAGE_ENDPOINT - S3 Endpoint
* STORAGE_BUCKET - S3 bucket name
* STORAGE_REGION - S3 Region
* STORAGE_PATH - backup folder path in bucket. default is `backup` and all dump file will save in `bucket_name/backup` directory
* STORAGE_SSL - default is `false`
* STORAGE_INSECURE_SKIP_VERIFY - default is `false`
* STORAGE_RETENTION - The number of backups to keep. default is `` (all)

### Schedule Section

* TIME_SCHEDULE - You may use one of several pre-defined schedules in place of a cron expression.
