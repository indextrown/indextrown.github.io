---
title: "Partial Regression"
tags:
- Linear Model
- Regression
- Partial Regression
category: Linear Model
use_math: true
header: 
 teaser: /assets/img/Partial Regression.assets/Partial_Regression_0.png
---
{% raw %}
## Partial Regression

Linear Regression model에서 예측변수가 여러개일 때, 즉 multiple linear regression인 경우 각각의 변수 고유의 영향력을 파악하는 방법으로 partial regression이 있다(*[Partial Least Square algorithm](https://ddangchani.github.io/linear%20model/linearreg2/)과 명백히 다르다!*). 이에 대해 간단히 다루어보도록 하자. 우선 다음과 같은 회귀모형

$$

Y=X_1\beta_1+X_2\beta_2+\epsilon\tag{Full Model}

$$

이 존재한다고 하자. 이때, 예측변수 $X_1,X_2$ 중 $X_1$만을 사용하여 다음과 같이 새로운 모형을 만든다고 하자.

$$

Y=X_1\beta_1^{\ast}+\epsilon\tag{Reduced Model}

$$

그러면, 행렬 $X_1,X_2$가 직교하지 않는 한 OLS<sup>Ordinary Least Square</sup>를 이용해 추정한 회귀계수에 대해서 $\hat\beta_1\neq\hat\beta_1^{\ast}$ 이 성립한다(아래 참고).

> Full Model에 대한 Least squares:
> 
> $$
> 
> [ \hat\beta_1 \;\; \hat\beta_2 ]^\top = \begin{bmatrix}X_1^TX_1 & X_1^TX_2\\X_2^TX_1&X_2^TX_2\end{bmatrix}^{-1}\begin{bmatrix}X_1^TY\\X_2^TY\end{bmatrix}\tag{1}
> 
> $$
> 
> Reduced Model에 대한 Least squares:
> 
> $$
> 
> \hat\beta_1^{\ast} = (X_1^TX_1)^{-1}X_1^TY
> 
> $$
> 
> 로 주어지므로, 식 (1)에서 $X_1^TX_2=0$ 인 조건이 주어지면 $\hat\beta_1=\hat\beta_1^{\ast}$이 성립한다.

하지만 일반적으로 두 예측변수 행렬이 직교하는 경우는 거의 존재하지 않으므로, 예측변수 $X_1$에 대해 Full-Model에서의 회귀계수(벡터)와 Reduced-Model에서의 회귀계수는 편차가 존재하게 된다. 이와 관련하여 다음 정리가 성립한다.

### Frisch-Waugh-Lovell<sup>프리슈-워-로벨</sup> THM

FWL Theorem이라고도 하는 위 정리는 앞서 설명한 Full Model과 Reduced Model 간의 관계와 관련한 정리이다. 앞선 상황처럼 $X_1,X_2$가 예측변수로 주어진다고 하자. 이제 다음 두 단계를 진행하자.

1. 반응변수 $Y$를 $X_1$로만 Regression하여(**Reduced Model**) 이때의 잔차를 $Y^{\ast}$라고 두자.
2. 나머지 예측변수 $X_2$를 $X_1$로 Regression하여 이때의 잔차를 $X_2^{\ast}$라고 하자.

이때 $Y^\ast$을 반응변수로, $X_2^\ast$를 예측변수로 하는 선형회귀모형의 회귀계수와 **Full Model**에서의 $\hat\beta_2$ 는 동일하다.

> 증명. 
>
> 먼저 1단계에서의 잔차를 구하면 다음과 같다.
> 
> $$
> 
> Y^{\ast}=Y-X_1\hat\beta_1^{\ast}\\
> =(I-H_1)Y
> 
> $$
> 
> 여기서 $I$는 identity matrix, $H_1=X_1(X_1^TX_1)^{-1}X_1^T$ 는 [Hat Matrix](https://ddangchani.github.io/linear%20model/linearreg1/)이다. 마찬가지로, 이번에는 2단계에서의 잔차를 구해보도록 하자.
> 
> $$
> 
> X_2^{\ast}=X_2-X_1(X_1^TX_1)^{-1}X_1^TX_2\\
> =(I-H_1)X_2
> 
> $$
> 
> 이를 바탕으로 $$Y^{\ast}$$와 $$X_2^{\ast}$$를 이용한 회귀계수 $$\hat\beta_2^{\ast}$$를 구하면
> 
> $$
> 
> \hat\beta_2^{\ast} = (X_2^{*T}X_2^{\ast})^{-1}X_2^{*T}Y^{\ast} \\
> = (X_2^T(I-H_1)^2X_2)^{-1}X_2^T(I-H_1)^2Y
> 
> $$
> 
> 이때 $I-H_1$은 idempotent, symmetric 하므로
> 
> $$
> 
> \hat\beta_2^{\ast} = (X_2^T(I-H_1)X_2)^{-1}X_2^T(I-H_1)Y
> 
> $$
> 
> 으로 주어진다. 반면, Full Model에서 $X_2$의 계수를 구하면 위 식 (1)의 Block Matrix의 역행렬을 구하는 것으로부터 $$\hat\beta_2$$가 $$\hat\beta_2^{\ast}$$ 와 동일하게 주어짐을 확인할 수 있다. *(Block Matrix의 역행렬을 구하는 것은 어렵진 않으나 작성의 어려움으로 인해 생략*)

### Partial Regression Plot

데이터 분석에서는 선형모형의 변수 유의성을 확인하기 위해 Partial Regression Plot을 확인하는 경우가 종종 있다. 앞선 FWL 정리의 두 잔차 $X_2^{\ast}, Y^{\ast}$의 scatter plot과 Regression plot(Line)을 함께 나타낸 것이 Partial Regression Plot으로, 두 잔차는 모두 해당 변수($X_2, Y$)로부터 다른 변수들(각각 $X_1$, $X$ 전체)의 영향을 제거했다는 점에서 의미가 있는 벡터이다.

![스크린샷 2022-04-09 오후 7.36.48](/assets/img/Partial Regression.assets/Partial_Regression_0.png){: .align-center}

위와 같은 형태를 가지는데(python `statsmodels`패키지를 이용한 그래프이다), 여기서 $e(MEDV\vert X)$ 는 반응변수 MEDV를 예측변수 전체(X)로 회귀분석하여 나온 잔차(e)를 의미하고, $e(AGE\vert X)$는 변수 AGE를 남은 반응변수(X, AGE 제외)로 회귀분석하여 나온 잔차(e)를 의미한다. 위 plot의 경우는 AGE와 종속변수 MEDV가 상관관계가 없음을 보여주고 있고, 이러한 방식으로 선형모형의 각 변수들에 대한 partial regression을 진행하여 각각의 유의성을 파악할 수 있다.

# References

- https://datascienceschool.net/
- The Elements of Statistical Learning
{% endraw %}