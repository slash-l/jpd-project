terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
        }
    }
}

module "zookeeper" {
    // 一个本地路径必须以./或者../为前缀来标明要使用的本地路径，以区别于使用Terraform Registry路径。
    source = "./modules/zk"
}

module "kafka" {
    source = "./modules/kafka"
    // 由于依赖了zk模块是输出参数，terraform能够分析出来依赖关系，这里无需depends_on参数
    # depends_on = [
    #    module.zookeeper
    # ]
    zk_port = module.zookeeper.zk_port
}
