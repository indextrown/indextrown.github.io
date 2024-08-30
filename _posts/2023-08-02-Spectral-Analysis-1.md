---
title: Spectral Analysis - Perturbation Theory
tags:
- Spectral Analysis
- Clustering
- Mathematics
- Graph Clustering
category: 
use_math: true
---
{% raw %}
# Basics of matrix analysis

## Perturbation

실행렬 $M^{\star}$와 교란(perturbed)된 실행렬 $M$ 에 대해 다음 관계를 가정하자.

$$

M=M^{\star}+E


$$

여기서 $E$는 **perturbation matrix** 라고 하며, 통계학적인 관점에서 $M, M^{\star}$ 이 각각 관측치와 기댓값이라면 $E$를 오차 정도로 볼 수 있다(아래).

$$

M = \mathbb{E} M + (M-\mathbb{E}M)


$$

이때 우리의 관심사는 관측치 $M$을 바탕으로 기댓값 행렬 (일반적으로 low-rank인) $M^{\star}$을 추정하는 것이며, 이 과정에서 고유값공간(혹은 특이값공간)의 성질을 이용하는데 이러한 접근 방식을 **Spectral Analysis**라고 한다.

## Unitarily invariant matrix norm

### Definition
$\mathbb{R}^{m\times n}$ 에서 정의되는 행렬 노음 $\Vert\cdot\Vert$ 가 **unitarily invariant** 하다는 것은 임의의 두 정규직교행렬 $U\in \mathcal{O}^{m\times m},V\in\mathcal{O}^{n\times n}$ 에 대해 다음이 성립하는 것을 의미한다.

$$

\Vert A\Vert=\Vert U^{T}AV\Vert


$$


### Lemma. Weyl's inequality

$A,E\in\mathbb{R}^{n\times n}$ 이 대칭 실행렬이고, $\lambda_{i}(A)$ 를 행렬 $A$의 $i$번째로 큰 고유값이라고 하자. 그러면 다음 부등식이 성립한다.

$$

\vert\lambda_{i}(A)-\lambda_{i}(A+E)\vert\leq\Vert E\Vert


$$

이때 우변의 노음 $\Vert\cdot\Vert$ 은 *spectral norm*으로, 행렬의 가장 큰 특이값(singular value) $\max_{i}\sigma_{i}(E)$를 의미한다. 대칭실행렬 외에 일반적인 행렬 $A,E\in\mathbb{R}^{m\times n}$ 에 대해서도 고유값 대신 특이값을 이용한 다음의 부등식이 성립한다.

$$

\vert\sigma_{i}(A)-\sigma_{i}(A+E)\vert\leq\Vert E\Vert


$$


### Distance between subspaces
$\mathbb{R}^n$ 에서의 두 r-dimensional 부분공간 $\mathcal{U}^{\star},\mathcal{U}$ 를  생각하자. 각 부분공간의 정규직교기저(orthonormal basis)를 각각 $U^{\star},U\in\mathbb{R}^{n\times r}$ 라고 하고, $n\times n$ 정규직교행렬을 만들기 위해 각 기저에 대한 직교행렬 $U_{\perp}^{\star},U_{\perp}$ 를 구성하자. 그러면 행렬 $$[U^{\star},U^{\star}_{\perp}], [U,U_{\perp}]$$ 는 각각 $n\times n$ 정규직교행렬이 된다.

두 부분공간 $\mathcal{U^{\star},U}$ 의 거리를 측정하기 위해서는 새로운 metric을 정의해야하는데, 기존에 사용하는 spectral norm 혹은 Frobenius norm은 회전변환을 고려하지 못하기 때문이다. 즉, 회전변환 $R\in\mathcal{O}^{r\times r}$ 에 대해 $UR$은 $U$와 같은 basis를 가지지만, $\Vert UR-U\Vert\neq 0$ 이 되어 두 공간의 기저가 같음에도 거리가 0이 아닌 문제가 발생한다. 일반적으로 이 문제를 해결하기 위해, 다음과 같이 회전변환에 영향을 받지 않는 $UU^{T}$를 이용한다.

$$

URR^{T}U^{T}=UU^T 


$$

이를 이용해 다음과 같이 두 부분공간 $\mathcal{U^{\star},U}$ 의 거리를 다음과 같이 정의한다.

$$

dist_{p,\Vert\cdot\Vert}(U,U^{\star}) := \Vert UU^{T}-U^{\star}{U^{\star}}^{T}\Vert


$$

여기서 matrix norm $\Vert\cdot\Vert$ 는 주로 spectral norm 혹은 Frobenius norm을 사용한다.

### Angle between subspaces

$U^T U^{\star}$ 의 특이값들이 $\sigma_{1}\geq\sigma_{2}\geq\cdots\geq\sigma_{r}\geq 0$ 으로 주어진다고 하자. $U,U^{\star}$ 의 노음이 1이므로, 모든 특이값들은 0과 1사이의 값을 갖는다. 이점에서 아이디어를 얻어, 각 특이값들을 어떤 각도의 코사인 값으로 볼 수 있는데, 이를 이용해 두 부분공간의 각도를 다음과 같이 정의하고, 이를 **principal angles** 라고 한다.

$$

\theta_{i}:= \arccos\sigma_{i}\;\;i=1,\ldots,r


$$

또한, 각도들로 이루어진 행렬을 다음과 같이 정의한다면

$$

\cos\Theta = \begin{pmatrix}\cos\theta_{1} \\ & cos\theta_{2} \\ & & \ddots \\ & & & \cos\theta_{r}\end{pmatrix}


$$

$U^{T}U^{\star}$ 의 특이값분해(SVD)를 다음과 같이 쓸 수 있다.

$$

U^{T}U^{\star}=X\cos\Theta Y^{T}


$$

### Relationship between Angle and Distance
대각행렬 $\sin\Theta=\mathrm{diag}(\sin\theta_{i})$ 를 $cos\Theta$ 와 마찬가지로 정의하면, Spectral norm $\Vert\cdot\Vert$과 Frobenius norm $\Vert\cdot\Vert_F$ 에 대해 다음 관계식이 성립한다.

$$

\begin{aligned}
\Vert UU^{T}-U^{\star}{U^{\star}}^{T} \Vert&=\Vert\sin\Theta\Vert=\Vert U_{\perp}^{T}U^{\star}\Vert=\Vert U^T U_{\perp}^{\star}\Vert\\
\frac{1}{\sqrt 2}\Vert UU^{T}-U^{\star}{U^{\star}}^{T} \Vert_{F}&=\Vert\sin\Theta\Vert_{F}=\Vert U_{\perp}^{T}U^{\star}\Vert_F =\Vert U^T U_{\perp}^{\star}\Vert_F 
\end{aligned}


$$

따라서, 두 부분공간의 거리를 측정하기 위해서는 위 동치인 것들 중 하나를 선택해서 사용하면 된다.

## Perturbation Theory

### Setup
$\mathbb{R}^{n\times n}$ 에서의 두 대칭실행렬 $M=M^{\star}+E$ 에 대해 다음과 같은 고유값분해(eigendecomposition)을 고려하자.

$$

\begin{aligned}
M^{\star}&= \sum_{i=1}^{n}\lambda_{i}^{\star}u_{i}^{\star}{u_{i}^{\star}}^{T}=\begin{pmatrix}U^{\star}&U_{\perp}^{\star}\end{pmatrix}\begin{pmatrix}\Lambda^{\star}&0\\
0&\Lambda^{\star}_{\perp}\end{pmatrix}\begin{pmatrix}{U^{\star}}^{T}\\{U^{\star}_{\perp}}^{T}
\end{pmatrix}\\
M&= \sum_{i=1}^{n}\lambda_{i}u_{i}{u_{i}}^{T}=\begin{pmatrix}U&U_{\perp}\end{pmatrix}\begin{pmatrix}\Lambda&0\\
0&\Lambda_{\perp}\end{pmatrix}\begin{pmatrix}{U}^{T}\\{U_{\perp}}^{T}
\end{pmatrix}
\end{aligned}


$$

### Davis-Kahan's Theorem
Davis-Kahan의 $\sin\Theta$ 정리는 대칭실행렬의 eigenspace에 대한 성질을 다루는 정리이다. 우선 Eigengap $\Delta>0$ 와 위 setup의 고유값행렬에 대해 다음 성질이 성립한다고 하자.

$$

\begin{aligned}
\mathrm{eigenvalues}(\Lambda^{\star})&\subseteq [\alpha,\beta]\\
\mathrm{eigenvalues}(\Lambda_{\perp})&\subseteq (-\infty,\alpha-\Delta]\cup [\beta+\Delta,\infty)
\end{aligned}


$$

이 경우 다음과 같은 부등식이 성립한다.

$$

\begin{aligned}
\mathrm{dist}(U,U^{\star})\leq\sqrt{2}\Vert\sin\Theta\Vert\leq\frac{\sqrt{2}\Vert EU^{\star}\Vert}{\Delta}\leq \frac{\sqrt{2}\Vert E\Vert}{\Delta}\\
\mathrm{dist}(U,U^{\star})\leq\sqrt{2}\Vert\sin\Theta\Vert_F\leq\frac{\sqrt{2}\Vert EU^{\star}\Vert_F}{\Delta}\leq \frac{\sqrt{2r}\Vert E\Vert_F}{\Delta}
\end{aligned}


$$

추후에 다루겠지만, $E$가 sparse한 경우 위 부등식의 상한이 더욱 유용해지는 결과를 갖는다. 또한, 위 정리로부터 더 사용하기 편한 따름정리를 얻을 수 있는데, 다음과 같다.

> Corollary.
> 행렬 $M^{\star},M$ 의 고유값들이 각각 $|\lambda_{1}^{\star}|\geq\cdots\geq|\lambda_{r}^{\star}|>|\lambda_{r+1}^{\star}|\geq\cdots\geq|\lambda_{n}^{\star}|$ 와 $$|\lambda_{1}|\geq\cdots\geq|\lambda_{r}\}|>|\lambda_{r+1}|\geq\cdots\geq|\lambda_{n}|$$ 으로 주어진다고 하자. 
> 
> 만일 perturbation $E$에서 다음 성질이 성립하면
> 
> $$
> 
\Vert E\Vert<(1-1/\sqrt{2})(|\lambda_{r}^{\star}|-|\lambda_{r+1}^{*}|)
> 
> 
> $$
> 
> 이로부터 다음 부등식이 성립한다.
> 
> $$
> 
\begin{aligned}
\mathrm{dist}(U,U^{\star})\leq\sqrt{2}\Vert\sin\Theta\Vert\leq\frac{\sqrt{2}\Vert EU^{\star}\Vert}{|\lambda_{r}^{\star}|-|\lambda_{r+1}^\star|}\leq \frac{\sqrt{2}\Vert E\Vert}{|\lambda_{r}^{\star}|-|\lambda_{r+1}^\star|}\\
\mathrm{dist}(U,U^{\star})\leq\sqrt{2}\Vert\sin\Theta\Vert_F\leq\frac{\sqrt{2}\Vert EU^{\star}\Vert_F}{|\lambda_{r}^{\star}|-|\lambda_{r+1}^\star|}\leq \frac{\sqrt{2r}\Vert E\Vert_F}{|\lambda_{r}^{\star}|-|\lambda_{r+1}^\star|}
\end{aligned}
> 
> 
> $$
> 

### Wedin's Theorem
David-Kahan Theorem을 일반 실행렬공간과 그것의 특이값공간(singular subspace)로 확장한 정리가 바로 Wedin's $\sin\Theta$ theorem이다. 우선 다음과 같은 $M=M^{\star}+E$ 에 대한 특이값분해를 가정하자.

$$

\begin{aligned}
M^{\star}&= \sum_{i=1}^{n}\sigma_{i}^{\star}u_{i}^{\star}{u_{i}^{\star}}^{T}=\begin{pmatrix}U^{\star}&U_{\perp}^{\star}\end{pmatrix}\begin{pmatrix}\Sigma^{\star}&0&0\\
0&\Sigma^{\star}_{\perp}&0\end{pmatrix}\begin{pmatrix}{V^{\star}}^{T}\\{V^{\star}_{\perp}}^{T}
\end{pmatrix}\\
M&= \sum_{i=1}^{n}\sigma_{i}u_{i}{u_{i}}^{T}=\begin{pmatrix}U&U_{\perp}\end{pmatrix}\begin{pmatrix}\Sigma&0&0\\
0&\Sigma_{\perp}&0\end{pmatrix}\begin{pmatrix}{V}^{T}\\{V_{\perp}}^{T}
\end{pmatrix}
\end{aligned}


$$

그러면 다음과 같은 부등식이 성립한다(Wedin's $\sin\Theta$ Theorem).

$$

\begin{aligned}
\max\{\mathrm{dist}(U,U^{\star}),\mathrm{dist}(V,V^{\star})\} &\leq \frac{\sqrt{2}\max \{\Vert E^{T}U^{\star}\Vert,\Vert EV^{\star}\Vert\}}{\sigma_{r}^{\star}-\sigma_{r+1}^{\star}-\Vert E\Vert}\\
\max\{\mathrm{dist}_F(U,U^{\star}),\mathrm{dist}_F(V,V^{\star})\} &\leq \frac{\sqrt{2}\max \{\Vert E^{T}U^{\star}\Vert_{F},\Vert EV^{\star}\Vert_{F}\}}{\sigma_{r}^{\star}-\sigma_{r+1}^{\star}-\Vert E\Vert}
\end{aligned}


$$


# References
- Yuxin Chen et al. - Spectral Methods for Data Science: A Statistical Perspective (2021)
- KOCW 현대통계학(김충락) 강의
{% endraw %}