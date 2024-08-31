---
title: "Linear Mixed Effect Model"
tags:
- Linear Model
- Experimental design
category: Linear Model
use_math: true
---
{% raw %}
# Fixed and Random effect

$i$번째 그룹에 대한 $j$번째 관측값 $y_{11},\ldots,y_{nn}$ 들이 주어질 때, 이들의 평균을 모델링하는 다음과 같은 모형을 생각해보자.

$$

\mathrm{E}[y_{ij}] = \mu + \alpha_{i}+\epsilon_{ij}

$$

이때 각 parameter $\mu,\alpha$ 는 평균에 영향을 미치는 모수이고 $\mu$는 global mean에, $\alpha$는 각 그룹의 평균에 영향을 미친다. $\epsilon_{ij}$ 는 개별 관측값에 영향을 미치는 오차항이다. 여기서 두 가지 경우를 살펴보도록 하자.

###  1. $\alpha$ is a fixed effect
$\alpha$가 고정효과라는 것은, 각 그룹에 대한 평균의 영향이 그룹 내에서는 모두 일정하다는 것을 의미한다. 예를 들어 n개의 환자 그룹에 서로 다른 n가지 치료방법을 적용한다 했을 때, 그룹 내에서는 일정한 효과가 있다고 가정하고 그룹 간 효과는 유의미하게 차이가 있다고 설정한 상황을 생각해 볼 수 있다. 이 경우 n개의 parameter $\alpha_i$를 설정하게 되며 이를 **고정효과** 모형이라고 한다.

### 2. $\alpha$ is a random effect
$\alpha$가 임의효과(random effect)라는 것은, 각 그룹 간의 차이가 일정하다고 설정하기 보단, 일종의 변동(variation)으로 간주하는 것을 의미한다. 앞선 예시에서와 같이 n개의 환자 그룹이 존재하는데, 이번에는 이들을 각각 서울에 있는 임의의 n개의 (동급의) 일반병원에서 치료하는 상황을 고려해보자. 이 경우는 고정효과와는 다르게 각 병원의 차이가 실험적으로 유의미하지 않으며, 임의로 선택한 상황이므로 개별 그룹 간 효과 역시 임의인 상황이다. 이런 경우 $\alpha_i$ 를 random variable로 보게 되며, 이를 **임의효과** 모형이라고 한다. 즉 다음과 같은 상황을 생각해볼 수 있다.

$$

\begin{aligned}
y_{ij}&= \mu+\alpha_i+\epsilon_{ij}\\
\alpha_{i}&\overset{iid}{\sim} N(0,\sigma_{a}^{2})\\
\epsilon_{ij}&\overset{iid}{\sim} N(0,\sigma^{2})\\
\alpha_i&\perp\epsilon_{ij}
\end{aligned}

$$

## Mixed effect model
Mixed effect model이란 앞서 다룬 고정효과와 임의효과가 모두 포함되어있는 모형을 말한다. 다음과 같이 일반적인 모형을 살펴보자.

$$

Y=X\beta+Z\gamma+e

$$

여기서 $X,Z$는 알려진 design matrix이고 $\beta$는 고정효과 벡터를, $\gamma$는 임의효과 벡터를 각각 나타낸다. 이때 임의효과 벡터의 경우 확률벡터의 일종이므로, 공분산행렬과 평균벡터를 지정해주어야 하는데, 

$$

\mathrm{E}(\gamma)=0, cov(\gamma)=:D,cov(\gamma,e) = 0, cov=(e)=R

$$

로 두도록 하자. 그러면 관측값과 임의효과의 결합분포는 다음과 같이 주어진다.

$$

\pmatrix{Y\\\gamma} \sim \pmatrix{\pmatrix{X\beta\\0},\pmatrix{ZDZ^T+R&ZD\\DZ^{T}& D}}

$$

그런데 실제로 각 모수(행렬)들을 추정하는 과정에서 임의효과의 공분산행렬 $D$가 복잡한 경우, 즉 그룹간 임의효과의 상관관계가 존재하는 경우 해당 성분의 추정이 어려워지는 문제가 발생하기 때문에, **Variance component model**을 활용하여 공분산행렬들에 구조를 주어 추정가능하게끔 변환하는 과정을 거친다. 여기서는 $cov(\gamma)=D=diag\{\sigma_{i}^{2}I\}$ 형태를 주어 $cov(Y)=V=\sum_{l}\sigma_{l}^{2}Z_{l}Z_{l}^{T}+R$ 로 변환하고, 이를 이용해 최대가능도 추정량을 구할 수 있다.

### Mixed model equation
$X\beta$의 best linear unbiased estimator(BLUE)와 $Z\gamma$의 best linear unbiased predictor(BLUP)은 다음과 같은 손실함수를 최소화하는 $\beta,\gamma$를 찾으면 구할 수 있는데, 이를 mixed model equation이라고 한다. 

$$

\min_{\beta,\gamma}\;\; (Y-X\beta-Z\gamma)^{T}R^{-1}(Y-X\beta-Z\gamma)+\gamma^{T}D^{-1}\gamma

$$

이는 $Y,\gamma$의 joint likelihood와 동일한데, 일반적으로 임의효과인 $\gamma$는 관측이 불가능하므로 실제 가능도를 상정하기 어렵지만, 여기서는 joint distribution이 존재한다고 가정하여 다음과 같은 분해를 이용한 것이다.

$$

f(Y,\gamma\vert \beta)=f(Y\vert \gamma,\beta)f(\gamma\vert \beta)

$$

### Estimation example
처음 다루었던 예시 모형을 살펴보도록 하자.

$$

y_{ij}=\mu +\alpha_{i}+\epsilon_{ij}

$$

이 경우에 $\alpha$가 고정효과인지, 임의효과인지에 따라 추정 형태가 어떻게 달라지는지 살펴보자. 먼저 $\alpha$가 고정효과인 경우, 다음과 같이 최대가능도 추정량을 구할 수 있다.

$$

\hat\alpha_{i}=\bar{y}_{i.}-\bar{y}_{..}

$$

여기서 $\bar y_{..}, \bar y_i.$ 는 각각 전체 관측치의 평균과 i번째 그룹 내 관측치의 평균을 의미한다. 반면, $\alpha$를 임의효과로 가정하는 경우는 다음과 같이 주어진다(mixed model equation을 풀면 된다).

$$

\tilde\alpha_{i}=\frac{\hat\sigma_{a}^{2}}{\hat\sigma_{a}^{2}+\hat\sigma^{2}/n_{i}}(\bar y_{i.}-\bar y_{..})

$$

이를 고정효과의 추정 결과와 비교해보면, additional term 

$$

\frac{\hat\sigma_{a}^{2}}{\hat\sigma_{a}^{2}+\hat\sigma^{2}/n_{i}}

$$

가 1보다 작으므로 추정량의 수축(shrinkage)이 발생했다고 볼 수 있다. 다만, 그룹 간 분산 $\sigma_{a}^{2}$이 커질수록 그 수축효과가 작아지는 것 역시 확인가능한데, 이는 그룹간 분산이 클수록 임의효과가 random effect와 같이 작용한다는 것을 의미한다. 좀 더 생각해보면, 그룹간 분산을 바탕으로 그룹 간 평균의 모델링을 임의효과로 설정할지, 고정효과로 설정할지 판단할 수 있다는 것을 의미한다.
{% endraw %}