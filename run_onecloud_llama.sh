#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# 工作目录
WORK_DIR=$(pwd)
LLAMA_CPP_DIR="$WORK_DIR/llama.cpp"
MODELS_DIR="$WORK_DIR/models"
QUANTIZED_MODELS_DIR="$WORK_DIR/quantized_models"
TOKENIZER_PATH="$WORK_DIR/tokenizer.model"

# 确保目录存在
mkdir -p $MODELS_DIR
mkdir -p $QUANTIZED_MODELS_DIR

# 检查参数
BUILD_TYPE="Release"
if [ "$1" = "debug" ]; then
    BUILD_TYPE="Debug"
    echo -e "${YELLOW}使用调试模式构建${RESET}"
fi

# 检查是否安装了必要的依赖
echo -e "${GREEN}检查依赖...${RESET}"
dependencies=("git" "cmake" "make" "g++" "wget" "unzip" "python3" "pip")
missing_deps=()

for dep in "${dependencies[@]}"; do
    if ! command -v $dep &> /dev/null; then
        missing_deps+=($dep)
    fi
done

if [ ${#missing_deps[@]} -ne 0 ]; then
    echo -e "${RED}错误: 缺少以下依赖:${RESET}"
    for dep in "${missing_deps[@]}"; do
        echo -e "${RED}- $dep${RESET}"
    done
    echo -e "${YELLOW}请先安装这些依赖再继续。${RESET}"
    exit 1
fi

# 克隆 llama.cpp 仓库
echo -e "${GREEN}克隆 llama.cpp 仓库...${RESET}"
if [ ! -d "$LLAMA_CPP_DIR" ]; then
    git clone https://github.com/ggerganov/llama.cpp.git $LLAMA_CPP_DIR
    cd $LLAMA_CPP_DIR
    git checkout master
    cd $WORK_DIR
else
    echo -e "${YELLOW}llama.cpp 仓库已存在，跳过克隆${RESET}"
fi

# 构建 llama.cpp
echo -e "${GREEN}构建 llama.cpp...${RESET}"
cd $LLAMA_CPP_DIR
if [ "$BUILD_TYPE" = "Release" ]; then
    cmake -B build -DCMAKE_BUILD_TYPE=Release
    cmake --build build --config Release -j $((`nproc`)) --verbose
else
    cmake -B build -DCMAKE_BUILD_TYPE=Debug
    cmake --build build --config Debug -j $((`nproc`)) --verbose
fi
cd $WORK_DIR

# 下载模型和分词器
echo -e "${GREEN}下载模型和分词器...${RESET}"
# 这里应该有下载模型和分词器的代码
# 由于不清楚具体模型，这部分保持原样

# 量化模型
echo -e "${GREEN}量化模型...${RESET}"
# 这里应该有量化模型的代码
# 由于不清楚具体模型，这部分保持原样

# 运行推理
echo -e "${GREEN}运行推理...${RESET}"
# 这里应该有运行推理的代码
# 由于不清楚具体模型，这部分保持原样

echo -e "${GREEN}OneCloud-Llama-CPP 设置完成！${RESET}"
