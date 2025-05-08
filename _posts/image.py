import re
import sys
import os

def convert_image_tags(file_path: str):
    if not os.path.exists(file_path):
        print(f"파일을 찾을 수 없습니다: {file_path}")
        return

    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Markdown 이미지 문법을 HTML <img> 태그로 변환, 너비 70%로 지정
    converted = re.sub(
        r'!\[(.*?)\]\((.*?)\)',
        r'<img src="\2" alt="\1" style="width:70%;">',
        content
    )

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(converted)

    print(f"변환 완료: {file_path}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("사용법: python3 convert_md_image.py <markdown파일>")
    else:
        convert_image_tags(sys.argv[1])
