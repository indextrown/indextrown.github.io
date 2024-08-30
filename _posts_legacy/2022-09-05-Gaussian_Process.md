---
title: "Gaussian Process"
tags:
- Machine Learning
- Gaussian Process
- Bayesian
category: Machine Learning
use_math: true
---
{% raw %}
# Gaussian Process (1)

## Definition

Gaussian Process(줄여서 GP라고도 한다)는 비모수방법의 일종으로, 사전분포를 표현하여 베이즈 정리를 바탕으로 사후확률을 추론하는 기법으로 사용된다. 길이 $N$의 가우시안 랜덤 벡터(**Gaussian Random Vector**)란

$$

\mathbf{f} = [f_1,\ldots,f_N]

$$

의 형태로 주어지며, 평균벡터 $\mu = \rm{E}[\mathbf f]$, 공분산행렬 $\Sigma = \rm{Cov}[\mathbf f]$ 가 정의된다.

Input data $\mathbf{X} = \{x_n\in \mathcal{X}\}_{n=1}^N$ 에서 정의되는 함수 $f:\mathcal X\to \mathbb R$ 의 형태가 주어진다고 하자. 이때

$$

\mathbf{f}_X = [f(x_1),\ldots,f(x_N)]

$$

으로 주어진 벡터의 각 성분은 해당 데이터셋에서의 unknown function value이고, 이는 random variable에 각각 대응되므로, 이는 앞서 정의한 가우시안 랜덤 벡터이다. 만일 위 랜덤 벡터가 임의의 $N\geq 1$ 개의 점들에 대해서 모두 **jointly Gaussain**이라면, 함수 $f:\mathcal X\to \mathbb R$ 을 **Gaussain Process** 라고 정의한다. 또한, GP에 대해 다음과 같이 mean function, covariance function이 정의된다.

$$

m(x)\in\mathbb R,\;\;\mathcal{K}(x,x')\geq 0

$$

이때 covariance function은 Mercer Kernel(=Positive definite kernel)로 주어지는데, 예를 들어 Gaussian RBF kernel

$$

\mathcal K(x,x')\propto \exp(-\Vert x-x'\Vert^2)

$$

가 이용될 수 있다. 이렇게 정의되는 GP를 다음과 같이 표기한다.

$$

f(x) \sim GP(m(x),\mathcal K(x,x')) \\
\text{where} \\
m(x) = \rm{E}[f(x)]\\
\mathcal K(x,x') = \rm{E}[(f(x)-m(x))(f(x')-m(x'))^T]

$$

또한, Gaussan Process의 정의에 의해 Input points $\mathbf X=\{x_1,\ldots,x_N\}$ 에 대해

$$

p(f_X\vert \mathbf X) = \mathcal N(f_X\vert \mu_X,\mathbf K_{X,X})

$$

이 성립한다(각각 GP의 평균함수, 공분산함수에 Input을 대입한 벡터, 행렬을 의미함).

## Kernels

### Mercer Kernel

커널에 대한 기본적인 설명은 [예전에 다룬 글](https://ddangchani.github.io/machine%20learning/kernel2/)로 대체하고, 여기서는 주로 사용되는 커널들에 대해 다루어보도록 하자. 우선, 만약 입력벡터가 유클리드공간($\mathbb R^D$)인 경우 **stationary kernel**이 주로 사용된다. Stationary kernel은 $\mathcal K(x,x') = \mathcal K(x-x') = \mathcal K(r)$ 꼴로 표현되는 커널함수를 의미한다.

#### Examples

1. Squared Exponential(SE) Kernel

   $$

   \mathcal K(r;l) = \exp({-r^2 \over 2l^2})

   $$

2. Automatic Relevance Determination(ARD) Kernel

   RBF 커널에서 유클리드 거리를 마할라노비스 거리로 대체
   
   $$
   \mathcal K(r;\Sigma,\sigma^2) = \sigma^2\exp(-{1\over2}r^T\Sigma^{-1}r)
   $$

3. Matern Kernel

   ​	SE kernel보다 더 rough한 커널로, 더 널리 사용.

      $$

      \mathcal{K}(r;\nu,l) = {2^{1-\nu}\over\Gamma(\nu)}\bigg({\sqrt{2\nu}r\over l}\bigg)^\nu K_\nu\bigg({\sqrt{2\nu}r\over l}\bigg)

      $$

   ​	($K_\nu$ 는 수정된 Bessel function)

### Mercer's Theorem

고유값분해(eigendecomposition)를 이용하면 p.d인 kernel matrix $\mathbf K$를 분해햐여 $(i,j)$ 번째 성분을 다음과 같이 나타낼 수 있다.

$$

k_{ij} = \phi(x_i)^T\phi(x_j)\\
\text{where}\\
\phi(x_i) = \Lambda^{1\over2}\mathbf U_{:i,}

$$

이러한 아이디어를 기반으로 Kernel Matrix가 아닌, **kernel function** 자체에 대한 eigendecomposition을 생각할 수 있다. 우선, kernel function $\mathcal K$ 에 대한 eigenfunction $\phi$ 및 이에 대응하는 고유값(eigenvalue) $\lambda$를 다음 관계에서 정의하자.

$$

\int\mathcal K(x,x')\phi(x)d\mu(x) = \lambda\phi(x')

$$

이렇게 구해진 eigenfunction들은 서로 orthogonal하다. 즉,

$$

\int\phi_i(x)\phi_j(x)d\mu(x) = \delta_{ij}

$$

을 만족한다(우변은 Kronecker delta 함수).

**Mercer's Theorem**은 이를 바탕으로 한 정리인데, 이는 임의의 p.d인 커널함수는 모두 다음과 같은 무한합으로 나타낼 수 있음을 의미한다.

$$

\mathcal K(x,x') = \sum_{m=1}^\infty \lambda_m\phi_m(x)\phi_m(x')

$$

## GP Regression

### Noise-Free observation

Training data $\mathcal D = \{(x_n,y_n) : n=1:N, x_i\in\mathbb R^D\}$ 이 주어지고, 이때 noise-free인(오차항이 없는) 함수 $y_n=f(x_n)$ 로 관계식이 주어진다고 하자. 이때, 이미 관측된(Training data) $x$에 대한 함수값 $f(x)$를 추정하는 문제가 주어진다고 하자. 이 경우에는 **GP를 가정**한 함수 $f$를 추정하는 것이 비교적 간단하다. 오차항이 없으므로 Training data를 보간(Interpolate)하는 함수를 찾으면 된다.

반면, 이번에는 Training data 외부에서 관측된 $x$,에서의 문제를 생각해보자. 예컨대 $$N_*\times D$$ 크기의 test dataseet $$\mathbf X_*$$ 의 원소들에 대응하는 가우시안 벡터

$$

\mathbf f_* = [f(x_1),\ldots,f(x_n)]

$$

를 추정하는 상황을 가정하자. 그러면 GP의 정의에 의해 joint distribution $p(f_X,f_*\vert X,X_*)$은 다음과 같은 joint Gaussian이다.

$$

\pmatrix{\mathbf f_X\\ \mathbf f_*} \sim \rm{N}\pmatrix{\pmatrix{\mu_X\\ \mu_*}, \pmatrix{\mathbf K_{X,X}&\mathbf K_{X,*} \\ \mathbf K^T_{X,*} & \mathbf K_{*,*}}}

$$

또한, Joint Gaussian Distribution의 성질로부터(수리통계학 참고) 다음 식들이 성립한다.

$$

p(\mathbf f_*\vert \mathbf X_*,\mathcal D) = \rm{N}(\mathbf f_*\vert \mu_{*\vert X},\Sigma_{*\vert X}) \\
\mu_{*\vert X} = \mu_* + \mathbf K^T_{X,*}\mathbf K^{-1}_{X,X}(\mathbf f_X-\mu_X) \\
\Sigma_*\vert X = \mathbf K_{*,*} - \mathbf K

$$

### Noisy observation

이번에는 일반적인 경우, 즉 Training data가 $y_n = f(x_n)+\epsilon_n$ 의 형태로 주어지는 경우를 다루어보도록 하자. 여기서 오차항은 정규분포($N(0,\sigma^2_y)$)를 따른다고 가정하자. 이 경우, 앞선 케이스와 같이 Interpolation은 불가능하지만, 관측 데이터들에 어느정도 가까운 Regression이 이루어진다. 우선, 관측값들의 공분산은 다음과 같이 주어진다.

$$

\text{Cov}(y_i,y_j) = \text{Cov}(f_i,f_j) + \text{Cov}(\epsilon_i,\epsilon_j) = \mathcal{K}(\mathbf x_i, \mathbf x_j) + \sigma_y^2\delta_{ij}

$$

이를 모든 성분에 대한 행렬로 표현하면,

$$

\text{Cov}(\mathbf{y\vert X}) = \mathbf K_{X,X} + \sigma^2_y\mathbf I_N

$$

으로 주어진다. 따라서, GP의 정의로부터

$$

\pmatrix{\mathbf y\\ \mathbf f_*} \sim \rm{N}\pmatrix{\pmatrix{\mu_X\\ \mu_*}, \pmatrix{\mathbf K_{X,X}+\sigma_y^2\mathbf I&\mathbf K_{X,*} \\ \mathbf K^T_{X,*} & \mathbf K_{*,*}}}

$$

이 성립한다. 앞선 Noise-free 모델에서 공분산행렬의 구조만 바뀐 것을 확인할 수 있다. 또한, Noise-free 모델과 마찬가지로 Test data $\mathbf X_*$ 에 대한 Posterior predictive density 역시 구할 수 있다.

Gausaain Process 모델의 적합 과정은 다음 게시글에서 이어서 다루도록 하겠다.



# References

- *Probabilistic Machine Learning - Advanced Topics*, K.Murphy.


{% endraw %}