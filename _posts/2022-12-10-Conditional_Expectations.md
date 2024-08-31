---
title: "Conditional Expectations"
tags:
- Probability Theory
- Statistics
category: Probability Theory
use_math: true
---
{% raw %}
# Conditional Expectations

Measure Theory를 기반으로 한 조건부 기댓값 및 조건부 확률을 정의해보도록 하자. 일반적으로 measure를 다루지 않는 통계학에서는 조건부 확률을 먼저 정의하고, 이후에 조건부 기댓값을 조건부 확률을 이용해 정의하는데 measure를 이용하면 좀 더 엄밀한 정의가 가능하다. 또한, 측도를 기반으로 한 새로운 조건부 기댓값의 정의와 기초통계학에서의 정의가 동치임을 확인해보도록 하자.

## Definition

### Conditional Expectation

확률공간 $(\Omega, \mathcal F, P)$ 에서 정의된 Random Variable $X$가 적분가능(integrable)하다고 하자. 이때 $\mathcal F$ 의 sub-$\sigma$-field $\mathcal A\subset \mathcal F$ 와 $X$에 대해 다음과 같이 조건부 기댓값 $E(X\vert \mathcal A)$ 을 정의한다.

> Conditional Expectation of $X$ given $\mathcal A$ 는 다음 두 조건을 만족하는 a.s. unique한 random variable이다.
>
> 1. $E(X\vert \mathcal A)$ 는 $(\Omega,\mathcal A)\to(\mathbb R, \mathcal B)$ 로의 가측함수이다(i.e. Borel Function).
> 2. 모든 $A\in \mathcal A$ 에 대해
>
> 
> $$
> 
> \int_A E(X\vert \mathcal A)dP = \int_A XdP
> 
> $$
> 
즉, 일반적으로 정의되는 두 확률변수 사이의 조건부 기댓값과는 다르게 가장 먼저 sub-$\sigma$-field를 이용한 조건부 기댓값이 정의된다. 이를 바탕으로 다음과 같이 조건부 확률 및 두 확률변수 간의 조건부 기댓값을 정의한다.

### Conditional Probability

$\mathcal A\subset F$ (sub-$\sigma$-field) 가 주어질 때 event $B\in\mathcal F$의 조건부 확률은 다음과 같이 정의한다.

$$

P(B\vert \mathcal A) = E(I_B\vert \mathcal A)

$$

여기서 $I_B$는 indicator function을 의미한다.

### Conditional Expectation between r.v.

Random variable $X$가 위와 같이 주어지고, 추가로 $Y$가 $(\Omega,\mathcal F,P)\to(\Lambda,\mathcal G)$ 로의 가측함수(random variable)로 주어질 때 조건부 기댓값은 다음과 같이 정의된다.

$$

E(X\;\vert \;Y) = E(X\vert \sigma(Y)) = E(X\vert Y^{-1}(\mathcal G))

$$

### 보조정리

가측함수 $Y:(\Omega,\mathcal F)\to (\Lambda,\mathcal G)$와 실함수 $Z:(\Omega,\mathcal F)\to \mathbb R^k$ 가 주어질 때, $Z$가 $(\Omega,\sigma(Y))\to(\mathbb R^k,\mathcal B^k)$ 로의 가측함수일 **필요충분조건**은 가측함수 $h:(\Lambda,\mathcal G)\to (\mathbb R^k,\mathcal B^k)$ 가 존재해 $Z=h\circ Y$ 인 것이다.

위 보조정리를 이용하면 앞서 정의한 두 확률변수 간의 조건부 기댓값에서 보조정리의 $h$에 해당하는 borel function이

$$

h(y) = E(X\vert Y=y)

$$

로 주어짐을 알 수 있다.

### Conditional probability density function(p.d.f.)

Random vector $(X,Y)$와 이것의 joint p.d.f. $f(x,y)$가 product measure $\nu\times\lambda$ 에 대해 주어진다고 하자. 이때 $Y=y$가 주어졌을 때 $X$의 조건부 확률밀도함수는 다음과 같의 정의된다.

$$

f_{X\vert Y}(x\vert y) = \frac{f(x,y)}{f_Y(y)}

$$

여기서 $f_Y$는 marginal p.d.f.를 의미한다. 즉, $f_Y = \int f(x,y)d\nu(x)$ 이다.

## 조건부 기댓값의 다른 표현

### Definition

Random variable $X,Y$ 가 각각 $n,m$ 차원이고 joint p.d.f.가 $\nu\times\lambda$ 에 대해 주어진다고 하자. 이때 측도 $\nu,\lambda$는 각각 $(\mathbb R^n,\mathcal B^n),(\mathbb R^m,\mathcal B^m)$ 에서 $\sigma$-finite하다. 어떤 함수 $g(x,y)$가 $\mathbb R^{n+m}$ 에서 borel이고 $E\vert g(X,Y)\vert <\infty$ 일때, 다음이 성립한다.

$$

E[g(X,Y)\vert Y] = \frac{\int g(x,Y)f(x,Y)d\nu(x)}{\int f(x,Y)d\nu(x)}\\
= \int g(x,Y)f_{X\vert Y}(x\vert Y)d\nu(x)\;\;\;\text{a.s.}

$$

즉, 조건부 기댓값을 조건부 확률밀도함수를 이용해 계산한다는 기초통계학의 내용이다. 다만, 앞서 조건부 기댓값을 새로운 borel function으로 정의했기 때문에, 새로운 정의와 여기서의 정의가 동치임을 확인하기 위해서는 증명 과정이 필요하다.

### Proof

위 식의 $\int g(x,Y)f_{X\vert Y}(x\vert Y)d\nu(x)$ 부분을 $h(Y)$ 로 정의하면, 이는 marginal integration의 형태이므로 Fubini's Theorem에 의해 $h(Y)$ 도 borel function이다.

또한, 처음 정의한 조건부 기댓값의 정의로부터 $E[g(X,Y)\vert Y] = E[g(X,Y)\vert Y^{-1}(\mathcal B^m)]$ 이므로 임의의 $B\in\mathcal B^m$ 에 대해 조건부 기댓값 정의의 성질 (2), 즉 $\int_{Y^{-1}(B)}h(Y)dP = \int_{Y^{-1}(B)}g(X,Y)dP$ 임을 보이면 우변이 좌변과 동치임을 보일 수 있다.

$$

\int_{Y^{-1}(B)}h(Y)dP = \int_{Y^{-1}(B)}h\circ Y(y)dP

$$

로 두면, distribution $P_Y$ 의 정의로부터

$$

\int_{Y^{-1}(B)}h(Y)dP = \int_Bh(y)dP_Y

$$

가 된다. 또한, $Y$의 확률밀도함수는 Radon-Nikodym derivative $f_Y=dP_Y/d\lambda$ 로 주어지므로

$$

\int_{Y^{-1}(B)}h(Y)dP = \int_B \int g(x,Y)f_{X\vert Y}(x\vert Y)d\nu(x) f_Y(x)d\lambda(y)

$$

로 주어진다. 이때 conditional p.d.f.의 정의로부터

$$

\int_{Y^{-1}(B)}h(Y)dP = \int_B\int g(x,Y)f(x,y)d\nu(x)d\lambda(y)

$$

가 되고, Fubini의 정리로부터

$$

\int_{Y^{-1}(B)}h(Y)dP = \int_{\mathbb R^n\times B}g(x,y)f(x,y)d(\nu\times\lambda)

$$

가 된다. 마찬가지로 joint p.d.f.의 Radon-Nikodym 정의로부터

$$

\int_{Y^{-1}(B)}h(Y)dP = \int_{\mathbb R^n\times B}g(x,y)P_{X,Y}

$$

이고, distribution의 정의로부터 $X^{-1}(\mathbb R^n) = \Omega$ 이므로

$$

\int_{Y^{-1}(B)}h(Y)dP = \int_{Y^{-1}(B)} g(X,Y)dP

$$

가 성립한다.

# References

- Mathematical Statistics, Jun Shao.
{% endraw %}