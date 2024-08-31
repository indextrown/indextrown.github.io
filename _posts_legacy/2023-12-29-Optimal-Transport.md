---
title: Optimal Transport
tags: 
- Machine Learning
- Optimization
- Python
category: ""
use_math: true
header: 
  teaser: /assets/img/Pasted image 20231229142238.png
---
본 포스트는 서울대학교 M2480.001200 *인공지능을 위한 이론과 모델링* 강의노트를 간단히 재구성한 것입니다.

# Optimal Transport

## Distance of densities

확률변수 $X,Y$가 분포 $P,Q$를 갖고, 확률밀도함수를 각각 $p,q$라고 하자. 확률밀도함수 간의 거리를 측정하는 방법에는 여러 종류가 있다. 대표적으로, 다음과 같은 것들이 있다.


$$

\begin{align}
TV(P,Q) &:=  \frac{1}{2}\int\vert p-q\vert d\mu\\
H(P,Q) &:= \sqrt{\int(\sqrt{p}-\sqrt{q})^{2}} d\mu\\
L_{2}(p,q) &:= \int (p-q)^{2}d\mu
\end{align}


$$

그러나, 이러한 거리 개념들은 분포 간의 거리를 측정할 때 위치 정보를 반영하지 못한다는 문제가 있다. 아래 그림을 살펴보면 이해가 가능하다.
![](/assets/img/Pasted image 20231229142238.png)

위 세 개의 밀도함수는 TV, Hellinger distance, L2 distance 등의 관점에선 서로 동일한 거리를 갖는다. 그러나, 1번과 2번의 밀도함수가 더 가깝다는 정보를 반영하고 싶다면 해당 거리함수는 사용할 수 없게 된다. 이러한 관점을 반영한 것이 *optimal transport*이다.

## 정의

함수 $T:\mathbb{R}^{d}\to \mathbb{R}^{d}$ 에 대해 분포 $P$의 push-forward를 다음과 같이 정의한다.


$$

T_{\#}P(A) = P(\{x:T(x)\in A\}) = P(T^{-1}(A)).


$$

*Monge optimal transport*란 


$$

\inf_{T} \int \Vert x-T(x)\Vert^{p}dP(x)


$$

와 같이 정의되는데, 직관적으로는 분포 $P$를 $Q$로 옮기는데 필요한 비용을 측정하는 것이다. 만일 이를 최소로 하는 $T^{\star}$ 가 존재한다면 이를 optimal transport map이라고 한다. 다만 optimal transport map이 존재하지 않을 수 있다.


$$

P=\delta_{0}\quad Q=\frac{1}{2}\delta_{-1}+ \frac{1}{2}\delta_{1}


$$

위 경우의 $P,Q$를 살펴보면, 두 분포의 support가 다르기 때문에 $P$에서 $Q$를 매핑하는 사상이 존재하지 않게 된다. 이를 해결하기 위해 다음 **Wasserstein** distance(or **Kantorovich** distance)을 이용하여 정의한다.


$$

W_{p}(P,Q) = \bigg(\inf_{J\in \mathcal{J}(P,Q)}\int\Vert x-y\Vert^{p}dJ(x,y)\bigg)^{\frac{1}{p}}


$$

여기서 $\mathcal{J}(P,Q)$는 $(P,Q)$를 각각 marginal distribution으로 하는 모든 결합확률분포의 모임이다. 즉, $$T_{X\#}J=P, T_{Y\#}J=Q$$를 의미한다. Monge 정의와의 차이점은, Wasserstein distance로부터는 optimal transport가 항상 존재한다는 점이다. 

$p=1$인 경우, 다음과 같이 간단한 형태를 얻을 수 있다.


$$

W_{1}(P,Q) = \sup\bigg\{\int f(x)dP(x)-\int f(x)dQ(x) : f\in\mathcal{F}\bigg\}


$$

여기서 $\mathcal{F}$는 $\vert f(y)-f(x)\vert\leq \Vert x-y\Vert$ 를 만족하는 함수집합을 의미한다.

$d=1$인 경우, Wasserstein distance는 다음과 같은 형태로 나타낼 수 있다.


$$

W_{p}(P,Q)=\bigg(\int_{0}^{1}\vert F^{-1}(z)-G^{-1}(z)\vert^{p}dz\bigg)^{\frac{1}{p}}


$$

여기서 $F,G$는 $P,Q$의 누적분포함수를 의미한다.

## Geodesics

두 확률분포 $P_{0},P_{1}$이 있을 때, $c(0)=P_{0},c(1)=P_{1}$을 만족하도록 사상 $c:[0,1]\to\mathcal{P}$를 정의할 수 있다. 또한, 이렇게 만들어진 사상에 대해 길이 $L(c)$를 정의할 수 있는데, 이 경우 $L(c)=W_{p}(P_{0},P_{1})$을 만족하는 사상 $c$가 존재한다. 즉, $(P_{t}:0\leq t\leq 1)$ 은 $P_{0},P_{1}$을 연결하는 geodesic이 된다.

## Barycenter

확률분포 $P_{1},\cdots, P_{N}$이 존재할 때, 확률분포들을 요약하여 하나의 분포로 나타내는 과정을 생각해보자. 일반적으로 확률분포들의 평균함수를(유클리드 평균) 사용하게 될 경우, 확률분포의 특성을 제대로 반영할 수 없다. 이를 해결하기 위해 중앙값과 유사하게 서로 간의 Wassestein distance를 계산하여, 중앙 분포를 대표 분포로 사용한다. 이를 **barycenter**라고 한다.


## Example

`POT` (Python Optimal Transport) 패키지를 이용하면 파이썬에서 optimal transport를 간단하게 구현할 수 있다.

### Optimal Transport between 1D Gaussian

```python
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import ot
import ot.plot
import scipy

n = 100
x = np.arange(n, dtype=np.float64)

# Gaussian distributions
a = scipy.stats.norm.pdf(x, loc=20, scale=5)
b = scipy.stats.norm.pdf(x, loc=60, scale=10)

# Loss matrix
M = ot.dist(a.reshape((n, 1)), b.reshape((n, 1)))
M /= M.max()

plt.subplots(1,1,figsize=(6,6))
plt.plot(x, a, label='Source distribution')
plt.plot(x, b, label='Target distribution')
plt.legend()
plt.show()

```


![](/assets/img/Pasted image 20231231162834.png)

`scipy`로 위와 같은 두 가우시안 분포를 생성하여, 두 분포 간 Optimal Transport를 계산해보자.

```python
plt.figure(2, figsize=(6, 6))
ot.plot.plot1D_mat(a, b, M, 'Cost matrix M')

```

![](/assets/img/Pasted image 20231231162928.png)

Cost matrix는 위와 같고, Sinkhorn 알고리즘을 사용하여 아래와 같이 최소 cost matrix를 구할 수 있다.

```python
# Optimal transport
Gs = ot.sinkhorn(a, b, M, 1e-3, verbose=True)

plt.figure(3, figsize=(6, 6))
ot.plot.plot1D_mat(a, b, Gs, 'OT matrix Sinkhorn')

plt.show()

```

![](/assets/img/Pasted image 20231231163043.png)

### Image adaptation

Optimal transport는 이미지 데이터에 사용하기 좋은데, 한 이미지의 RGB 분포를 다른 이미지의 RGB 분포로 Transport하는 OT를 찾게 되면, 이미지의 colormap을 다른 이미지로 옮길 수 있게 된다. 이러한 과정을 *image adaptation*이라고 한다. 아래와 같은 두 이미지를 고려해보자.

![](/assets/img/Pasted image 20231231163249.png)

위 두 이미지의 colormap을 산점도로 나타내면 다음과 같다.

![](/assets/img/Pasted image 20231231163321.png)

우리가 찾고자 하는 OT는 두 색상 분포간의 mapping이며, 이를 적용한 결과는 다음과 같다.

![](/assets/img/Pasted image 20231231163408.png)


확인해보면, Target 이미지의 색상 분포가 기존 source 이미지에 학습된 것을 확인할 수 있다.

# References
- https://pythonot.github.io/
- Murphy, K. P. (2023). _Probabilistic machine learning: Advanced topics_. The MIT Press.