---
title: Markov Random Field
tags:
- Spatial Statistics
- Probability Theory
- Statistics
category: ''
use_math: true
---
{% raw %}
# Markov Random Field

Markov Random Field란, 공간자료 중 격자형(lattice) 자료를 모델링하기 위해 사용되는 모델이다. 격자형 자료란, 말그대로 (규칙적 혹은 불규칙적) 격자 단위에서 변수들의 값이 주어지는 것을 의미한다. 이때 데이터셋을 구성하는 각 격자는 정사각형이나 정육각형처럼 규칙적일 필요는 없지만, 격자들 간의 인접구조(neighborhood structure)는 파악할 수 있어야 한다.

## Definition

**Markov Random Field**란, 한마디로 요약하자면 **local Markov property**를 만족하는 무방향성(undirected) 그래피컬 모델을 의미한다. 우선 local Markov property에 대해 살펴보도록 하자.

### Local Markov property

그래프 $\mathcal{G}=(V,E)$ 가 주어지고, 노드집합 $V$의 각 인덱스에 확률변수 $X_{i}, i\in V$ 가 대응된다고 하자. 이때 $i$번째 노드의 인접노드들의 인덱스 집합을 $\mathcal{N}_{i}$ 라고 하자. 이때 Markov property는 다음의 세 가지 경우가 존재한다.

1. **Pairwise Markov property**

    두 개의 인접 노드가 나머지 변수들이 주어졌을 때 조건부 독립

    $$
    X_{i}\perp X_{j}\;\vert\;X_{V\backslash\{u,v\}}
    $$

1. **Local Markov property**

    어떤 노드의 인접 노드들이 주어졌을 때, 해당 노드와 나머지 노드들과 조건부 독립

    $$
    X_{i}\perp X_{V\backslash\mathcal{N}_{i}}\;\vert\;X_{\mathcal{N}_{i}}
    $$

2. **Global Markov property**

    노드집합 $V$의 어떤 두 부분집합 $A,B\subset V$ 가 separating subset $S\subset V$ 에 의해 조건부 독립. 이때 $A$의 노드에서 $B$의 노드로 가는 경로는 $S$의 노드를 거쳐간다. 

    $$
    X_{A}\perp X_{B}\;\vert\;X_{S}\tag{1}
    $$

### Example

앞서 살펴본 것 처럼 Markov Random Field는 조건부 독립성질 중 하나인 local Markov property를 만족하기 때문에, 조건부 확률분포를 이용해 모델링이 가능하다. 대표적으로 다음과 같은 모델들이 있다.

1. Auto-logistic model : $X_{1},\ldots,X_{n}$ 이 $0,1$의 값을 갖는 이진확률변수일 때

    $$
    P(X_{i}=1|X_{j}=x_{j},j\neq i)=\frac{\exp(\alpha_{i}+\sum_{j\in\mathcal{N}_{i}}\beta_{ij}x_{j})}{1+\exp(\alpha_{i}+\sum_{j\in\mathcal{N}_{i}}\beta_{ij}x_{j})}
    $$

2. Auto-normal model :

    $$
    X_{i}\;\vert\;X_{j}=x_{j},j\neq i\sim N(\mu_{i}+\sum_{j\in\mathcal{N}_{i}}\beta_{ij}(x_{j}-\mu_{j}),\sigma^{2})
    $$

3. Simultaneous equation model :

    $$
    X_{i}=\mu_{i}+\sum_{j\in\mathcal{N}_{i}}\beta_{ij}(X_{j}-\mu_{j})+\epsilon_{i},\quad \epsilon_{i}\sim N(0,\sigma^{2})
    $$

## Hammersley-Clifford Theorem

Hammersley-Clifford 정리는 MRF에 대해 조건부 확률분포와 결합확률분포의 관계를 설정가능하게 해주는 정리이다.

### Clique
클릭(Clique)이란, 그래프의 부분집합(부분그래프<sup>subgraph</sup>) 중 상호 인접성을 만족하는 것을 의미한다. 즉, 클릭의 각 노드는 서로 다른 노드의 인접노드이다.

### Theorem
Markov random field $\mathbf{X}=(X_{1},X_{2},\cdots)$ 에 대해 다음이 성립한다.

$$
p(\mathbf{x})\propto\prod_{c\in\mathcal{C}}\Psi_{c}(\mathbf{x}_{c})
$$

여기서 $c$는 $\mathbf{X}$에서의 각 클릭을, $\mathcal{C}$ 는 가능한 모든 클릭들의 집합을 의미한다.

### Corollary
Hammersley-Clifford Theorem으로부터 다음 딸림정리가 성립한다.

> MRF $\mathbf{X}$ 는 global Markov property (1)을 만족시킨다.

즉, local Markov property만 만족하는 MRF로부터 global Markov property까지 확장이 가능한 것이다.

## Gaussian Markov Random Field

### Definition
그래프 $\mathcal{G}=(V,E)$ 에 확률변수 $X_{1},\ldots,X_{v}$ 들이 각 노드로 대응된다고 하자. 이때 다음 조건을 만족하면 이러한 MRF를 **Gaussian Markov Random Field**라고 정의한다.

$$
\begin{align}
\mathbf{X}=(X_{v})_{v\in V}&\sim MVN(\mathbf{\mu},\Sigma)\\\\

(\Sigma^{-1})_{uv}=0\;\;&\text{iff}\;\;\{u,v\}\notin E
\end{align}
$$

이때 공분산행렬 $\Sigma$의 역행렬을 *precision matrix*라고 하며, $Q=\Sigma^{-1}$ 라고 쓰기도 한다.


# References

- 서울대학교 공간통계 강의노트
- Handbook of spatial statistics
{% endraw %}