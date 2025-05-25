---
title: "[Docker] code-server"
tags: 
- Docker
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

```bash
# Dockerfile

FROM ubuntu:latest

# ----- 기본 패키지 설치 -----
RUN apt-get update && \
    apt-get install -y \
        curl sudo python3 python3-pip default-jdk \
        git wget nano locales \
        libpython3.10 libicu-dev libxml2-dev clang \
        unzip gnupg2 libcurl4-openssl-dev pkg-config \
    && apt-get clean

# ----- 로케일 설정 -----
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ----- ARG로 외부에서 변수 받기 -----
ARG USER
ARG PASSWORD

# ----- 사용자 생성 및 sudo 권한 부여 -----
RUN useradd -m ${USER} && echo "${USER}:${PASSWORD}" | chpasswd && adduser ${USER} sudo

# ----- code-server 설치 및 작업 디렉토리 생성 -----
ENV WORKINGDIR="/home/${USER}/vscode"
RUN curl -fsSL https://code-server.dev/install.sh | sh && \
    mkdir -p ${WORKINGDIR} && chown -R ${USER}:${USER} ${WORKINGDIR}

# ----- 컨테이너 환경변수로도 유지 -----
ENV PASSWORD=${PASSWORD}
ENV USER=${USER}

# ----- 사용자 전환 -----
USER ${USER}
WORKDIR ${WORKINGDIR}

# ----- VSCode 확장 설치 -----
RUN code-server --install-extension ms-python.python && \
    code-server --install-extension ms-azuretools.vscode-docker && \
    code-server --install-extension formulahendry.code-runner

# ----- 포트 오픈 -----
EXPOSE 8080

# ----- code-server 실행 -----
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password", "."]
```

```bash
# 컨테이너 터미널로 진입
docker exec -it vscode-container bash

# 이동
cd /home/ec2-user/.local/share/code-server/User

nano settings.json

{
  "code-runner.executorMap": {
    "python": "python3 -u",
    "swift": "/home/ec2-user/.local/share/swiftly/bin/swift"
  },
  "code-runner.showExecutionMessage": false,
  "code-runner.clearPreviousOutput": true
}

# 저장
ctrl + o
enter
ctrl x

# 나가고 재빌드
exit
docker compose up -d --build
```

# swift 추가
```bash
# 컨테이너 터미널로 진입
docker exec -it vscode-container bash
```

```bash
# 1. 기존 swiftly 완전 삭제
rm -rf ~/.local/share/swiftly
rm -f ~/swiftly

# 2. 필수 패키지 설치
sudo apt-get update
sudo apt-get install -y clang libicu-dev wget libpython3-dev

# 3. 최신 swiftly 설치
curl -O "https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz"
tar zxf "swiftly-$(uname -m).tar.gz"
chmod +x swiftly
./swiftly init --quiet-shell-followup --assume-yes

# 4. 환경 변수 적용
source ~/.local/share/swiftly/env.sh
echo 'source ~/.local/share/swiftly/env.sh' >> ~/.bashrc

# 5. Swift 6.1.0 설치 (실제 toolchain 다운로드)
~/.local/share/swiftly/bin/swiftly install 6.1.0 --assume-yes --verify

# 6. swift 실행 확인
find ~/.local/share/swiftly/toolchains -name swift -type f -executable
swift --version
```