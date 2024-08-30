---
title: "Distribution"
tags:
- Probability Theory
- Distribution
category: Probability Theory
use_math: true
---
{% raw %}
## Distributions

이전 게시글에서는 random elements에 대해 다루었으며, 확률분포<sup>distribution</sup>가 어떻게 새로운 측도로 정의되는지 살펴보았다. 이번에는 random elements의 분포와 분포 함수 및 수리통계학에서 다룬 기댓값, 적률 등을 살펴보고자 한다.

### Finite-dimensional distribution

$X$를 어떤 finite index set $T=\{t_1,\ldots,t_n\}$에서 정의되는 random process라고 하자. 이에 관한 finite-dimensional distributions은 다음과 같이 주어진다.

$$

\mu_{t_1,\ldots,t_n}=P\circ(X_{t_1},\ldots,X_{t_n})^{-1}, \;\;t_1,\ldots,t_n\in T,n\in \mathbb N

$$

이때 유한차원분포에 대해 다음 명제가 성립한다.

#### Prop 2.2

Measurable space $(S,\mathcal{S})$ 와 index set $T$, $U\subset S^T$ 를 고정하자. $X,Y$가 $U$에서의 path를 갖는 $T$에서의 random process 라고 두면, $X,Y$ 가 동일한 분포($X\stackrel{d}{=}Y$​)를 갖는 **필요충분조건**은

$$

(X_{t_1},\ldots,X_{t_n})\stackrel{d}{=}(Y_{t_1},\ldots,Y_{t_n}),\;\;\; t_1,\ldots,t_n\in T,n\in\mathbb N\tag{1}

$$

이다.

> 증명. 조건 (1)을 가정하자. $P\{X\in A\}=P\{Y\in A\}$ 가 성립하는 집합 $A\in S^T$들의 모임을 $\mathcal{D}$라고 하자. 그리고 
> 
> $$
> 
> A=\{f\in S^T:(f_{t_1},\ldots,f_{t_n})\in B\}, \\ t_1,\ldots,t_n\in T, B\in \mathcal{S}^n,n\in\mathbb N
> 
> $$
> 
> 로 정의되는 모든 집합 $A$들의 모임을 $\mathcal{C}$ 라고 하자. 그러면 $\mathcal C$는 $\pi$-system이고, $\mathcal{D}$는 $\lambda$-system이다.



# References

- Foundations of Modern Probability, O.Kallenberg
{% endraw %}