## maven Demo
### step 1 maven build war
```
mvn clean install
```

### step 2 构建 app-simple-boot 镜像
```
docker build -t soleng.jfrog.io/slash-docker-dev-local/app-simple-maven:v1.0.3 .

docker push soleng.jfrog.io/slash-docker-dev-local/app-simple-maven:v1.0.3
```

### step 3 生成部署脚本
```
kubectl create deployment slash-simple-maven \
  --image=soleng.jfrog.io/slash-docker-dev-local/app-simple-maven:v1.0.3 \
  --namespace=slash-ns \
  --dry-run=client -o yaml > slash-simple-maven-deployment.yaml
```

生成以下 deployment.yaml 部署文件，添加 secret 认证（前提：已经创建好了 secret 认证）
```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: slash-simple-maven
  name: slash-simple-maven
  namespace: slash-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: slash-simple-maven
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: slash-simple-maven
    spec:
      containers:
      - image: soleng.jfrog.io/slash-docker-dev-local/app-simple-maven:v1.0.3
        name: slash-simple-maven
      imagePullSecrets:
      - name: jfrog-registry-secret
```

如果第一次需要创建认证
```
kubectl create secret docker-registry jfrog-registry-secret \
  --namespace=slash-ns \
  --docker-server=soleng.jfrog.io \
  --docker-username=<用户名> \
  --docker-password=<密码>
```

### step 4 部署到 k8s 
```
kubectl apply -f slash-simple-maven-deployment.yaml
```

