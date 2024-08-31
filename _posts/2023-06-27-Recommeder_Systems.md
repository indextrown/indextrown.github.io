---
title: "Recommeder Systems"
tags:
- Recommender System
- Machine Learning
category: Recommender System
use_math: true
---
{% raw %}

이번 여름방학 기간을 활용하여 데이터사이언스 영역에서 갈수록 중요해지는 토픽 중 하나인 추천시스템<sup>recommender system</sup>에 대해 공부해 포스팅해보고자 한다. 추천시스템의 목적은 궁극적으로 사용자에게 적절한 아이템을 추천해주는 것인데, 기존의 statistical learning model과는 다른 상황이 분명히 존재한다. 사용자에게 추천해주는 아이템은 그 사용자가 경험해보지 못한 아이템, 즉 유저 피드백이 없는 상황이므로 기존의 회귀모형이나 분류모형을 활용하기에 어려움이 있을 수 있다. 다만 최근 미디어 영역에서 소위 '알고리즘'이라고 하는 추천 시스템의 활용 및 그 효과가 도드라지면서 추천시스템과 관련된 방법론 역시 다양한 방면으로 발전하는 중이다. 본 포스팅 및 차후 작성되는 포스트들은 *Charu C. Aggarwal*의 **Recommender Systems** 책의 내용을 바탕으로 작성될 것이다.

# Introduction to Recommender Systems
## Goals of Recommender systems

추천 시스템의 목적은 크게 다음 네 가지로 볼 수 있다.
- Relevance : 사용자의 관심사에 관련된 아이템을 추천해주어야 함
- Novelty : 사용자가 과거에 경험해보지 못한 아이템을 추천해주어야 함
- Serendipity : 추천되는 아이템은 단순히 경험해보지 못한 것뿐(novelty) 아니라 놀랍고 신선해야 함
- Diversity : 추천되는 아이템들의 유사성을 줄여 추천의 성공 확률을 높임

개인적으로 diversity의 개념이 와닿았는데, 실제로 알고리즘이 추천해주는 상품(기사, 미디어, 제품)이 매우 유사할 경우 단 하나의 상품도 이목을 끌지 못하는 경우가 종종 있다. 이런 경우를 방지하기 위해 추천 제품의 카테고리를 다양화하는 것이 필수적이라고 생각된다.

## Basic Models of Recommender Systems

추천 시스템을 크게 분류하면 다음 세 가지로 나타난다.
- Collaborative Filtering(CF)
- Content-based recommender(CB)
- Knowledge-based recommender(KB)

### Collaborative Filtering
협업 필터링(CF) 모델은 행렬(matrix) 채우기 문제로 볼 수 있다. 기본적인 아이디어는 특정 사용자가 평가하지 않은 아이템의 평가를 예측하는 것인데, 이 과정에서 해당 아이템에 대한 다른 사용자들의 평가를 이용한다. 결국 각 사용자들의 취향의 **유사도**를 측정하여, 유사한 사용자들의 평가를 기반으로 예측하는 것이 주요 과제가 된다. 협업 필터링 모델은 다시 크게 두 가지로 나눌 수 있다.
- Memory-based method : 유사한 사용자 혹은 유사한 아이템을 기반으로 특정 아이템에 대한 특정 사용자의 값을 예측
- Model-based method : 평가 데이터를 활용하여 decision tree, bayesian model, latent factor model 등 데이터마이닝 모델을 학습시키고 활용

> 사용자가 서비스를 이용하면서 생성하는 평가의 종류는 명시적인 평가와 암묵적인 평가(Explicit/Implicit)가 존재한다. 명시적인 평가란, 5점 척도, 좋아요 버튼(0 or 1, Unary rating) 등과 같은 유저의 직접적인 피드백이 존재하는 것을 의미한다. 반면, 암묵적인 평가 역시 수집할 수 있는데, 유저가 어떤 상품의 링크를 클릭한 활동(http request 등)이나 어떤 미디어를 시청한 기간(ex. youtube 시청시간) 등을 활용하면 가능하다.

### Content-Based Recommender Systems
콘텐츠 기반 추천시스템은 특정 아이템의 descriptive attribute, 즉 아이템의 구체적인 특징들을 기반으로 추천하는 것을 의미한다. 예를 들어 어떤 사용자가 특정 브랜드의 파란색 반팔 셔츠를 구입했거나 혹은 장바구니에 담았다고 가정하면, 해당 유저에게 해당 상품의 특성(파란색, 반팔, 셔츠)들을 조합해 이에 부합하는 아이템들을 추천해주는 것이다. 따라서 CB 모델에서는 다른 유저들의 피드백은 사용되지 않으며, 오로지 추천 대상이 되는 **active user**에만 초점을 둔다.

### Knowledge-Based Recommender Systems
지식 기반 추천시스템은 일반적으로 자주 구입되지 않는 아이템(ex. 차량, 고가의 전자제품 등)을 추천하고자 할 때 사용된다. 이러한 아이템들의 특징은 **cold-start problem**이 발생한다는 것이다. Cold-start problem이란 어떤 서비스 혹은 상품이 런칭된 직후 혹은 짧은 기간 내에 피드백이 부족하여, counter-network effect 등에 의해 오히려 초기 사용자가 이탈하는 현상을 말한다. 추천 시스템에서 cold-start problem이란, 해당 상품에 대한 피드백이 부족해 적절한 추천이 이루어지지 못하는 현상을 의미한다고 보면 된다. 
이를 극복하기 위해 지식 기반 추천시스템을 활용한다. 여기서 '지식'은 **도메인 지식**을 의미하는데, 이는 실제 해당 제품의 도메인에서 다루어지는 지식 뿐 아니라 사용자가 직접적으로 제공한(ex. 주행거리가 10만km 이하인 중고차량을 구매하고 싶음) 제약(constraint) 등이 모두 포함된다.

앞선 세 가지 분류 외에도, 사용자의 인구통계학적인(demographic) 요소(ex. 성별, 나이대 등)을 고려하는 등의 context-sensitive recommender system과 같은 방법론 역시 존재한다. 또한 각각의 추천 시스템에는 장단점이 모두 존재하기 때문에, 여러 종류의 추천 시스템을 조합한 ensemble-based recommender system 역시 고려할 수 있다.

# References
- *Charu C. Aggarwal - Recommender Systems*
{% endraw %}