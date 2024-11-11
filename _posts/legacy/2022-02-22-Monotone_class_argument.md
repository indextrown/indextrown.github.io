---
title: "Monotone class argument"
tags:
- Probability Theory
- Measure Theory
category: Probability Theory
use_math: true
---
{% raw %}
## Monotone Class Argument

Dynkin's $\pi-\lambda$ system이라고도 불리는 체계는 실변수함수론에서 다양한 정리들을 증명하거나 할 때 유용하게 사용된다. 또한, 확률론에서도 사건이나 random event의 독립성을 확인할 때 역시 이용된다. 우선 $\pi$ system, $\lambda$ system이 무엇인지 살펴보고, 간단한 예시를 통해 이들이 어떻게 이용되는지 알아보도록 하자.

### 정의

1. $\pi$-system : 집합 $X$의 부분집합들의 모임 $\mathcal{C}$에 대해 
   $$
   A,B\in\mathcal{C} \Rightarrow A\cap B\in \mathcal{C}
   $$
   가 성립할 때 $\mathcal{C}$를 $\pi$-system 이라고 정의한다.

   

2. $\lambda$-system : 집합 $X$의 부분집합들의 모임 $\mathcal{D}$에 대해

> 1. $X\in\mathcal{D}$
>
> 2. $A\in\mathcal{D}\Rightarrow A^c\in\mathcal{D}$
>
> 3. $\{A_n:n\in\mathbb{N}\}\subset\mathcal{D}$​ 이 **mutually disjoint** 일 때
>    $$
>    \bigcup_{n\in\mathbb{N}}A_n\in\mathcal{D}
>    $$
>    가 성립한다.

위와 같이 각각 $\pi$ system, $\lambda$ system을 정의한다. 이때 $\lambda$ system과 $\sigma$-algebra는 유사한 형태를 가지고 있는데([정의](https://ddangchani.github.io/mathematics/실해석학2) 참고), 3번의 mutually disjoint union으로부터의 닫힘 조건만이 다르다는 것을 알 수 있다. 즉, $\sigma-$algebra는 $\pi-$system이면서 동시에 $\lambda$-system이기도 하다. 이 정의를 바탕으로, 다음과 같이 Dynkin's THM이 성립한다.

### Dynkin's $\pi-\lambda$ Theorem

> $X$에서의 $\pi$-system $\mathcal{C}$ 와 $\lambda-$system $\mathcal{D}$ 를 생각하자. 이때 $\mathcal{C\subset D}$ 가 성립하면 $\sigma(\mathcal{C})\subset\mathcal{D}$ 이다.

### Separating

> Measurable Space $(Y,\mathcal{Y})$에서의 $\pi$-system $\mathcal{C}$ 가 $\sigma(\mathcal{C})=\mathcal{Y}$ 를 만족한다면 $\mathcal{C}$ 를 $\mathcal{Y}$의 **separating class** 라고 정의한다.

#### Example

$\mathcal{F}=\{(a,b):a,b\in\mathbb{R}, a<b\}$ 는 Measurable Space $(\mathbb{R},\mathcal{B}(\mathbb{R}))$ 의 separating class 이다. (여기서 $\mathcal{B(\mathbb{R})}$은 $\mathbb{R}$의 Borel-$\sigma$-algebra이다.)

> 우선, $\mathcal{F}$ 에 대해 두 열린구간의 교집합 역시 $\mathcal{F}$의 원소이므로 이는 $\mathbb{R}$에서의 $\pi-$system임을 알 수 있다. 
>
> 또한, 각 열린구간 $(a,b)$ 는 실수집합의 Borel Set 이므로 $\mathcal{F}$를 포함하는 $\sigma$-algebra를 구성하면 이는 $\mathbb{R}$의 $\sigma$-algebra이기도 하다. 추가적으로 $a=-\infty$ 인 경우나 $b=\infty$ 인 경우 역시 $\sigma$-algebra 를 구성한다.

### Measurability of function

앞서 [Lebesgue measurable function](https://ddangchani.github.io/mathematics/실해석학5)을 정의할 때 실함수들의 치역이 가측인지를 기반으로 가측함수를 정의했었다. 여기서는 보다 일반적으로 함수의 measurability를 정의하고 르벡가측함수의 정의와 동치가 됨을 앞선 pi-lambda system 논의를 이용해 보여보도록 하자.

#### 가측함수

> 가측공간 $(X,\mathcal{X}),(Y,\mathcal{Y})$ 에 대해 함수 $f:X\to Y$ 가 주어진다고 하자. 이때 임의의 $A\in\mathcal{Y}$ 에 대해 $f^{-1}(A)\in\mathcal{X}$  가 성립하면 함수 $f$를 $\mathcal{X/Y}$-measurable 하다고 정의한다.

이때 임의의 $A\in\mathcal{Y}$ 에 대해 $f^{-1}(A)\in\mathcal{X}$ 이 성립한다는 것은 $f^{-1}(\mathcal{Y})\subset\mathcal{X}$ 과 동치이므로 이를 이용해도 된다. 우선 다음 보조정리를 살펴보자.

#### Lemma (Induced $\sigma$-algebra)

가측공간 $(X,\mathcal{X}),(Y,\mathcal{Y})$ 에 대해 주어진 사상 $f:X\to Y$ 에서

$$

\{B\subset Y:f^{-1}(B)\in \mathcal{X}\}

$$

으로 정의된 모임은 $Y$의 $\sigma$-algebra이다.

> 증명. 역상<sup>inverse image</sup>에 대해 다음의 기본적인 집합 연산들
> 
> $$
> 
> f^{-1}(B^c)=(f^{-1}(B))^c, f^{-1}(\bigcup_k B_k)=\bigcup_kf^{-1}(B_k), f^{-1}(\bigcap_kB_k)=\bigcap_kf^{-1}(B_k)
> 
> $$
> 
> 이 성립하므로, 이를 이용해 위 집합이 $\sigma$-algebra 임을 보일 수 있다.

#### $\mathcal{X/Y}$-measurable과 동치인 것들

만일 $\mathcal{Y}$의 separating class $\mathcal{C}$가 존재한다고 하자. 즉, $\sigma(\mathcal{C})=\mathcal{Y}$ 를 만족한다. 이때 $f^{-1}(\mathcal{C})=\{f^{-1}(B):B\in\mathcal{C}\}$ 이므로 $f^{-1}(\mathcal{C})\subset f^{-1}(\mathcal{Y})$ 가 성립한다. 즉, $f$가 measurable이면 $f^{-1}(\mathcal{C})\subset \mathcal{X}$ 이다. 역을 살펴보면 우선 Lemma의 집합은 $Y$의 $\sigma$-algebra 이므로 $\mathcal{C}\subset\{B\subset Y:f^{-1}(B)\in \mathcal{X}\} $ 이 성립한다. 즉, 임의의 $A\in\mathcal{C}(\subset\mathcal{Y})$ 에 대해 $f^{-1}(A)\in\mathcal{X}$ 가 성립하므로 이는 가측함수의 정의와 동치이다. 따라서 함수의 measurability는 separating class로도 보일 수 있다.

만약 위에서 $Y$가 위상공간이고 Borel-$\sigma$-algebra $\mathcal{B}(Y)$ 가 존재한다면 $Y$의 토폴로지가 $\mathcal{B}(Y)$의 separating class이므로(보렐 시그마 대수의 정의에 의해) 토폴로지의 원소, 즉 임의의 열린 집합 $V$들에 대해 $f^{-1}(V)\in\mathcal{X}$ 이 성립하는지를 보면 될 것이다.

#### [Lebesgue measurable function](https://ddangchani.github.io/mathematics/실해석학5) 의 정의 도출

(Real-valued) Lebesgue measurable funciton $f:X\to\mathbb{R}$ 의 경우 임의의 실수 $c\in\mathbb{R}$ 에 대해 집합 $\{x\in X:f(x)\leq c\}$ 이 가측집합이면 $f$를 가측함수라고 정의했었다. 이 정의를 앞선 Monotone class argument를 이용해 보여보도록 하자.

앞선 [예시](#Example)에서 구간들의 모임 $\mathcal{C}=\{(-\infty,c]:c\in\mathbb{R} \}$이 (부등호에 관계없이) 가측공간 $(\mathbb{R},\mathcal{B}(\mathbb{R} ))$의 separating class임을 알게 되었다. 따라서 앞서 살펴본 가측함수의 동치조건으로부터 separating class $\mathcal{C}$의 역상이 $\mathcal{X}$의 부분집합임을 보이는 것으로 함수의 가측여부를 보일 수 있고, 이는 임의의 $c\in\mathbb{R}$에 대해 $f^{-1}(-\infty,c]\in\mathcal{X}$ 임을 보이는 것과 동치이다.



# References

- Foundations of Modern Probability, O.Kallenberg
- Real and Complex Analysis, W.Rudin

{% endraw %}