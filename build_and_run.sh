#!/bin/bash

# 设置镜像名称和版本
IMAGE_NAME="we-mp-rss"
IMAGE_VERSION="local"

# 停止并移除现有的 Docker Compose 服务
echo "停止并移除现有的 Docker Compose 服务..."
docker-compose -f ./compose/docker-compose-local.yaml down
if [ $? -ne 0 ]; then
    echo "Docker Compose 停止失败，可能未运行。继续执行..."
fi

# 删除之前的 Docker 镜像
echo "删除之前的 Docker 镜像..."
docker rmi -f $IMAGE_NAME:$IMAGE_VERSION
if [ $? -ne 0 ]; then
    echo "未找到之前的镜像或删除失败，继续执行..."
fi

# 构建 Docker 镜像
echo "开始构建 Docker 镜像..."
docker build -t $IMAGE_NAME:$IMAGE_VERSION .
if [ $? -ne 0 ]; then
    echo "Docker 镜像构建失败！"
    exit 1
fi
echo "Docker 镜像构建成功：$IMAGE_NAME:$IMAGE_VERSION"

# 启动 Docker Compose 服务
echo "启动 Docker Compose 服务..."
docker-compose -f ./compose/docker-compose-local.yaml up -d
if [ $? -ne 0 ]; then
    echo "Docker Compose 启动失败！"
    exit 1
fi
echo "Docker Compose 服务已启动。"

# 显示运行中的容器
echo "当前运行中的容器："
docker ps