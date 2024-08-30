---
title: Confounder Adjustment
tags:
- Causal Inference
- ATE
- Confounder
category: ""
use_math: true
header: 
  teaser: /assets/img/screenshot_confounder_adjustment.png
---

# Confounder Adjustment

인과추론에서 실제로 인과관계를 규명해내는 가장 기본적인 방법은 [Average Treatment Effect](https://ddangchani.github.io/Average-Treatment-Effect)를 추정하는 것이다. 여기서는 아래와 같은 기본적인 SCM 예시를 바탕으로 살펴보도록 하겠다. 

![](/assets/img/screenshot_confounder_adjustment.png)

우선, 위 SCM에서 처치변수 $A$, 결과변수 $Y$, 공변량 $X$가 모두 관측가능하고 joint distribution $P$는 알려져있지 않다고 가정하자. 이때 우리가 측정해야 하는 평균처치효과는 다음과 같다.

$$

\mathrm{ATE} = \mathrm{E}[Y\vert do(A=1)]-\mathrm{E}[Y\vert do(A=0)]


$$

이를 측정하기 위해서는, ATE를 statistical estimand, 즉 확률분포 $P$의 모수로 식별가능하게끔 충분조건을 주어야 한다. 그런데 이는 confounder $X$의 존재로 인해 단순하지만은 않다. 그런데, 만일 모든 confounder가 관측된다면, 즉 관측되지 못한 confounder가 존재하지 않는다면 다음과 같은 정리로 인해 평균처치효과에 대한 statistical estimand를 유도할 수 있다.

## Theorem for no unobserved confounders

$A,Y,X\sim P$ 이 관측된다고 하자. 이때, 다음 두 가지를 가정하자.
1. $A,Y,X$ 가 위 예시와 같은 인과구조를 가진다.
2. (중첩<sup>overlap</sup>) 모든 $x$에 대해 $0<P(A=1\vert X=x)<1$ 이 성립한다. 즉, 처치가 항상 이루어지거나 전혀 이루어지지 않는 처치대상은 존재하지 않는다.

그러면, 평균처치효과는 $\mathrm{ATE}=\tau$로 식별된다. 이때 $\tau$는 다음으로부터 정의된다.


$$

\tau=\mathrm{E}[\mathrm{E}[Y\vert A=1,X]] - \mathrm{E}[\mathrm{E}[Y\vert A=0,X]]


$$

### 증명

이중기댓값정리와 불변성을 이용하면 다음과 같이 보일 수 있다.


$$

\begin{align}
\mathrm{ATE} &= \mathrm{E}[Y\vert do(A=1)]-\mathrm{E}[Y\vert do(A=0)]\\
&= \mathrm{E}[\mathrm{E}[Y\vert do(A=1),X]]-\mathrm{E}[\mathrm{E}[Y\vert do(A=0),X]]\\
&= \mathrm{E}[\mathrm{E}[Y\vert A=1,X]] - \mathrm{E}[\mathrm{E}[Y\vert A=0,X]]
\end{align}


$$

세번째 등식은 불변성으로부터 비롯되는데, 이는 intervention(*do-calculus*)의 정의로부터 성립한다. 즉, $do(A=1)$ 과 같은 intervention이 이루어지면 $A\leftarrow f_{A}(X,N_{A})$ 가 $A\leftarrow 1$ 로 바뀌며 $X\to A$ 변이 사라지는 것과 같은 효과를 낸다. 따라서, $A=1, X$가 주어진 경우와 $do(A=1), X$가 주어진 경우 모두 결과변수의 조건부분포가 같게 되므로(다른 confounder가 관측되지 않고 삼각형 형태의 SCM이 유일한 구조이기 때문) 세번째 등식이 성립한다.

## Overlap
인과모형의 식별가능성을 위한 가정들 이외에도, 처치가 어떻게 이루어지는지에 대한 충분한 random variation이 존재해야 한다. 예를 들어 어떤 처치효과를 성별에 따라 적용한다면(남성에 대해 투약, 여성에게는 투약 X), 투약 여부의 처치효과만을 파악할 수 없게 된다. 따라서, randomized control test과 같이 처치가 이루어지는 확률이 0 또는 1이 되어서는 안된다. 이를 **overlap**(중첩) 이라고 한다.

> Overlap : 모든 $x$에 대해 $0<P(A=1\vert x)<1$  
> Strict overlap : 모든 $x$와 어떤 $\epsilon>0$에 대해 
> 
> $$
> \epsilon<P(A=1\vert x)<1-\epsilon
> $$



# References
- K. Murphy, Probabilistic Machine Learning-Advanced Topics