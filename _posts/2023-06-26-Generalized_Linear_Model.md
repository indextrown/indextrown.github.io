---
title: "Generalized Linear Model"
tags:
- Generalized Linear Model
- Linear Model
- Statistics
category: Linear Model
use_math: true
---
{% raw %}
일반화 선형모형(GLM)은 일반적인 선형모형(Linear Model, 반응변수와 설명변수의 관계가 선형이고 오차항의 분포가 normal인 모형)을 확장한 모형이다. 확장 방식은 반응변수와 설명변수의 관계를 nonlinear(ex. Exponential form)하게 바꾸거나, 혹은 오차항의 분포를 정규분포가 아닌 다른 분포로 가정하는 것이다. GLM을 정의하기 위해서는 세 가지 요소가 필요한데, **Random component, Systematic component, Link function**이다.

## Random component

Random component는 오차항의 분포, 즉 반응변수의 분포를 정의하는 요소이다. 일반적으로 분석의 편의를 위해 반응변수 $Y$가 지수족(exponential family) 분포를 따른다고 가정하는데, 이는 다음과 같다.

$$

f_{Y}(Y:\theta,\phi) = \exp\biggl(\frac{Y\theta-b(\theta)}{{\phi}} + c(Y,\theta)\biggr)

$$

예를 들어, Y가 Bernoulli random variable $Ber(p)$ 이면 다음과 같다.

$$

f(y) = \exp(y\log \frac{p}{1-p} - \log \frac{1}{1-p})

$$

여기서 $p=\frac{e^{\theta}}{1+e^{\theta}}$ 의 관계가 성립하는 것을 확인할 수 있다.
또한, 지수족의 성질에 의해(수리통계학에서 자주 다루는 내용)

$$

\mathrm{E}Y = b'(\theta)\quad \mathrm{Var}(Y) = b''(\theta)\phi

$$

가 성립한다.

## Systematic component

Systematic component는 $Y$와 $X$의 관계를 설정하는 요소이다. 이때 관계 설정은 조건부 기댓값 $\mathrm{E}(Y\vert X)$ 를 통해 이루어지며, 일반적으로 다음과 같이 $X$의 선형결합으로 주어진다.

$$

\mu_{i}=\mathrm{E(Y_{i}\vert X_{i})}

$$

$$

\eta_{i}=\sum_{j=1}^{p}X_{ij}\beta_{j}

$$

## Link function

앞서 정의한 $\mu_i,\eta_i$ 를 다음과 같이 연결해주는 함수 $g$를 link function이라고 한다.

$$

\eta = g(\mu)

$$

이때, $g$가 항등함수인 경우를 **canonical link function**이라고 한다.

# Likelihood Inference of GLM

그러면 앞서 정의된 GLM에서의 $\beta$를 어떻게 추정할 수 있을지 생각해보도록 하자. 일반적으로 선형모형의 계수를 추정하는 방법에는 최소제곱법과 최대가능도 추정량 두 개가 존재했고, 두 가지 방법으로 구한 선형계수의 추정량이 일치함은 확인할 수 있었다. 하지만 일반화선형모형의 경우 오차항의 closed form 을 직접적으로 구하고 미분하는 방식의 최소제곱법이 어렵기 때문에, **최대가능도 추정량(MLE)** 을 사용한다. 먼저, 가능도함수는 다음과 같이 구할 수 있다.

$$

\begin{aligned}
L(\beta(\theta),\phi) &= \prod_{i=1}^{n}f(y_{i}\vert \theta_{i},\phi)\\
&=\exp(\sum_{i=1}^{n}(\frac{y_{i}\theta_{i}-b(\theta_{i})}{\phi}+c(y_{i},\phi)))
\end{aligned}

$$

로그가능도는 다음과 같다.

$$

l(\beta) = \sum_{i=1}^{n}\frac{y_{i}\theta_{i}-b(\theta_{i})}{\phi}+c(y_{i},\phi)

$$

지수족에서는 $\beta$의 형태가 직접 드러나지 않기 때문에, chain rule을 이용해서 미분하는 작업이 필요하다. 이 과정에서 다음과 같은 Score function을 얻을 수 있다.

$$

\begin{aligned}
\frac{\partial}{\partial\beta}l(\beta) &= \sum_{i=1}^{n}\frac{\partial\eta_{i}}{\partial\beta}\frac{\partial\mu_i}{\partial\eta_{i}}\frac{\partial\theta_{i}}{\partial\mu_{i}} \frac{\partial}{\partial\theta_{i}}l(\beta)\\
&=\sum_{i=1}^{n}X_{i}^{T}\{g'(\mu_{i})\mathrm{Var}(Y_{i})\}^{-1}(Y_{i}-\mu_{i})
\end{aligned}

$$

만약 canonical link function이 사용될 경우, $\eta=\mu$ 이므로 비교적 간단하게 정리된다.

$$

\frac{\partial}{\partial\beta}l(\beta) = \sum_{i=1}^{n}\frac{X_{i}^{T}(Y_{i}-\mu_{i})}{\phi}

$$

마찬가지로, Fisher Information 역시 로그가능도를 한번 더 미분하여 다음과 같이 구할 수 있다.

$$

i(\beta) = \sum_{i=1}^{n}X_{i}^{T}g'(\mu_{i})^{-1}\mathrm{Var}(Y_{i})^{-1}g'
(\mu_{i})^{-1}X_{i}

$$

canonical link에 대해서도 다음과 같이 간단하게 쓸 수 있다.

$$

i(\beta)=\sum_{i=1}^{n}\frac{X_{i}^{T}b''(\theta_{i})X_{i}}{\phi}

$$

## Solution

### Newton-Raphson
앞서 구한 score equation을 풀면 최대가능도 추정량을 찾을 수 있겠지만, closed form을 구하는 것이 매우 복잡하므로 추정량을 구하기 위해서는 좀 더 numerical한 해결 방안이 필요하다. 우선 다음과 같이 매 step마다 추정량을 업데이트하여 local maximum을 구하는 Newton-Raphson algorithm을 고려해볼 수 있다.

$$

\theta^{(p+1)}=\theta^{(p)}+I(\theta^{(p)})^{-1}S(\theta^{(p)})

$$

여기서 $I(\theta^{(p)})$ 는 p 번째 step에서의 observed information을 의미하며 $S$는 score function을 의미한다.

### Iteratively reweighted least squared estimate
IRLSE는 다음과 같은 pseudo-dependent variable

$$

\begin{aligned}
z_{i}&= \eta_{i}+\frac{\partial\eta_{i}}{\partial\mu_{i}}(Y_{i}-\mu_{i})\\
&=:X_{i}^{T}\beta + \epsilon_{i}
\end{aligned}

$$

을 생각하고, $z_i$ 들을 종속변수로 하는 회귀모형을 생각하여 다음과 같은 weighted least square estimator를 구하는 아이디어이다.

$$

\hat\beta = (\sum_{i=1}^{n}X_{i}^{T}\mathrm{Var}(z_{i})^{-1}X_{i})^{-1}(\sum_{i=1}^{n}X_{i}^{T}\mathrm{Var}(z_{i})^{-1}z_{i})

$$

이때 $\mathrm{Var}(z_{i})$ 는 $g'(\mu_{i})^{2}\mathrm{Var}(Y_{i})$ 로 주어지며, 이를 이용해 numerical한 추정량을 찾으면

$$

\beta^{(p+1)}=\beta^{(p)}+i(\beta^{(p)})^{-1}S(\beta^{(p)})

$$

가 되어, 사실상 Newton-Raphson algoritm과 동치임을 확인할 수 있다. 즉, 이는 IRLSE의 해가 MLE임을 나타낸다.

## Ex. Logistic Regression

Logistic Regression은 GLM의 한 종류로서, 반응변수가 0 또는 1의 값만을 갖는 Bernoulli independent random variable이고, 이 경우 가능도함수는 다음과 같이 주어진다.

$$

Y_{i}\sim Ber(1,\mu_i)

$$

$$

L(\beta,Y) = \exp\bigg(\sum_{i=1}^{n}y_i\log(\frac{\mu_{i}}{1-\mu_{i}})+\log(1-\mu_i)\bigg)

$$

이때 하나의 설명변수만 사용하는 모형을 살펴보면,

$$

\eta_{i}=\log(\frac{\mu_{i}}{1-\mu_{i}}),\quad \mathrm{E}(Y_i\vert x_{i})= \mu_{i}=\frac{e^{\eta_{i}}}{1+e^{\eta_{i}}}

$$

과 같이 canonical link function을 사용해 나타낼 수 있고, 이때 $\eta$는 

$$

\eta_{i}=\beta_{0}+\beta_{1}x_{i}

$$

와 같이 주어진다.
Canonical link function의 사용으로 인해 회귀계수 $\beta_{1}$의 해석은 다음과 같은 로그 오즈비(**odds ratio**)를 의미한다.

$$

\beta_{1}=\log\frac{P(Y_{i}=1\vert x_{i}=1)P(Y_{i}=0\vert x_{i}=0)}
{P(Y_{i}=1\vert x_{i}=0)P(Y_{i}=0\vert x_{i}=1)}

$$

{% endraw %}