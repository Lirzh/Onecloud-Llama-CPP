#!/bin/bash
set -euo pipefail  # 严格模式：遇到错误立即退出，未定义变量报错

# 颜色与样式定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 无颜色

# 进度显示函数
show_progress() {
    local current=$1
    local total=$2
    local percentage=$((current * 100 / total))
    local bar_length=40
    local filled_length=$((percentage * bar_length / 100))
    local bar=$(printf "%0.s#" $(seq 1 $filled_length))
    local spaces=$(printf "%0.s " $(seq 1 $((bar_length - filled_length))))
    echo -ne "\r[${bar}${spaces}] ${percentage}%  (${current}/${total})"
}

# 主程序开始
echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}         Onecloud-Llama-CPP 启动脚本         ${NC}"
echo -e "${BLUE}=============================================${NC}\n"

# 创建并切换到工作目录
WORK_DIR="/opt/Onecloud-Llama-CPP"
echo -e "${YELLOW}准备工作目录：${WORK_DIR}${NC}"
sudo mkdir -p "$WORK_DIR"
sudo chown -R "$USER:$USER" "$WORK_DIR"
cd "$WORK_DIR" || { echo -e "${RED}错误：无法创建或访问工作目录${WORK_DIR}${NC}"; exit 1; }

# 1. 环境准备
echo -e "${YELLOW}【步骤1/4】正在准备运行环境...${NC}"
total_steps=5
current_step=1

show_progress $current_step $total_steps
if ! sudo apt update -y > /dev/null 2>&1; then
    echo -e "\n${YELLOW}警告：更新软件源失败，继续执行后续步骤${NC}"
else
    current_step=$((current_step + 1))
fi
show_progress $current_step $total_steps

sudo apt install -y g++ cmake libcurl4-openssl-dev > /dev/null 2>&1 || { echo -e "\n${RED}错误：安装依赖失败${NC}"; exit 1; }
current_step=$((current_step + 1))
show_progress $current_step $total_steps

# 检查cmake版本
cmake_version=$(cmake --version | head -n1 | awk '{print $3}')
if dpkg --compare-versions "$cmake_version" lt "3.16"; then
    echo -e "\n${YELLOW}警告：cmake版本过低，可能导致编译失败${NC}"
    echo -e "${YELLOW}建议安装cmake 3.16+版本${NC}"
    read -p "是否继续？[y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
current_step=$((current_step + 1))
show_progress $current_step $total_steps

echo -e "\r${GREEN}【步骤1/4】环境准备完成！${NC}\n"

# 2. 下载并编译Llama.cpp
echo -e "${YELLOW}【步骤2/4】正在编译Llama.cpp...${NC}"
current_step=1
total_steps=3

show_progress $current_step $total_steps
if [ ! -d "llama.cpp" ]; then
    git clone https://github.com/ggerganov/llama.cpp.git > /dev/null 2>&1 || { echo -e "\n${RED}错误：克隆仓库失败，请检查网络${NC}"; exit 1; }
else
    echo -e "\r${YELLOW}提示：llama.cpp已存在，跳过克隆${NC}"
fi
current_step=$((current_step + 1))
show_progress $current_step $total_steps

cd llama.cpp || { echo -e "\n${RED}错误：进入llama.cpp目录失败${NC}"; exit 1; }
mkdir -p build && cd build > /dev/null 2>&1
cmake .. > /dev/null 2>&1 || { echo -e "\n${RED}错误：cmake配置失败${NC}"; exit 1; }
current_step=$((current_step + 1))
show_progress $current_step $total_steps

make -j$(nproc) > /dev/null 2>&1 || { echo -e "\n${RED}错误：编译失败${NC}"; exit 1; }
echo -e "\r${GREEN}【步骤2/4】Llama.cpp编译完成！${NC}\n"

# 3. 下载模型文件
echo -e "${YELLOW}【步骤3/4】正在下载模型文件...${NC}"
model_name="Llama-3.2-1B-Instruct-Q2_K_L.gguf"
model_url="http://hf-mirror.com/unsloth/Llama-3.2-1B-Instruct-GGUF/resolve/main/${model_name}?download=true"

cd "$WORK_DIR" || exit 1  # 确保回到工作目录

if [ -f "$model_name" ]; then
    echo -e "${YELLOW}提示：模型文件已存在，跳过下载${NC}"
else
    # 使用wget带进度条下载
    wget -O "$model_name" "$model_url" --progress=bar:force 2>&1 || {
        echo -e "\n${RED}错误：模型下载失败${NC}"
        echo -e "${YELLOW}备用链接：https://huggingface.co/unsloth/Llama-3.2-1B-Instruct-GGUF${NC}"
        exit 1
    }
fi
echo -e "${GREEN}【步骤3/4】模型文件准备完成！${NC}\n"

# 4. 启动服务
echo -e "${YELLOW}【步骤4/4】正在启动服务...${NC}"
port=8080

# 检查端口是否被占用
if lsof -i:$port > /dev/null 2>&1; then
    echo -e "${YELLOW}警告：端口${port}已被占用${NC}"
    read -p "请输入新的端口号 [1024-65535]: " port
    if ! [[ $port =~ ^[0-9]+$ ]] || [ $port -lt 1024 ] || [ $port -gt 65535 ]; then
        echo -e "${RED}错误：无效的端口号${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}启动参数：${NC}"
echo -e "  模型文件：${model_name}"
echo -e "  端口：${port}"
echo -e "  上下文长度：2048\n"

read -p "是否立即启动服务？[y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$WORK_DIR/llama.cpp/build/bin" || { echo -e "${RED}错误：找不到llama-server可执行文件${NC}"; exit 1; }
    ./llama-server -m "../../$model_name" -c 2048 -ngl 0 --host 0.0.0.0 -port $port
else
    echo -e "${YELLOW}服务未启动，可手动执行以下命令启动：${NC}"
    echo -e "cd $WORK_DIR/llama.cpp/build/bin; ./llama-server -m \"../../$model_name\" -c 2048 -ngl 0 --host 0.0.0.0 -port $port"
fi

echo -e "\n${BLUE}=============================================${NC}"
echo -e "${GREEN}操作完成！如有问题请查看项目文档${NC}"
echo -e "${BLUE}=============================================${NC}"