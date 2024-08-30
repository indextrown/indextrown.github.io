---
title: "Lebesgue Integration with General measure"
tags:
- Mathematics
- Real Analysis
- Measure Theory
category: Mathematics
use_math: true
---
{% raw %}
# Lebesgue Integration with General Measure

이전 글들에서 르벡 측도를 이용해 정의한 르벡적분과 앞으로 살펴볼 일반측도 $\mu$를 이용해 정의하는 르벡적분은 크게 다르지 않다. 르벡측도를 이용한 르벡적분은 $\mu=m$ 의 특수한 경우이지만 대부분의 중요한 정리들은 그대로 성립한다.

## 르벡적분의 정의

이전에 살펴본 [단순함수근사](https://ddangchani.github.io/mathematics/실해석학5)로부터 양함수 $f:X\to[0,\infty)$ 로 수렴하는 단순함수 $S:X\to[0,\infty)$ 의 열이 존재하므로 르벡적분을 다음과 같이 정의할 수 있다.

> Measure space $(X,\mathcal{X},\mu)$ 에서 정의되는 단순함수 $s=\sum_i^n c_i I_{A_i}$ 에 대한 르벡적분은
> 
> $$
> 
> \int_Esd\mu=\sum_{i=1}^n c_i\mu(A_i\cap E)
> 
> $$
> 
> 으로 정의되며(단, $E\in\mathcal{X}$ ),
>
> 함수 $f$​에 대한 르벡적분은
> 
> $$
> 
> \int_Efd\mu = \sup_{0\leq s\leq f}\int_E sd\mu
> 
> $$
> 
> 으로 정의된다.

*✅르벡측도 $m$을 이용해 정의한 르벡적분과 동일한 형태이다.*

이때 측도가 다양한 형태로 주어질 수 있으므로, 다양한 측도에 대해 생각해보자.

1. 만약 counting measure $c$ 가 주어지는 측도공간 $(X,2^X,c)$ 에서 $E\subset X$​를 잡으면 르벡적분은
   $$
   \int_Efdc=\sum_{x\in E} f(x)
   $$
   로 주어진다. 이때 counting measure은 $X$의 모든 부분집합들에 대해 동일한 mass를 주는 측도이므로, counting measure space에서 정의되는 함수는 수열<sup>series</sup>이고, 르벡적분은 수열의 합으로 주어진다.

2. 확률공간 $(X,\mathcal{X},\mathbb{P})$ 에서의 함수는 distribution function이므로(추은는 확률변수의 기댓값으로 주어진다.

또한, 일반측도로 주어진 르벡적분 역시 적분의 Linearity를 만족한다.

양함수가 아닌 함수 $f$에 대해서는 르벡적분가능성(initegrability)을 $L^1(\mu)$ 에 속하는 것으로 정의한다. 즉, 

$$

\int_X\vert f\vert d\mu<\infty

$$

인 경우 $f$가 적분가능하다고 하며 ($f\in L^1(\mu)$)적분값은

$$

\int_Efd\mu=\int_Ef^+d\mu-\int_Ef^-d\mu

$$

로 정의한다(르벡측도에서 살펴본 것과 동일하다).

리만적분의 경우 측도공간 $(\mathbb{R},\mathcal{B}(\mathbb{R}),m)$ 에서 정의되는 르벡적분

$$

\int_a^bf(x)dx=\int_{[a,b]}fdm

$$

으로 정의된다.

## 르벡적분의 수렴정리

르벡측도를 이용해 살펴보았던 Fatou's lemma, MCT, LDCT 등 역시 general measure space에서도 성립한다. 여기서는 LDCT만 다시 살펴보도록 하자.

### LDCT<sup>르벡지배수렴정리</sup>

가측함수열 $\{f_n:n\in\mathbb{N}\}$ 에 대해 극한 $\lim_nf_n(x)$이 모든 점 $x\in X$에서 존재하고 이를 지배하는<sup>dominate</sup> 함수(**envelope** 라고 한다) $g\in L^1(\mu)$ 가 존재한다고 하자. 그러면 $f\in L^1(\mu)$이며 

$$

\lim_n\int_X\vert f_n-f\vert d\mu=0\tag{1}

$$

이 성립한다. 이때 $\vert \int f\vert \leq\int\vert f\vert $ 이므로 

$$

\lim_n\int_X f_nd\mu=\int_Xfd\mu\tag{2}

$$

도 성립한다.*(✅ 이때 1번 식이 2번보다 강력한 식임을 잊지말자! )*

간단한 예제를 보면

> $\forall f\in L^1(\mathbb{R})$ 에 대해
> 
> $$
> 
> \lim_{n\to\infty}\int_{-\infty}^\infty \cos(\frac{x}{n})f(x)dx=\int_\mathbb{R} f(x)dx
> 
> $$
> 
> 임이 성립함을 보여라.

위와 같은 문제에서 LDCT를 이용하기 위해서는이 적분함수의 $L^1$ envelope을 찾아내는 것이 필요하다. 위 문제에서는 $\vert \cos(x/n)f(x)\vert \leq \vert f(x)\vert $ 가 성립하고, $f$가 $L^1$ 공간의 원소이므로 LDCT를 사용해 쉽게 보일 수 있다.

## $L^p$공간에 대한 정리

엘피공간에 대해 살펴보았던 횔더/민코우스키 부등식 역시 그대로 성립하는 것을 보일 수 있다. 요약한다면 다음과 같다.

1. $L^p$ 공간은 벡터공간이다 : [민코우스키 부등식](https://ddangchani.github.io/mathematics/실해석학10)에 의해 벡터공간의 요건인 삼각부등식이 성립한다.

2. $L^p$ 공간은 완비공간이다 : [Riesz-Fischer](https://ddangchani.github.io/mathematics/실해석학11) 정리 참고

3. $L^p$ 공간은 Banach Space이다 : 
   $$
   \Vert f\Vert_p=\biggl(\int_X\vert f\vert ^pd\mu\biggr)^{1/p}
   $$
   으로 정의하고, $p=\infty$​ 인 경우는
   $$
   \Vert f\Vert_\infty = \inf\{\alpha\in\mathbb{R}:\mu(f^{-1}(\alpha,\infty ])=0\}
   $$
   으로 정의된다.

3. ($p=q=2$​ 인 경우) $L^2$​ 공간은 Hilbert Space이다. 즉, 다음과 같은 내적
   $$
   \langle f,g\rangle = \int_X f\cdot gd\mu
   $$
   이 정의된다.


{% endraw %}