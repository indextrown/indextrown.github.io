---
title: 코딩 테스트 문제풀이 블로그에 자동 포스팅하기 with 백준허브
tags:
- ETC 
- Jekyll
category: ''
use_math: true
---
{% raw %}

크롬 브라우저의 [백준허브](https://chrome.google.com/webstore/detail/%EB%B0%B1%EC%A4%80%ED%97%88%EB%B8%8Cbaekjoonhub/ccammcjdkpgjmcpijpahlehmapgmphmk/related?utm_source=ext_sidebar&hl=ko)를 이용하면 프로그래머스와 백준에서 푼 코딩테스트 연습문제들을 깃허브에 자동으로 커밋&푸시 해주는데, 이 결과를 이용해 아래처럼 블로그에도 자동으로 포스트를 생성할 수 있게 코드를 짜보았다.

## 1. 로컬저장소에 알고리즘 깃 저장소 불러오기

```shell
git clone {자신의 코테 저장소 깃허브 주소} 
# ex. git clone https://github.com/ddangchani/Algorithm
git pull
```

## 2. 디렉토리 변수 설정

```python
import os
from datetime import datetime

blog_dir = '/Users/dangchan/Desktop/ddangchani.github.io' # 깃블로그 디렉토리
target_dir = '/Users/dangchan/Desktop/Github/Algorithm/프로그래머스' # 알고리즘 문제 디렉토리 : 프로그래머스

questions = []

for root, dirs, files in os.walk(target_dir):
    # check .py file in files
    for file in files:
        if file.endswith(".py"):
            # save root at questions
            questions.append(root)
```

`blog_dir`와 `target_dir` 에 `...`은 자신의 로컬 환경에 맞게 수정하면 된다. `question` 리스트는 코딩테스트 풀이가 저장된 로컬 저장소에서 *문제별 폴더 경로*를 저장한다.

## 3. 포스트 만들기

```python
for q_dir in questions:
    ls_file = os.listdir(q_dir)
    md_file = 'README.md'
    py_file = [f for f in ls_file if f.endswith('.py')][0]

    # create date
    date = os.path.getctime(q_dir + '/' + py_file)
    date = datetime.fromtimestamp(date).strftime('%Y-%m-%d')
    
    # title
    title = q_dir.replace('\u2005', ' ')
    title = title.split('/')[-1]
    question_number = title.split('.')[0] # 문제 번호
    filename = f'{date}-프로그래머스-{question_number}.md' # 저장할 파일 이름

    # 이미 포스팅되었으면 넘어가기
    if filename in os.listdir(blog_dir + '/_posts'):
        continue

    # YAML
    header = ['---\n',
 f'title: (프로그래머스) {title} \n',
 'tags:\n',
 '- Algorithm\n',
 '- Coding Test\n',
 "category: ''\n",
 'use_math: true\n',
 'header: \n',
 ' teaser: /assets/logos/teaser_coding.jpg\n',
 '---\n']
    
    # read md file
    with open(q_dir + '/' + md_file, 'r') as f:
        lines = f.readlines()

    # read py file
    with open(q_dir + '/' + py_file, 'r') as f:
        py_lines = f.readlines()
    py_lines[-1] = py_lines[-1] + '\n'
    
    lines = header + lines + ['\n','\n','```python\n'] + py_lines + ['\n','```\n']

    # image size adjust
    for i, line in enumerate(lines):
        if '<img' in line:
            lines[i] = line.replace('<img', '<img width="50%"')

    # write md file
    with open(blog_dir + '/_posts/' + filename, 'w') as f:
        f.writelines(lines)
    
    print('Create post : ', filename)

```

`header` 리스트는 지킬 블로그 게시글의 YAML 헤더를 설정한 것인데, 태그와 티저 이미지는 자신의 블로그 형태에 맞게 설정하면 된다. 위 코드를 실행하면, 앞서 저장된 `questions` 리스트에 있는 각 문제 폴더들에 대해 자동으로 포스트가 생성되며, 예시 결과는 [다음 게시글](https://ddangchani.github.io/프로그래머스-181187/)과 같다.

비교적 편하게 글을 자동으로 생성하고, 추가로 생성된 마크다운을 수정해 자신이 원하는 코멘트를 남길 수 있어서 유용하게 사용할 수 있을 것 같다.

(**백준**문제는 아직 백준허브 사용 이후 풀지 않아서 추가로 코드 수정을 해 첨부하도록 할 예정)

{% endraw %}