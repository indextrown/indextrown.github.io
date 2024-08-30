---
title: Differential Privacy
tags: 
- Machine Learning
- Differential Privacy
category: ""
use_math: true
---
본 포스트는 서울대학교 M2480.001200 *인공지능을 위한 이론과 모델링* 강의노트를 간단히 재구성한 것입니다.

# Differential Privacy

차등적 정보보호<sup>differential privacy, DP</sup>란, 데이터 분석 과정에서 개별 데이터의 정확한 값(privacy)을 보호하면서 동시에 분석의 결과를 일정 수준 보장할 수 있도록 하는 이론이다. 인과추론 연구에서 무작위 실험(randomized experiment)과 그 결이 비슷한데, 정의는 다음과 같이 이루어진다.

데이터셋 $D=\{X_{1},\ldots,X_{n}\}$가 주어졌다고 하자. 이때, 각 데이터의 sample space는 $X_{i}\in\mathcal{X}$로 주어진다. 데이터의 표본 공간을 명확히 아는 것은 차등적 정보보호에서 매우 중요하다. 차등적 정보보호에서 결과적으로 도출해야 하는 것은, 데이터셋에 대한 통계량<sup>statistic</sup> $Z=T(D)$ 이다. 이때, 통계량을 직접적으로 사용하기 보다는 일종의 randomization을 적용하여 $Z\sim Q(\cdot\vert D)$ 라는 분포를 가정하자.

두 개의 데이터셋 $D,D'$가 서로 **이웃**이라는 것은 한 개의 성분 데이터에만 차이가 존재하는 것을 의미한다. 즉, 다음과 같고 이를 $D\sim D'$ 라고 정의하자.

$$

\begin{align}
D &=  \{X_{1},\ldots,X_{i-1},X_{i},X_{i+1},\ldots,X_{n}\} \\
D' &= \{X_{1},\ldots,X_{i-1},X'_{i},X_{i+1},\ldots,X_{n}\} \\
\end{align}


$$

## 정의

$Q$가 다음을 만족할 때, $Q$가 $\epsilon$-differential privacy를 만족한다고 정의한다.

$$

Q(Z\in A\vert D)\le e^{\epsilon}Q(Z\in A\vert D'),\quad \forall A,\forall D,D'\in \mathcal{X}^{n}


$$

만일 분포 $Q$가 확률밀도 $q$를 갖는다면, 이는 다음과 같다.


$$

\sup_{z}\frac{q(z\vert D)}{q(z\vert D')}\le e^{\epsilon}


$$

### 의미

$\epsilon$-differential privacy의 의미는 데이터베이스에서 개별 관측값의 존재가 결과 $Z$에 미미한 영향을 미친다는 것이다. 역으로 생각하면, 통계량 $Z$를 관측한다고 해서 특정 $i$번째 객체의 데이터 $X_{i}$를 예상하기 어렵다는 것을 의미한다. 구체적으로는 다음과 같다.


$$

\frac{P(X_{i}=a\vert Z)}{P(X_{i}=b\vert Z)}=\frac{q(z\vert X_{i}=a)P(X_{i}=a)}{q(z\vert X_{i}=b)P(X_{i}=b)}


$$

가 성립하므로, $\epsilon$-differential privacy 하에서 관측 후 오즈비와 관측 전 오즈비 사이에는 다음 관계가 성립한다.


$$

e^{-\epsilon}\frac{P(X_{i}=a)}{P(X_{i}=b)}\leq \frac{P(X_{i}=a\vert Z)}{P(X_{i}=b\vert Z)}\leq e^\epsilon\frac{P(X_{i}=a)}{P(X_{i}=b)}


$$

이때, $e^{\epsilon}\approx 1+\epsilon$ 으로 근사가능하므로, 실제로 작은 $\epsilon$에 대해 구체적인 관측값에 대한 확률은 통계량 관측에 대해 크게 변화하지 않는다는 것을 알 수 있다.

## Queries

일반적인 데이터 분석 프로세스를 생각해보자. 데이터 분석가는, 대용량 데이터베이스를 직접 보유하여 다루기보다는 서버에 데이터베이스를 적재하고, SQL 쿼리나 어떠한 머신러닝 모델 등으로 데이터에 대한 함수를 도출하고자 할 것이다. 즉, 분석가 입장에서 필요한 것은 데이터에 대한 함수 $f(D)$이다. 이때, 함수에 대한 민감도<sup>sensitivity</sup>를 다음과 같이 정의하자.

$$

\Delta:=\sup_{D\sim D'}\vert f(D)-f(D')\vert


$$

데이터에 대한 함수 $f(D)$를 직접 출력하는 경우도 있겠지만, 다음과 같이 Laplace 노이즈를 추가한 경우를 생각해보자. 


$$

Z = f(D)+W,\quad f_{W}(w) \propto e^{-w/\lambda}


$$

만일 $\lambda=\Delta/\epsilon$으로 두면,


$$

\frac{p(z\vert D)}{p(z\vert D')}\leq \exp(\frac{\vert f(D)-f(D')\vert}{\lambda})=e^{\epsilon}


$$

이 성립하므로, $\epsilon$-differential privacy를 만족한다.

만약 $\mathcal{X}=[-B,B], f(D)=\overline X$ 라고 하자. 그러면 위 결과로부터 표준편차가 $O(\dfrac{B}{n\epsilon})$ 인 노이즈를 추가하게 된다. $n$의 관점에서 이는 좋은 함수인 반면, $B$의 관점에서는 $\mathcal{X}$의 크기가 커질수록 노이즈의 표준편차가 커지는, 그닥 좋은 함수는 아니게 된다. 결과적으로 노이즈를 추가하는 $\epsilon$-DP에서는 데이터셋의 표본공간과 데이터셋의 크기를 종합적으로 고려해야 한다.

### Minimax risk

모평균 $\mu$를 추정하는 간단한 문제를 생각해보자. DP를 사용하지 않을 경우에는 표본평균 $\bar X$를 사용하면 간단하게 추정이 가능하다. 이 경우 L2 loss에 대한 risk는 $\mathrm{E}\Vert\bar X -\mu\Vert^{2}= \dfrac{d}{n}$이다. 반면, 차등적 정보보호를 사용할 경우 $\dfrac{d}{n}$의 loss를 보장할 수 없다. 이에 대해 minimak theory 관점에서, 임의의 $\epsilon$-DP 추정치 $\hat\mu$의 L2 risk가 다음의 lower bound를 갖는다는 것이 알려져 있다 (Barber, 2014).

$$

\mathrm{E}\Vert \hat\mu-\mu\Vert^{2}\succeq \frac{d}{n}+ \frac{d^{3}}{n^{2}\epsilon^{2}}


$$

즉, $\epsilon$-DP를 사용하기 위한 비용이 $\dfrac{d^{3}}{n^{2}\epsilon^{2}}$ 정도라고 보면 될 것이다.

## 데이터셋 관점

앞서 설명한 $\epsilon$-DP는 사실 데이터 분석가의 관점에서 그렇게 유용할 수는 없다. 일반적으로 데이터를 분석하는 과정은 실제 데이터셋 전부를 불러오거나, 일부를 추출하여 데이터셋의 전반적인 분포를 확인하고 이에 맞추어 모델 선택 및 예측 등이 이루어지기 때문이다. 따라서, 더 주목해야 할 것은 $\epsilon$-DP인 통계량을 확보하는 것 보다 데이터셋 자체에 차등적 정보보호를 적용하여 **privatized** 데이터셋을 도출해내는 문제이다. 이러한 문제에 대한 방법론으로 제안된 것들을 살펴보도록 하자.

### Exponential Mechanism (McSherry, 2007)

정보보호가 이루어진 private dataset $Z=(Z_{1},\ldots Z_{k})$를 도출해내는 문제를 생각하자. 이때 임의의 두 데이터셋 $x=(x_{1},\ldots,x_{n}), y=(y_{1},\ldots,y_{k})$ 에 대해 (*크기가 다를 수 있음에 주의*) 거리를 $\xi(x,y)$ 로 정의하고 다음과 같이 민감도를 정의하자.


$$

\Delta:=\sup_{x\sim y}\sup_{z}\vert\xi(x,z)-\xi(y,z)\vert


$$

이때, $Z$를 다음과 같은 확률밀도함수 $q$


$$

q(z\vert x)\propto \exp\bigg(- \frac{\epsilon\xi(x,z)}{2\Delta} \bigg)


$$

로부터 샘플링하면 민감도의 정의로부터 $\epsilon$-DP가 만족된다는 것을 확인할 수 있다.

#### Example

$\mathcal{X}$가 compact set이고 $\xi(x,z)=\Vert F_{x}-F_{z}\Vert_\infty=\sup_{t}\vert F_{x}(t)-F_{z}(t)\vert$ 로 주어진다고 하자 (Kolmogorov-Smirnov distance). 정의로부터 $\Delta= \dfrac{1}{n}$ 이고 $q$는 다음과 같다.


$$

q(z\vert x) \propto \exp \bigg(- \frac{n\epsilon\Vert F_{x}-F_{z}\Vert_{\infty}}{2}\bigg)


$$

이때 optimal $\Vert F-F_{z}\Vert_{\infty}=O_{P}(n^{-\frac{1}{3}})$ 인 반면, privacy가 없을 때에는 $O_{P}(n^{-\frac{1}{2}})$ 이므로 DP의 적용으로 일부 정확도 손실이 있음을 알 수 있다.

### Density estimation

앞선 Exponential mechanism은 데이터셋을 직접 도출해내는 관점인데, 다른 방법으로는 정보보호가 이루어진 밀도추정을 생각해볼 수 있다. 즉, 추정된 밀도함수 $\hat p$ 로부터 데이터셋 $Z_{1},\ldots,Z_{N}\sim \hat p$ 를 추출하는 것이다. 밀도추정에 가장 널리 사용되는 kernel density estimator에 차등적 정보보호를 적용하는 것을 고려해보자.


$$

\hat p(x) = \frac{1}{n}\sum_{i} \frac{1}{h^{d}}K\bigg( \frac{x-X_{i}}{h}\bigg)


$$

$\hat p$는 유한한 모수집합으로 나타낼 수 없기 때문에 다른 방법이 고안되어야 한다. Hall, Rinaldo, Wasserman (2013)은 다음과 같은 밀도함수의 추정량을 제안했다.


$$

g = \hat p + \frac{C}{n\epsilon h^{\frac{d}{2}}}G


$$

여기서 $C$는 적절한 상수를 의미하고, $G\sim GP(0,\Sigma)$ 이다. 이렇게 추정된 밀도함수는 매우 복잡하지만, 차등적 정보보호를 만족하기는 한다. 또한, 수렴속도가 기존의 커널밀도추정치 $\hat p$와 동일하다는 장점이 있다.


# References

- Dwork, C. (2006). Differential Privacy. In M. Bugliesi, B. Preneel, V. Sassone, & I. Wegener (Eds.), _Automata, Languages and Programming_ (pp. 1–12). Springer. [https://doi.org/10.1007/11787006_1](https://doi.org/10.1007/11787006_1)
- Wasserman, L., & Zhou, S. (2010). A Statistical Framework for Differential Privacy. _Journal of the American Statistical Association_, _105_(489), 375–389. [https://doi.org/10.1198/jasa.2009.tm08651](https://doi.org/10.1198/jasa.2009.tm08651)