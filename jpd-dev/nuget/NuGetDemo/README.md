
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
dotnet nuget Add source -n Artifactory https://demo.jfrogchina.com/artifactory/api/nuget/v3/slash-nuget-remote/index.json -u slash -p cmVmdGtuOjAxOjE3NTc3MjEwNTc6aXNyQ3VseTJhd3A2dEJwamR2eUlGQVExNUdI --store-password-in-clear-text

添加一个 http 源，需要在全局配置文件手动添加：   
vim ~/.nuget/NuGet/NuGet.Config  
```
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
    <add key="Artifactory" value="https://demo.jfrogchina.com/artifactory/api/nuget/v3/slash-nuget-remote/inde
x.json" />
    <add key="Artifactory2" value="https://demo.jfrogchina.com/artifactory/api/nuget/v3/slash-nuget-nexus-remo
te/index.json" />
    <add key="Nexus" value="http://47.117.139.192:8081/repository/nuget.org-proxy/index.json" allowInsecureCon
nections="true"/>
  </packageSources>
  <packageSourceCredentials>
    <Artifactory>
        <add key="Username" value="slash" />
        <add key="ClearTextPassword" value="cmVmdGtuOjAxOjE3NTc3MjEwNTc6aXNyQ3VseTJhd3A2dEJwamR2eUlGQVExNUdI" 
/>
      </Artifactory>
    <Artifactory2>
      <add key="Username" value="slash" />
      <add key="ClearTextPassword" value="cmVmdGtuOjAxOjE3NTc3MjEwNTc6aXNyQ3VseTJhd3A2dEJwamR2eUlGQVExNUdI" />
    </Artifactory2>
    <Nexus>
      <add key="Username" value="admin" />
      <add key="ClearTextPassword" value="Slashliu0709!" />
    </Nexus>
  </packageSourceCredentials>

  <disabledPackageSources>
    <add key="nuget.org" value="true" />
    <add key="Artifactory" value="true" />
    <add key="Artifactory2" value="true" />
  </disabledPackageSources>
</configuration>
```

# 关闭 nuget.org 源
dotnet nuget disable source nuget.org
