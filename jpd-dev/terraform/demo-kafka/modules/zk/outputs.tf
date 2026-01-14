output "zk_port" {
        // 在表达式中引用资源属性的语法是<RESOURCE TYPE>.<NAME>.<ATTRIBUTE>。
        value = docker_container.zookeeper.ports[0].external
}
