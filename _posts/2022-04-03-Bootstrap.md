---
title: "Bootstrap"
tags:
- Machine Learning
- Bootstrap
- Statistics
category: Machine Learning
use_math: true
---
{% raw %}
## Bootstrap Methods

Bootstrap 방법은 정확도(accuracy)를 측정하기 위해 사용되는 일반적인 방법이다. Cross-validation과 마찬가지로 bootstrap은 (conditional) [test error](https://ddangchani.github.io/machine%20learning/Model_Assessment/) $\text{Err}_\mathcal T$ 를 추정하기 위해 사용되지만, 일반적으로 기대예측오차 $\text {Err}$ 만을 잘 추정해낸다.

### 정의

크기가 $N$인 Training set이 $\mathbf Z=(z_1,\ldots,z_N)$ 와 같이 주어졌다고 하고, 이때 각 데이터는 $z_i=(x_i,y_i)$ 로 구성되었다고 하자. **Bootstrap**은 이러한 training data에서 무작위로 **복원추출**을 진행하는 것인데, 추출한 sample의 크기가 원래 training set의 크기 $N$과 동일할 때까지 추출한다. 이 과정을 $B$번 진행하면 $B$개의 **bootstrap dataset**이 생성되고, 이렇게 생성된 $B$개의 데이터셋에 대해 모델의 성능을 측정하는 것을 bootstrap 과정이라고 한다.

Training set $\mathbf Z$에 대해 어떤 정확도 지표 $S(\mathbf Z)$를 측정하는 상황이라고 하자. 즉, 우리가 관심있는 대상(qunatity of interest)은 $S(\mathbf Z)$이고, 이에 대한 통계적 정확도를 측정해야 한다. 이를 위해 $B$번의 bootstrap을 실행하여 데이터셋 $Z^1,\ldots,Z^B$ 각각에 대해 $S$값을 계산하여, 이들을 $S(Z^1),\ldots,S(Z^B)$ 라고 두자. 그러면 이로부터 원래 $S(\mathbf Z)$의 sample distribution를 다음과 같이 얻을 수 있다.

$$

\bar S=\frac{\sum_b S(Z^b)}{B}, \widehat{\text{Var}}={1\over B-1}\sum_{b=1}^B(S(Z^b)-\bar S)^2

$$

### Bootstrap prediction error

이번에는 앞서 설명한 bootstrap 방법을 이용해 예측오차를 추정하는 방법에 대해 생각해보자. 먼저, 각 bootstrap 데이터셋($b=1,\ldots,B$)에 대해 모델을 추정하는 방법을 생각하자($\hat f^b$). 그러면 이를 이용해 손실함수의 표본평균으로 예측오차의 추정량을 다음과 같이 정의할 수 있다.

$$

\widehat{\text{Err}}_{boot}={1\over B}\sum_{b=1}^B{1\over N}\sum_{i=1}^N L(y_i,\hat f^b(x_i))

$$

그러나, 이는 올바른 추정량이 될 수 없다. 손실함수를 계산하는데 쓰이는 데이터, 즉 test sample의 역할을 하는 데이터가 각 $z_i=(x_i,y_i)$ 로 원래 Training set $\mathbf Z$인 반면 훈련에 쓰인 데이터는 $\mathbf Z$에서 추출한 bootstrap set들이기 때문이다. 즉, 훈련과 테스트 데이터의 성격이 매우 유사하여 test error의 추정량으로서의 의미가 없어진다. 만일 위 추정량을 이용하게 되면 예측오차가 비현실적으로 좋게 추정되고, 그렇기 때문에 [cross-validation](https://ddangchani.github.io/machine%20learning/Cross_Validation/)의 경우 training-test data가 중첩되지 않도록 하는 것이다.

### Bootstrap error의 개선

$\widehat{\text{Err}}_{boot}$의 성능을 개선하기 위해, 우선 bootstrap이 예측오차 추정에 주는 영향을 간단한 예를 통해 살펴보도록 하자.

> 클래스 $\{0,1\}$ 각각 $N$개의 데이터가 있는 분류 문제에 1-Nearest Neighbor 분류기를 이용한다고 하자. 그러면 0-1 loss를 이용할 때 원 데이터셋의 true error(rate)는 0.5가 된다. 하지만 bootstrap을 이용하게 되는 경우 $\widehat{\text{Err}}_{boot}$은 true error보다 낮아지게 된다. 만일 $j$번째 관측값이 $k$번째 bootstrap sample에 포함되지 않으면
> 
> $$
> 
> \widehat{\text{Err}}_{boot}={1\over N}\sum_{i=1}^N{1\over B}\sum_{b=1}^B L(y_i,\hat f^b(x_i))
> 
> $$
> 
> 위 식에서 $i=j, b=k$인 항의 값이 $0$이 되므로 true error보다 낮아지게 된다. 이때 낮아지는 정도는 $i$번째 관측값이 $b$번째 bootstrap sample에 속하지 않을 확률, 즉
> 
> $$
> 
> \begin{aligned}
> P\{\text{observation  }i\notin \text{bootstrap sample } b\} &=1-[1-(1-{1\over N})^N]\\
> &\approx e^{-1} = 0.368
> \end{aligned}
> 
> $$
> 
> 에 비례한다. 즉, $\widehat{\text{Err}}_{boot}$의 기댓값은 대략 $0.5\times0.368 = 0.184$ 가 되고, 실제 true error 0.5에 비해 많이 낮은 수치이다.

즉, 위 예시에서 문제가 되었던 것은 bootstrap이 특정 관측값을 포함하지 않는 경우이고, 이를 해결하기 위해 [LOOCV](https://ddangchani.github.io/machine%20learning/Cross_Validation/)와 유사한 방법을 사용해야 한다. 각각의 관측값 $z_i$에 대해 $z_i$를 포함하지 않는 bootstrap sample만을 다루자. 즉, $z_i$를 포함하지 않는 bootstrap sample들의 인덱스 집합을 $C^{-i}$로 두고, 이때 샘플의 개수를 $\vert C^{-i}\vert $로 쓰자. 이를 이용해 다음과 같이 예측오차에 대한 *Leave-one-out* bootstrap(LOOB) 추정치를 정의할 수 있다.

$$

\widehat{\text{Err}}^{(1)}={1\over N}\sum_{i=1}^N{1\over\vert C^{-i}\vert }\sum_{b\in C^{-i}}L(y_i,\hat f^b(x_i))

$$

이때 주의해야 할 것은, 모든 bootstrap sample이 어떤 관측값 $z_i$를 모두 포함하면 $\vert C^{-i}\vert =0$이 되므로 모든 관측값에 대해 $\vert C^{-i}\vert >0$이 되도록 큰 $B$값을 설정해야 한다는 것이다. 또한, 앞서 살펴본 *특정 관측값이 어떤 bootstrap sample에 포함될 확률* 0.632를 이용해 ".632 estimator"를 다음과 같이 정의할 수 있다(*자세한 유도과정은 복잡하므로 생략했다*).

$$

\widehat{\text{Err}}^{.632}=0.368\cdot\overline{\text{err}}+0.632\cdot\widehat{\text{Err}}^{(1)}

$$

앞선 0-1 class 분류 문제에 이를 적용하면, $\overline{\text{err}}=0$, $\widehat{\text{Err}}^{(1)}=0.5$ 이므로 .632 estimator는 0.316의 값을 갖는다. 그러나, 이 역시도 true error 0.5에 못미치는 bias을 갖는다. 이를 해결하기 위해, 과적합이 일어나는 정도를 수치화하여 이를 토대로 추정치를 개선할 수 있다.

#### .632+ estimator

우선, no-information error rate $\gamma$ 를 정의하자. 이는 input data와 클래스 레이블이 **독립**이라고 가정할 때 예측 규칙의 error rate로 정의된다. 하지만 실제 데이터는 독립성을 보장할 수 없으므로, 우리는 이에 대한 추정치를 다음과 같이 정의한다.

$$

\hat\gamma = {1\over N^2}\sum_{i=1}^N\sum_{i'=1}^NL(y_i,\hat f(x_{i'}))

$$

즉, 각 예측변수 $x_i$들과 반응변수 $y_i$들의 모든 가능한 $N^2$ 개의 조합에 대한 sample error rate를 추정치로 사용한다. 이를 이용하여 *상대적 과적합율<sup>relative overfitting rate</sup>* 을 다음과 같이 정의하는데, 이는 LOOB 추정치의 과적합이 상대적으로 얼만큼 발생했는지를 측정하는 변수이다.

$$

\hat R=\frac{\widehat{\text{Err}}^{(1)}-\overline{\text{err}}}{\hat \gamma-\overline{\text{err}}}

$$

위 값이 0이면 과적합이 일어나지 않음을 의미하고, 1이면 과적합의 정도가 no-information value $\hat\gamma-\overline{\text{err}}$와 일치함을 의미한다. 이를 바탕으로 다음과 같이 개선된 *.632+ estimator*을 얻을 수 있다.

$$

\widehat{\text{Err}}^{.632+}=(1-\hat w)\cdot\overline{\text{err}}+\hat w\cdot\widehat{\text{Err}}^{(1)}\\
\text{where  } \hat w=\frac{0.632}{1-0.368\hat R}

$$


# References

- The Elements of Statistical Learning, 2e.

 
{% endraw %}