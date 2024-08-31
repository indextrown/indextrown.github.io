---
title: Spectral Analysis - Matrix Completion
tags:
- Matrix Completion
- Spectral Analysis
- Missing Data Analysis
- Recommender System
category: 
use_math: true
header: 
 teaser: /assets/img/Spectral-Analysis-5_0.png
---
{% raw %}
# Matrix Completion

![](/assets/img/Spectral-Analysis-5_0.png){: .align-center width="50%"}

행렬에서의 결측치(missing data) 문제는 최근 데이터사이언스 분야에서 중요한 화두이다. 특히 Netflix, Youtube 등의 알고리즘 기반 미디어 플랫폼들이 등장하며 사용자에게 적합한 미디어를 추천해주는 알고리즘이 중요해졌다. 추천 알고리즘의 큰 비중을 차지하는 **협업 필터링(Collaborative Filtering)** 같은 대부분의 추천 시스템은 결과적으로 행렬에서의 결측치 추정으로 귀결된다. 각 사용자들을 행으로, 각 미디어(혹은 상품)을 열로 하는 행렬을 구성한 뒤, 각 행렬의 성분을 추정하는 문제의 일종이기 때문이다(위 그림). 

일반적인 행렬에서는 결측치의 추정이 매우 어렵다. 그러나 행렬의 저차원 구조를 어느정도 가정한다면, 혹은 행렬의 계수를 낮게 가정한다면 적은 수의 latent factor들을 기반으로 추정이 가능해지는데, 이런 원리를 이용해 협업 필터링 등의 알고리즘이 가능한 것이다. 이번 글에서는 행렬의 결측치를 spectral analysis 방법으로 추정하는 내용을 다루어보도록 하겠다.

## Problem Formulation
결측치를 추정해야 할 행렬이 $M^{\star}\in\mathbb{R}^{n_{1}\times n_{2}}$ 으로 주어진다고 하자. 또한, 행렬에 대한 특이값분해를 다음과 같이 가정하자.


$$

M^{\star}=U^{\star}\Sigma^{\star}V^{\star T}


$$

또한, 행렬 $M^{\star}$ 의 **condition number**라는 새로운 모수를 다음과 같이 정의하자.


$$

\kappa:=\frac{\sigma_{1}(M^{\star})}{\sigma_{r}(M^{\star})}


$$

이때 $\sigma_{i}$ 는 행렬의 $i$ 번째(로 큰) 특이값을 의미한다. 이제, 각 성분의 결측여부를 파악하기 위해 index set $\Omega\subset\{1,\ldots,n_{1}\}\times\{1,\ldots,n_{2} \}$ 를 정의하는데, 행렬의 각 성분 $M_{i,j}^{\star}$ 가 관측된 것은 $(i,j)\in\Omega$ 와 동치이다.

### Random sampling
행렬 $M^{\star}$ 의 추정을 위해 다음과 같은 가정이 필요하다.

> **Assumption** 행렬의 각 성분 $M_{i,j}^{\star}$ 는 서로 **독립적으로**, 확률 $0<p<1$ 로 관측된다. 즉,
> 
> 
> $$
> 
> P((i,j)\in\Omega)=p
> 
> 
> $$
> 
> 이다.

이러한 가정하에서, 행렬의 전체 기대관측수를 $pn_{1}n_{2}$ 로 생각할 수 있다.

### Incoherence condition
앞선 random sampling 가정이 이루어져도, 다음과 같은 경우에는 효과적인 결측치 추정이 이루어지지 못한다.


$$

M^{\star}=\begin{bmatrix}1&0&\cdots&0 \\ 0&0&\cdots&0 \\ \vdots&\vdots&\ddots&\vdots \\ 0&0&\cdots&0\end{bmatrix}


$$

여기서 $M^{\star}$은 계수가 1인, $(1,1)$만 0이 아닌 행렬이다. 이 경우 만일 $p=o(1)$ 로 설정하면(ex. $p=\frac{1}{n_{1}n_{2}}$) 행렬의 크기가 커질수록 첫번째 성분 $M_{1,1}^{\star}$ 를 참값 1로 추정할 확률이 0에 수렴하게 된다($1-p\to 0$ as $n\uparrow$). 이러한 문제를 해결하기 위해 다음과 같은 새로운 파라미터를 설정한다.

#### Incoherence parameter
행렬 $M^{\star}$의 Incoherence paramter $\mu$ 는 다음과 같이 정의된다.


$$

\mu := \max\bigg\{
\frac{n_{1}\Vert U^{\star}\Vert_{2,\infty}^{2}}{r},\frac{n_{2}\Vert V^{\star}\Vert_{2,\infty}^{2}}{r}
\bigg\}


$$

여기서 노음 $\Vert\cdot\Vert_{2,\infty}$ 는 $\max_{i=1,\ldots,n_{1}}\Vert A_{i,\cdot}\Vert^{2}$ 를 의미한다(행벡터의 최대 2-norm). 또한, frobenius norm, spectral norm, $L_{2,\infty}$ norm에 대해 다음 관계가 성립하므로


$$

\frac{r}{n_{1}}=\frac{1}{n_{1}}\Vert U^{\star}\Vert_{F}^{2}\leq\Vert U^{\star}\Vert_{2,\infty}^{2}\leq \Vert U^{\star}\Vert^{2} =1


$$

$1\leq\mu\leq\max\{n_{1},n_{2}\}/r$ 이 성립한다.

#### Lemma
또한, 행렬 $M^{\star}$가 $\mu$-incoherent할 때 다음이 성립한다.


$$

\Vert M^{\star}\Vert_{2,\infty}\leq \sqrt{\frac{\mu r}{n_{1}}}\Vert M^{\star}\Vert;\;\;\Vert M^{\star T}\Vert_{2,\infty}\leq \sqrt{\frac{\mu r}{n_{2}}}\Vert M^{\star}\Vert


$$

$$

\Vert M^{\star}\Vert_{\infty}\leq \frac{\mu r\Vert M^{\star}\Vert}{\sqrt{n_{1}n_{2}}}


$$

### Additional Notation
표기의 편의를 위해 다음과 같은 Euclidean projection operator $$\mathcal{P}_{\Omega}:\mathbb{R}^{n_{1}\times n_{2}}\to \mathbb{R}^{n_{1}\times n_{2}}$$ 를 정의하자.


$$

[\mathcal{P}_{\Omega}(A)]_{i,j}=\begin{cases}
A_{i,j},\quad \text{if}\;\;(i,j)\in\Omega  \\
0,\quad\;\;\;\text{else}
\end{cases}


$$

즉, 이러한 표기 하에서 matrix completion은 $\mathcal{P}_{\Omega}(M^{\star})$ 의 기저(basis)를 바탕으로 $M^{\star}$를 추정하는 것이다. 

## Algorithm

Random sampling 가정으로부터 다음과 같이 **inverse probability weighting** 방법을 이용해 추정치 $M$을 구할 수 있다.


$$

M:=p^{-1} \mathcal{P}_\Omega(M^{\star})


$$

이때, 행렬 $\mathcal{P}_{\Omega}(M^{\star})$ 의 기대값이 $pM^{\star}$ 이므로 다음이 성립한다.


$$

\mathbb{E}M = M^{\star}


$$

즉, 이 관계로부터 [spectral method](https://ddangchani.github.io/Spectral-Analysis-1)에서의 관계 $M = M^{\star}+E$ 를 이용할 수 있게 되며, 결국 matrix completion은 추정치 행렬 $M$의  rank-$r$ SVD $U\Sigma V^{T}$ 를 이용해 이를 각각 $U^{\star}\Sigma^{\star}V^{\star T}$ 의 근사치로 사용하게 된다.

## Performance

다른 spectral analysis 방법론들과 마찬가지로, perturbation $E=M-M^{\star}$의 노음 크기를 제한할 수 있으면 위 방법의 성능을 높은 확률로 보장받을 수 있다. 우선, 다음 Lemma로부터 perturbation $E$의 크기를 제한할 수 있게 된다.

### Lemma
어떤 상수 $C>0$ 에 대해 $n_{2}p\geq C\mu r$ 이 성립한다고 하자. 그러면 확률 $1-O(n_{2}^{-10})$ 으로 다음이 성립한다.


$$

\Vert M-M^{\star}\Vert\lesssim \sqrt{\frac{\mu r\log n_{2}}{n_{1}p}}\Vert M^{\star}\Vert


$$

즉, perturbation 행렬의 노음 크기를 제한할 수 있다. 이를 바탕으로 Wedin's $\sin\Theta$ [theorem](https://ddangchani.github.io/Spectral-Analysis-1)을 이용할 수 있는데, 다음 정리로부터 추정치와 추정대상 부분공간의 거리를 높은 확률로 제한할 수 있음을 확인할 수 있다.

### Theorem
충분히 큰 $C_{1}> 0$ 에 대해 $n_{1}p\geq C_{1}\kappa^{2}\mu r$ 이 성립한다고 가정하자. 그러면 확률 $1-O(n_{2}^{-10})$으로 다음이 성립한다.


$$

\max\big\{
\mathrm{dist}(U,U^{\star}),\mathrm{dist(V,V^{\star})}
\big\}\lesssim
\kappa\sqrt{\frac{\mu r\log n_{2}}{n_{1}p}}


$$

> Proof.
> 
> Wedin's $\sin\Theta$ 정리로부터 다음이 성립한다.
> 
> 
> $$
> 
> \frac{2\Vert M-M^{\star}\Vert}{\sigma_{r}(M^{\star})}\lesssim \kappa\sqrt{\frac{\mu r\log n_{2}}{n_{1}p}}
> 
> 
> $$
> 

또한, 추정행렬 $M$과 대상 행렬 $M^{\star}$에 대해서도 다음과 같은 정리가 성립한다.

### Theorem
충분히 큰 상수 $C>0$ 에 대해 $n_{2}p\geq C\mu r\log n_{2}$ 가 성립한다고 하자. 그러면 확률 $1-O(n_{2}^{-10})$ 으로 다음이 성립한다.


$$

\Vert U\Sigma V^{T} -M^{\star}\Vert_{F}\lesssim \sqrt{\frac{\mu r^{2}\log n_{2}}{n_{1}p}}\Vert M^{\star}\Vert


$$

행렬 뿐 아니라 고차원 텐서(3차원 이상)에서도 spectral analysis를 이용하여 tensor completion 문제를 풀 수 있다. 다만, 표기와 내용이 복잡하기 때문에 여기서는 다루지 않도록 하겠다.

# References
- Yuxin Chen et al. - Spectral Methods for Data Science: A Statistical Perspective (2021)
{% endraw %}