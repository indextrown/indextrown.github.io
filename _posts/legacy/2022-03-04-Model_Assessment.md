---
title: "Model Assessment"
tags:
- Machine Learning
- Model Assessment
- Bias-Variance tradeoff
category: Machine Learning
use_math: true
---
{% raw %}
# How to make an assessment of a model?

우리가 어떤 머신러닝 모델을 만들었을 때, 모델의 성능은 어떻게 측정할 수 있을까🤔? 간단히 생각해보면, 서로 다른 데이터셋들에 대해 모델의 정확도를 측정하고, 이들을 종합해서 지표화하면 될 것이다(이때 데이터셋들은 확률적으로 **독립**이어야 할 것이다). 모델의 성능을 측정하는 것은 매우 중요한 문제이다. 실제로 모델을 개발해야 할 때, 다양한 성능지표가 이용될 수 있고 이에 따라 성능이 다르게 측정되어, 모델의 과적합이 유발되거나 하는 등의 문제가 발생하거나, 사용하는 머신러닝 기법 역시 달라질 수 있기 때문이다. 이번 게시글에서는 모델의 성능이 어떤 방법을 통해 측정되는지 기본적인 내용을 다루어보도록 하자.

## Bias-Variance tradeoff

머신러닝과 관련된 글들에서 계속적으로 등장하는 내용이 바로 편향과 분산의 최적화에 대한 내용이다. 모델의 복잡성이 증가할 수록 편향<sup>bias</sup>이 감소하지만 분산<sup>variance</sup>이 올라가고, 따라서 이 둘 사이의 tradeoff 관계를 적절히 맞출 hyperparameter(*ex. Spline Model에서 매듭의 개수*)를 조율하는 것이 중요한 문제이다.

Target Variable $Y$와 Input data(Vector) $X$에 대해 모델을 훈련시킨다는 것은, Training set $\mathcal{T}$로부터 적절한 모형을 설정하여 $Y$에 대한 예측값 $\hat f (X)$를 구하는 것이다. 당연히 주어진 변수와 예측값 사이에는 오차가 발생할 수 밖에 없으며, 이 오차를 측정하는 함수 $L(Y,\hat f(X))$ 를 Loss function<sup>손실함수</sup>라고 정의한다. 대표적으로 squared error $(Y-\hat f(X))^2$와 absolute error $\vert Y-\hat f(X)\vert $가 있고, 실제 머신러닝에서는 이에 대한 평균<sup>mean</sup> MSE, MAE를 사용한다.

#### Test error and Training error

**Test error**<sup>generalization error</sup>는 training data와 독립적인 test sample에 대한 예측오차<sup>prediction error</sup>로, 

$$

\text{Err}_\mathcal{T}=E[L(Y,\hat f(X))\vert \mathcal T]

$$

로 표현된다. 여기서 주목해야할 것은 Training set $\mathcal T$가 고정되어 있으므로, 위 test error는 고정된 특정 훈련 데이터셋을 기준으로 이와 독립적인 test sample을 대입한 경우의 오차를 의미한다. 즉, training set과 독립적인 test sample을 설정하는 것이 확률변수적 요소이므로, 위 식은 기댓값의 형태를 취하고 이는 randomness가 존재함을 의미한다. 

반면, **Training error**는 각 training data들에 대한 손실함수의 표본평균이다. 즉,

$$

\overline{\text{err}}=\frac{1}{N}\sum_{i=1}^NL(y_i,\hat f(x_i))

$$

를 의미한다. 이 두 가지 오차중 우리가 실제로 관심을 가져야 하는것은 훈련 중 오차가 아닌 실제 테스트를 수행했을 때의 오차에 대한 기댓값이다. 모델의 과적합이 발생하면 훈련 중 오차는 낮게 도출되지만, 실제 test error는 그렇지 못할 가능성이 높기 때문이다. 즉, Training error는 모델을 복잡하게 하여 bias를 낮추기만 한다면(과적합) 계속해서 감소하는 성질이 있는 반면, Test error는 bias가 낮아져도 모델의 복잡성이 올라가면 오차가 반드시 감소하지는 않는다 (*이는 다음 bias-variance decomposition에서 확인할 수 있다*). 만일 Training error가 0인 어떤 모델을 발견했다면, 이는 다른 데이터셋에서는 매우 형편없이 작동할 것이므로 사실상 training error는 test error의 좋은 추정치가 되지 못한다. 따라서, test error에 대한 다른 추정치가 요구된다.

## Bias-Variance Decomposition

훈련오차와 예측오차에 대한 추정치를 살펴보기 이전에, 편향과 분산에 대한 기본적인 관계를 살펴보도록 하자. 먼저, squared error<sup>제곱오차</sup>를 기준으로 살펴보도록 하자. 모델이 $Y=f(X)+\epsilon$ 형태로 주어지고 $E[\epsilon]=0, \text{Var}(\epsilon)=\sigma_\epsilon^2$ 이 성립한다고 가정하자. 이때 $X=x_0$에서의 기대예측오차<sup>EPE, Estimated Prediction Error</sup>는 다음과 같이 분해될 수 있는데, 이를 bias-variance decomposition이라고 한다.

$$

\begin{aligned}
\text{Err}(x_0) &=E[(Y-\hat f(x_0))^2\vert X=x_0]\\
&=\sigma_\epsilon^2+[E\hat f(x_0)-f(x_0)]^2+E[\hat f(x_0)-E\hat f(x_0)]^2\\
&=\sigma_\epsilon^2+\text{Bias}^2(\hat f(x_0))+\text{Var}(\hat f(x_0))
\end{aligned}

$$

마지막 식에서 첫째항은 모델의 추정에 관계없이 발생하는 데이터로부터의 오차이므로(일종의 잡음<sup>noise</sup>) 우리가 컨트롤 할 수 없다. 따라서 bias와 variance만이 남으며, 이는 tradeoff관계가 있으므로 모델의 복잡성을 컨트롤하는것이 필요하다.



## Estimate of Training error

Training set $\mathcal T=\{(x_1,y_1),(x_2,y_2),\ldots,(x_N,y_N)\}$ 가 주어지고 이를 바탕으로 어떤 모델 $f$ 를 만들었다고 하자. 이때 training data와 독립적인 새로운 test data $(X^0,Y^0)$에 대한 **test error**를 다음과 같이 나타내자. 이때 기댓값의 subscript $X^0,Y^0$은 test data를 확률변수로 한 기댓값임을 의미한다(*기댓값을 구할 때 test data의 joint pdf를 곱한다는 의미이다*).

$$

\text{Err}_\mathcal T=E_{X^0,Y^0}[L(Y^0,\hat f(X^0))\vert \mathcal T]

$$

그런데 training set $\mathcal T$ 역시 어떤 확률분포로부터 random하게 얻을 수 있는 데이터셋이므로, 우리는 $\mathcal T$를 확률변수로 보아 이에 대해 기댓값을 취할 수 있고, 이를 **Expected error**<sup>기대오차</sup>라고 정의하며 다음과 같이 표현된다.

$$

\text{Err}=E_\mathcal T E_{X^0,Y^0}[L(Y^0,\hat f(X^0))\vert \mathcal T]

$$

이때 expected error $\text{Err}$는 새로운 데이터에 대해 기존 test error보다 더 통계학적으로 접근할 수 있게 되는데, 일반적으로 test error $E_\mathcal T$를 추정하는 것보다 expected error $\text {Err}$을 추정하는 방법이 더 다양하고 효과적이기 때문인데, expected error는 randomness가 있는 모든 변수들에 대한 기댓값을 취한 것이므로 sample을 이용한 average가 더 쉽고 효과적이기 때문이다.

### Optimism

간단히 생각해보면, training error는 모델을 추정하는데 이용하는 데이터셋을 바탕으로 그대로 (training) error를 추정하기 때문에 랜덤성이 더 높은 test error보다 오차가 낮을 수 밖에 없다. 즉, Test error와 Training error의 불일치가 발생하는 것은 모델의 평가<sup>evaluation</sup>이 어떤 데이터셋에서 이루어지느냐에 기인한다. 우선 다음과 같이 정의된 **In-sample error**에 주목해보자.

$$

\text{Err}_{in}=\frac{1}{N}\sum_{i=1}^NE_{Y^0}[L(Y_i^0,\hat f(x_i))\vert \mathcal T]

$$

여기서 $Y_i^0$는 각 training point $x_i,\;\;i=1,2,\ldots,N$ 에 대해 각각 1개의(총 $N$개의) 새로운 반응변수를 관찰한 것을 의미한다. 즉, Training error와의 차이점은 training 데이터셋으로 모델 추정을 하고, training 데이터셋의 반응변수가 아닌 새로운 반응변수 $Y_i^0$ 를 확률변수로 한 기댓값을 이용했다는 것이다. 이때 In-sample error와 training error의 차이를 **optimism**이라고 정의하자.(*이 책의 저자는 아마 training error가 test error에 비해 일반적으로 더 낮으므로 더 optimistic한 error라는 의미에서 그렇게 이름붙인 것 같다🤔* )

$$

\text{op}\stackrel{\text{def}}{=}\text{Err}_\text{in}-\overline{\text{err}}

$$

또한, 앞서 말했듯 training error가 예측오차보다 더 낮으므로 optimism 값은  양의 값을 가진다고 보면 될 것이다. 마지막으로, In-sample error가 $Y$의 randomness를 가지므로 우리는 optimism에 대한 기댓값을 정의할 수 있다. 이때 아래 식의 세번째 항이 도출되는 것은 squared error를 이용하면 보일 수 있다(*사실 모든 loss function에 대해 성립한다*).

$$

\omega\stackrel{\text{def}}{=}\text{E}_Y(\text{op})={2\over N}\sum_{i=1}^N\text{Cov}(\hat y_i, y_i)

$$

따라서, training error가 In-sample error에 못미치는 정도 $\omega$는 각 반응변수 $y_i$가 그것의 예측값과 얼마나 연관되어있는지(공분산)에 비례한다. 즉, 주어진 데이터에 모델을 열심히 적합시킬수록 반응변수와 예측값의 공분산이 커질 것이고, 이로 인해 optimism 역시 증가하게 된다.

일반적으로 Training set에 대한 조건부 오류 $\text{Err}_\mathcal T$를 사용하는 것 대신 이에 대한 기댓값 $\text{Err}$을 추정하는 것과 마찬가지로, 여기에서도 optimism 값을 직접 사용하는 것 보다 $\omega$ 에 대한 추정치를 사용하게 된다.

### Estimates of In-sample prediction error

#### Mallow's C<sub>p</sub>

앞서 정의한 것 처럼 training error는 표본평균이므로, 우리는 In-sample error에 대해 다음과 같은 추정치를 정할 수 있다.

$$

\widehat{\text{Err}}_{\text{in}}=\overline{\text{err}}+\hat\omega\tag{1}

$$

이때 $\hat\omega$는 optimism 값의 기댓값($\omega$)에 대한 추정치이다. 앞서 설명한 것 처럼optimism의 기댓값인 $\omega$에 대해 다음이 성립하는데,

$$

\omega=\frac{2}{N}\sum_{i=1}^N\text{Cov}(\hat y_i,y_i)\tag{2}

$$

만일 제곱오차손실함수를 이용하고, $d$개의 모수가 추정되는 상황(*d개의 basis function이 이용되는 상황이라고 보면 된다*.)이라면 식 (1)과 (2)로부터

$$

C_p=\overline{\text{err}}+\frac{2d}{N}\hat\sigma_\epsilon^2

$$

라는 형태로 In-sample estimate를 정의할 수 있는데, 이를 **(Mallow's) C<sub>p</sub> statistic**이라도고 한다. 이를 이용하면, Training error를 구하고 사용되는 basis function의 개수($d$)에 비례한 In-sample error를 추정할 수 있다. 예시로, Linear Regression의 model selection 과정에서 $d$는 $\mathbf X$의 변수 개수가 $k$ 개일 때 선택된 index set $\{1,\ldots,k\}$ 의 부분집합의 cardinality를 의미한다.

#### AIC

AIC<sup>Akaike information criterion</sup>는 $C_p$와 마찬가지로 In-sample error에 대한 추정치로 사용되는데 로그가능도비<sup>log-likelihood</sup> 손실함수가 사용될 때 $C_p$ statistic보다 더 일반적으로 사용된다. 앞서 설명한 In-sample error와 training error의 관계에서

$$

\text{E}_Y[\text{Err}_{\text{in}}]=\text{E}_Y[\overline{\text{err}}]+{2\over N}\sum_{i=1}^N\text{Cov}(\hat y_i,y_i)

$$

이 성립함을 알 수 있었다. 위 관계식과 유사하게 다음 관계식이 $N\to\infty$ 일 때 점근적으로 성립하는데, 이때 아래 식의 값을 AIC라고 정의한다.

$$

-2\text{E}[\log L(\hat\theta:Y)]\approx-\frac{2}{N}\cdot\text{E}[l(\hat\theta)]+\frac{2d}{N}\tag{*}

$$

위 식에서 $L(\theta:Y)$ 는 반응변수 $Y$가 주어질 때 가능도함수를 의미하며(*loss function이 아님*) $\hat\theta$ 는 $\theta$ 에 대한 최대가능도추정량<sup>mle</sup>이고, $l(\hat\theta)$은 다음과 같은 최대화된 로그가능도를 나타낸다(*$l$은 로그가능도함수를 의미*).

$$

l(\hat\theta)=\sum_{i=1}^N\log L(\hat\theta:y_i)=\sum_{i=1}^N\log P(y_i:\hat\theta)

$$

예를 들어, 로지스틱 회귀 모형에서 binomial log-likelihood, 즉 이항분포의 로그가능도비를 사용한다고 하자. 그러면 AIC값은 다음과 같이 표현된다.

$$

\text{AIC}=-{2\over N}\cdot l(\hat\theta)+{2d\over N}

$$

> **Linear Regression 문제에서 AIC**
>
> $\theta = (\beta,\sigma^2)$, $\beta = (\beta_0,\beta_1,\ldots,\beta_p)^\top$ 조건에서 Linear model $Y=X\beta+\epsilon$ 을 추정한다고 하자(단, $\epsilon\sim N(0,\sigma^2\mathbf I)$). 그러면 확률밀도함수가
> 
> $$
> 
> f(Y_i,\beta,\sigma^2) = {1\over\sqrt{2\pi}\sigma}\exp[-(Y_i-\beta_0-\beta_1x_{i1}-\cdots-\beta_px_{ip})^2/(2\sigma^2)]
> 
> $$
> 
> 으로 주어지고 $S$를 $\{1,\ldots,p\}$ 의 부분집합이라 할 때 분산에 대한 추정량 $\hat\sigma_S^2=n^{-1}\Vert Y-X\hat\beta_S\Vert^2$ 을 취하면 AIC는 다음과 같다.
> 
> $$
> 
> \begin{aligned}
> \text{AIC}(S)&=\log(2\pi\hat\sigma^2_S)+\frac{\Vert Y-X\hat\beta_S\Vert^2}{n\hat\sigma_S^2}+\frac{2(\vert S\vert +1)}{n}\\
> &=\log\text{SSE}(S) + {2\vert S\vert \over n}
> \end{aligned}
> 
> $$
>

### BIC

AIC의 경우와 마찬가지로, mle를 이용하는 경우에 BIC<sup>Bayesian Information Criterion</sup>이 사용될 수 있다. 정의는 다음과 같다.

$$

\text{BIC}=-2\cdot l(\hat\theta)+d\log N

$$

정규분포 모델에서 오차항의 분산 $\sigma_\epsilon^2$ 가 알려져있다고 가정하면 $-2l(\hat\theta)=\sum_i(y-\hat f(x_i))^2/\sigma_\epsilon^2$ 이 성립하는데, 이는 제곱오차 손실함수에 대한 $N\cdot\overline{\text{err}}/\sigma_\epsilon^2$ 와 동일하기도 하다. 따라서 이를 통해 BIC를 아래와 같이 쓸 수 있다.

$$

\text{BIC} = {N\over\sigma^2_\epsilon}[\overline{\text{err}}+(\log N)\cdot{d\over N}\sigma_\epsilon^2]

$$

{% endraw %}