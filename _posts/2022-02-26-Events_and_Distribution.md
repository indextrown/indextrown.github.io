---
title: "Events and Distribution"
tags:
- Probability Theory
- Measure Theory
category: Probability Theory
use_math: true
---
{% raw %}
## Random Elements

저번에 다룬 확률측도 공간(Probability Space, 이하 *확률공간*) $(\Omega,\mathcal{F},P)$ 를 바탕으로 확률론의 대상이 되는 random elements 대한 내용을 다루도록 할 것이다. (확률측도의 $\sigma$-algebra에 대해서도 인식의 편의(🤔)를 위해 $\mathcal{M}$ 대신 $\mathcal{F}$을 사용하도록 하겠다.)

### Tail Events

특별히 확률공간의 $\sigma$-algebra $\mathcal{F}$ 의 원소들을 사건<sup>event</sup>이라고 칭하고, 각각의 사건에 대한 확률측도 값 $P(A)$ 를 확률<sup>probability</sup>이라고 정의한다. 또한 사건 $A$가 True라는 것은 **확률 실험**<sup>probability experiment</sup>이 랜덤하게 생성하는 원소 $\omega\in\Omega$ 가 $\omega\in A$ 를 만족함을 의미한다. (반대로 $\omega\notin A$ 이면 $A$가 False 라고 정의한다.) 만일 확률공간에 사건열 $A_1,A_2,\ldots\in\mathcal{F}$ 들이 주어진다고 하자. 우선 사건열에 대해 다음 두 가지 경우를 정의하도록 하겠다.

1. **Infinitely Often**(i.o) : $A_n$이 무한한 index set $n\in\{1,2,3,\ldots\}$ 에서 True임을 의미한다. 이때 다음과 같이 무한한 사건열을 True로 하는 outcome $\omega\in\Omega$ 들의 집합 $\{A_n \;\text{i.o}\}$ 은 다음과 같이 표현할 수 있다. 

$$

\{A_n \;\text{i.o}\}=\limsup_nA_n=\bigcap_n\bigcup_{k\geq n}A_k=\{\omega\in\Omega:\sum_nI_{A_n}(\omega)=\infty\}

$$

2. **All but finitely many / Ultimately**(a.b.f or ult.) : $A_n$이 유한한 index set에서 True임을 의미한다.

$$

\{A_n \;\text{a.b.f}\}=\liminf_nA_n=\bigcup_n\bigcap_{k\geq n}A_k=\{\omega\in\Omega:\sum_nI_{A_n^c}(\omega)<\infty\}

$$



또한, 두 정의에서 Indicator function을 취하면

$$

I_{\{A_n\;\text{i.o}\}} = \limsup_{n\to\infty}I_{A_n}

$$

$$

I_{\{A_n\;\text{a.b.f}\}} = \liminf_{n\to\infty}I_{A_n}

$$

으로 표현된다. 이때 [Fatou's Lemma](https://ddangchani.github.io/mathematics/실해석학7)을 이용하면

$$

P\{A_n\; \text{i.o}\}\geq\limsup_nP(A_n),\;\;P\{A_n\; \text{a.b.f}\}\leq\liminf_nP(A_n)

$$

임을 알 수 있다. 여기서 확률측도의 연속성과 가산가법성을 이용하면 이전에 살펴보았던 **Borel-Canteli Lemma**를 얻을 수 있다.

#### Borel-Canteli Lemma

사건열 $A_1,A_2,\ldots\in\mathcal{F}$에 대해 $\sum_nP(A_n)<\infty$ 이면 $P\{A_n\;\;\text{i.o}\}=0$ 이다.

> pf. 확률측도의 연속성과 가산가법성에 의해
> 
> $$
> 
> P\{A_n\;\;\text{i.o}\}=\lim_nP(\bigcup_{k\geq n }A_k)\leq\lim_n\sum_{k\geq n} P(A_k)
> 
> $$
> 
> 인데, 이때 $\sum_nP(A_n)<\infty$ 이면 부등호 우변이 $0$이 된다.

### Distribution

#### Random Element

Probability space $(\Omega,\mathcal{F},P)$의 Sample space $\Omega$ 에서 어떤 가측공간 $(S,\mathcal{S})$ 로 정의된 measurable한 사상 $\xi:\Omega\to S$을 $S$의  **random element**라고 정의한다. 또한 $\mathcal{S}$의 원소 $B\in\mathcal{S}$ 을 생각하면 이에 대해 $\{\xi\in B\}=\xi^{-1}(B)\in\mathcal{F}$ 을 대응시킬 수 있다. 그러면

$$

P\{\xi\in B\}=P(\xi^{-1}(B))=(P\circ\xi^{-1})(B),\quad B\in \mathcal{S}

$$

으로 정의되는 새로운 set function $P\circ\xi^{-1}$을 정의할 수 있고, 이는 $S$에서 정의되는 새로운 확률측도가 되고, 이를 $\xi$의 (확률)**분포**<sup>distribution</sup>라고 부른다.

이렇게 정의되는 random element는 $S$가 어떤 공간이냐에 따라 다른 명칭으로 불린다. 대표적으로 $S=\mathbb{R}$인 경우 random variable<sup>확률변수</sup>가 되며, $S=\mathbb{R}^d$인 경우 random vector가 된다. 만일 $S$가 함수공간<sup>function space</sup> 인 경우는 이를 stochastic(*or random*) process<sup>확률과정</sup>이 된다. 또한, 만일 두 random elements $\xi,\eta$가 $(S,\mathcal{S})$에서 같은 distribution을 갖는다면 이를 $\xi\stackrel{d}{=}\eta$ 로 표기한다.



Measurable space $(S,\mathcal{S})$ 와 $A\subset S$ 에 대해 $(A,A\cap\mathcal{S})$ 도 measurable space가 된다. 그러면 역으로, $(A,A\cap\mathcal{S})$ 에서의 random element는 $S$에서의 random element로 여겨질 수 있다.

Measurable space $(S,\mathcal{S})$ 와 index set $T$가 주어질 때 $S^T$를 함수 $f:T\to S$ 들의 모임<sup>class</sup>으로 정의하자. 이때 $S^T$에서의 $\sigma$-field $\mathcal{S}^T$ 를 정의하는데, 이는 $\pi_t:S^T\to S,\;\;t\in T$ , $\pi_tf=f(t)$ 로 정의되는 모든 **evaluation map** $\pi_i$들로부터 생성된다. 만일 어떤 $X:\Omega\to U\subset S^T$ 가 주어지고 이때 $X_t=\pi_t\circ X$ 로 정의하면 이는 $\Omega$에서 $S$로의 사상이다. 즉, $X$는 $t\in T,\omega\in\Omega$ 에 대해 $T\times\Omega\to S$ 의 사상으로 볼 수 있다. 이와 관련하여 다음 보조정리가 성립한다.

##### Lemma 2.1

Measurable space $(S,\mathcal{S})$ 와 index set $T$, $U\subset S^T$ 를 고정하자. 이때 사상 $X_t:\Omega\to S$ 가 모든 $t\in T$ 에 대해 $\mathcal{S}$-measurable 하면, 사상 $X:\Omega\to U$ 는 $U\cap \mathcal{S}^T$-measurable 하다.

이때 위 성질을 만족하는 사상 $X$를 $U$에서 path를 갖는 $T$에서의 $S$-valued random process라고 정의한다. 또한, Lemma에  의해 $X$를 **state space** $S$에서의 random elements $X_t$ 들의 모임으로 볼 수 있다.



# References

- Foundations of Modern Probability, O.Kallenberg


{% endraw %}