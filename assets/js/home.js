var selectedTags = [];

// Tag Filter
  // Function to handle the click events on tags
  function toggleSelected(element) {
    element.classList.toggle("selected");
    var tag = element.dataset.tag;

    var index = selectedTags.indexOf(tag);
    if (index === -1) {
        selectedTags.push(tag);
    } else {
        selectedTags.splice(index, 1);
    }

    updateQueryString();
    
    // 필터링하여 선택된 태그에 해당하는 포스트 보이기/숨기기
    const postWrappers = document.querySelectorAll('.post-wrapper');
    const selectedTagsElements = document.querySelectorAll('.tag.selected');

    postWrappers.forEach(function(postWrapper) {
        const postTags = postWrapper.dataset;
        // 태그가 하나도 선택되지 않았을 때
        if (selectedTagsElements.length === 0) {
            postWrapper.style.display = 'block';
            return;
        }
        // 선택된 태그들을 하나라도 포함하는 포스트는 보이기
        else {
            var show = false;
            selectedTagsElements.forEach(function(selectedTagElement) {
                const selectedTag = selectedTagElement.dataset.tag;
                if (postTags[selectedTag.toLowerCase()] === "") {
                    show = true;
                    console.log(postTags[selectedTag]);
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

// 외부 링크에서 href로 홈화면 왔을 때 쿼리 추출
function getQuery() {     
    var params = {};  
    
    window.location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi, 
    	function(str, key, value) { 
        	params[key] = value; 
        }
    );     
    
    return params; 
}

// 쿼리 추출하여 태그 선택
// 외부 링크에서 href로 홈화면 왔을 때 쿼리 추출
jQuery(document).ready(function($) {
    let currentTag = "";
    const queryTag = getQuery()["tag"];
    
    // 이전에 선택한 태그와 쿼리 파라미터를 유지
    if (queryTag) {
        selectedTags = queryTag ? queryTag.split(",") : [];
        currentTag = selectedTags[0]; // 선택된 첫 번째 태그를 currentTag로 설정
        // 선택된 태그에 selected 클래스 추가
        const tagElements = document.querySelectorAll('.tag');
        tagElements.forEach(function(tagElement) {
            if (selectedTags.includes(tagElement.dataset.tag)) {
                tagElement.classList.add("selected");
            }
        });
    }
    
    // 게시글 필터링
    const postWrappers = document.querySelectorAll('.post-wrapper');
    postWrappers.forEach(function(postWrapper) {
        const postTags = postWrapper.dataset;
        if (currentTag === "") {
            postWrapper.style.display = 'block';
            return;
        }
        if (postTags[currentTag.toLowerCase()] === "") {
            postWrapper.style.display = 'block';
        } else {
            postWrapper.style.display = 'none';
        }
    });
});


// 쿼리 업데이트 함수
function updateQueryString() {
    var params = getQuery();
    if (selectedTags.length > 0) {
        params.tag = selectedTags.join(",");
    } else {
        delete params.tag;
    } 

    var newQuery = Object.keys(params).map(key => key + '=' + params[key]).join('&');
    var newUrl = `${location.protocol}//${location.host}${location.pathname}${newQuery ? '?' + newQuery : ''}`;

    window.history.replaceState({}, '', newUrl);
}

function addQuery(tag) {
    if (!selectedTags.includes(tag)) {
        selectedTags.push(tag);
    }
    updateQueryString();
}

function removeQuery(tag) {
    const index = selectedTags.indexOf(tag);
    if (index !== -1) {
        selectedTags.splice(index, 1);
        updateQueryString();
    }
}