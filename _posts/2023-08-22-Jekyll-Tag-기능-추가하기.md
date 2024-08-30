---
title: Jekyll 블로그에 태그 정렬기능 추가하기
tags:
- Front-end
- Jekyll
- Blog
category: 
use_math: true
---
{% raw %}
![](/assets/img/스크린샷 2023-08-22 오후 9.22.50.png)

이전에 지킬 블로그를 시작하면서, 태그 기능을 완벽하게 구현해내신 [블로그](https://wormwlrm.github.io/2019/09/22/How-to-add-tags-on-Jekyll.html)가 있길래 아이디어를 참고하여 게시글 리스트를 보여주는 화면에 태그 정렬 기능을 위 그림과 같이 설정해보았다. 현재 사용하고 있는 Jekyll의 블로그 테마는 minimal-mistake 이므로 본인이 사용하고 있는 테마의 파일구조에 맞추어서 확인하면 될 것이다.

# 포스트에 태그 추가하기

```markdown
---
layout: post
tags:
- 태그 1
- 태그 2
header: 
  teaser: /assets/img/스크린샷 2023-08-22 오후 9.22.50.png
---

```

Jekyll에서 포스트를 작성할 때에는 위 코드와 같이 앞에 YAML 머릿말에 태그를 작성하게 된다. 이때, 태그를 좀 더 쉽게 관리하기 위해 모든 태그를 나열하는 것이 아닌, 특정 중요 태그들만 나열하는 것이 편리하기 때문에 사이트 내부의 데이터셋에서 태그들을 별도로 관리해주는 것이 좋다.

## 태그 저장

사이트에서 관리하는 데이터셋은 루트 디렉토리의 `_data` 폴더에 저장되는데, 여기에 다음과 같이 `tags.yml` 파일을 생성하도록 하자.

```
├── navigation.yml
├── tags.yml
└── ui-text.yml

```

파일은 다음과 같이 게시글 목록에 보여지고자 하는 태그들을 나열하면 된다.

```
- Statistics
- Machine Learning
- Deep Learning
- Data Science
- Python
- Opinion
- Project
- Time Series
- NLP
- Research
- Paper Review

```

# 태그 표시

우선 정렬기능을 구현하기 이전에, 태그 리스트를 게시글 리스트 상단에 표시해보도록 하자. 최근 게시글들이 표시되는 *홈 화면*(`_layouts/home.html`)에서 이 기능을 구현할 것인데, html 파일에서 `archive__subtitle` 영역 아래에 다음과 같이 태그 리스트들을 불러오도록 하자.

```html
{{ content }}

{% assign n_posts = site.posts | size %}

<h3 class="archive__subtitle">전체 게시글 
  <span class="n_posts">({{n_posts}})</span>
</h3>

{% assign tags = site.data.tags | sort_natural %}

<!--Tag List-->
<ul class="tags">
  {% for tag in tags %}
    {% capture tag_size %}{{ site.tags[tag] | size }}{% endcapture %}
    {% if tag_size > "0" %}
    <li><span class="tag" data-tag="{{tag | replace : ' ', '_' }}">{{ tag }}</span></li>
    {% endif %}
  {% endfor %}
</ul>

```

여기서 `{% assign tags = site.data.tags | sort_natural %}` 는 앞서 생성한 사이트의 태그 데이터셋들을 변수로 저장하는 liquid 구문이다. 또한, 각 태그에 `data-tag`라는 추가적인 요소를 지정해주었는데, 이는 나중에 정렬기능을 구현할 때 변수로 활용할 예정이고, 여기서 공백문자를 언더바(`_`) 로 변환한 것은 띄어쓰기의 문제로 인해 `data-tag` 요소를 잘못 불러올 수 있으므로 이를 방지하기 위함이다.

또한, 만약 페이지생성기(paginator)가 활성화 된 경우, 이로 인해 정렬이 원하는 결과로 나오지 않을 수 있으므로 다음과 같이 사용하지 않도록 주석처리했다.

```html
<!-- {% if paginator %}
  {% assign posts = paginator.posts %}
{% else %}
  {% assign posts = site.posts %}
{% endif %} -->

{% assign posts = site.posts %}

```

이제, `data-tag`를 활용하기 위해 태그들 아래 표시되는 각 게시글들에 대해서도 태그정보를 입력해주는데, `post-wrapper`로 각 게시글에 대한 정보들을 감싼 뒤, 이에 대해 `data-{태그이름}` 형태의 요소들을 추가해주었다.

```html
{% assign posts = site.posts %}

{% assign entries_layout = page.entries_layout | default: 'list' %}
<div class="entries-{{ entries_layout }}">
  {% for post in posts %}
  <div class="post-wrapper" 
  {% if post.tags %}
    {% for tag in post.tags %}
      data-{{ tag | replace : ' ', '_' }}
    {% endfor %}
  {% endif %}>
    {% include archive-single.html type=entries_layout %}
    {% if post.tags %}
      <div class="archive__item-tags">
        {% for tag in post.tags %}
          {% if site.data.tags contains tag %}
            <a class="posttag" id="tagged">{{ tag }}</a>
          {% else %}
            <a class="posttag" id="untagged">{{ tag }}</a>
          {% endif %}
        {% endfor %}
      </div>
    {% endif %}
  </div>
  {% endfor %}
</div>

```

여기서 `id`를 `tagged`, `untagged` 로 나누어 태깅한 것은 앞서 정의한 사이트의 태그 데이터셋에 포함되지 않는 태그가 존재할 경우 이를 표시하지 않기보다는, 다른 색으로 구분하는 등 추가적인 조치를 취할 수 있게 설정한 것이다.

# 정렬

이제, 정렬을 위해 다음 기능들을 구현해야 한다.
1. 태그를 선택하면 `selected` 클래스를 추가하여 선택된 것임을 전달
2. 태그를 선택한 뒤 `selected` 된 태그들을 변수로 지정하여, 각 포스트에 대해 해당 태그들 중 하나를 포함하는지 확인
3. 만약 포함한다면, 해당 게시글을 보이게 하고 그렇지 않은 경우 숨김
4. 만일 태그가 하나도 선택되지 않았다면(초기화면) 전체 게시글 표시

이를 위한 자바스크립트 코드는 다음과 같다. 필자의 경우 `home.html` 파일에 내부 스크립트 형태로 넣어서 사용했다.


```html
<script>
  // Tag Filter
  // Function to handle the click events on tags
  function toggleSelected(element) {
    element.classList.toggle("selected");

    // 필터링하여 선택된 태그에 해당하는 포스트 보이기/숨기기
    const postWrappers = document.querySelectorAll('.post-wrapper');
    const selectedTags = document.querySelectorAll('.tag.selected');

    postWrappers.forEach(function(postWrapper) {
      const postTags = postWrapper.dataset;
      // 태그가 하나도 선택되지 않았을 때
      if (selectedTags.length === 0) {
        postWrapper.style.display = 'block';
        return;
      }
      // 선택된 태그들을 하나라도 포함하는 포스트는 보이기
      else {
        var show = false;
        selectedTags.forEach(function(selectedTag) {
          if (postTags[selectedTag.dataset.tag.toLowerCase()] === "") {
            show = true;
            console.log(postTags[selectedTag.dataset.tag])
          }
        });
        if (show) {
          postWrapper.style.display = 'block';
        } else {
          postWrapper.style.display = 'none';
        }
      }
  });
  }

  // Add click event listenrs to tag elements
  document.addEventListener('DOMContentLoaded', function() {
    const tagElements = document.querySelectorAll('.tag');
    tagElements.forEach(function(tagElement) {
      tagElement.addEventListener('click', function() {
        toggleSelected(tagElement);
      });
    });
  });


</script>

```

위 조건 1-4를 만족하는 함수 `toggleSelected`를 만든 뒤, `addEventListener`를 이용해 각 태그 엘리먼트들에 대해 해당 함수를 마우스 클릭에 대해 적용시켰다.

# CSS 적용

태그 블럭을 보기좋게 하기 위해, [CodePen](https://codepen.io/wbeeftink/pen/AJjVZQ)에서 `hover` 기능이 적용된 태그 html을 가져와 사용했다. `_sass/minimal-mistakes/_archive.scss` 파일에 다음을 추가하면 된다.

```css
/* Tag List */

@media (hover: hover) {}

.tags {
  list-style: none;
  margin: 0;
  overflow: hidden; 
  padding: 0;
  font-size: 12px;
  font-family: 'PT Sans', serif;
  // border-bottom: $border-color 1px solid;

}

.tags li {
  float: left; 
}

.tag {
  background: #eee;
  border-radius: 3px 0 0 3px;
  color: #575c6c;
  display: inline-block;
  height: 26px;
  line-height: 26px;
  padding: 0 20px 0 20px;
  position: relative;
  margin: 0 10px 5px 0;
  text-decoration: none;
  -webkit-transition: color 0.2s;
}

.tag::before {
  background: #fff;
  color: #575c6c;
  border-radius: 10px;
  box-shadow: inset 0 1px rgba(0, 0, 0, 0.25);
  content: '';
  height: 6px;
  left: 10px;
  position: absolute;
  width: 6px;
  top: 10px;
}

.tag::after {
  background: #fff;
  border-bottom: 13px solid transparent;
  border-left: 10px solid #eee;
  border-top: 13px solid transparent;
  content: '';
  position: absolute;
  right: 0;
  top: 0;
}

.tag:hover {
  background-color: rgb(20, 120, 220);
  color: white;
}

.tag:hover::after {
   border-left-color: rgb(20, 120, 220); 
}

.tag.selected {
  background-color: rgb(20, 120, 220);
  color: white;
}

.tag.selected::after {
   border-left-color: rgb(20, 120, 220); 
}

.post-wrapper.show {
  display: block;
}

.post-wrapper.hide {
  display: none;
}

.archive__item-tags {
  list-style: none;
  margin: 0;
  overflow: hidden; 
  padding: 0;
  font-size: 12px;
  font-family: 'PT Sans', serif;
  // border-bottom: $border-color 1px solid;

  .posttag {
    background: #eee;
    border-radius: 3px 0 0 3px;
    color: #575c6c;
    display: inline-block;
    height: 26px;
    line-height: 26px;
    padding: 0 20px 0 20px;
    position: relative;
    margin: 0 10px 5px 0;
    text-decoration: none;
    } 

  .posttag::before {
    background: #fff;
    color: #575c6c;
    border-radius: 10px;
    box-shadow: inset 0 1px rgba(0, 0, 0, 0.25);
    content: '';
    height: 6px;
    left: 10px;
    position: absolute;
    width: 6px;
    top: 10px;
  }

  .posttag::after {
    background: #fff;
    border-bottom: 13px solid transparent;
    border-left: 10px solid #eee;
    border-top: 13px solid transparent;
    content: '';
    position: absolute;
    right: 0;
    top: 0;
  }

}

```

# References
- 원 자료 : [https://wormwlrm.github.io/2019/09/22/How-to-add-tags-on-Jekyll.html](https://wormwlrm.github.io/2019/09/22/How-to-add-tags-on-Jekyll.html)
- CSS 태그 : [https://codepen.io/wbeeftink/pen/AJjVZQ](https://codepen.io/wbeeftink/pen/AJjVZQ)
{% endraw %}