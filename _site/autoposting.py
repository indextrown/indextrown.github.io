import sys
import os

post_dir = '_posts/'

from datetime import datetime
md_files = os.listdir(post_dir)

md_files = [f for f in md_files if f.endswith('.md')]

# Sort by date from recent to old
md_files.sort(key=lambda x: os.path.getctime(os.path.join(post_dir, x)), reverse=True)

count = input('How many posts do you want to select? (default: 1) ')
if count == '':
    count = 0
else:
    count = int(count)

# Select recent posts
md_files = md_files[:count]
print(md_files)

# Continue or not

yes_or_no = input('Do you want to continue posting? (y/n) ')

if yes_or_no == 'n':
    sys.exit()
elif yes_or_no == 'y':
    pass
else:
    print('Invalid input')
    yes_or_no = input('Do you want to continue posting? (y/n) ')

# move asset files to assets folder
filelist = [ f for f in os.listdir(post_dir + 'assets/') if f.endswith(".png") or f.endswith(".jpg") or f.endswith(".gif") or f.endswith(".jpeg") ]

for f in filelist:
    os.rename(post_dir + 'assets/' + f, 'assets/img/' + f)

print(f'moved {len(filelist)} files')

# Image file link editor for markdowns

import os
post_dir = '_posts/'

# read all markdown files
# mdfiles = [f for f in os.listdir(post_dir) if f.endswith('.md')]
for mdfile in md_files:
    # read the file
    with open(os.path.join(post_dir, mdfile), 'r') as f:
        lines = f.readlines()

    # find the image links
    img_extensions = ['.jpg', '.png', '.gif', '.jpeg', '.svg', '.bmp']

    for i, line in enumerate(lines):
        if any([ext in line for ext in img_extensions]) and 'plt' not in line: # except for matplotlib plot code
            # extract the image name
            if 'img src' in line:
                img_name = line.split('src="')[1].split('"')[0] # for <img src="image.png"> style
            elif line.startswith('![['):
                img_name = line.split('[[')[1].split(']]')[0] # for ![[image.png]] style
            else:
                img_name = line.split('(')[1].split(')')[0] # for ![img](image.png) style
            
            img_name_only = img_name.split('/')[-1]
            
            # If there exists % in the image name, replace with blank space
            if '%20' in img_name_only:
                img_name_only = img_name_only.replace('%20', ' ')

            # find img name in the directory

            target_dir = 'assets/img/'

            for root, dirs, files in os.walk(target_dir):
                if img_name_only in files:
                    img_path = '/' + os.path.join(root, img_name_only)
                    # print(img_path)
                
                    # replace the image link
                    if line.startswith('![['):
                        line = f'![]({img_path})'
                    else:
                        line = line.replace(img_name, img_path)

                    # replace the line
                    lines[i] = line

                    # write the file
                    with open(os.path.join(post_dir, mdfile), 'w') as f:
                        f.writelines(lines)


## If there is double dollar sign '$$\n' in the file add a blank line at before and after the double dollar sign

for md_file in md_files:
    with open(os.path.join(post_dir, md_file)) as f:
        lines = f.readlines()

    for i, line in enumerate(lines):
        if line.startswith('$$') and lines[i-1] != '\n':
            lines.insert(i, '\n')

        if line.startswith('$$') and lines[i+1] != '\n':
            lines.insert(i+1, '\n')

        if line.startswith('> $$') and lines[i-1] != '> \n':
            lines.insert(i, '> \n')

        if line.startswith('> $$') and lines[i+1] != '> \n':
            lines.insert(i+1, '> \n')

    with open(os.path.join(post_dir, md_file), 'w') as f:
        f.writelines(lines)

for md_file in md_files:
    with open(os.path.join(post_dir, md_file)) as f:
        lines = f.readlines()
    
    for i, line in enumerate(lines):
        if line.startswith('> $$') and lines[i-1] == '\n':
            lines[i-1] = '> \n'
        
        if line.startswith('> $$') and lines[i+1] == '\n':
            lines[i+1] = '> \n'

    with open(os.path.join(post_dir, md_file), 'w') as f:
        f.writelines(lines)

# Blockquote line error fix

for md_file in md_files:
    with open(post_dir + md_file, 'r') as f:
        lines = f.readlines()

    for i, line in enumerate(lines):
        # if there exists '\n' line between two blockquote lines remove it
        if line.startswith('>'):
            if lines[i+1] == '\n' and lines[i+2].startswith('>'):
                lines.pop(i+1)

            if lines[i+1].startswith('#'):
                lines.insert(i+1, '\n')

    with open(post_dir + md_file, 'w') as f:
        f.writelines(lines)

import random

img_extensions = ['.jpg', '.png', '.gif', '.jpeg', '.svg', '.bmp']

for md_file in md_files:
    with open(post_dir + md_file, 'r') as f:
        lines = f.readlines()
    
    img_paths = []

    for i, line in enumerate(lines):
        # YAML header idx
        if line.startswith('---') and i != 0:
            idx = i

        # Get all the image links
        if (not 'teaser' in line) and any([ext in line for ext in img_extensions]) and 'plt' not in line: # except for matplotlib plot code
            # extract the image path
            if 'img src' in line:
                img_path = line.split('src="')[1].split('"')[0]
            elif line.startswith('![['):
                img_path = line.split('[[')[1].split(']]')[0]
            else:
                img_path = line.split('(')[1].split(')')[0]

            img_paths.append(img_path)
        
    if img_paths:
        # Is there header: at YAML
        is_header = False

        for i, line in enumerate(lines[:idx+1]):
            if line.startswith('header'):
                is_header = True
                idx_header = i
        
        if not is_header:
            lines.insert(idx, 'header: \n')
            lines.insert(idx+1, '  teaser: {}\n'.format(random.choice(img_paths)))

    with open(post_dir + md_file, 'w') as f:
        f.writelines(lines)

# Codeblock error

for md_file in md_files:
    with open(post_dir + md_file, 'r') as f:
        lines = f.readlines()
    opened = False # check if the code block is open or not
    for i, line in enumerate(lines):
        if line.startswith('```'):
            if opened:
                opened = False
            else:
                opened = True
                if lines[i-1] != '\n':
                    lines.insert(i, '\n')

    with open(post_dir + md_file, 'w') as f:
        f.writelines(lines)

print('Done')