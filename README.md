# Onecloud-Llama-CPP
一个极简教程，让你在玩客云上跑AI。

## 简介

- **名字**：Onecloud-Llama-CPP
- **作者**：[Lirzh](https://github.com/lirzh)
- **内容概括**：一个帮助你在玩客云上跑AI的极简教程。
- **协议**：MIT
- **最后更新**：2025.7.9
- **关于AI**：该教程由AI与人工共同编写，人工检验，如有错误请联系作者。

## 使用方法

#### 环境准备：

你需要准备 g++ 和 cmake ，以及 g++ 的 curl 库：

##### 一起安装：

```
apt install g++ cmake libcurl4-openssl-dev
```

##### 或

##### g++安装：

```
apt install g++
```

##### cmake安装：

```
apt install cmake
```

##### curl库安装：

```
sudo apt-get install libcurl4-openssl-dev
```

#### 下载并编译 Llama.cpp ：

第一步是克隆仓库并进入该目录：

```
cd /root
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
```

随后，使用 CMake 执行 llama.cpp 构建：

```
cmake -B build
cmake --build build --config Release
```

第一条命令将检查本地环境并确定需要包含的推理后端与特性。第二条命令将实际构建程序文件。

为了缩短时间，你还可以根据你的CPU核心数开启并行编译，例如：

```
cmake --build build --config Release -j 4
```

这将以4个并行编译任务来构建程序。

结果将存于 `./build/bin/` 。

#### 上传gguf格式的模型

自己下载并上传到 /root/opt/llama.cpp/build/bin 文件夹中，一定要 **gguf** 格式

推荐 [Llama-3.2-1B-Instruct-Q2_K_L.gguf · unsloth/Llama-3.2-1B-Instruct-GGUF at main](https://huggingface.co/unsloth/Llama-3.2-1B-Instruct-GGUF/blob/main/Llama-3.2-1B-Instruct-Q2_K_L.gguf) 需要科学上网下载

##### 或

使用预制的 Llama-3.2-1B-Instruct-Q2_K_L.gguf 下载方式（采用 hf-mirror.com 镜像）：

```
wget http://hf-mirror.com/unsloth/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q2_K_L.gguf?download=true
```

#### 启动

```
./llama-server -m Llama-3.2-1B-Instruct-Q2_K_L.gguf -c 2048 -ngl 0 --host 0.0.0.0 -port 8080
```

## 版本

| 发布时间 | 版本号                                                       |
| -------- | ------------------------------------------------------------ |
| 2025.7.9 | [发行版 1..0 · Lirzh/Onecloud-Cpu-Control](https://github.com/Lirzh/Onecloud-Cpu-Control/releases/tag/1.1.0) |



## 反馈问题和 Bug

如果你在使用过程中遇到问题或发现 Bug，可以前往 [项目的 Issues 页面](https://github.com/lirzh/Onecloud-Llama-CPP/issues) 提交反馈，我们会 ~~尽快~~ 处理。

## 鸣谢

我们非常感谢所有为项目做出贡献的开发者（排名不分先后）：

[豆包AI](https://doubao.com)

[ggml-org/llama.cpp: LLM inference in C/C++](https://github.com/ggml-org/llama.cpp)

[Llama-3.2-1B-Instruct-Q2_K_L.gguf · unsloth/Llama-3.2-1B-Instruct-GGUF at main](https://huggingface.co/unsloth/Llama-3.2-1B-Instruct-GGUF/blob/main/Llama-3.2-1B-Instruct-Q2_K_L.gguf)

## 参考文献

- [ggml-org/llama.cpp: LLM inference in C/C++](https://github.com/ggml-org/llama.cpp)
- [llama.cpp - Qwen](https://qwen.readthedocs.io/zh-cn/latest/run_locally/llama.cpp.html)
- [Llama-3.2-1B-Instruct-Q2_K_L.gguf · unsloth/Llama-3.2-1B-Instruct-GGUF at main](https://huggingface.co/unsloth/Llama-3.2-1B-Instruct-GGUF/blob/main/Llama-3.2-1B-Instruct-Q2_K_L.gguf)

