//
//  ViewController.swift
//  HelloCocoaPods
//
//  Created by Jingyi Liu on 2026/1/11.
//

import UIKit
import Alamofire // 引入外部包

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("🚀 Demo 成功！Hello World!")
        
        // 使用 Alamofire 发起一个简单的请求
//        AF.request("https://httpbin.org/get").response { response in
//            debugPrint(response)
//            
//            // 如果请求成功，在控制台打印 Hello World
//            if response.error == nil {
//                print("🚀 成功！CocoaPods 依赖包已工作。Hello World!")
//            }
//        }
    }


}

