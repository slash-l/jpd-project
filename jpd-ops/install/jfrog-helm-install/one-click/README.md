### JFrog Helm Charts 配置
Add JFrog Helm Charts Repository
```
helm repo add jfrog https://charts.jfrog.io
helm repo update jfrog
```

下载 JFrog Helm Chart
```
helm pull jfrog/artifactory --version <artifactory helm version>
helm pull jfrog/xray --version <xray helm version>

for example:  
helm pull jfrog/artifactory --version 107.104.15
helm pull jfrog/xray --version 103.124.11
```

查看目前 k8s 安装 JPD 中包含哪些镜像：  
kubectl get pods -n artifactory -o jsonpath="{..image}"
kubectl get pods -n xray -o jsonpath="{..image}"





