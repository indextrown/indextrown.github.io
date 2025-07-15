DATE := $(shell date +%F)

# 그냥 make 입력시 실행
.PHONY: all update
all: update
update:
	git add .
	git commit -m "update"
	git push origin main

# 파라미터 추가시 아래 실행
%:
	touch $(DATE)-$@.md