---
title: "Gradient Boosting Machine"
tags:
- Machine Learning
- GBM
- Tree
- Boosting
category: Machine Learning
use_math: true
header: 
 teaser: /assets/img/Gradient Boosting.assets/Gradient_Boosting_1.png
---
{% raw %}
## Gradient Boosting Machine

이번 글에서는 [Boosting](https://ddangchani.github.io/machine%20learning/boosting/) 알고리즘과 관련하여, 특히 함수추정과 예측 문제에서 뛰어난 성능을 보이는 Gradient Boosting Machine에 대해 살펴보고자 한다. 여기서는 GBM을 제안한 Jerome H. Friedman의 *Greedy Function Approximation: A Gradient Boosting Machine* 이라는 논문을 리뷰해보며 함수추정의 전반적인 내용과 GBM에 대해 살펴보도록 하겠다.

## Function Estimation

함수 추정이란, 머신러닝의 예측 문제에서 머신러닝 모델을 개발하는 것과 동일하다. 즉, 예측변수를 바탕으로 반응변수의 추정치를 계산하는 함수 $f$를 추정하는 것이다. 이때 이러한 과정은 어떠한 손실함수의 기댓값<sup>expected value</sup>을 최소화하는 방식으로 이루어진다. 손실함수 $L$이 주어졌을 때, 함수 $f$와 반응변수 $y$를 이용한 데이터셋의 Loss는

$$

L(f)=\sum_{i=1}^N L(y_i,f(x_i))

$$

와 같이 주어진다. 여기서 핵심은 $f$에 대해 $E_{y,x}L(f)$ 값을 최소화하는 것이다. 그런데, 아무것도 주어지지 않은 상태에서 어떤 함수를 추정하는 것은 불가능에 가깝다. 그렇기에 우리는 이러한 함수가 존재할 수 있는 함수들의 집합, 즉 함수족<sup>class of functions</sup> $\mathcal F(X:P)$ 를 정의하고, 함수족의 원소 중에서 손실함수으 최적화가 이루어지는 특정 함수 $\hat f$ 를 선택하는 것이다. 여기서 $P=\{P_1,P_2,\ldots\}$는 parameter들의 유한집합, 즉 함수족의 개별 함수들을 구분짓는 모수 집합이다. **Boosting** 알고리즘의 경우, 특별히 개별 함수들을 additive한 모델로 표현하여(Boosting - basis expansion과의 관계 [참조](https://ddangchani.github.io/machine%20learning/boosting/)) 모수화<sup>parameterization</sup>하였다. 즉, 

$$

f(x:\{\beta_m,\gamma_m\}_1^M) = \sum_{m=1}^M\beta_mh(x:\gamma_m)\tag{1}

$$

의 형태를 취하는 함수들로 함수족 $\mathcal F$를 정의하기로 한다.

### Numerical Optimization

Parameterization이 이루어지면, 함수 추정의 문제는 곧 모수 최적화<sup>parameter optimization</sup>의 문제로 변환된다. 즉, 기존의 함수 최적화 문제에서

$$

\hat P = \arg\min_P E_{y,x}L(y,f(x:P))

$$

의 모수 최적화 문제로 변환된다. 이러한 문제를 해결하기 위해서는 수치적 최적화과정이 필요한데, 이는 최적 모수 $\hat P$를 

$$

\hat P = \sum_{m=0}^M \mathbf p_m

$$

와 같이 단계별 successive increment들로 표현했을 때 각 단계에서의 increment를 계산하는 과정을 의미한다. 반면, parameterization 없이 non-parametic한 방법으로도 numerical optimization을 진행할 수 있다.

우선 함수 최적화 문제를 아래와 같이 numerical 한 형태로 표현할 수 있다.

$$

\hat {\mathbf f} = \arg\min_{\mathbf f} E_{y,x}L(\mathbf f)\tag{1}

$$

여기서 $f$ 대신 볼드체 $\mathbf f$로 표기한 이유는, $\mathbf f$를 함수로 보지 않고 각 예측변수에 대한 함수값으로 구성된 근사함수(벡터)로 보기 때문이다. 즉, $\mathbf f\in \mathbb R^N$ 이며,

$$

\mathbf f = \{f(x_1),f(x_2),\ldots,f(x_N)\}^T

$$

로 주어진다. 이때 이처럼 함수를 수치적으로 근사하여 최적화 문제를 해결하는 방식을 (Non-parametic) **Numerical Optimization**이라고 하며, 이는 위 식 (1)을 successive increments $\mathbf h_m$ 들의 합으로 해결한다. 즉,

$$

\mathbf f_M = \sum_{m=0}^M \mathbf h_m, \;\;\mathbf h_m\in \mathbb R^N

$$

으로 주어진다. 각각의 successive increment를 step 혹은 boost라고 하며, $m=0$인 경우의 $\mathbf f_0 = \mathbf h_0$은 초기값을 의미한다. Numerical optimization에서 각각의 연속적인<sup>successive</sup> $\mathbf f_m$들은 직전 단계의 parameter vector $\mathbf f_{m-1}$ 로부터 유도된다. 이때 새로이 $\mathbf f_m$이 계산될 때 $\mathbf h_m$ 이 추가되는 방식, 즉 **increment vector** $\mathbf h_m$을 계산하는 방식에 따라 Numerical optimization의 큰 방식이 분류된다.

### Steepest Descent

Steepest Descent 방식에서는 scalar $\rho_m$, vector $\mathbf g_m\in \mathbb R^N$에 의해 계산이 이루어지는데, 이때 **gradient vector** $\mathbf g_m$은 Loss function의 그래디언트로

$$

\mathbf g_m=\{g_{im}\}_{i=1}^N = \bigg[\frac{\partial L(y_i, f(x_i))}{\partial f(x_i)}\bigg]_{f(x_i) = f_{m-1}(x_i)}

$$

와 같이 $\mathbf{f=f}_{m-1}$ 에서의 $L$의 그래디언트로 정의되며 Optimization은 각 step에서

$$

\mathbf h_m = -\rho_m\mathbf g_m

$$

으로 진행된다. 또한, 각 step마다의 학습정도를 나타내는 *step length* $\rho_m$은 다음 식의 해이다.

$$

\rho_m = \arg\min_\rho E_{y,x}L(y,\mathbf f_{m-1}-\rho\mathbf g_m)

$$

즉, 이러한 일련의 과정으로 current solution은 다음과 같이 update된다.

$$

\mathbf f_m = \mathbf f_{m-1}-\rho_m\mathbf g_m

$$

위와 같은 Steepest descent 방식은 $L(\mathbf f)$가 가장 빠르게 감소하는 지점에서 decreasing이 일어나므로, 매우 greedy한 알고리즘으로 볼 수 있다.

## Finite Data

앞선 nonparametic numerical optimization은 타당해보이지만, 만일 데이터셋이 $\{y_i,x_i\}_{i=1}^N$ 처럼 유한하게 주어지고, 이를 바탕으로 joint distribution을 추정하는 경우 문제가 생긴다. 이 경우 $x$에 대한 $y$의 조건부 기대값 $E_y[\cdot\vert x]$ 가 정확하게 추정될 수 없으며, 추정이 가능할지라도 실제 머신러닝 문제에서는 training data가 아닌 새로운 데이터셋에 대한 추정치를 구해야하는 상황이 요지이기 때문이다. 이를 해결하기 위해서는 앞선 식 (1)의 parameterized form을 이용해 다음과 같이 손실함수의 기댓값<sup>expected loss</sup>를 최소화하하는 문제로 치환해야한다.

$$

\{\beta_m,\gamma_m\}_1^M = \arg\min_{\{\beta_m',\gamma_m'\}}\sum_{i=1}^N
L\bigg(y_i,\sum_{m=1}^M\beta_m' h(x_i:\gamma_m')\bigg)

$$

이를 해결하기 위해, 다음과 같은 [Forward-stagewise additive modeling](https://ddangchani.github.io/machine%20learning/boosting/)과 유사한 *greedy-stagewise* approach를 생각해 볼 수 있다. 즉, 각 단계 $m=1,\ldots,M$ 에 대해 

$$

(\beta_m,\gamma_m) = \arg\min_{\beta,\gamma}\sum_{i=1}^NL(y_i, f_{m-1}(x_i)+\beta h(x_i:\gamma))\tag{2}

$$

로 각 단계의 parameter들을 구하여

$$

f_m(x)= f_{m-1}(x)+\beta_mh(x:\gamma_m)

$$

으로 update를 진행하는 방식이다. 여기서 $y\in\{-1,1\}$이고 $L(y,f) = e^{-yf}$ 로 주어지면 이를 Boosting이라고 한다(Boosting 게시글 참고).

### Gradient Boosting

그런데, 만일 앞선 최적화 과정에서 식 (2)에 대한 최적화 해가 쉽게 구해지지 않는다고 하자. 그러면 전 단계의 근사함수 $f_{m-1}(x)$ 에 대해 steepest-descent 방식으로 $N$-dimensional vector인 steepest-descent step direction $-\mathbf g_m$을 구하는 방법을 고려해볼 수 있다. 그러나 이 그래디언트는 오직 training data $\{x_i\}_{i=1}^N$ 에 대해서만 정의되고, 다른 $x$값들에 대해서는 일반화되기 어렵다. 

따라서 다른 $x$값에도 일반화하기 위해 Steepest-descnet의 $\rho_m \mathbf g_m$ 을 이용한 최적화 과정 대신 $\beta_m h(x)$ 를 이용해야 할 것이다. 이때 함수족 $\{h(x:\gamma_m)\}$ 에서 $-\mathbf g_m\in \mathbb R^N$ 에 가장 평행한<sup>parallel</sup> 함수를 고른다면 이는 전체 데이터 분포에 걸쳐 $-g_m(x)$와 가장 큰 상관관계를 갖는 solution이 될 것이다. 이는 다음 식으로부터 구할 수 있다.

$$

\gamma_m = \arg\min_{\gamma,\beta}\sum_{i=1}^N[-g_m(x_i)-\beta h(x_i,\gamma)]^2

$$

이렇게 얻어진 constrained negative gradient $h(x:\gamma_m)$ 를 steepest descent 알고리즘에 대입시켜 다음과 같이 $\rho_m$을 구하고,

$$

\rho_m = \arg\min_\rho\sum_{i=1}^N L(y_i,f_{m-1}(x_i+\rho h(x_i:\gamma_m)))

$$

이로부터 다음과 같은 update 과정을 실행하면 된다.

$$

f_m(x) = f_{m-1}(x)+\rho_m h(x:\gamma_m)

$$

전체적인 알고리즘은 아래 그림과 같다.

![스크린샷 2022-04-18 오전 10.26.16](/assets/img/Gradient Boosting.assets/Gradient_Boosting_0.png){: .align-center}

## Application

앞서 살펴본 GBM의 알고리즘은 다양한 손실함수와 모델에 대해 사용될 수 있다. 여기서는 논문에서 다룬 것들 중 대표적으로 OLS와 GBM Tree만 간단히 다루어보도록 하자.

### Least-Squares Regression

Least Squares에서는 손실함수가 $L(y,F) = (y-F)^2/2$ 로 주어진다(*미분의 편의를 위해 2로 나누어줌*). 이를 바탕으로 다음과 같은 Gradient Boost가 이루어진 Least Squares 알고리즘을 고안할 수 있다.

![](/assets/img/Gradient Boosting.assets/Gradient_Boosting_1.png){: .align-center}

3번째 줄의 $\tilde y_i$는 current residual을 의미하고, current residual을 fit하는 $\rho_m$은 $m$번째 단계에서 생성되는 회귀계수 $\beta_m$을 의미한다.

### Gradient-Boosted Tree(Regression)

여기서는 Terminal node가 $J$개인 J-terminal node regression tree 모델을 살펴보도록 하자. 각각의 트리 모델의 base learner $h$는 우선 다음과 같은 additive한 형태로 나타낼 수 있는데,

$$

h(x:\{b_j,R_j\}_1^J) = \sum_{j=1}^J b_j I(x\in R_j)

$$

여기서 base learner의 paremeter $\gamma_j$로 작용하는 $R_j$와 $b_j$는 각각 region과 region에서의 상수값(constant)을 의미한다. 이때 Gradient Boost 알고리즘(Algorithm 1 참고)의 update line은

$$

f_m(x) = f_{m-1}(x) + \rho_m\sum_{j=1}^J b_{jm}I(x\in R_{jm})\tag{3}

$$

으로 이루어지며, 여기서 $R_{jm}$은 각 $m$번째 단계에서의 terminal node들에 의해 정의된다. Gradient-Boost 알고리즘에서 각 pseudo-response($\tilde y_i$)에 대한 예측은 이전 단계의 $R_{j,m-1}$ 트리를 바탕으로 이루어지며, 이를 바탕으로 각 coefficients들은

$$

b_{jm}=\text{ave}_{x_i\in R_{jm}}[\tilde y_i]

$$

으로 생성된다. 이때 위 식 (3)은 다음과 같이 볼 수 있는데,

$$

f_m(x) = f_{m-1}(x) + \sum_{j=1}^J \gamma_{jm}I(x\in R_{jm})

$$

여기서 $\gamma_{jm}=\rho_m b_{jm}$ 을 의미한다. 그런데, 위 식은 각 단계에서 $J$개의 basis function인 $I(x\in R_{jm})$이 추가되는 것으로 볼 수 있으므로 각 $j$에 대해 최적의 계수를 선택하여 적합도를 더 높이는 방안을 고안할 수 있다. 즉, 다음과 같이 $\gamma$를 구할 수 있다.

$$

\{\gamma_{jm}\}_1^J = \arg\min_{\{\gamma_j\}_1^J}
\sum_{i=1}^N L\bigg(y_i, f_{m-1}(x_i)+\sum_{j=1}^J\gamma_j I(x\in R_{jm})\bigg)

$$

이때, 각 region들은 disjoint하기 때문에 위 식은 다음과 같이 축소되고, 이는 각각의 terminal region들에 대해 current approximation $f_{m-1}$을 바탕으로 최적의 constant를 update하는 과정이라고 볼 수 있다.

$$

\gamma_{jm}=\arg\min_\gamma\sum_{x_i\in R_{jm}}L(y_i, f_{m-1}(x_i)+\gamma)

$$

 만일 Mean Absolute Error을 손실함수로 사용한다면(이를 LAD<sup>Least Absolute Deviance</sup> Regression이라고 한다), 각 계수들은 다음을 통해 구해진다.

$$

\gamma_{jm}=\text{median}_{x\in R_{jm}}[y_i- f_{m-1}(x_i)]

$$

전체적인 알고리즘은 다음과 같다.

![](/assets/img/Gradient Boosting.assets/Gradient_Boosting_2.png){: .align-center}

## Interpretation

GBM에서 추가적으로 주목해볼 수 있는 것은 각각의 예측변수들이 반응변수의 예측 과정에서 미치는 영향을 파악할 수 있다는 점이다. 즉, 함수 $f$의 추정치 $\hat f$에 대해 각 변수 $x_j$(열벡터)들의 상대적인 영향(relative influence) $I_j$를 측정할 수 있고, 그 예시로 다음과 같이 주어질 수 있다.

$$

I_j=\bigg(E_X\bigg[\frac{\partial \hat f(X)}{\partial x_j}\bigg]^2\cdot \text{Var}_X[x_j]\bigg)^{1/2}\tag{4}

$$

일반적인 Tree model $T$의 경우 위 식 (4)와 같은 형태로 $I_j$를 직접 구할 수 없다. 따라서 이에 대한 추정치를 다음과 같은 방법으로 구한다.

$$

\hat I_j^2(T)=\sum_{t=1}^{J-1}\hat i_t^2I(v_t = j)

$$

여기서 $J-1$개의 합으로 구성된 이유는 $J$-terminal node tree $T$의 non-terminal node들로 오차합을 구하기 위함이다. 이때 $v_t$는 각 노드 $t$에 대한 splitting variable을,  $\hat i_t^2$는 각 노드 $t$에 대해 split의 결과로 발생하는 Squared-error의 개선치를 나타낸 것으로 어떤 Region $R$이 subregions $R_l,R_r$로 split될 때 각 subregion들의 가중치와 y값들의 평균치를 이용해

$$

i^2(R_l,R_r) = \frac{w_lw_r}{w_l+w_r}(\bar y_l - \bar y_r)^2

$$

로 주어진다. Gradient-Boosted Tree의 경우 Tree들의 합 $\{T_m\}_1^M$ 으로 주어지므로, Influence 추정치는 다음과 같이 개별 트리들의 추정치들의 합 형태로 주어진다.

$$

\hat I_j^2 = {1\over M}\sum_{m=1}^M \hat I_j^2 (T_m)

$$


# References

- The Elements of Statistical Learning
- Greedy Function Approximation: A Gradient Boosting Machine, Jerome Friedman, 1999
{% endraw %}