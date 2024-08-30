import os
from datetime import datetime

blog_dir = '/Users/dangchan/Desktop/ddangchani.github.io' # 깃블로그 디렉토리
target_dir = '/Users/dangchan/Desktop/Github/Algorithm/프로그래머스' # 알고리즘 문제 디렉토리 프로그래머스

questions = []



def yes_or_no(question):
    while "the answer is invalid":
        reply = str(input(question+' (y/n): ')).lower().strip()
        if reply[0] == 'y':
            return True
        if reply[0] == 'n':
            return False

# os.system('cd ' + target_dir) # git pull을 위해 디렉토리 이동
print('Github repository를 최신화합니다.')
stream = os.popen('git -C ' + target_dir + ' pull') # git pull
output = stream.read()
print(output)

for root, dirs, files in os.walk(target_dir):
    # check .py file in files
    for file in files:
        if file.endswith(".py") and 'unpost' not in root:
            # save root at questions
            questions.append(root)

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

    else:
        # Y/N 입력받아 N이면 넘어가기
        question = f'{date}에 작성된 게시글 {title} 포스팅 하시겠습니까?'
        if not yes_or_no(question):
            # unpost 폴더로 옮김
            os.system(f'mv {q_dir} {target_dir}/unpost')
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
    
    print('Post created : ', filename)
