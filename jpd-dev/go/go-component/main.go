package main

import "fmt"

func main() {
    fmt.Println("Hello, Go Demo!")
    
    // 基础类型示例
    var name string = "Go Demo"
    version := 1.0
    isActive := true
    
    fmt.Printf("Project: %s\n", name)
    fmt.Printf("Version: %.1f\n", version)
    fmt.Printf("Active: %v\n", isActive)
    
    // 调用其他函数
    result := add(10, 5)
    fmt.Printf("10 + 5 = %d\n", result)
    
    // 切片示例
    numbers := []int{1, 2, 3, 4, 5}
    fmt.Printf("Numbers: %v\n", numbers)
}

func add(a, b int) int {
    return a + b
}
