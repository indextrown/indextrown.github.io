---
title: "Sufficiency"
tags:
- Statistics
category: Statistics
use_math: true
---
{% raw %}
이번 포스트에서는 통계학의 추정, 검정 등에서 중요하게 사용되는 통계량의 충분성에 대해 정리하고자 한다. 확률공간 $(\Omega,\mathcal{F},P)$ 을 이용해 random experiment를 정의할 때, 우리는 확률측도 $P$를 population이라고 정의하기도 한다. 이때 random sample이란, 주어진 population $P$로부터 데이터를 생성하는 random element(ex. random vector, random variable)을 의미한다.
만일 모든 event $A\in\mathcal{F}$ 에 대한 확률분포 $P(A)$ 를 알 수 있으면 좋을 것이지만, 현실에서는 주어진 데이터가 어떤 확률분포로부터 생성되었는지 알 수 없으므로, 우리는 주어진 데이터, 즉 sample로부터 적절한 연역적 과정을 거쳐 $P$에 대한 정보를 추정해나가야 할 것이다. 이것이 통계적 추정(Statistical Inference)의 기본 원리이다.

## Statistical Model and Statistics
통계적 추론 과정에서 모델(Model)이란, 실제 확률분포 $P$에 대한 가정들의 집합이라고 볼 수 있다. 일반적으로 많이 사용하는 모델은 모수적 모형(**parametic family**) 이다. 이는 확률공간에서 주어진 확률측도의 집합 $P_\theta$ 가 $\theta\in\Theta\subset\mathbb{R}^{d}$ 에 의해 주어지고, 각 parameter $\theta$의 값이 주어지면 확률분포를 알 수 있게 되는 것을 의미한다.
예를 들면, A라는 집단의 어떤 특성을 파악하고자 할 때, 해당 특성이 정규분포를 나타낼 것이라고 가정하면 

$$

\mathcal{P}_{\theta} = \{N(\mu,\sigma^{2}):\mu\in\mathbb{R},\sigma^2>0\} 

$$

처럼 모수적 모형을 가정할 수 있다. 이때 모수공간 $\Theta$는 $\mathbb{R}^{2}$의 부분집합임을 알 수 있다. 

통계량(**Statistic**)이란 random sample $X$의 함수 $T(X)$를 의미한다. 확률론적인 관점에서 살펴보면, 통계량의 중요성을 이해할 수 있다. 통계량 $T(X)$는 $X$의 미지의 분포에 대한 정보를 가지고 있는데, 이는 $\sigma$-field $\sigma(T(X))$ 를 살펴보면 된다. 또한, $T(X)$가 $X$와 일대일 대응이 아니라면, 일반적으로 $\sigma(T(X))\subset\sigma(X)$ 이 성립하므로 통계량은 random element의 $\sigma-$field 를 축소시키는 역할을 한다. 

## Sufficiency

미지의 확률분포 $P\in\mathcal{P}$ 으로부터의 random sample $X$와 이에 대한 통계량 $T(X)$가 주어졌다고 하자. 이때 통계량 $T(X)$가 $\mathcal{P}$에 대한 **충분통계량**(sufficient statistic)이라는 것은 $T$가 주어졌을 때 $X$의 조건부 분포가 알려져 있음(known)을 의미한다. (i.e. does not depend on $P$ or $\theta$)

일반적으로 충분통계량은 직접적으로 구하기보다는 아래의 분해정리를 이용한다.

### Factorization Theorem

$X\sim\mathcal{P}_{\theta}\in\mathcal{P}$, $T(X)$가 $\theta$의 충분통계량인 것은 아래를 만족하는 음이 아닌 함수 $g,h$ 가 존재한다는 것과 동치이다.

$$

p_{\theta}(x)=g(T(X),\theta)h(X)\;\; \forall x\in\mathcal{X},\forall\theta\in\Theta

$$

그런데, 충분통계량은 유일하게 존재하지 않음을 간단하게 확인할 수 있다. 극단적으로, 통계량 $T(X)$ 를 다음과 같이 잡아버리면

$$

T(X) = (X_{1},\ldots,X_{n})

$$

모든 random sample의 값이 주어졌으므로, 통계량이 주어졌을 때 random sample의 조건부 확률분포는

$$

P(\mathbf{X}\vert T=t) = P(X_1=t_1,\ldots,X_{n}=t_{n})

$$

처럼 실수의 확률값이 되어 population 혹은 모수에 의존하지 않게 된다. 즉, random sample 자기 자신은 충분통계량이 되는 것이다.
그렇다면 충분통계량의 개수가 수없이 많아지므로, 이들 중 가장 좋은 충분통계량을 선택해야 할 필요성이 제기된다. 이때 주어진 샘플의 정보를 유지하며 축소시키는 것이 관건인데, 이 관점으로 다음과 같이 최소충분통계량을 선택할 수 있다.

### Minimal Sufficiency
Random sample $X\sim P_{\theta},\theta\in\Theta$에 대해 통계량 $T(X)$가 다음 두 조건을 만족하면 이를 $\theta$에 대한 최소충분통계량(**minimal sufficient statistic**)이라고 정의한다.

> 1. $T(X)$가 $\theta$에 대한 충분통계량이다.
> 2. 모든 충분통계량 $S(X)$에 대해
> 
> $$ T(X)=r(S(X))\;\;\text{a.s.}\;\;\forall\theta$$
> 
이때 minimal sufficiency와 관련하여 다음 정리가 성립한다.

> Suppose that $\mathcal{P}$ contains p.d.f.'s $f_{P}$ w.r.t. a $\sigma$-finite measure and that there exists a sufficient statistic $T(X)$ such that, for any possible values $x,y\in X$ 
> 
> $$f_{P}(x)=f_{P}(y)\phi(x,y)\;\forall P \Rightarrow T(x)=T(y)$$
> 
> Then $T(X)$ is minimal sufficient for $P\in\mathcal{P}$


# References
- Mathematical Statistics, Jun Shao.
- Mathematical Statistics, Bickel and Doksum.
{% endraw %}