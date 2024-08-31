---
title: "Absolute Continuity"
tags:
- Mathematics
- Real Analysis
- Measure Theory
category: Mathematics
use_math: true
---
{% raw %}
## Absolute Continuity

## 정의

measurable space $(X,\mathcal{X})$ 에서 두 측도 $\mu,\nu$ 가 정의되었다고 하자. 이때 임의의 $\mu$-null set이 $\nu$-null set이라면, 즉

$$

\mu(A)=0\Rightarrow\nu(A)=0

$$

이라면 $\nu$를 $\mu$에 대해 **absolutely continuous** 하다고 정의한다. 또한, 이를 기호로

$$

\nu\ll\mu

$$

로 표기한다. 다른 관점에서 $\mu$가 $\nu$를 dominating한다고 볼 수 있고, 이때 dominating 하는 측도 $\mu$를 **reference measure**라고 한다. 또한, 만일 $(X,\mathcal{X})$에서의 측도들의 모임 $\mathcal{P}$에 대해 임의의 $\mathcal{P}$의 원소(측도)가 $\mu$에 대해 absolutely continuous 하다면 $\mathcal{P}\ll\mu$ 라고 표기한다.

### 예시

측도공간 $(X,\mathcal{X},\mu)$ 에서 가측함수 $f,g\geq 0$ 이 주어진다고 할 때, set function $(f\cdot \mu):X\to\mathbb{R}^+$ 를 다음과 같이 정의하자.

$$

(f\cdot\mu)(A)=\int_A fd\mu,\quad A\in\mathcal{X}\tag{1}

$$

그러면 $(f\cdot\mu)$ 는 measure의 정의를 만족하며, $(f\cdot\mu)(A)=0$ 인 $A\in\mathcal{X}$에 대해 $\mu(A)=0$ 을 만족해야 하므로(르벡적분값이 0이므로) $\mu$가 $(f\cdot\mu)$를 dominate 한다. 또한, 만일 $(f\cdot\mu)=(g\cdot\mu)$ 인 상황이라면, $f=g$ 가 $[\mu]$-a.e 에서 성립해야 할 것이다.

## Radon-Nikodym THM

Measurable space $(X,\mathcal{X})$ 에서 $\sigma$-finite 한 두 측도 $\mu,\nu$ 가 정의된다고 하자. 이때 $\nu\ll\mu$ 일 **필요충분조건**은 $[\mu]$-a.e <sup>$\mu$에 대해 almost everywhere을 의미한다</sup>인 **유일**한 가측함수 $f\geq 0$ 이 $(X,\mathcal{X})$ 에 존재하여 $\nu=(f\cdot\mu)$ (식 1)를 만족하는 것이다. 또한 이를 만족하는 $f\geq0$을 $\mu$에 대한 $\nu$의 **Radon-Nikodym** derivate, 또는 $\mu$-density function 이라고 하며 $f=d\nu/d\mu$ 로 표기한다.

$\mu$-density function $f$가 유일함은 위의 예시로부터 자명하다($f=g$ at $[\mu]$-a.e.). 특히, $X=\mathbb{R}$ 이고 $\mu=m$, 즉 르벡측도공간이 주어질 때 $f=d\nu/dm$ 을 $\nu$의 **density function** 이라고 하며, 이는 확률론에서 다루는 내용의 근간을 이룬다.
{% endraw %}