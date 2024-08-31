---
title: "Classic Geostatistical Methods"
tags: 
- Spatial Statistics
- Kriging
category: 
collection: 
use_math: true
---

이번 글에서는 이전에 [Covariance models]({% post_url 2024-02-02-CovModels %})에서 살펴본 연속형 공간자료를 모델링하는 고전적인 공간통계 방법론들에 대해 살펴보도록 하겠다. 이전 글에서 연속형 geostatistical 자료를 표현하는 방법으로 variogram 등을 살펴보았는데, 이러한 방법을 데이터로부터 어떻게 추론해내는지를 이번 글의 주요 관심사로 볼 수 있다.

# Geostatistical Model

## Model

Covariance model에서와 같이, 공간 $\mathcal{D}\subseteq \mathbb{R}^{d}$에서의 확률과정 $Z(s)$를 생각하고 이를 다음과 같은 구조로 나타내자.


$$

Z(s) = \mu(s) + e(s)\tag{1}


$$

이때 $\mu(s) := \mathrm{E}Z(s)$ 이고 이를 *mean function*이라고 하며, $e(s)$는 오차를 나타내는 평균이 0인 확률과정을 나타낸다. 또한, 오차 확률과정에 대해 일반적으로 다음과 같은 약정상성<sup>weakly stationarity</sup>을 가정한다.


$$

\mathrm{Cov}(e(s),e(t)) = C(s-t),\quad \forall s,t\in \mathcal{D}


$$

또한, 약정상과정 $e(\cdot)$의 semivariogram $\gamma$에 대해 다음이 성립한다.


$$

\gamma(h) = C(0)-C(h)


$$

위와 같은 모델 $(1)$은 큰 공간 변동성을 $\mu$를 통해 고려하고, 작은 공간 변동성은 오차 과정 $e$를 통해 고려한다. 그러나 일반적으로 실제 데이터로부터 이들을 구분하는 것은 거의 불가능하다. 실제 데이터는 어떠한 샘플링 과정 한번으로부터의 샘플에 불과하며, 이를 반복적으로 샘플링 할 경우의 문제는 고려하지 않기 때문이다.

> One person's deterministic mean structure may be another person's correlated error structure (Cressie, 1991)

따라서 이를 해결하기 위해 오차 과정 $e$를 다음과 같이 다시 분해하여 고려한다.


$$

e(s) = \eta(s) + \epsilon(s)


$$

여기서 $\eta$는 공간종속성을 갖는 요소인 반면, $\epsilon$은 측정오차를 나타내기 때문에 공간종속성을 갖지 않는다.

# Analyzing

Geostatistical 데이터를 분석하는 단계는 일반적으로 다음과 같이 이루어진다.

1. Mean function $\mathrm{E}Z(s)$ 를 추정한다.
2. Second-order structure (semivariogram 등)을 추정한다.
3. 관측되지 않은 지점에서의 반응변수 값을 예측한다. (Kriging)

이제 각 과정에서의 방법론들을 살펴보도록 하자.

## Mean function estimation

앞선 형태로 공간데이터에 대한 모델링을 진행하기 위해, 우선 기본적인 모수적 모형<sup>parametric model</sup>을 생각하자. 선형회귀모형과 유사하게, 다음과 같은 기본적인 형태를 가정할 수 있다.


$$

\mu(s;\beta) = X(s)^{\top}\beta


$$

여기서 $X(s)$는 지점 $s$에서 관측된 설명변수(공변량)들을 의미한다. 이러한 가정에서는 선형회귀모형에서와 같이 다음과 같은 OLS<sup>Ordinary Least Squares</sup> estimator를 생각할 수 있다.


$$

\hat\beta^{ols}=\arg\min\sum_{i=1}^{n}\left(Y(s_{i})-X(s_{i})^{\top}\beta\right)^{2}.


$$

## Semivariogram estimation

Geostatistical 데이터 분석의 두번째 과정은 second-order structure를 추정하는 것이다. 이는 공간자료의 공분산 구조, 즉 공간 종속성을 추정하는 과정이라고 생각하면 되는데, 일반적으로 $e(\cdot)$을 intrinsically stationary하다고 가정하고 이에 대해 semivariogram $\gamma$에 대한 추정함수 $\hat\gamma$를 구하는 것을 목표로 한다. 

### Nonparametric approach

$Z(s)$가 $s_{1},\ldots,s_{n}$에서 관측되었다고 하자. 이때 다음과 같은 적률추정량을 사용할 수 있다. (Matheron, 1963)


$$

2\hat\gamma(h) =\frac{1}{\left\vert N(h)\right\vert}\sum_{(s_{i},s_{j})\in N(h)}\left(Z(s_{i})-Z(s_{j}\right)^{2}


$$

이때 $N(h)=\{(s_{i},s_{j}:s_{i}-s_{j}=h\}$를 의미한다. 이는 관측된 자료로부터 경험적으로 추정한 semivariogram의 분포를 나타내므로, 이를 *empirical semivariogram*이라고도 한다. 문제는, 관측된 자료의 lag $h$의 분포가 균일하지 않은 경우 $\left\vert N(h)\right\vert$가 1또는 매우 작은 수를 갖게 된다. 이러한 경우에는 추정치로 사용하기 어렵기 때문에, 일종의 히스토그램 형태로 lag space $H=\{s-t:s,t\in\mathcal{D}\}$를 $H_{1},\ldots,H_{k}$로 분할하여 다음과 같은 추정치를 사용할 수 있을 것이다.


$$

\hat \gamma(h_{u})=\frac{1}{2N(H_{u})} \sum_{s_{i}-s_{j}\in H_{u}}\left(\hat e(s_{i})-\hat e(s_{j})\right)^{2}


$$

이러한 경우 히스토그램에서와 같이 optimal smoothing parameter를 찾는 문제가 발생하는데, 이에 대해 각 bin $H_{i}$가 30개 이상의 쌍 $(s_{k},s_{j})$들을 갖도록 설정하면 좋다는 것이 알려져 있다. (Journal, Hujibregts)

### Robust estimator

그러나 위 추정량은 이상치에 대해 robust하지 않다는 문제가 있다. 이에 대해 다음과 같이 bias correction을 추가한 robust estimator가 제안된 바 있다. (Cressie, Hawkins)


$$

\bar \gamma(h) = \frac{1}{0.914+\frac{0.988}{\left\vert N(h)\right\vert}}\left(\frac{1}{\left\vert N(h)\right\vert}\sum_{(s_{i},s_{j})\in N(h)}\left\vert Z(s_{i})-Z(s_{j})\right\vert^\frac{1}{2}\right)^{4}


$$

이는 다음의 아이디어로부터 도출된다.

> 확률변수 $X\sim \chi_{1}^{2}$ 에 대해 $X^\frac{1}{4}$가 거의 대칭적인 분포를 갖는다는 것이 알려져 있다. 따라서 $\left\vert Z(s_{i})-Z(s_{j})\right\vert^{2}$ 측면에서 $\left\vert Z(s_{i})-Z(s_{j})\right\vert^{\frac{1}{4}}$ 의 표본평균이 더 robust한 추정량이 된다.

### Parametric approach

일반적으로 모수적 방법과 비모수적 방법은 어떤 추정 문제에서 별개의 솔루션으로 여겨질 때도 있지만, semivariogram $\gamma$를 추정하는 문제에서는 결합되어 이루어지는 경우가 많다. 구체적으로, 앞서 경험적으로 추정한 semivariogram을, 모수적 방법을 이용하여 일종의 smoothing을 진행하게 된다. 이는 smoothing은 모델의 분산을 낮출 수 있고 이에 따라 공간종속성 파악을 더 용이하게 하기 때문이다. 또한, empirical model을 사용할 경우 예측 문제(단계 3)로 넘어갔을 때 공분산행렬의 *역행렬*을 구하는 과정에서 문제가 발생할 수 있다는 것이 다른 이유이다.

우선, 앞선 비모수적 방법론들로부터 얻은 semivariogram $\hat \gamma(h)$을 생각하자. 이때 $h\in\{h_{1},\ldots,h_{k}\}$ 이다. 모수공간 $\Theta$ 를 가정하여, 다음과 같은 parametric model을 생각하자.

1. $\gamma(0;\theta)=0$
2. $\gamma(-h;\theta)=\gamma(h;\theta)$ for all $h$.
3. Conditional negative definiteness


$$

\sum_{i=1}^{n}\sum_{j=1}^{n}a_{i}a_{j}\gamma(s_{i}-s_{j};\theta)\leq 0,\quad \sum_{i=1}^{n}a_{i}=0


$$

위 세 가지 조건은 모수적 모형 $\gamma(h;\theta\in\Theta)$ 가 semivariogram이 되기 위한 필요충분조건을 나타낸다. 이러한 조건을 만족한 모델링 중 가장 널리 사용되는 모델에는 다음과 같은 것들이 있다.

- Matérn ($\mathcal{K}$ is modified Bessel function)


$$

\gamma(h;\theta) = \theta_{1}\left(1-\frac{(\frac{h}{\theta_{2}})^{\nu}\mathcal{K}_{\nu}(\frac{h}{\theta_{2}})}{2^{\nu-1}\Gamma(\nu)}\right)


$$

- Gaussian


$$

\gamma(h;\theta) = \theta_{1}\left(1-\exp \left(- \frac{h^{2}}{\theta_{2}^{2}}\right)\right)


$$

- Power


$$

\gamma(h;\theta) = \theta_{1}h^{\theta_{2}}


$$

이러한 모델을 기반으로, 다음과 같은 **최소제곱법** 형태의 방법들로 학습을 진행할 수 있다.

- Least Square<sup>LS</sup>


$$

\hat \theta^{LS }=\arg\min_\theta(\hat \gamma-\gamma(\theta))^{\top}(\hat \gamma-\gamma(\theta))


$$

- Generalized Least Square<sup>GLS</sup>


$$

\hat \theta^{GLS}=\arg\min_\theta(\hat \gamma-\gamma(\theta ))^{\top}V^{-1}(\theta)(\hat \gamma-\gamma(\theta)),\quad V(\theta)=\mathrm{Var}(\hat \gamma)


$$

- Weighted Least Square<sup>WLS</sup>


$$

\hat \theta^{WLS}=\arg\min_\theta(\hat \gamma-\gamma(\theta))^{\top}W^{-1}(\theta)(\hat \gamma-\gamma(\theta)),\quad W(\theta)=\mathrm{diag}(V(\theta)).


$$

### Mean function re-estimation

앞선 방법으로 확률과정 $Z(s)$의 2차 구조까지 추론을 진행했는데, 만일 분석의 목적이 설명변수들의 영향을 파악하는 것에 있다면 mean function $\mu(\cdot)$에 대한 추론을 다시 진행해야 할 필요가 있다. 이전에 구한 추정량은 공간종속성을 고려하지 않은 추정량이기 때문이다. 이러한 과정을 *reestimation*이라고 하며 다음과 같은 EGLS<sup>Estimated Generalized Least Squares</sup>를 사용한다.


$$

\hat \beta^{EGLS}=(X^{\top}\hat \Sigma^{-1}X)^{-1}X^{\top}\hat \Sigma^{-1}y


$$

이때 $\hat \Sigma$는 다음과 같이 주어진다.


$$

\hat \Sigma_{ij}=\hat C(s_{i}-s_{j}).


$$


## Kriging

Geostatistical 데이터 분석의 마지막 단계는 **Kriging**으로, 이는 예측 문제를 해결하는 것이다. 이는 다음 조건을 만족하는 estimator $\hat Z(s_0)$ 중 prediction error variance $\mathrm{Var}((\hat Z(s_{0})-Z(s_{0}))$ 을 최소화하는 문제를 말한다.

1. Linearity : $\hat Z(s_{0})=\lambda^{\top}\mathbf{Z}$.
2. Unbiasedness : $\mathrm{E}\hat Z(s_{0})=\mathrm{E}Z(s_{0})$.

이 문제에 대한 해는 다음과 같은 **universal kriging predictor**으로 주어진다.


$$

\hat Z(s_{0}) = \left[\gamma+\mathbf{X}(\mathbf{X}^{\top}\Gamma^{-1}\mathbf{X})^{-1}(\mathbf{x}_{0}-\mathbf{X}^{\top}\Gamma^{-1}\gamma)\right]^{\top}\Gamma^{-1}\mathbf{Z}


$$

여기서 $\gamma=(\gamma(s_{1}-s_{0}),\ldots,\gamma(s_{n}-s_{0}))^{\top}$이고 $\Gamma$는 $(i,j)$ 번째 성분이 $\gamma(s_{i}-s_{j})$인 $n\times n$ symmetric matrix를 나타낸다.

# References
- Fuentes, A. E. G., Peter Diggle, Peter Guttorp, Montserrat (Ed.). (2010). _Handbook of Spatial Statistics_. CRC Press. [https://doi.org/10.1201/9781420072884](https://doi.org/10.1201/9781420072884)
- 서울대학교 공간통계 강의노트