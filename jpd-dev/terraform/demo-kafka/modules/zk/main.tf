terraform {
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
            version = "3.0.2"
        }
    }
}

resource "docker_image" "zookeeper" {
    name = "ubuntu/zookeeper:latest"
}

resource "docker_container" "zookeeper" {
    image = docker_image.zookeeper.name
    name    = "zookeeper_test"
    ports {
        internal = 2181
        external = 12181
    }
}
