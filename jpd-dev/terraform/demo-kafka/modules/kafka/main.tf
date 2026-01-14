terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
        }
    }
}

resource "docker_image" "kafka" {
    name = "ubuntu/kafka:latest"
}

resource "docker_container" "kafka" {
    image = docker_image.kafka.name
    name    = "kafka_test"
    // zk的端口传递
    env = [
        "ZOOKEEPER_PORT=${var.zk_port}"
    ]
    ports {
        internal = 9092
        external = 19092
    }
}
