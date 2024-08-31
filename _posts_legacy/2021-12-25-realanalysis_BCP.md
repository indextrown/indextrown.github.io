---
title: "[실해석학] Banach Fixed Point Theorem"
tags:
- Mathematics
- Real Analysis
- Metric spaces
category: Mathematics
use_math: true
---
{% raw %}

## 바나흐 고정점 정리
바나흐 고정점 정리(혹은 축약 사상 정리)는 축약사상에 대해 고정점이 하나만 존재한다는 정리이다. 우선 이를 알기 위해 축약 사상과 고정점의 개념에 대해 다루어보자.   

**Def** 거리공간 X에서의 점 $x\in X$ 와 사상 $T:X\to X$ 에 대해 $T(x)=x$ 이 성립하면 점 $x$를 X의 고정점이라고 한다.   

**Def** 거리공간 $(X,\rho)$ 에서의 사상 $T$에 대해 다음이 성립하는 $c<1$ 이 존재한다면 이러한 립쉬츠 사상<sup>Lipschitz mapping</sup>을 **축약사상**<sup>contradiction</sup> 이라고 한다.   

$$

\rho(T(u),T(v))\leq c\cdot\rho(u,v)\quad \forall u,v\in X

$$

**Banach Contradiction Principle**   
완비거리공간 X와 축약사상 $T:X\to X$ 에 대해, T의 고정점은 **단 하나**만 존재한다.    

<증명>   
축약사상의 정의를 만족하는 $0\leq c<1$ 을 잡고, X의 원소 $x_0$을 택하자. 이를 바탕으로 수열을 구성하는데, $x_1 = T(x_0)$ 으로 시작하여 $x_k=T(x_{k-1})$ 의 방식으로 구성하자. 그러면 $T$의 상(image)가 X의 부분집합이므로 수열 {$x_n$} 은 X에 속한다. 이때, 축약사상 성질에 의해 다음이 성립한다.   

$$

\begin{aligned}
 \rho(x_{k+1},x_k) = \rho(T(x_k),T(x_{k-1})) &\leq c \rho(x_k,x_{k-1}) \\
 &\vdots \\
 &\leq c^k\rho(T(x_0),x_0)   
\end{aligned}

$$   

따라서, 어떤 자연수 $m>k$ 를 잡으면 삼각부등식으로부터   

$$

\begin{aligned}
\rho(x_m,x_k) &\leq \rho(x_m,x_{m-1})+\cdots +\rho(x_{k+1},x_k) \\
&\leq[c^{m-1}+c^{m-2}+\cdots+c^k]\rho(T(x_0),x_0)\\
&=c^k\cdot \frac{1-c^{m-k}}{1-c}\cdot \rho(T(x_0),x_0) \\
&\leq \frac{c^k}{1-c}\cdot\rho(T(x_0),x_0)
\end{aligned}

$$   

여기서 $\lim_k c^k =0$ 이므로 수열 {$x_n$}은 코시수열임을 알 수 있다. X가 완비공간이므로, 코시수열의 수렴값 역시 X에 포함된다. 이 점을 $x\in X$ 라고 하자. 또한, 립쉬츠 조건을 만족하는 사상 T는 연속이기도 하므로,    

$$

T(x)=\lim_k T(x_k) = \lim_k x_{k+1} = x

$$   

가 성립한다. 따라서 고정점이 한 개 이상임은 알 수 있다. 만약 고정점이 두개, 즉 $u,v\in X$ 가 존재한다고 가정하면   

$$
0\leq \rho(u,v) = \rho(T(u),T(v))\leq c\rho(u,v)
$$    

인데, c는 1보다 작으므로 $\rho(u,v)=0$ 이어야 한다. 따라서, 오직 한개의 고정점이 존재한다.
 

## References
 - Real Analysis 4th edition, Royden

{% endraw %}