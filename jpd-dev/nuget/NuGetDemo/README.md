## .net

### .csproj 文件
CSProj 文件（C# 项目文件）是 Visual Studio / .NET SDK 使用的项目配置文件，它定义了项目的结构、依赖项、构建规则和元数据。



# 查看当前源
dotnet nuget list source

dotnet restore

包会默认安装到本地的 ~/.nuget/packages

dotnet list package


# 1. 清除所有缓存
dotnet nuget locals all --clear

# 2. 验证缓存为空
dotnet nuget locals all --list

# 3. 还原项目（重新下载包）
dotnet restore


# 添加 Artifactory 源
dotnet nuget add source -n Artifactory https://demo.jfrogchina.com/artifactory/api/nuget/v3/slash-nuget-virtual/index.json -u slash -p <password> --store-password-in-clear-text

dotnet nuget list source

dotnet nuget remove source <source_repo_name>

添加一个 http 源，需要在全局配置文件手动添加：   
vim ~/.nuget/NuGet/NuGet.Config  
```
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
    <add key="Nexus" value="http://47.117.139.192:8081/repository/nuget.org-proxy/index.json" allowInsecureCon
nections="true"/>
  </packageSources>
  <packageSourceCredentials>
    <Nexus>
      <add key="Username" value="admin" />
      <add key="ClearTextPassword" value="<password>" />
    </Nexus>
  </packageSourceCredentials>

  <disabledPackageSources>
    <add key="nuget.org" value="true" />
  </disabledPackageSources>
</configuration>
```

# 关闭 nuget.org 源
dotnet nuget disable source nuget.org


## 添加 Nuget 包
```
dotnet add package Newtonsoft.Json
```
命令执行后会自动修改 .csproj 文件

