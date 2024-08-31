---
title: Spectral Analysis - Factor Models
tags:
- PCA
- Dimension Reduction
- Spectral Analysis
- Factor Model
category: 
use_math: true
---
{% raw %}
# PCA and Factor Models

PCA는 Spectral analysis의 대표격인 방법론으로, 데이터 차원 축소, 시각화, 이상치 탐지 등 여러 가지 목적으로 활용가능하다. 여기서는 [Perturbation Theory](https://ddangchani.github.io/Spectral-Analysis-1/)를 바탕으로 PCA와 Factor model을 다루어보도록 하겠다.

## Problem Formulation
고차원 데이터 간의 종속성(dependence)를 측정하는 것은 데이터사이언스에서 중요한 문제이다. 일반적으로 저차원 문제의 경우 공분산 행렬을 추정하는 방식을 이용해 데이터간 관계를 파악할 수 있지만, 고차원 문제에서는 계산 비용 문제, 혹은 $n<<p$ 인 문제로 인해 그러한 추정이 어렵다. 따라서, **잠재 변수**(latent factor)를 활용한 방식이 필요하다.

$n$개의 독립 샘플 $x_{i}\in\mathbb{R}^{p}$ 가 주어진 상황에서, 각 샘플 벡터를 다음과 같이 표현하기로 가정하자.


$$

x_{i}=L^{\star}f_{i}+\eta_{i} \quad 1\leq i\leq n 


$$

여기서 $f_{i}\in\mathbb{R}^{r}$ 은 잠재변수이고 $L^{\star}\in\mathbb{R}^{p\times r}$ 은 **loading matrix**라고 부르며, 마지막으로 $\eta_{i}\in\mathbb{R}^{p}$ 는 랜덤 노이즈에 해당하는 벡터이다. 즉, 각 샘플 $\{x_{i}\}$ 를 저차원($r$) 부분공간에 embedded 된 것으로 간주하고 이 과정에서 loading matrix $L^{\star}$ 는 서로 다른 변수 간의 종속성을 나타내는 것으로 간주한다. PCA에서는 일반적으로 $L^{\star}$ *principal subspace*라고 부른다. 다만, loading matrix는 apriori-unknown, 즉 데이터가 주어져야 비로소 추정할 수 있으므로(사전분포가 주어지지 않음) 추정을 위해 잠재변수와 노이즈 벡터에 대한 가정이 이루어져야 한다.

## Algorithm
### Assumption
잠재변수 벡터 $f_{i}$ 와 노이즈벡터 $\eta_{i}$ 는 다음과 같은 분포를 가정한다.


$$

f_{i}\overset{i.i.d}{\sim} N(0,I_{r})\quad\mathrm{and}\quad \eta_{i}\overset{i.i.d}{\sim} N(0,\sigma^{2}I_{p})


$$

또한, loading matrix에 대해 다음과 같은 eigendecomposition 형태를 가정하고


$$

L^{\star}{L^{\star}}^{T}=U^{\star}\Lambda^{\star}{U^{\star}}^{T} 


$$

이로부터 일반성을 잃지 않고 $L^{\star}=U^{\star}(\Lambda^{\star})^{\frac{1}{2}}$ 를 가정한다. 또한 고유값행렬이 다음과 같이 주어진다고 하자.


$$

\Lambda^{\star}=\mathrm{diag}([\lambda_{1}^{\star},\cdots,\lambda_{r}^{\star}])


$$

### Algorithm

위 가정으로부터 다음과 같이 샘플들의 분포를 얻을 수 있다.


$$

x_{i}\sim N(0,M^{\star})\quad M^{\star}=U^{\star}\Lambda^{\star}{U^{\star}}^{T} +\sigma^{2}I_{p} 


$$

이때 공분산행렬 $M^{\star}$의 구조로부터 $M^{\star}$의 top-$r$ eigenspace, 즉 가장 큰 고유값 $r$개로부터 생성한 고유공간이 $L^{\star}$로 생성한 고유공간과 일치함을 확인할 수 있다. 그렇기 때문에, sample covariance matrix


$$

M:=\frac{1}{n}\sum_{i=1}^{n}x_{i}x_{i}^T 


$$

의 rank-$r$ eigendecomposition $M=U\Lambda U^{T}$ 를 계산하는 것 만으로, $U$가 $U^{\star}$ 의 추정치로 기능할 수 있으므로 $M^{\star}$의 추정치 역시 얻을 수 있게 된다. 이것이 PCA의 일반적인 원리이다.

## Performance

PCA의 성능을 측정하기 위해, [Perturbation Theory](https://ddangchani.github.io/Spectral-Analysis-1/)의 형태를 다음과 같이 유도해보자. 우선 행렬 $F:=[f_{1},\ldots,f_{n}]\in\mathbb{R}^{r\times n}$ 및 $Z:=[\eta_{1},\ldots,\eta_{n}]\in\mathbb{R}^{p\times n}$ 을 정의하면 다음과 같이 샘플 공분산행렬을 분해할 수 있다.


$$

M=\frac{1}{n}(L^{\star}F+Z)(L^{\star}F+Z)^{T}=M^{\star}+E


$$

여기서 perturbation $E$ 는 다음과 같이 정의된다.


$$

E:= L^{\star}(\frac{1}{n}FF^{T}-I_{r}){L^{\star}}^{T}+ \frac{1}{n}L^{\star}FZ^{T}+ \frac{1}{n}ZF^{T}{L^{\star}}^{T}+(\frac{1}{n}ZZ^{T}-\sigma^{2}I_{p})


$$

David-Kahan Theorem을 사용하기 위해, $\Vert E\Vert$ 의 크기를 컨트롤해야 하는데, 다음 Lemma로부터 얻을 수 있다.

### Lemma

충분히 큰 상수 $c>0$ 에 대해 $n\geq cr\log^{3}(n+p)$ 가 성립한다고 하자. 그러면 확률 $1-O((n+p)^{-10})$ 으로 다음이 성립한다.


$$

\Vert E\Vert \lesssim\bigg(\lambda_{1}^{\star}\sqrt{\frac{r}{n}}+\sigma\sqrt{\frac{\lambda_{1}^{\star}p}{n}}+\sigma^{2}\sqrt{\frac{p}{n}}+ \frac{{\sigma^{2}p\log^{\frac{3}{2}}(n+p)}}{n}\bigg)\log^{\frac{1}{2}}(n+p)


$$

따라서, 1에 가까운 확률로 perturbation 크기를 컨트롤할 수 있기 때문에, 다음 정리로부터 추정 대상 저차원 부분공간 $U^{\star}$과 estimate subspace $U$ 의 거리 역시 높은 확률로 컨트롤됨을 확인할 수 있다.

### Theorem

충분히 큰 상수 $C>0$ 에 대해 $n\geq C(\kappa^{2}r+r\log^{2}(n+p)+ \frac{\kappa\sigma^{2}p}{\lambda_{r}^{\star}}+ \frac{\sigma^{4}p}{(\lambda_{r}^{\star})^{2}})\log^{3}(n+p)$ 가 만족한다고 하자. 그러면 확률 $1-O((n+p)^{-10})$ 으로 다음이 성립한다.


$$

\mathrm{dist}(U,U^{\star})\lesssim\bigg(\frac{\sigma}{\sqrt{\lambda_{r}^{\star}}} \sqrt{\kappa \frac{p}{n}}+ \frac{\sigma^{2}}{\lambda_{r}^{\star}}\sqrt{\frac{p}{n}}+\kappa\sqrt{\frac{r}{n}}\bigg)\log^{\frac{1}{2}}(n+p)


$$

여기서 $\kappa:=\lambda_{1}^{\star}/\lambda_{r}^{\star}$ 는 $M^{\star}$ 에서의 가장 큰 고유값과 가장 작은 고유값의 비를 의미한다. 정리는 David-Kahan $\sin\Theta$ theorem으로부터 얻어지며, 이는 Lemma에 의해 perturbation size가 컨트롤되기 때문에 가능하다.


# References
- Yuxin Chen et al. - Spectral Methods for Data Science: A Statistical Perspective (2021)
{% endraw %}