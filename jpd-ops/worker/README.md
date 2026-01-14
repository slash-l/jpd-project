# JFrog Workers
## 1. Workers 运维
### 1.1 Workers 安装
目前支持 Helm 和 Docker Compose 方式安装。  
安装略

### 1.2 Workers 配置
Worker 也有自己的 system.yaml 配置文件。  
具体参数参考如下：  
https://jfrog.com/help/r/jfrog-installation-setup-documentation/worker-yaml-configuration

## 2. Workers 开发
### 2.1 UI 方式开发
略

### 2.2 入参出参说明
#### context: PlatformContext
```
interface PlatformContext {
   baseUrl: string; // platform base URL
   clients: PlatformClients; // clients to communicate with the platform or external resources
   platformToken: string; // platform access token
   wait: (delayMs: number) => Promise<void> // creates a promise that resolves after "duration" expressed in millisecondes
}
```

PlatformContext 入参还有几层入参对象如下：  
PlatformContext
  |- PlatformClients
    |- PlatformHttpClient

每个对象都有自己的属性，具体参考：
https://jfrog.com/help/r/jfrog-platform-administration-documentation/platformcontext


#### data
每个 event 都有自己的 data 入参属性，例如：
- Before Upload Worker 
```
{
  "metadata": {  // Object containing metadata information about the artifact
    "repoPath": {  // Repository path information for the artifact
      "key": "local-repo",  // Unique key identifier for the repository
      "path": "folder/subfoder/my-file",  // Current path to the specific artifact within the repository
      "id": "local-repo:folder/subfoder/my-file",  // Unique identifier combining the repository key and path
      "isRoot": false,  // Indicates if the path is a root directory (false means it is nested)
      "isFolder": false  // Indicates if the path is a folder (false means it is a file)
    },
  }
  ...
}
```

### 2.3 CLI 方式开发
列出所有 worker 可以开发的触发事件
```
jf worker list-event
```
例如：创建一个下载后的触发 worker
```
jf worker init AFTER_DOWNLOAD slash-after-download-worker
```



