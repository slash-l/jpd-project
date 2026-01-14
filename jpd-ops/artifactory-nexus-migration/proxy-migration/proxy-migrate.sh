#!/bin/bash

proxy_repo="maven-releases"

nexus_url="http://47.117.146.131:8083"

echo -e "$proxy_repo" | while read repository_name; do
  > ${repository_name}.txt
  
  first_search_url="$nexus_url/service/rest/v1/search?repository=$repository_name"
  # 打印请求的 URL
  echo "Fetching data from $first_search_url"

  # 发送请求并保存响应
  response=$(curl -s "$first_search_url")
  
  # 打印响应内容
  echo "Proxy Repo $repository_name: First page: "
  echo "$response" | jq -r '.items[].assets[].path' | grep -v '.sha1'
  echo "$response" | jq -r '.items[].assets[].path' | grep -v '.sha1' >> ${repository_name}.txt
  
  continuationToken=`echo "$response" | jq -r '.continuationToken'`
  
  if [ "$continuationToken" != "null" ]; then
    while true; do
      search_url="$nexus_url/service/rest/v1/search?repository=$repository_name&continuationToken=$continuationToken"
      response=$(curl -s "$search_url")

      echo "Next page continuationToken is $continuationToken "
      echo "$response" | jq -r '.items[].assets[].path' | grep -v '.sha1'
      echo "$response" | jq -r '.items[].assets[].path' | grep -v '.sha1' >> ${repository_name}.log
      echo "$response" >> ${repository_name}.log

      echo "$response" | jq -r '.items[].assets[].path' | grep -v '.sha1' >> ${repository_name}.txt
      continuationToken=`echo "$response" | jq -r '.continuationToken'`
      if [[ "$continuationToken" == "null" ]]; then
        break
      fi
    done
  fi
done
