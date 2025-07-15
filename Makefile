DATE := $(shell date +%F)
FILENAME := _posts/$(DATE)-$@.md

# 그냥 make 입력시 실행
.PHONY: all update
all: update
update:
	git add .
	git commit -m "update"
	git push origin main

# make 파일명 → _posts/2025-07-16-파일명.md 생성
%:
	@mkdir -p _posts
	@FILENAME="_posts/$(DATE)-$@.md"; \
	echo '---'                             >  $$FILENAME; \
	echo 'title: ""'                      >> $$FILENAME; \
	echo 'tags:'                          >> $$FILENAME; \
	echo '- '                             >> $$FILENAME; \
	echo 'header:'                        >> $$FILENAME; \
	echo '  teaser:'                      >> $$FILENAME; \
	echo 'typora-root-url: ../'           >> $$FILENAME; \
	echo '---'                            >> $$FILENAME; \
	echo ''                               >> $$FILENAME; \
	echo '<!-- <img src="{{ '\''이미지경로'\'' | relative_url }}" alt="이미지" width="30%"> -->' >> $$FILENAME                    >> $(DATE)-$@.md
# %:
# 	touch $(DATE)-$@.md