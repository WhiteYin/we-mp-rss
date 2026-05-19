#!/bin/bash

# 设置镜像名称和版本
IMAGE_NAME="we-mp-rss"
IMAGE_VERSION="local"

# 参数检查：仅当传入 'web' 参数时执行前端构建
if [ "$1" == "web" ]; then
    # 前端构建步骤
    echo "开始构建前端项目..."
    cd web_ui
    if [ $? -ne 0 ]; then
        echo "进入 web_ui 目录失败！"
        exit 1
    fi

    # 运行build.sh脚本
    ./build.sh
    if [ $? -ne 0 ]; then
        echo "前端构建失败！"
        exit 1
    fi

    # 返回项目根目录
    cd ..
    echo "已返回项目根目录"
else
    echo "跳过前端构建步骤 (需要传递 'web' 参数以执行前端构建)"
fi

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