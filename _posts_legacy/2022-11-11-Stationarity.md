---
title: "Stationarity"
tags:
- Time Series
- Statistics
- Stationarity
category: Time Series
use_math: true
---
{% raw %}
# Stationarity

우리말로 **정상성**이라고 정의하는 Stationarity는 시계열 분석을 수행하기 위해 가정해야 하는 가장 중요한 도구이다. 회귀분석에 비유하자면, 회귀모형의 오차항(흔히 $\epsilon$으로 나타나는)이 정규성을 가진다고 가정하는 것과 비슷하다. 가장 단순한 (단변량) 시계열은 다음과 같이 시간 $t$에 대해 변화하는 확률변수의 sequence로 정의된다.

$$

\{X_t\}_{t\in\mathbb N} : x_1,\ldots,x_t

$$

시계열에 대한 Strict Stationarity는 다음과 같이 정의된다.

$$

F_{t_1+h,\ldots,t_n+h}(x_1,\ldots,x_n) = F_{t_1,t_2,\ldots,t_n}(x_1,\ldots,x_n)\;\; \forall n\in\mathbb N

$$

하지만 일반적으로 $n$개 확률변수의 joint distribution을 구하는 것은 사실상 매우 힘들다. 따라서 joint distribution 기반의 위 정의 대신 보다 약한(weaker) 정상성을 다음과 같이 정의한다.

> 1. $E[X_t]$ 가 상수(constant)이다.
> 2. 임의의 시간 $t,s$에 대해 $\mathrm{Cov}(X_{t+h}, X_{s+h}) = \mathrm{Cov}(X_t,X_s)$ 

정상 시계열에서 다음과 같은 Autocovariance function을 정의할 수 있다.

$$

\gamma_X(h) = \mathrm{Cov}(X_t,X_{t+h})

$$

이때 정상성 조건에 의해 ACF는 시간에 의존하지 않고, lag($h$)에만 의존하는 함수임을 알 수 있다.

Autocovariace function으로부터, 공분산으로부터 상관계수를 정의하듯 다음과 같은 Autocorrelation function(ACF)를 정의할 수 있다.

$$

\begin{aligned}
\rho_X(h) &= \frac{\mathrm{Cov}(X_{t+h},X_t)}{\sqrt{\mathrm{Var}(X_{t+h})\mathrm{Var}(X_t)}} \\
&= {\gamma(h)\over \gamma(0)}
\end{aligned}

$$

### White Noise

시계열 모형에서 White noise란 선형회귀모형에서 오차항과 비슷한 존재이다. 시계열 모형과 마찬가지로 white noise 역시 시간에 따른 sequence이며, $a_0,a_1,\ldots$ 의 형태로 표기한다. 이때 다음 조건을 만족해야 한다.

$$

\mathrm{Cov}(a_t,a_s) = 0 \;\; \text{for}\;\; t\neq s \\
\mathrm E[a_t] = 0,\;\; \mathrm{Var}(a_t) = \sigma_a^2\text{(const)}

$$

# References

- Time Series Analysis Lecture notes, Kichun Lee, HYU (2013)

{% endraw %}