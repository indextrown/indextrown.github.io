---
title: Bayesian Causal Inference
tags:
- Causal Inference
- Bayesian
category: ""
use_math: true
---

# Bayesian Causal Inference

## Setting

각 샘플 단위(개체)에 대해 다음과 같이 네 가지 변수가 존재한다.


$$

Y_{i}(0), Y_{i}(1), Z_{i}\in\{0,1\},X_{i} 


$$

이때 결과변수 $Y_{i}$에 대해서는 하나만 관측된다. 즉, 


$$

Y_{i}^{mis}=Y_{i}(1-Z_{i})


$$

의 관계가 성립한다. 그렇다면, 주어진 처치변수 $Z_{i}$에 대해 관측한 결과변수와 관측하지 못한 결과변수 사이에는 다음과 같은 mapping이 가능하다.


$$

Y_{i}^{obs}=Y_{i}(1)Z_{i}+Y_{i}(0)(1-Z_{i})


$$

베이지안 관점에서는, 위 세팅에서 관측되는 변수들은 확률변수의 실현<sup>realisation</sup>으로 보고, 그렇지 않은 변수들은 관측되지 않는 확률변수라고 본다.

## Factorization

우선, 베이지안 모델링을 위해 다음과 같이 joint density가 주어진다고 하자. 여기서 모수벡터는 $\theta=(\theta_{X},\theta_{Z},\theta_{Y})$ 로 모델링된다.

$$

P(\mathbf{Y}(0),\mathbf{Y}(1),\mathbf{Z},\mathbf{X}\; \vert\; \theta) = \prod_{i} P(Y_{i}(0),Y_{i}(1),Z_{i},X_{i}\vert \theta)


$$

이때 개별 샘플에 대한 결합확률밀도는 다음과 같이 분해될 수 있다. 참고 : [계층적 모델링](https://ddangchani.github.io/Spatial-Hierarchical-Model)<sup>Hierarchical Modeling</sup>


$$

\begin{align}
& P(Y_{i}(0),Y_{i}(1),Z_{i},X_{i}\vert \theta)  \\
& =  P(Z_{i} \vert Y_{i}(0),Y_{i}(1),X_{i};\theta_{Z})P(Y_{i}(0),Y_{i}(1)\vert X_{i};\theta_{Y})P(X_{i};\theta_{X})
\end{align}


$$

## Estimands

베이지안 관점에서 인과모형을 다룰 때에는 평균처치효과로 다음과 같은 세 가지 버전을 고려한다.

### Population ATE

모평균처치효과 PATE는 다음과 같이 정의된다.

$$

\tau^{P}=\int \tau(x;\theta_{Y})F(dx;\theta_{X})


$$

여기서 $\tau(x)=\mathrm{E}[Y_{i}(1)-Y_{i}(0)\vert X_{i}=x]=\mu_{1}(x)-\mu_{0}(x)$ 이며 $F(dx;\theta_{X})$ 는 공변량 $X$의 누적확률밀도함수를 의미한다. PATE는 잠재적 결과변수를 모집단에서 추출한 확률변수로 보고 이에 대한 기댓값을 취한다. 이때, 모수 $\theta_{X},\theta_{Y}$ 에 대한 사후분포<sup>posterior</sup>를 구해 베이지안 추론이 이루어진다.

### Sample ATE

표본평균처치효과 SATE는 다음과 같이 정의된다.

$$

\tau^{S} = \frac{\sum_{i=1}^{N} Y_{i}(1)-Y_{i}(0)}{N}


$$

그런데, SATE를 추정하기 위해서는 주어진 관측치로부터 missing potential outcome $Y_{i}^{mis}$를 추정해야 한다. 이러한 과정은 사후예측분포를 구성하여 이루어진다.

### Mixed ATE

일반적으로, 분석 과정에서 공변량의 확률분포 $P(X)$ 를 직접 모델링하지는 않는다. 대신 경험분포 $\hat F_{X}$를 사용하여 $F(x;\theta_{X})$ 를 대체한다. 이를 이용하여 PATE를 변형한 것이 혼합평균처치효과 MATE인데, 다음과 같이 정의한다.

$$

\begin{align}
\tau^{M} :&= \int \tau(x;\theta_{Y})d\hat F_{X}(x)\\
&= N^{-1}\sum_{i=1}^{N}\tau (X_{i};\theta_{Y})
\end{align}


$$

이때 $\tau(x)=\mathrm{E}[Y_{i}(1)-Y_{i}(0)\vert X_{i}=x]$ 로 정의되는 함수를 $X=x$ 에서의 CATE<sup>Conditional ATE</sup>라고 한다. MATE와 SATE의 차이점은, MATE는 공변량에 조건을 두는 반면 SATE는 결과변수에 조건을 둔다는 것이다.

## Example: Regression Adjustment

결과변수가 연속형인 실험을 생각하자. 우선, 결과변수에 대해 다음과 같은 이변량정규분포 모형을 상정하자.

$$

\begin{pmatrix} Y_{i}(1) \\ Y_{i}(0)\end{pmatrix} \vert (X_{i},\theta_{Y})
\sim BVN\bigg(\begin{pmatrix} \beta_{1}^{T} X_{i}\\ \beta_{0}^T X_{i}\end{pmatrix},
\begin{pmatrix}\sigma^{2}_{1} & \rho\sigma_{1}\sigma_{0} \\ \rho\sigma_{1}\sigma_{0} & \sigma_{0}^{2}\end{pmatrix}\bigg)


$$

그러면, 정규분포의 성질에 의해 다음과 같은 marginal (outcome) model을 얻을 수 있다. 


$$

\mu_{z}(x) := Y_{i}(z)\vert X_{i},\beta_{z},\sigma_{z}^{2}\sim N(\beta^{T}_{z}X_{i},\sigma_{z}^{2})\quad z=0,1


$$

이 경우 각 ATE들은 다음과 같이 구해진다.

- CATE : $\tau(x) = (\beta_{1}-\beta_{0})^T x$
- PATE : $\tau^{P} = (\beta_{1}-\beta_{0})^{T}\mathrm{E}X_{i}$
- SATE : $\tau^{S}= N^{-1}\sum_{i=1}^{N}\{Y_{i}(1)-Y_{i}(0)\}$
- MATE : $\tau^{M} = (\beta_{1}-\beta_{0})^{T}\bar X$

## Prior Independence

ATE를 추정하기 위한 두 가지 Assumption(unconfoundedness, [Overlap](https://ddangchani.github.io/Confounder-Adjustment)) 외에도 베이지안 추정을 위해서는 사전분포에 대한 가정이 필요하다. 이는 다음과 같다.

> Assumption : 처치변수, 결과변수, 공변량에 각각 해당되는 parameter $\theta_{Z},\theta_{Y},\theta_{X}$ 는 각각 독립이고 구별<sup>distinct</sup>되어야 한다. 이를 prior independence라고 한다.

### Ignorability

사전분포의 독립이 주어지면 다음과 같은 사후분포의 분해가 가능하다.

$$

\begin{align}
P(\theta_{X},\theta_{Z},\theta_{Y}\vert\cdot) &\propto 
P(\theta_{X})\prod_{i=1}^{N} P(X_{i}\vert\theta_{X})\\
&\times P(\theta_{Z})\prod_{i=1}^{N}P(Z_{i}\vert X_{i};\theta_{Z })\\
&\times P(\theta_{Y})\prod_{i=1}^{N }P(Y_{i}(1),Y_{i}(0)\vert X_{i};\theta_{Y})
\end{align}


$$

이때, $\theta_{X},\theta_{Y}$ 만 고려하면 두 모수의 사후분포는 $P(Z_{i}\vert X_{i};\theta_{Z})$ 에 의존하지 않게 된다. 즉, propensity score에 대해 독립인데, 이로 인해 모평균처치효과 PATE 역시 propensity score에 대해 독립이게 된다. 이를 **ignorable**하다고 부른다. 다시 말하면, **ignorability**라는 것은 인과 효과를 추정하는 과정에서 처치여부를 결정하는 메커니즘은 무시<sup>ignore</sup>해도 무방하다는 것이다.

## Bayesian Inference for ATE

### PATE, MATE

PATE와 MATE는 모두 결과변수 $Y_{i}(0),Y_{i}(1)$ 의 상관관계에 의존하지 않는다. 따라서 이들을 추정하기 위해서는 marginal model $P(Y_{i}(z)\vert X_{i},\theta_{Y})$ 를 관측데이터에서의 모델 $P(Y_{i}\vert Z_{i}=z,X_{i},\theta_{Y})$ 와 동일하게 설정하면 된다. 이 경우 관측데이터에서의 가능도함수는 다음과 같이 주어진다.

$$

\prod_{i:Z_{i}=1}P(Y_{i}\vert Z_{i}=1,X_{i},\theta_{Y })\prod_{i:Z_{i}=0}P(Y_{i}\vert  Z_{i}=0,X_{i},\theta_{Y})


$$

그 다음에는 $\theta_{Y}$에 대해 적절한 사전분포를 주어, 베이지안 추론과정을 거쳐 MAP estimator $\hat\theta_{Y}^{MAP}$를 얻으면 된다.

### SATE

반면, SATE의 경우는 각각의 결과변수들을 고정된 값으로 보기 때문에, 모수와 결측치 $\theta_{Y},Y^{mis}$ 에 대해 사후분포로부터의 샘플링이 요구된다. 즉, 실제 실험에서와 같이 처치 대상의 경우 해당 대상이 대조군이 되었을 때 결과변수를 관측할 수 없고, 이로 인해 분석 과정이 더욱 복잡하다. 다만, PATE, MATE보다는 낮은 uncertainty를 갖는다는 점에서 더 짧은 신뢰구간을 가진다. SATE의 추정 문제를 해결하기 위한 전략으로 두 가지가 소개되는데, 구체적인 과정은 다음과 같다.

#### Data Augmentation(Rubin, 1978)

$\theta$의 사전분포 하에서 두 분포 $P(\mathbf{Y}^{mis}\vert \mathbf{Y}^{obs},\mathbf{Z},\mathbf{X},\theta), P(\theta\vert \mathbf{Y}^{obs},\mathbf{Y}^{mis},\mathbf{Z},\mathbf{X})$ 로부터 각각 $\mathbf{Y}^{mis},\theta$ 를 반복적으로 샘플링한다. 이때 결측치에 대한 사후예측분포는 다음과 같다.


$$

P(\mathbf{Y}^{mis}\vert \mathbf{Y}^{obs},\mathbf{Z},\mathbf{X},\theta)\propto \\
\prod_{i:Z_{i}=1}P(Y_{i}(0)\vert Y_{i}(1),X_{i},\theta_{Y })\prod_{i:Z_{i}=0}P(Y_{i}(1)\vert  Y_{i}(0),X_{i},\theta_{Y})


$$

이후 각 샘플에 대해, 만일 샘플에 대해 처치가 이루어졌다면 $Y_{i}(0)$ 을 $P(Y_{i}(0)\vert Y_{i}(1),X_{i},\theta_{Y })$ 로부터 대체<sup>imputation</sup>하고, 샘플이 대조군인 경우(처치가 이루어지지 않은 경우) 그 반대로 대체한다. 그러면 사후분포

$$

P(\theta \vert \mathbf{Y}^{mis},\mathbf{Y}^{obs},\mathbf{Z},\mathbf{X})


$$

의 형태는 $\theta$의 사전분포에 대한 켤레분포로 구할 수 있다. 

##### Example

앞선 이변량정규분포의 예시에서는, 모수 $\beta,\sigma^{2}$ 에 대해 정규분포의 켤레사전분포(inverse $\chi^{2}$)를 설정하여 다음과 같이 결측치를 대체한다.

> $Z_{i}=1$ 인 경우(대상이 처치집단)
> 
> $$
> 
> Y_{i}(0)\;\vert \;- \sim N\bigg(\beta_{0}^{T}X_{i}+\rho \frac{\sigma_{0}}{\sigma_{1}}(Y_{i}^{obs}-\beta_{1}^{T}X_{i}),\sigma_{0}^{2}(1-\rho^{2})\bigg)
> 
> 
> $$
> 
> $Z_{i}=0$ 인 경우(대상이 대조집단)
> 
> $$
> 
> Y_{i}(1)\;\vert \;- \sim N\bigg(\beta_{1}^{T}X_{i}+\rho \frac{\sigma_{1}}{\sigma_{0}}(Y_{i}^{obs}-\beta_{0}^{T}X_{i}),\sigma_{1}^{2}(1-\rho^{2})\bigg)
> 
> 
> $$
> 


#### 2. Transparent Parameterization(Richardson et al. 2010)

관측데이터에 해당하는 벡터들을 다음과 같이 데이터 행렬로 정의하자.


$$

\mathbf{O}^{obs} := (\mathbf{X},\mathbf{Y}^{obs},\mathbf{Z})


$$

그러면 조건부확률의 정의에 의해 다음과 같은 분해가 자명하다.


$$

P(\mathbf{Y}^{mis},\theta\vert \mathbf{O}^{obs}) = P(\theta\vert \mathbf{O}^{obs})P(\mathbf{Y}^{mis}\vert \theta,\mathbf{O^{obs}})


$$

이로부터, 우선 우변의 첫번째 분포에서 관측데이터 하에서 $\theta$를 시뮬레이션하고, 다음으로 두번째 항으로부터 해당 $\theta$와 관측치 하에서 결측데이터를 시뮬레이션한다.

또한, **transparent parameterization**이라는 기법을 이용하는데, 이는 전체 모수벡터를 두 개의 모수벡터 $\theta^{m},\theta^{a}$ 로 나누는 것이다. 이때 $\theta^{m}$은 결과변수의 marginal 분포에 대한 모수이고, $\theta^{a}$ 는 association, 즉 결과변수 $Y_{i}(0),Y_{i}(1)$ 간의 관계를 모델링하는 것과 관련된 모수이다. 중요한 것은, 두 모수벡터가 **사전적 독립**이어야 한다.

이러한 설정 하에서, 다음과 같이 전체 모수벡터의 사후분포를 구성할 수 있다.

$$

\begin{align}
\mathrm{P}(\theta\vert\mathbf{O}^{obs}) \propto &\pi(\theta_{Y}^{a})\pi(\theta_{Y}^{m})\\ &\times \prod_{Z_{i}=1}\mathrm{P}(Y_{i}(1)\vert X_{i},\theta_{Y}^{m})\prod_{Z_{i}=0}\mathrm{P}(Y_{i}(0)\vert X_{i},\theta_{Y}^{m})
\end{align}


$$


##### Example

이전 이변량정규분포 결과변수 가정 예시에서, MATE 추정치 $\delta^{M} =N^{-1}\sum_{i=1}^{N}\delta(X_{i})$ 를 고려하자. 이때


$$

\delta(x) = \mathrm{P}(Y_{i}(1)>Y_{i}(0)\vert X_{i} = x,\theta_{Y}^{m},\theta_{Y}^{a})


$$

으로 주어진다. 그렇다면 추정치 $\delta^{M}$ 의 시뮬레이션은 다음을 기반으로 하는데,


$$

\delta^{M} = \frac{1}{N}\sum_{i=1}^{N}\Phi\bigg( \frac{(\beta_{1}-\beta_{0})^T X_{i}}{(\sigma_{1}^{2}+\sigma_{0}^{2}-2\rho\sigma_{1}\sigma_{0})^{\frac{1}{2}}}\bigg)


$$

여기서 $\rho$는 sensitivity analysis의 parameter로서 작용한다.

# References
- STA 790 Lecture Notes of Duke University, Fan Li.