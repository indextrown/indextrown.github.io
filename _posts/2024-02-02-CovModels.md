---
title: "Covariance Models for Spatial Data"
tags: 
- Spatial Statistics
- Stochastic Process
category: 
collection: 
use_math: true
header: 
  teaser: /assets/img/Pasted image 20240202214222.png
---

# Covariance Models

## Definition

연속형 공간자료는 공간 $\mathcal{D}\subset \mathbb{R}^{d}$와 확률공간 $(\Omega,\mathcal{F},P)$ 에서 정의되는 일종의 확률과정<sup>stochastic process</sup>


$$

Z(s,\omega),s\in \mathcal{D}, \omega\in\Omega


$$

으로 나타낼 수 있다. 이때 $Z(s,\omega)$의 output space를 $(S,\mathcal{S})$ 라고 하면(여기서 $\mathcal{S}$는 $\sigma$-field를 의미한다), 어떤 공간 지점 $s$를 고정한 $Z(s,\cdot)=Z(s)$ 는 확률공간 $(\Omega,\mathcal{F})$ 에서 $(S,\mathcal{S})$로의 사상이므로 이는 확률변수가 된다.

일반적으로 확률과정
$$
Z(t,\omega):T\times (\Omega,\mathcal{F})\to (S,\mathcal{S)}
$$
을 $S^{T}$-valued random variable이라고도 하므로, 위 연속형 공간자료를 나타내는 (1차원) 확률과정은 $\mathbb{R}^\mathcal{D}$-valued random variable이라고 할 수 있을 것이다.

공간자료의 종속성을 파악하기 위한 방법으로 공분산을 고려하는 방법이 있다. 이러한 방법들을 **covariance model**이라고 하며, 이번 글에서는 해당 방법들에 대해 다루어보도록 하겠다.

## Stationarity

확률과정을 이용하기 전에, 공간자료의 확률과정에서 사용되는 정상성 개념들을 먼저 짚어보고자 한다.
### Strictly stationary process

Process $Z(s)$ 와 임의의 $h\in\mathbb{R}^{d}$ 에 대해 다음 조건을 만족하면 $Z(s)$를 **strictly stationary**<sup>강정상성</sup> 하다고 정의한다.


$$

F(z_{1},\ldots,z_{k};s_{1},\ldots,s_{k}) = F(z_{1},\ldots,z_{k};s_{1}+h,\ldots,s_{k}+h)


$$

이때 $\{s_{1},\cdots,s_{k},s_{1}+h,\cdots,s_{k}+h\}\subset \mathcal{D}$이고 $F$는 random vector $(Z(s_{1}),\ldots, Z(s_{k}))^{\top}$ 의 분포함수를 의미한다.

### Weakly stationary process

Process $Z(s)$, 임의의 $s_{1},s_{2}\in \mathcal{D}$에 대해 평균과 공분산이 다음 조건을 만족하면 $Z(s)$를 **weakly stationary**<sup>약정상성</sup> 하다고 정의한다.


$$

\mathrm{E}Z(s) = \mu ,\quad C(s_{1},s_{2}) = C(s_{1}-s_{2})


$$

즉, 기댓값이 상수로 주어지며, 공분산이 두 지점 간 거리에만 의존한다는 것을 의미한다.

### Intrinsically stationary process

Process $Z(s)$에 대해, 확률과정 *increment process*를 다음과 같이 정의하자.


$$

I_{h}(s) = \{Z(s)-Z(s+h)\}


$$

이때, $I_{h}(s)$가 모든 $h$에 대해 *weakly stationary* 하다면, $Z(s)$를 **intrinsically stationary** 하다고 한다. 또한, $\mathrm{E}[Z(s)-Z(s+h)]=0$인  intrinsically stationary process에 대해서는 다음과 같이 **variogram**을 정의할 수 있다.

$$

2\gamma(h) = \mathrm{E}\left(Z(s)-Z(s+h)\right)^{2}.


$$

여기서 $\gamma(h)$는 semi-variogram이라고 한다. 이러한 intrinsic stationarity는 공간통계학에서 일반적인 가정이다. 

또한, Weakly stationary $Z(s)$에 대해 다음이 성립한다.


$$

\gamma(h) = C(0)-C(h)


$$

> Proof.
>
> 
> 
> $$\begin{align}
> 
2\gamma(h) &= \mathrm{E}\left[Z(s)-Z(s+h)\right]^{2}\\
&= \mathrm{E}\left[Z(s)-\mathrm{E}Z(s) + \mathrm{E}Z(s+h)-Z(s+h)\right]^{2}\\
&= \mathrm{Var}(Z(s))+\mathrm{Var}(Z(s+h)) - 2C(s,s+h)\\
&= 2C(0) -2C(h)
\end{align}$$

### Nugget Effect

일반적인 geostatistical model은 확률과정 $Z(s)$를 다음과 같이 분해한다.


$$

Z(s) = \mu(s) + \eta(s) + \epsilon(s)


$$

여기서 $\mu(s) =\mathrm{E}Z(s)$ 는 **mean function**이고, $\eta$는 평균이 0인 확률과정이며 (개별 공간을 모델링), $\eta$는 일종의 오차를 나타내는 평균이 0이고 공간상관성이 없는 확률과정을 나타낸다. 구체적으로 $\epsilon(s)$는 다음과 같은 covariance function을 갖는다.


$$

\mathrm{Cov}(\epsilon(s),\epsilon(s+h)) = \begin{cases}
\sigma^{2}\ge 0, &h=0 \\
0,  &h\neq 0
\end{cases}


$$

또한, $\epsilon(s)$를 **nugget effect**라고 부른다. 이는 일반적으로 개별 지점에서 반복된 측정과정으로부터 발생가능한 관측 오차를 나타낸다.

## Bochner's Theorem

확률과정 $Z(s)$가 약정상성<sup>weakly stationarity</sup>을 갖는다고 하자. 그러면 임의의 $s_{1},\ldots,s_{n}\in \mathbb{R}^{d}$ 에 대응하는 확률변수들의 공분산 행렬은 다음과 같이 주어진다.


$$

\Sigma=
\begin{align}
\begin{pmatrix}C(0 )&C(s_{1}-s_{2})&\cdots &C(s_{1}-s_{n})\\
C(s_{2}-s_{1})&C(0) & \cdots & C(s_{2}-s_{n})\\
\vdots &\vdots&\ddots&\vdots\\
C(s_{n}-s_{1})&C(s_{n}-s_{2})&\cdots &C(0)\end{pmatrix}
\end{align}


$$

즉, 이로부터 어떤 함수 $C(\cdot)$가 covariance function이 되기 위해서는 non-negative definite 조건을 만족해야 한다는 것을 알 수 있다. 약정상성을 갖는 확률과정에 대해, 공분산함수의 타당성을 검정하는 방법으로 다음의 **Bochner's theorem**을 응용할 수 있다.

### Theorem
$\mathbb{R}^{d}$에서의 연속 실함수 $C$가 positive definte일 필요충분조건은 $C$가 $\mathbb{R}^{d}$에서의 symmetric, nonnegative인 측도 $F$의 푸리에 변환<sup>Fourier transformation</sup>이어야 한다는 것이다. 즉, 다음과 같다.


$$

C(h) = \int_{\mathbb{R}^{d}} \exp(ih^{\top}x)dF(x) = \int_{\mathbb{R}^{d}}\cos(h^{\top}x)dF(x)


$$

특히, 대부분의 경우에서 spectral measure $F$는 르벡 측도에 대한 **spectral density** $f$를 갖고 이를 이용하면 다음과 같이 나타낼 수 있다.


$$

C(h) = \int_{\mathbb{R}^{d}}\exp (ih^{\top}x)f(x)dx = \int_{\mathbb{R}^{d}}\cos(h^{\top}x)f(x)dx


$$

Inversion formula를 사용하면, spectral density는 다음과 같이 나타낼 수 있다.


$$

f(x) = \frac{1}{(2\pi)^{d}}\int_{\mathbb{R}^{d}}\cos(h^{\top}x)C(h)dh


$$


## Smoothness Properties

### Continuity and Differentiability

공간 확률과정 $Z(s):s\in D\subseteq \mathbb{R}^{d}$ 가 **mean square continuous** 하다는 것은


$$

\mathrm{E}\left[Z(s)-Z(s+h)\right]^{2}\to 0 \quad \text{as}\quad \left\Vert h\right\Vert\to 0


$$

임을 의미한다. 따라서, 약정상성을 갖는 과정에서는 다음과 같이 정의될 수 있다.


$$

\lim_{\left\Vert h\right\Vert\to 0}C(h) = C(0)


$$

**Mean square differentiability**는 다음과 같이 정의된다.


$$

\mathrm{E}\left[\frac{{Z(s+h)-Z(s)}}{h} -Z'(s)\right]^{2}\to 0\quad \text{as}\quad \left\vert h\right\vert\to 0


$$

## Isotropic Covariance

### Isotropic

약정상성을 갖는 확률과정의 공분산함수가 거리 $\left\Vert h\right\Vert$에만 의존한다면, 이를 *isotropic* covariance function 이라고 한다. 즉, $C(h) = C_{0}(\Vert h\Vert)$ 이다.

마찬가지로, Intrinsic process에 대해서는 variogram에 대해 isotropic variogram을 정의할 수 있다. 즉, $\gamma(h)=\gamma_{0}(\left\Vert h\right\Vert)$ 이다.

### Example

공간데이터의 모델링에 가장 널리 사용되는 isotropic covariance function은 **Matern class**이다. [Gaussian process]({% post_url 2022-09-05-Gaussian_Process %})에도 널리 사용되며, 다음과 같이 $t=\left\vert h\right\vert$의 함수로 정의된다.


$$

\varphi(t) = \frac{2^{1-v}}{\Gamma(v)}\left(\frac{t}{\theta}\right)^{v}K_{v}\left(\frac{t}{\theta}\right),\quad (v>0,\theta>0)


$$

여기서 $K_{v}$는 modified Bessel function이고, $v,\theta$ 는 각각 smoothness, scale을 나타내는 hyperparameter이다. $v$값은 일반적으로 $\{\frac{1}{2},\frac{3}{2},\frac{5}{2}\}$ 을 널리 이용하는데, $v=\frac{1}{2}$인 경우를 *Ornstein-Uhlenbeck process*라고 부르기도 한다. 

![](/assets/img/Pasted image 20240202214222.png)
*Gaussian process sample function from Matern covariance function (Murphy, 2023)*


## Prediction

공간통계 분야에서 예측 문제란, 관측되지 않은 test point $s_{\ast}\in \mathbb{R}^{d}$에 대한 process value $Z(s_{\ast})$를 찾아내는 것이다. 만일 이를 least squre 문제로 해결하고자 한다면, 기대예측오차(EPE)를 사용하여 optimal predictor로 다음의 조건부 기댓값을 사용할 수 있다.


$$

\hat Z(s_{\ast}) = \mathrm{E}\left[Z(s_{\ast})\mid Z(s_{1})=z_{1},\cdots,Z(s_{n})=z_{n}\right]


$$

하지만 일반적으로 위 조건부 기댓값을 모델링하는 것은 어렵다. 다만, *Gaussian process*와 같이 realisation의 분포를 다변량 정규분포로 가정한다면 정규분포의 성질로부터 다음과 같은 모델링이 가능하다.


$$

\hat Z(s) = \mu + \left(C(s-s_{1}),\cdots,C(s-s_{n})\right)\left[C(s_{i}-s_{j})\right]^{-1}
\begin{pmatrix}Z(s_{1})-\mu \\ \vdots \\ Z(s_{n})-\mu\end{pmatrix}


$$

이러한 과정으로 geostatistical data에 대해 예측 문제를 해결하는 과정을 **Kriging**이라고도 하는데, 이에 대해서는 다른 포스트로 자세히 다루도록 하겠다.


# References
- 서울대학교 공간통계학 강의노트
- Fuentes, A. E. G., Peter Diggle, Peter Guttorp, Montserrat (Ed.). (2010). _Handbook of Spatial Statistics_. CRC Press. [https://doi.org/10.1201/9781420072884](https://doi.org/10.1201/9781420072884)
- Murphy, K. P. (2023). _Probabilistic machine learning: Advanced topics_. The MIT Press.