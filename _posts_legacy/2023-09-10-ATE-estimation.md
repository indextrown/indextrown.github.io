---
title: ATE estimation
tags:
- ATE
- Causal Inference
- Inverse Probability Weighting
category: ""
use_math: true
---
# ATE estimation

바로 [이전 글](https://ddangchani.github.io/Confounder-Adjustment)에서 살펴보았듯이, 교란변수<sup>confounder</sup>(공변량)이 모두 관측된다는 가정하에서 평균처치효과가 statistical estimand $\tau$의 함수로 식별가능함을 확인했다. 이제 이로부터 평균처치효과 ATE를 관측데이터로부터 어떻게 추정할지 다루어보도록 하겠다. 평균처치효과를 추정하는 방법에는 크게 두 가지 (1) Outcome Regression(혹은 Outcome Adjustment)와 (2) 역확률 가중치(IPW estimator)가 존재한다.

## Outcome Adjustment

Outcome Adjustment(g-computation라고도 함)은 처치변수와 교란변수가 주어졌을 때 결과변수의 조건부 기댓값을 모델링하고자 하는 전략이다. 즉, 다음과 같은 조건부 기대 결과<sup>conditional expected outcome</sup>를 생각한다.

$$

Q(a,x) = \mathrm{E}[Y\vert A=a,X=x]


$$

그러면, 이전에 다루었던 statistical estimand는 정의에 의해 다음과 같이 표현된다.


$$

\tau = \mathrm{E}[Q(1,x)-Q(0,x)]


$$

따라서 조건부 기대 결과를 이용해 추정한 $\tau$는 다음과 같이 plug-in 방식으로 생각할 수 있다.


$$

\hat \tau^{Q}:= \frac{1}{n} \sum_{i} \hat Q(1,x_{i})-\hat Q(0,x_{i})


$$

이때 조건부 기대 결과 $\hat Q$를 추정하기 위해서 다음과 같은 성질을 고려하자.


$$

Q(a,x) = \mathrm{E}[Y\vert a,x] = \arg\min_{Q}\mathrm{E}[Y-Q(A,X)]^{2}


$$

즉, 조건부 기대 결과가 제곱손실함수를 최소화하므로 우리는 $Q$를 추정하기 위해 $A,X$로 부터 $Y$를 예측하는 예측(회귀)모형을 만들면 된다. 만일 $Q$의 함수공간을 선형함수로 제약하면 


$$

Q(A,X) = \beta_{0}+\beta_{A}A+\beta_{X}X


$$

와 같은 형태를 생각할 수 있고, 이로부터 다음 관계가 성립한다.


$$

Q(1,X)-Q(0,X)=\beta_{A}


$$

즉, Outcome-Adjustment 관점에서는 평균처치효과를 추정하는 것이 선형모형에서 모형의 계수를 추정하는 것과 유사한 논리를 가진다.


## Propensity score adjustment

Outcome adjustment 관점은 교란변수와 결과변수 간의 관계를 모델링하는 관점이었다. 반면 교란변수와 처치변수 간의 관계를 모델링할 수도 있는데, 이때 사용되는 정의가 **propensity score**이다.

### 정의
Propensity score $g$는 다음과 같이 정의된다.


$$

g(x) = P(A=1 \vert X=x)


$$

Propensity score을 이용하면, statistical estimand $\tau$를 다음과 같이 나타낼 수 있다.


$$

\tau = \mathrm{E}\bigg[ \frac{YA}{g(X)}- \frac{Y(1-A)}{1-g(X)} \bigg]


$$

### Inverse Probability Weighting

위 표현으로부터 다음과 같은 추정치를 고려할 수 있다.


$$

\hat\tau^{HT} = \frac{1}{n}\sum_{i} \frac{Y_{i}A_{i}}{\hat g(X_{i})} - \frac{Y_{i}(1-A_{i})}{1-\hat g(X_{i})} 


$$

이를 **Horvitz-Thompson Inverse probability weighted estimator**<sup>역확률가중추정치</sup> 라고 정의하는데, 여기서 *역확률 가중*이란, 주어진 관측 데이터로는 처치변수 $A$가 랜덤하게 설정되었는지 모르는 문제를 극복하기 위함이다. 즉, 처치를 받을 가능성이 낮은 대상인데 처치를 우연히 받게 된 대상에게는 높은 가중치를 주고, 반대의 경우도 마찬가지로 가중치를 준다.

이때, IPW 추정치를 사용하기 위해서는 propensity score의 추정치를 구해야 한다. 그런데 Cross-entropy 손실함수나 제곱손실함수를 사용하면 각 손실함수 $L$에 대해 다음이 성립한다.

$$

P(A=1\vert X) = \arg\min_{g}\mathrm{E}[L(A,g(X)]


$$

즉, 해당 손실함수 하에서 처치변수 $A$로 교란변수 $X$를 예측하는 회귀모형을 만들면 이를 통해 propensity score의 추정이 가능해진다.

### Hájek estimator

그러나 역확률가중추정치의 경우 어떠한 특정 대상의 propensity score가 0이나 1에 가깝게 되면 해당 대상에 대해 가중치가 극도로 커지는 문제가 발생한다. 이로 인해 추정치의 분산이 매우 커지게 되고, 이러한 문제를 극복하기 위해 Hájek은 IPW를 구조적으로 개선한 다음과 같은 추정치를 제안했다.

$$

\hat \tau^{\mathrm{Hajek}} := \sum_{i} Y_{i}A_{i}\frac{\hat g(X_{i})^{-1}}{\sum_{i} A_{i}\hat g(X_{i})^{-1}} - \sum_{i} Y_{i}(1-A_{i})\frac{(1-\hat g(X_{i}))^{-1}}{\sum_{i}(1-A_{i})(1-\hat g(X_{i}))^{-1}}


$$

이를 **Hajek estimator**라고 한다. Hajek estimator의 분산은 일반적인 IPW의 분산보다 더 낮고 더 안정적인 추정이 가능하다 (Hirano, Imbens, Ridder, 2003). 또한, Hajek estimator는 각 가중치를 정규화했기 때문에, 각 그룹에서의 합이 1이 되는 특성이 존재한다.

## Augmented IPW estimator

앞서 살펴본 두 가지 방법은 각각 교란변수와 결과변수, 교란변수와 처치변수 간의 관계를 모델링하는 관점을 근간으로 한다. 각 방법에서 핵심은 결국 추정치 $\hat Q,\hat g$ 를 구하는 것인데, 이는 표본의 수가 많지 않으면 좋은 추정치가 되지 못한다. 수렴속도<sup>convergence rate</sup>이 매우 느리기 때문이다($\sqrt{n}$ 의 수렴속도, Xinwei Ma, Jinshen Wang, 2019).

구체적으로, 역확률 추정치는 propensity score $g$가 정확한 경우 일치성<sup>consistency</sup>을 갖는 반면 outcome adjustment 추정치는 모형 $Q(A,X)$가 정확할 경우 일치성을 갖는다.

따라서, 이를 해결하기 위해 $Q,g$의 추정치를 결합해 사용하기도 하는데 이러한 방식을 **augmented inverse probability weighted estimator**<sup>AIPW estimator</sup>라고 하며, 두 방식을 모두 사용해 robust하다는 의미에서 **Doubly Robust Estimator**라고도 한다. 이는 다음과 같이 outcome adjustment 추정치에 propensity score에 기반한 안정화 항이 추가된 형태로 정의된다.

$$

\hat \tau^{dr}:= \frac{1}{n}\sum_{i}\hat Q(1,X_{i}) - \hat Q(0, X_{i}) + A_{i}\frac{Y_{i}-\hat Q(1,X_{i})}{\hat g(x_{i})} -(1-A_{i})\frac{Y_{i}-\hat Q(0,X_{i})}{1-\hat g(X_{i})}

$$

### Induction

이는 다음 성질로부터 유도된다. 맞게 설정된 $Q,g$에 대해


$$
\begin{align}
\tau &= \mathrm{E}\bigg[ \frac{AY}{g(X)} - \frac{Z-g(X)}{g(X)}Q(1,X)\bigg]- \mathrm{E}\bigg[\frac{(1-A)Y}{1-g(X)} + \frac{A-g(X)}{1-g(X)}Q(0,X)\bigg]\\
&= \mathrm{E}\bigg[ Q(1,X_{i})+ \frac{A_{i}(Y_{i}-Q(1,X_{i}))}{g(X_{i})} \bigg]- \mathrm{E}\bigg[ Q(0,X_{i})+ \frac{(1-A_{i})(Y_{i}-Q(0,X_{i}))}{1-g(X_{i})} \bigg]\\
&= \mathrm{E}[Y\vert do(A=1)] - \mathrm{E}[Y\vert do(A=0)]
\end{align}
$$

### Properties

- Doubly Robust estimator $\hat \tau^{dr}$ 는 propensity score나 outcome regression의 두 모델 중 하나만 정확하게 설정되어 있으면 일치성을 갖는다.
- $g,Q$가 모두 정확히 모델링 되어있다면 DR 추정치는 역확률가중추정치보다 더 적은 분산을 갖는다.
- Outcome model $Q$만 정확히 모델링 된다면, DR 추정치는 일반적인 outcome adjustment 추정치보다 더 큰 분산을 갖는다.


# References
- K. Murphy, Probabilistic Machine Learning-Advanced Topics