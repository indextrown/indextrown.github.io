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
	echo "---"                                      >  $(DATE)-$@.md ; \
	echo 'title: ""'                                >> $(DATE)-$@.md ; \
	echo 'tags:'                                    >> $(DATE)-$@.md ; \
	echo '- '                                       >> $(DATE)-$@.md ; \
	echo 'header:'                                  >> $(DATE)-$@.md ; \
	echo '  teaser:'                                >> $(DATE)-$@.md ; \
	echo 'typora-root-url: ../'                     >> $(DATE)-$@.md ; \
	echo "---"                                      >> $(DATE)-$@.md
# %:
# 	touch $(DATE)-$@.md