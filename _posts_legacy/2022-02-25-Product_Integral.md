---
title: "Product Integral"
tags:
- Mathematics
- Measure Theory
- Real Analysis
category: Mathematics
use_math: true
---
{% raw %}
# Product Integral

이번 글에서는 르벡적분에 대한 다중적분을 정의해보도록 할 것이다. 다중적분을 하기 위해서는 곱함수가 정의되는 product space와, product space에서 측도로 사용될 수 있는 product meausre이 필요할 것이다.

## Product Space

두 위상공간 $X,Y$에 대한 cartesian product $X\times Y$ 는 다음과 같이 정의된다.

$$

X\times Y = \{(x,y):x\in X,y\in Y\}

$$

위상공간의 열 $\{X_i : i\in I\}$​ 에 대한 cartesian product는 

$$

\times_{i\in I}X_i = \{(x_i:i\in I):x_i\in X_i\}

$$

으로 정의된다. 이때 index set $I$는 countable set일 때뿐만 아니라 uncountable set일 때도 정의된다.

### Product $\sigma$-algebra

가측공간의 열 $\{(X_i,\mathcal{X_i}):i\in I\}$ 이 주어진다고 하자.  $X_i$ 들의 곱공간은 위처럼 cartesian product를 이용해 정의하면 되므로 $\sigma$-algebra들의 곱을 정의해보도록 하자.

곱공간 $\times_{i\in I}X_i$에서 정의되는 product $\sigma$-algebra 는 다음과 같이 정의된다.


$$

\begin{aligned}
\bigotimes_{i\in I}\mathcal{X_i}&=\sigma\bigg(\bigg\{A_i\times\times_{i\neq j\in I}X_j:i\in I,A_i\in\mathcal{X_i}\bigg\}\bigg)\\
&=\sigma\bigg(\bigg\{A_{i1}\times\cdots\times A_{in}\times\times_{i_1,\ldots,i_n\neq j\in I}X_j : n\in\mathbb{N},i_1,\ldots,i_n\in I, A_{it}\in\mathcal{X_i}\forall t=1,\ldots,n\bigg\}\bigg)
\end{aligned}

$$

자세히 보아도 이해가 쉽지 않다😅. 형태를 살펴보면, 어떤 집합이 생성하는 시그마 대수로 정의되는데, 위 식과 아래 식에서 사용되는 집합이 다르다. 우선 첫번째 집합을 살펴보자. 우선 $A_i\times\times_{i\neq j\in I}X_j$ 꼴로 주어지는 집합들을 cylinder set이라고 하는데, 하나의 축 $i$에 대한 $\sigma$-algebra를 기준으로 나머지 축들은 모두 포함한다. 이를 한개의 축 $i$에 대해 정의된 cylinder set이라는 의미에서 one-dimensional cylinder set이라고도 한다.

반면 아래 식을 보면 이는 $n$차원 cylinder set을 이용해 $\sigma$-field를 생성한다. 즉, 위 정의는 cylinder sets의 차원에 관계없이 같은 product $\sigma$-algebra 가 생성된다는 것이다. $i$번째 one-dimensional cylinder set을 $\mathcal{A_i}=A_i\times\times_{i\neq j\in I}X_j$ 라고 정의하자. 이때 one-dimensional cylinder sets의 모임 $\{\mathcal{A_1,A_2,\ldots,A_i,\ldots}\}$ 를 생각하면 이는 $\pi$-system이 아닌데, 임의의  $\mathcal{A_i,A_j}$ 의 교집합을 생각하면 이는 두 개의 축 $i,j$에 대한 $\mathcal{X_i,X_j}$을 포함해야 하므로 이는 two-dimensional cylinder set이 된다.

따라서 cartesian product space $\times_i X_i$에 대한 $\sigma$-algebra를 정의하기 위해서는 사실상 모든 축($i\in I$) 에 대한 one-dimensional cylinder sets들로부터 생성해야 할 것이다. 그러므로 임의의 유한차원 cylinder set으로부터 생성한 $\sigma$-algebra는 곱공간의 product $\sigma$-algebra가 된다.

#### Product Borel $\sigma$-algebra

Separable metric spaces(**Polish space**) $S_1,S_2,\ldots$​ 가 주어진다고 하자. 이때 

$$

\mathcal{B}(S_1\times S_2\times\ldots) = \mathcal{B}(S_1)\otimes\mathcal{B}(S_2)\otimes\ldots

$$

이 성립한다. 특히 $\mathcal{B}(\mathbb{R}^d)=\mathcal{B}^d$ 가 되는데, 이는 d차원 유클리드공간의 Borel-$\sigma$-algebra가 $d$차원 박스 $I_1\times\cdots\times I_d$ 로 구성됨을 의미한다.

### Product Measure Space

측도공간의 열 $(X_i,\mathcal{X_i},\mu_i)$ 에 대해 product space와 product $\sigma$-algebra 를 각각 $X=\times_iX_i$, $\mathcal{X}=\bigotimes_i\mathcal{X_i}$ 로 정의하자. 그러면 각 one-dimensional cylinder set들에 대해 다음과 같이 정의되는 측도 $\mu$가 $(X,\mathcal{X})$ 에 **유일하게 존재**하며, 이를 product measure<sup>곱측도</sup>라고 한다.

$$

\mu\big(A_i\times\times_{i\neq j\in I} X_j\big) = \mu(A_i),\quad \forall i\in I, A_i\in\mathcal{X}

$$

#### Tonelli, Fubini's THM

$\sigma$-finite한 측도 공간 $(S,\mathcal{S},\mu)$ 와 $(T,\mathcal{T},\nu)$ 에 대해 다음과 같은 $(S\times T,\mathcal{S\otimes T})$ 에서의 **product measure** 

$$

(\mu\otimes\nu)(B\times C)=\mu B\cdot\nu C,\quad B\in\mathcal{S},C\in\mathcal{T}

$$

이 주어진다. 여기서  $(S,\mathcal{S},\mu)$가 $\sigma$-**finite** 하다는 말은 $E_1\cup E_2\cup\ldots=S$ 인 $E_1,E_2,\ldots\in\mathcal{S}$ 가 존재하여 각 $E_i$의 측도가 유한하다는 것을 의미한다. 이때 다음과 같은 다중적분이 성립한다.

1. $f:S\times T\to[0,+\infty)$ 인 경우
   $$
   \int_{X\times Y}fd(\mu\otimes\nu)=\int_Y\int_Xfd\mu d\nu=\int_X\int_Yfd\nu d\mu
   $$

2. $f\in L^1(\mu\otimes\nu)$ 인 경우
   $$
   \int_{X\times Y}fd(\mu\otimes\nu)=\int_Y\int_Xfd\mu d\nu=\int_X\int_Yfd\nu d\mu
   $$
   

> 증명. 



- # References

  - Foundations of Modern Probability, O.Kallenberg
  - Real and Complex Analysis, W.Rudin
{% endraw %}