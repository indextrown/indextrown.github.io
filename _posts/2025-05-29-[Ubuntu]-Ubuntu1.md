---
title: "[Ubuntu] 우분투 원격 서버 설정"
tags: 
- Xcode
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# 우분투 원격 서버 설정

[kt 공유기 링크](http://172.30.1.254:8899)
장치설정 -> 트래픽 관리 -> 포트포워딩 추가

<img src="{{ '/assets/img/2025-05-28-[Ubuntu]-Ubuntu1/image-20250529234134757.png' | relative_url }}" alt="이미지" width="30%">

## CUI 세팅 및 접속
```bash
sudo apt update
sudo apt install openssh-server

# 직접 실행
sudo systemctl start ssh

# 부팅 시 자동 실행
sudo systemctl enable ssh

# 서버 접속
ssh 로그인유저@링크 -p 포트번호  
```

## GUI 세틸 및 접속
```bash
# xrdp, xfce4, lightdm
sudo apt update
sudo apt install xrdp xfce4 lightdm -y

# .xsession 파일 재설정
echo "startxfce4" > ~/.xsession
chmod +x ~/.xsession

# 권한/세션 파일 정리
rm -f ~/.Xauthority ~/.ICEauthority

# xrdp 서비스 재시작
sudo systemctl restart xrdp

# lightdm 디스플레이 매니저로 고정
sudo dpkg-reconfigure lightdm

# Windows APP 프로그램으로 GUI 접속 진행
```

## 우분투 wake on lan 설정
```bash
# ethtool 설치
sudo apt update
sudo apt install ethtool -y

# 현재 설정 확인 (유선 NIC명 확인, 예: enp1s0) -> enp1s0, eth0 등 유선랜 이름 확인
ip link

# "Wake-on: g" 라고 나오면 WOL 지원
sudo ethtool enp1s0

# d로 되있으면 wake on lan 활성화
sudo ethtool -s enp1s0 wol g
sudo ethtool enp1s0

# 재부팅 시 자동으로 WOL이 켜지도록,
sudo nmcli connection show

# NAME            UUID                                  TYPE      DEVICE 
# netplan-enp1s0  cac41fbe-bc18-3d87-bba7-af2af7f8ffab  ethernet  enp1s0 
# lo              5ee3992e-8232-483a-88d7-6cf21f44d700  loopback  lo     

# 아래 명령어를 입력
sudo nmcli connection modify "netplan-enp1s0" 802-3-ethernet.wake-on-lan magic
sudo systemctl restart NetworkManager




```