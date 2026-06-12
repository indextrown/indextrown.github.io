```bash
bundle exec jekyll serve
```

## Notion Toggle List 사용법

Markdown 포스트에서 긴 내용을 접고 펼치고 싶을 때는 `<details>`와 `<summary>`를 바로 쓰면 됩니다.
`markdown="1"`을 붙이면 토글 안에서도 `**강조**`, 리스트, 코드블록 같은 Markdown 문법을 사용할 수 있습니다.

### 기본 사용법

{% raw %}
```html
<details class="notion-toggle-list" markdown="1">
<summary>더 보기</summary>

여기에 Markdown을 그대로 작성합니다.

- 리스트
- **굵은 텍스트**
- `inline code`

</details>
```
{% endraw %}

### 처음부터 열린 상태

{% raw %}
```html
<details class="notion-toggle-list" markdown="1" open>
<summary>처음부터 열려 있는 토글</summary>

이 내용은 페이지가 열릴 때 바로 보입니다.

</details>
```
{% endraw %}

### 중첩 토글

{% raw %}
```html
<details class="notion-toggle-list" markdown="1" open>
<summary>부모 토글</summary>

부모 토글 내용입니다.

<details class="notion-toggle-list" markdown="1">
<summary>중첩 토글</summary>

중첩 토글 안에서도 **Markdown**을 사용할 수 있습니다.

</details>
</details>
```
{% endraw %}

### Include로 사용하기

반복되는 형태를 Liquid include로 관리하고 싶을 때는 `_includes/toggle.html`도 사용할 수 있습니다.

{% raw %}
```liquid
{% include toggle.html title="짧은 토글" content="간단한 내용은 이렇게 넘길 수 있습니다." %}
```
{% endraw %}

## Code Media Row 사용법

코드와 이미지 또는 여러 미디어를 나란히 배치할 때는 `code-media-row`를 사용합니다.

### 2열 기본형

{% raw %}
````html
<div class="code-media-row" markdown="1">

```swift
print("code")
```

![이미지](/assets/img/example.png)

</div>
````
{% endraw %}

### 3열 사용

{% raw %}
```html
<div class="code-media-row code-media-row--3" markdown="1">

![첫 번째](/assets/img/one.png)

![두 번째](/assets/img/two.png)

![세 번째](/assets/img/three.png)

</div>
```
{% endraw %}
