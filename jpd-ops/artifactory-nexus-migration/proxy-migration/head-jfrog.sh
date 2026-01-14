#!/bin/bash

proxy_repo="maven-central"

jfrog_url="http://8.133.207.178:8082"

echo -e "$proxy_repo" | while read repository_name; do
  > ${repository_name}.log

  # 读取文件路径
  cat ${repository_name}.txt | while read file_path; do
    head_url="$jfrog_url/artifactory/$repository_name/$file_path"
    echo "curl -sI $head_url"
    
    status=`curl -sI "$head_url" | grep HTTP | tr -d '\n'`
    echo "${file_path} ${status}"  >> ${repository_name}.log
  done
done
