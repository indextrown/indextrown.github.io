---
title: "Boosting Tree"
tags:
- Machine Learning
- Boosting
- CART
- Tree
category: Machine Learning
use_math: true
---
{% raw %}
## Boosting Tree

이전에 Regression Tree와 Classification Tree([CART](https://ddangchani.github.io/machine%20learning/Tree/)) 모형에 대해 살펴보았는데, Tree에 대해서도 [boosting algorithm](https://ddangchani.github.io/machine%20learning/boosting/)을 적용할 수 있다. Tree 모델은 기본적으로 partition된 region $R_m$들에 대한 예측값 $\gamma_m$을 부여하는 것인데, 이를 이용해 $J$개의 region을 분리하는 Tree를

$$

T(x:\theta) = \sum_{j=1}^J \gamma_j I(x\in R_j)

$$

로 표현할 수 있다. 이때 parmeter $\theta$는 $\{R_j,\gamma_j\}_1^J$ 를 의미하고, $J$는 Tree의 깊이를 설정하는 hyperparmeter이다. parameter의 최적화는

$$

\hat \theta =\arg\min_\theta\sum_{j=1}^J\sum_{x_i\in R_j} L(y_i,\gamma_j)

$$

으로 이루어진다. 이 과정에서 optimization은 두 개의 문제로 이루어지는데, $R_j$가 주어졌을 때 split point $\gamma_j$를 찾는 것과 $R_j$를 찾는 것이다. 첫 번째 optimization은 비교적 쉬운 방법으로 구현할 수 있다. 주어진 classification loss에 대한 $\hat\gamma$로 modal class<sup>최빈값</sup> 을 설정하거나, 평균치를 이용하는 방법을 사용하면 된다. 반면, 두 번째 optimization, 즉 Region을 어떻게 분리할 것인지 찾는 것은 어려운 문제이다. $R_j$를 찾는 것은 곧 $\gamma_j$를 추정하는 것을 수반하며, 이는 주로 top-down 방식으로, 다른 criterion index를(ex. Gini Index) 바탕으로 이루어진다([Tree 게시글](https://ddangchani.github.io/machine%20learning/Tree/) 참고).

Boosted Tree model은 이러한 트리들의 합으로 주어진다. 즉,

$$

f_M(x)=\sum_{m=1}^M T(x:\theta_m)

$$

와 같은 형태인데, 이는 [forward-stagewise additive modeling](https://ddangchani.github.io/machine%20learning/boosting/)의 알고리즘으로부터 유도된다. 각 단계 $m=1,\ldots,M$에 대해 다음의 최적화 과정

$$

\hat\theta_m = \arg\min_{\theta_m}\sum_{i=1}^N L(y_i, f_{m-1}(x_i)+T(x_i:\theta_m))\tag{1}

$$

의 해를 구하는 과정으로 $\hat\theta_m$의 update가 이루어진다. 식 (1)의 해를 찾는 것은 $\theta_m = \{R_{jm},\gamma_{jm}\}_1^{J_m}$ , 즉 region과 optimal constant $\gamma$ 모두에 대한 추정치를 구하는 것을 의미한다. 하지만 앞서 말했듯 Region을 찾는 것은 어려운 문제이며, 특히 boosting algorithm 과정에서 이를 찾는 것은 개별 트리에 대한 문제보다 더 복잡하다. 그러나, 아래와 같이 몇 가지 경우에 대해 위 식 (1)의 문제는 단순화된다.

> 1. Squared-error Loss : 식 (1)의 문제는 Regression Tree를 만드는 것과 동일하다. 즉, region의 경우 current residual $y_i-f_{m-1}(x_i)$를 최적화하는 Region으로 update하고, region의 평균값을 $\hat\gamma_{jm}$ 으로 사용하게 된다.
>
> 2. Binary Classification과 Exponential Loss :
>
>    이진 분류와 exponential loss에 대해서 위 식 (1)의 stagewise 알고리즘은 AdaBoost 알고리즘과 동일하며, AdaBoost를 Classification Tree에 적용하는 것으로 치환된다. 이는 [이전](https://ddangchani.github.io/machine%20learning/boosting/)에 살펴본 AdaBoost - Stagewise Modeling 간의 관계로부터 도출된다. 즉, exponential loss의 경우 임의의 $R_{jm}$이 주어질 때 optimal constant는
>    $$
>    \hat\gamma_{jm}={1\over 2}\log\frac{\sum_{x_i\in R_{jm}}w_i^{(m)}I(y_i=1)}{\sum_{x_i\in R_{jm}}w_i^{(m)}I(y_i=-1)}
>    $$
>    으로 주어진다(전 게시글 참고).

만일 Loss function이 absolute error, Huber Loss 등 다른 기준으로 주어지면 이는 Boosting tree 알고리즘을 robust<sup>이상치에 안정적임</sup>하게 만들 것이다. 하지만 robust한 Loss function이 있다 해도 앞선 두 개의 케이스처럼 단순하고 빠른 boosting 알고리즘을 구현할 수 없다. 그렇기에 손실함수 $L$ 대신 이를 근사할 수 있는 더 간편한 기준 $\tilde{L}$ 을 설정하게 되고, 이를 이용해

$$

\tilde\theta = \arg\min_\theta\sum_{i=1}^N \tilde L(y_i,T(x_i,\theta))

$$

로 optimization을 수행한다.
{% endraw %}