## 1. Sonarqube 安装
制定下载镜像及对应的平台  
```
docker pull sonarqube:26.1.0.118079-community --platform linux/amd64
```
启动 sonarqube
```
docker run -d --name sonarqube \
    -p 9000:9000 \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    -v sonarqube_logs:/opt/sonarqube/logs \
    sonarqube:26.1.0.118079-community
```
启动后默认登录认证信息
- 用户名：admin
- 密码：admin

## 2. 扫描
### 2.1 maven 项目
setting.xml 添加以下内容
```
<pluginGroups>
    <!-- sonarqube plugin -->
    <pluginGroup>org.sonarsource.scanner.maven</pluginGroup>
</pluginGroups>
```

执行以下扫描命令
```
mvn clean verify sonar:sonar \
  -Dsonar.host.url=http://<sonarqube url>:9000 \
  -Dsonar.token=<sonarqube token>
```

mvn clean verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.token=myAuthenticationToken

jf evd create \
--build-name slash-app-simple-maven \
--build-number 4 \
--key evidence.key \
--key-alias evd-key-20251230-150302 \
--integration sonar
