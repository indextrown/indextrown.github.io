---
title: Spectral Analysis - Low-rank matrix denoising
tags:
- Spectral Analysis
- Matrix Denoising
- Mathematics
- Bernstein Inequality
category: 
use_math: true
---
{% raw %}
# Preliminary
## Matrix Bernstein Inequality
### Theorem
Independent random matrix sequence $$\{X_{i}\}_{1\leq i\leq m}, X_{i}\in\mathbb{R}^{n_{1}\times n_{2}}$$ 에 대해 다음을 가정하자.


$$

\begin{aligned}
\mathbb{P}(\Vert X_{i}-\mathbb{E}X_{i}\Vert\geq L)\leq q_{0}\\
\Vert\mathbb{E}X_{i}-\mathbb{E}X_{i}I(\Vert X_{i}\vert\Vert<L)\Vert\leq q_{1}
\end{aligned}


$$

여기서 $0\leq q_{0}\leq 1$, $q_{1}\geq 0$ 이다. 또한, 행렬에 대한 분산 통계량(matrix variance statistic) $v$를 다음과 같이 정의하자.

$$

v:= \max\bigg\{\bigg\Vert\sum_{i=1}^{m}\mathbb{E}\big[(X_{i}-\mathbb{E}X_{i})(X_{i}-\mathbb{E}X_{i})^{T}\big]\bigg\Vert, \\ \bigg\Vert\sum_{i=1}^{m}\mathbb{E}\big[(X_{i}-\mathbb{E}X_{i})^{T}(X_{i}-\mathbb{E}X_{i})\big]\bigg\Vert\bigg\}


$$

그러면 모든 $t\geq mq_{1}$ 에 대해 다음과 같은 부등식이 성립한다.

$$

\mathbb{P}\bigg(\bigg\Vert\sum_{i=1}^{m}(X_{i}-\mathbb{E}X_{i})\bigg\Vert\geq t\bigg)\leq (n_{1}+n_{2})\exp\bigg(\frac{-(t-mq_{1})^{2}/2}{v+L(t-mq_{1})/3}\bigg)+mq_{0}


$$

### Corollary
위 정리를 실제로 사용하기 위해 몇 가지 가정을 추가하여 다음과 같이 보다 user-friendly한 형태의 부등식을 얻을 수 있다. 우선 random matrix sequence에 다음과 같은 가정을 추가하자.


$$

\mathbb{E}X_{i}=\mathbf{0},\quad \Vert X_{i}\Vert\leq L,\quad \forall i


$$

그러면 $n=\max\{n_1,n_2\}$ 라고 둘 때 임의의 $a\geq 2$ 에 대해 다음이 성립한다.


$$

\mathbb{P}\bigg(\bigg\Vert\sum_{i=1}^{m}X_{i}\bigg\Vert\leq\sqrt{2av\log n}+\frac{2a}{3}L\log n\bigg)>1-2n^{-a+1}


$$

### Spectral Norm inequality
Bernstein inequality를 이용하면, 랜덤행렬 $\mathbf{X}=[X_{i,j}]$ 에서 각 원소들이 독립일 때 다음과 같은 정리가 성립한다는 것을 도출할 수 있다.

> 정리.
> 대칭 랜덤행렬 $\mathbf{X}=[X_{i,j}]\in\mathbb{R}^{n\times n}$이 다음 성질을 만족한다고 하자.
> 
> 
> $$
> 
> \mathbb{E}X_{i,j}=0,\quad \vert X_{i,j}\vert\leq B
>
> 
> 
> $$
> 
>
> 이때 matrix variance statistic
> 
> 
> $$
> 
> v:=\max_{i}\sum_{j}\mathbb{E}X_{i,j}^{2}
>
>
> 
> 
> $$
> 
>
> 를 정의하면 spectral norm에 대해 모든 $t\geq 0$ 에 대해 다음 부등식을 만족하는 universal constant $c>0$ 이 존재한다.
> 
> 
> $$
> 
> \mathbb{P}(\Vert X\Vert\geq 4\sqrt{v}+t)\leq n\exp\big(-\frac{t^{2}}{cB^{2}}\big)
> 
> 
> $$
> 

# Low-rank matrix Denoising

Perturbation theory를 사용하는 데이터사이언스 분야로 우선 **Low-rank matrix denoising** 을 다루어보도록 하자. Low-rank matrix denoising이란, 주어진 관측 행렬에서 노이즈를 제거한 Low-rank matrix를 추정하는 과정이라고 생각하면 된다. 이전 [Perturbation Theory](https://ddangchani.github.io/Spectral-Analysis-1/)에서 고려한 다음과 같은 모델을 생각하자.


$$

M=M^{\star}+E 

$$

여기서 행렬 $M$이 관측치를 의미하고, $E$는 노이즈에 해당하는 행렬이다. 따라서 우리가 추정해야할 대상 행렬은 $M^{\star}$ 인데, 이를 위해서 우선 eigendecomposition $$M^{\star}=U^{\star}\Lambda^{\star}{U^{\star}}^{T}$$ 를 생각하자. 또한, 고유값이 $$\vert\lambda_{1}^{\star}\vert\geq\cdots\geq\vert\lambda_{r}^{\star}\vert>0$$ 으로 주어진다고 가정하자. 일반적으로 노이즈 행렬은 다음과 같은 랜덤 행렬로 가정한다.


$$

E_{i,j}\overset{\mathrm{i.i.d}}{\sim}N(0,\sigma^{2})


$$

### How to
관측 행렬 $M$으로부터 노이즈가 제거된 행렬 $M^{\star}$를 추정하는 것은 어려워 보이지만, 해답은 비교적 간단하다. 만일 추정해야할 행렬 $M^{\star}$의 계수가 $r$이라면, 단지 관측행렬 $M$에서 $r$개의 고유값 및 고유벡터를 취하는 것으로 해결된다. 즉, 만일 $M$의 고유값들이 다음과 같이 정렬된다면


$$

\vert\lambda_{1}\vert\geq\vert\lambda_{2}\vert\geq\cdots\geq \vert\lambda_{n}\vert


$$

여기서 큰 고유값 순으로 $r$개를 취한 후, 각 고유값에 대응되는 고유벡터로 공간으로 만든 행렬


$$[u_{1},u_{2},\ldots,u_{r}]\in\mathbb{R}^{n\times r}$$ 은 행렬 $U^{\star}$의 추정치가 된다.

### Performance
방식은 매우 간단한 반면, 실제로 위와 같은 방법이 얼마나 효과적인지를 파악하기 위해서는 이전 글에서 다룬 David-Kahan $\sin\Theta$ [정리](https://ddangchani.github.io/Spectral-Analysis-1/)를 이용하면 된다. David-Kahan theorem으로 부터 다음과 같은 부등식을 얻을 수 있는데, 이는 추정해야할 부분공간 $U^\star$ 와 추정치로 제시된 부분공간 $U$ 의 거리가 매우 높은 확률로 가깝게 도출될 수 있음을 의미한다.


$$

\mathbb{P}\bigg(\mathrm{dist}(U,U^{\star})\leq \frac{2\Vert E\Vert}{\vert\lambda_{r}^{\star}\vert}\bigg)>1-O(n^{-8})


$$

또한, 이 과정에서 노이즈 행렬에 대해 $\sigma\sqrt{n}\leq\frac{1-1/\sqrt{2}}{5}\vert\lambda_{r}^{\star}\vert$ 을 가정하면 Weyl 부등식으로부터 다음이 확률 $1-O(n^{-8})$ 로 성립한다.


$$

\vert\lambda_{i}\vert\leq \Vert E\Vert\leq 5\sigma\sqrt{n}\quad \forall i\geq r+1


$$


#### Euclidean Accuracy
앞선 추정방법을 종합하여, 알려지지 않은 행렬 $M^{\star}$ 를 추정치 $\hat M=U\Lambda U^{T}$ 로 추정하는 과정에서의 정확성을 살펴보면 다음과 같다. 우선 삼각부등식을 이용하면 다음 부등식을 얻을 수 있는데,


$$

\begin{aligned}
\Vert U\Lambda U^{T}-M^{\star}\Vert&\leq \Vert M-M^{\star}\Vert+\Vert U\Lambda U^{T}-M \Vert\\
&= \Vert E\Vert +\vert\lambda_{r+1}\vert\\
&\leq 2\Vert E\Vert
\end{aligned}


$$

행렬 $U\Lambda U^{T -}M^{\star}$ 의 계수가 최대 $2r$ 이므로, 다음이 성립한다.


$$

\mathbb{P}\bigg(\bigg\Vert U\Lambda U^{T}-M^{\star}\bigg\Vert_{F}\leq 10\sigma\sqrt{2nr}\bigg)> 1-O(n^{-8})


$$

# References
- Yuxin Chen et al. - Spectral Methods for Data Science: A Statistical Perspective (2021)

{% endraw %}