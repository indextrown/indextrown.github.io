---
title: "An Overview of Statistical Learning"
tags:
- Machine Learning
- VC Dimension
- Empirical Risk
- Vapnik-Chervonenkis Dimension
- Statistical Learning
category: Machine Learning
use_math: true
---
{% raw %}
## Empirical Risk 사용의 근거?

이번 게시글은 Statistical Learning, 즉 통계적 학습이론의 근간이 되는 추정 이론 중 Empirical risk 사용의 근거와 관련 이론에 대해 살펴보도록 하자. 내용은 대표적인 머신러닝 알고리즘인 Support Vector Machine의 공동 창시자 Vladimir N. Vapnik의 *’An Overview of Statistical Learning’(1999)* 논문을 바탕으로 하였다. 

### Learning Problem
통계적 학습이론(혹은 머신러닝)의 근간은 함수추정(function estimation) 과정이다. 즉, i.i.d인 N개의 관측값(training data)

$$

(x_1,y_1),\ldots,(x_N,y_N)

$$

이 주어질 때 함수들의 집합 $\{f(x,\alpha):\alpha\in\Lambda\}$에서 데이터를 가장 잘 설명하는 특정 함수 $f(x,\alpha_0)$ 를 찾는 과정이다. 이때 이러한 과정은 risk functional(위험 범함수)

$$

R(\alpha) = \int L(y,f(x,\alpha))dP(x,y)\tag{1}

$$

값을 최소화하는 것으로 나타난다. 여기서 $P(x,y)$는 데이터셋의 확률측도를 의미한다. 이번 글에서는 각각의 관측 데이터셋 $z=(x,y)$가 sample space $Z$에서 추출된다고 정의하고, $Z$에서의 확률측도를 $P(z)$라고 두자. 또한, 앞서 언급한 함수들의 집합을 $Q(z,\alpha), \alpha\in\Lambda$ 로 나타내자. 여기서 $\Lambda$는 각 parameter $\alpha$가 취할 수 있는 값들의 모임이다(parameter space).

### Empirical Risk
하지만, 일반적인 학습문제에서는 데이터셋의 확률측도 $P(z)$가 직접 주어지지 않으므로 이를 알 수 없다. 따라서 손실함수의 기댓값인 위험범함수 대신 다음과 같은 empirical risk functional

$$

R_{emp}(\alpha) = {1\over N}\sum_{i=1}^N Q(z,\alpha)

$$

을 사용해야 한다. 이는 기댓값 형태가 아니므로 확률측도에 대한 사전정보가 불필요하고, 대신 training data에 기반한다. 이로 인해 함수추정의 문제는 $R(\alpha)$를 최소화하는 $Q(z,\alpha_0)$을 직접 찾는 것이 아닌, 이를 근사하는 함수 $Q(z,\alpha_N)$ 을 찾는 과정으로 변환된다. 이를 **Empirical Risk Minimization(ERM) principle**이라고 부른다.

이러한 ERM principle은 사실 머신러닝에서만의 특별한 방법이 아니다. Loss function으로 squared loss를 사용하고, 함수모임 $Q(z,\alpha),\alpha\in\Lambda$를 선형함수로 제한하면 이는 선형회귀분석의 OLS 문제와 동치이다. 즉, 오히려 ERM principle은 이러한 기존의 classic한 추정 문제들을 일반화(**generalization**)한 것으로 볼 수 있다. 하지만 이를 어떻게 일반화할 수 있는지가 핵심 문제이다. 선형회귀의 OLS coefficient의 경우 Gauss-Markov THM에 의해 BLUE임을 보이거나, MLE와도 동치임을 보일 수 있다. 즉, ERM principle을 통해 얻은 근사함수가 실질적으로 의미있는 모델임에 근거가 있다. 반면, Support Vector Machine부터 Neural Network 등 다양한 머신러닝 모델들에 대해서는 어떠할까? 생각해보면 다양한 머신러닝 기법들에 대해 일일이 일반화가능성을 따지는 것은 어렵고, 복잡한 문제일 것이다.

Risk functional(식 1)을 최소화하는 함수 $Q(z,\alpha_0)$에 대응하는 (이론상 최소의)risk value를 $R(\alpha_0)$ 이라고 하자. 이때 ERM을 통해 얻은 risk value $R(\alpha_N)$가 $R(\alpha_0)$으로 수렴(convergence)할 때 ERM을 사용할 수 있을 것이며, 이를 **일치성(consistency)** 이라고 한다. 또한, 여러 종류의 함수열이 Minimun risk로 수렴할 경우 각각이 수렴하는 속도를 비교할 필요가 있는데 이를 **rate of generalization** 이라고 한다. 이제부터 이러한 일치성과 rate of generalization에 관련된 정리들을 살펴보도록 하자.

## Theory of Consistency
### Key Theorem of the Learning Theory
Vapnik이 제시한 학습이론에서의 핵심 정리는 다음과 같다.
> Key Theorem : 함수모임 $Q(z,\alpha),\alpha\in\Lambda$이 확률측도 $P(z)$에 대해 bounded loss를 가진다고 하자. 즉,
> 
> $$A\leq\int Q(z,\alpha)dP(z)\leq B\quad\forall\alpha\in\Lambda$$
> 
> 그러면 ERM principle이 일치성을 갖기 위할 필요충분조건은 $Q(z,\alpha),\alpha\in\Lambda$에서 $R_{emp}(\alpha)$가 $R(\alpha)$로 **균등수렴(uniformly convergence)**하는 것이다. 즉, 임의의 $\epsilon>0$에 대해
> 
> $$\lim_{N\to\infty} P\bigg(\sup_{\alpha\in\Lambda}(R(\alpha)-R_{emp}(\alpha))>\epsilon\bigg)=0\tag{2}$$
> 
> 을 만족해야 한다.

위와 같은 형태의 수렴을 uniform one-sided convergence라고도 한다(절대값 없이 한 방향으로의 수렴이기 때문). 위 정리가 Key theorem인 이유는, ERM principle에서의 어떠한 형태의 수렴여부를 판정하기 위해서는 worst case를 판별해야 한다는 조건을 제시해주기 때문이다. 위 정리에서는 함수집합들 중에서 상한을 취했기 때문에 risk value와 empirical risk value가 가장 크게 차이나는 worst case가 기준이 되는 것이다.

### Uniform Convergence
위 key Theorem으로부터 ERM principle의 일치성 확인을 위해 균등수렴이 보장되어야 된다는 것을 확인했다. 그렇다면 균등수렴이 성립할 필요충분조건은 어떤 것이 있을지 살펴보도록 하자. 여기서 중요한 개념으로 **엔트로피(entropy)** 가 정의되는데, 두 단계로 나누어 살펴보도록 하자.
#### Entropy of the set of Indicators
우선 함수모임 $Q(z,\alpha),\alpha\in\Lambda$가 Indicator function의 집합이라고 하자. 즉, 각각의 함수는 0 또는 1의 값만을 취할 수 있다. 그러면 random sample $z_1,\ldots,z_N$가 주어질 때,
Sample과 parameter space($\Lambda$)들에 대해 정의되는 정수 $N^\Lambda(z_1,\ldots,z_N)$의 값을 Indicator function의 집합 $Q(z,\alpha),\alpha\in\Lambda$ 에 의해 sample $z_1,\ldots,z_N$ 들이 분류되는 서로다른 경우의 수를 나타낸다고 하자. 즉, 만일 $\alpha$가 한개의 값만을 취하면 한개의 함수 $Q(z,\alpha)$에 의해 분류되는 가짓수는 한가지 뿐이므로 $N^\Lambda=1$ 이 된다. 이때 다음과 같이 정의되는

$$

H^\Lambda(z_1,\ldots,z_N) = \ln N^\Lambda(z_1,\ldots,z_N)

$$

값을 **random entropy**라고 정의하며, 이는 주어진 데이터셋에서 정의될 수 있는 분류기(함수) 집합의 diversity를 설명하는 역할을 한다. 또한, 여기서 더 나아가면 random sample $z_1,\ldots,z_N$ 은 확률측도 $P(z)$에서의 joint distribution $P(z_1,\ldots,z_N)$으로부터 얻어진 iid sample이므로, 이들을 확률변수로 볼 수 있다. 즉, 이로부터 다음과 같이 random entropy에 대한 기댓값을 생각할 수 있는데

$$

H^\Lambda = E\ln N^\Lambda(z_1,\ldots,z_N)

$$

이를 Indicator functions $Q(z,\alpha),\alpha\in\Lambda$ 의 집합에 대한 entropy라고 정의한다. random entropy와 다르게 위 값은 sample들에 의존하지 않고, 확률측도에만 의존하게 된다. 이로부터 다음과 같이 Indicator loss function에 대한 일치성(consistency)의 필요충분조건이 성립한다.
> Theorem.
> ERM principle의 uniform two-sided convergence, 즉 임의의 $\epsilon>0$에 대해 다음 조건
> 
> $$\lim_{N\to\infty} P(\sup_{\alpha\in\Lambda}\vert R(\alpha)-R_{emp}(\alpha)\vert >\epsilon)$$ = 0
> 
> 이 성립할 **필요충분조건**은 다음 식이 성립하는 것이다.
> 
> $$\lim_{N\to\infty}{H^\Lambda(N)\over N}=0$$
> 

#### Entropy of the Set of Real Functions
앞에서 살펴본 Indicator function들의 집합에 대한 entropy를 이번에는 실함수 집합으로 확장시켜보도록 하자. 유계인 손실함수들의 집합 $A\leq Q(z,\alpha)\leq B,\alpha\in\Lambda$ 에 대해 앞선 내용과 마찬가지로 $N$개의 random sample이 주어졌다고 하자. 이때 다음과 같은 N-dimensional real-valued vector들의 모임

$$

q(\alpha) = (Q(z_1,\alpha),\ldots,Q(z_N,\alpha)),\alpha\in\Lambda

$$

을 정의할 수 있다. 이때 C metric에 대한 위 벡터모임의 minimal $\epsilon$-net의 원소 개수 $N^\Lambda(\epsilon:z_1,\ldots,z_N)$을 $n$이라고 하자. 이는 임의의 $q(\alpha^{\ast}),\alpha^{\ast}\in\Lambda$에 대해 다음을 만족하는 $q(\alpha_k)$가 $n$개의 vector $q(\alpha_1),\ldots,q(\alpha_n)$중에 항상 존재함을 의미한다.

$$

\rho(q(\alpha^{\ast}),\rho(\alpha_k)) = \max_{1\leq i\leq N}\vert Q(z_i,\alpha^{\ast}),Q(z_i,\alpha_k)\vert \leq \epsilon

$$

또한, 위 식에서 metric $\rho$를 $C$-metric 이라고 한다. 앞서 정의된 random value(sample로부터 얻어진 값이므로) $N^\Lambda(\epsilon:z_1,\ldots,z_N)$에 로그를 취한 값

$$

H^\Lambda(\epsilon,z_1,\ldots,z_N) = \ln N^\Lambda(\epsilon:z_1,\ldots,z_N)

$$ 

을 유계함수모임 $Q(z,\alpha),\alpha\in\Lambda$의 **random VC-entropy**라고 정의하며, Indicator function의 경우와 마찬가지로 기댓값을 취한

$$

H^\Lambda(\epsilon:N) = EH^\Lambda(\epsilon:z_1,\ldots,z_N)

$$

을 함수모임에 대한 **VC-entropy**라고 정의한다. 이를 이용하여 유계인 (실함수)손실함수들에 대한 일치성의 필요충분조건을 다음과 같이 정리할 수 있다.
> Theorem.
> 유계실함수인 손실함수에 대한 ERM principle의 uniform two-sided convergence, 즉 임의의 $\epsilon>0$에 대해 다음 조건
> 
> $$\lim_{N\to\infty} P(\sup_{\alpha\in\Lambda}\vert R(\alpha)-R_{emp}(\alpha)\vert >\epsilon)$$ = 0
> 
> 이 성립할 **필요충분조건**은 임의의 $\epsilon>0$에 대해 다음 식이 성립하는 것이다.
> 
> $$\lim_{N\to\infty}{H^\Lambda(\epsilon:N)\over N}=0$$
> 

### VC Dimension
앞선 내용에서 ERM principle이 일치성을 갖기 위한 필요충분조건에 대해 살펴보았다. 그러나 앞선 식들은 수렴의 속도(rate of convergence)에 대한 정보를 제공하고 있지 않다. 이를 해결하기 위해서는 VC-dimension이라는 새로운 capacity 개념과 Growth function $G^\Lambda(N)$을 이용해야 하는데, 먼저 이들을 정의해보도록 하자.
#### VC-dimension using Growth function
앞서 Indicator function들의 집합 $Q(z,\alpha),\alpha\in\Lambda$ 에 대한 entropy를

$$

H^\Lambda(N) = E\ln N^\Lambda(z)

$$

로 정의했었다. 이때 기댓값과 로그함수의 순서를 바꾼

$$

H^\Lambda_{ann}(N)= \ln EN^\Lambda(z)

$$

를 **annealed VC-entropy**라고 정의하며, 이는 Jensen’s Ineqaulity로부터 entropy 이상의 값을 갖는다. 또한 기댓값 대신 상한을 취한

$$

G^\Lambda(N) = \ln\sup_{z_1,\ldots,z_N} N^\Lambda(z_1,\ldots,z_N)

$$

을 **growth function**이라고 정의하며, 이는 상한에 의해 annealed VC-entropy 이상의 값을 갖는다. 이때 growth function에 대해 다음 정리가 성립한다.
> Theorem.
> 임의의 growth function은 다음 등식
> 
> $$G^\Lambda(N) = N\ln2$$
> 
> 를 만족하거나 다음과 같이 위로 유계이다.
> $G^\Lambda(N)<h\bigg(\ln{N\over h}+1\bigg)$
> 이때 $h$는 다음을 만족하는 정수이다.
> 
> $$G^\Lambda(h) = h\ln 2 \\ G^\Lambda(h+1)\neq (h+1)\ln2$$
> 
위 정리는 growth function이 선형함수이거나, 로그함수에 의해 유계라는 사실을 의미한다. 만일 $Q(z,\alpha),\alpha\in\Lambda$ 에 대한 growth function이 선형함수라면 함수집합의 VC-dimension이 무한(infinite)하다고 정의한다. 만일 선형함수가 아니라면(로그함수에 의해 유계) VC-dimension이 유한(finite)하다고 정의하며 이때 위 정리를 만족하는 $h$의 값을 VC-dimension으로 정의한다.

#### Another Definition
반면, 다른 방법에 의해 VC-dimension을 동일하게 정의하고 이를 실함수로 확장할 수 있다. 우선 Indicator function의 집합 $Q(z,\alpha),\alpha\in\Lambda$이 주어졌을 때 집합의 VC-dimension은
> 벡터 $z_1,\ldots,z_h$가 집합 $Q(z,\alpha),\alpha\in\Lambda$에 의해 모든 분류의 경우의 수($2^h$가지)로 분류될 때(**shattered**) 이를 만족하는 $h$중 최댓값
으로 정의된다. 예를 들어, 만일 어떤 지시함수 집합의 VC-dimension이 3이라는 것은 해당 집합의 지시함수들로 최대 3개의 벡터를 shatter(8가지로 나눔)할 수 있음을 의미한다. 만일 $\forall n\in \mathbb N$개의 벡터가 shatter될 수 있다면, 해당 집합의 VC-dimension은 무한차원이다.

이러한 정의를 유계실함수들의 모임 $A\leq Q(z,\alpha)\leq B,\alpha\in\Lambda$ 로 확장해보자. 이 함수모임에 대해 새로운 지시함수들의 모임

$$

I(z,\alpha,\beta) = I(Q(z,\alpha)-\beta\geq 0),\alpha\in\Lambda

$$

를 정의하고($A<\beta<B$는 상수이다). 그러면 유계실함수들의 모임에 대한 VC-dimension은 위 지시함수들의 모임의 VC-dimension으로 정의된다.

#### Example
N-dimensional coordinate space $Z=(z_1,\ldots,z_N)$에서의 선형모형(Linear model)

$$

Q(z,\alpha) = \sum_{k=1}^p \alpha_kz_k + \alpha_0

$$

의 VC-dimension은 다음과 같은 지시함수모임

$$

Q(z,\alpha) = I(\sum_k \alpha_kz_k + \alpha_0 \geq 0),\alpha\in\Lambda

$$

의 VC-dimension과 동일한데, 이때 위 지시함수모임은 최대 $n+1$개의 벡터를 분리할 수 있으므로 VC-dimension은 $h=n+1$ 으로 정의된다.

## Structural Risk Minimization
### ERM의 문제점
ERM principle은 risk functional 최적화 문제의 해에 대한 일치성을 갖는다. 그러나 이러한 일치성은 sample size에만 의존한다는 문제점이 있다. 실제로 유계실함수집합

$$

0\leq Q(z,\alpha)\leq B, \alpha\in\Lambda

$$

에 대해 다음이 성립하는데,

$$

P\bigg(R(\alpha)\leq R_{emp}(\alpha)+{B\epsilon\over2}\big(1+\sqrt{1+{4R_{emp}(\alpha)\over B\epsilon}} \big)\bigg)\geq 1-\eta\tag{3}

$$

여기서

$$

\epsilon = 4{{h\big(\ln{2N\over h}+1 \big)-\ln\eta}\over N}

$$

으로 정의된다. 만일 식에서 $N/h$ 값이 작으면 empirical risk가 작아도 위 부등식의 우변의 두번째 항으로 인해 expected risk가 작은 값을 가질 수 없게 된다. 즉, empirical risk의 최소화만을 고려하는 ERM principle은 VC-dimension($h$) 값과 sample size($N$)을 모두 고려하지 못하므로, 새로운 원리가 필요하고, 이를 **Structural Risk Minimization(SRM)** 이라고 한다.

### Def of SRM
함수모임 $S=\{Q(z,\alpha):\alpha\in\Lambda\}$ 에 대해

$$

S_1\subset S_2\subset\cdots\subset S_n\cdots

$$

를 만족하는 부분집합열 $\{S_k\ = \{Q(z,\alpha):\alpha\in\Lambda_k\}\}$ 이 존재하면 이러한 부분집합열을 S에 부여된 **structure**라고 정의한다.
이때 **admissible structure**는 다음 세 조건을 만족하는 structure을 의미한다.
> 1. 집합 $S^{\ast} = \cup_k S_k$ 가 S에서 조밀하다.
> 2. $S_k$의 VC-dimension $h_k$는 모두 유한하다.
> 3. $S_k$의 모든 함수는 totally bounded($0\leq Q(z,\alpha)\leq B_k$)이다.

이로부터 정의되는 SRM principle은 random sample $z_1,\ldots,z_N$이 주어졌을 때 $N$에 대응하는 $k=n(N)$ 번째 structure $S_k$에 속한 함수들을 이용해 앞선 guaranteed risk 식 (3)을 최소화하는 원리이다. 이는 사실 근사함수의 복잡도(complexity)와 근사의 수준(quality) 간의 tradeoff를 의미하는데, structure number $k$가 커질수록 해당 $S_k$에 속한 함수의 개수가 많아지므로(용량 증가), empirical risk는 감소할 것이지만 그에 따른 신뢰구간(식 (3) 우변의 두번째 항)의 길이는 증가할 것이다.

이때 다음 정리가 성립한다.
> Theorem.
> 임의의 확률분포에 대해 SRM method는 best possible solution(minimizes the expected risk)으로의 수렴을 보장한다.

즉, 이는 SRM priciple이 전역적으로(universally) 일치성을 갖는다는 의미이다. 또한, SRM의 수렴 속도와 관련하여 다음 정리가 성립한다.

> Theorem.
> Admissible structure에 대해 SRM을 적용하여 N개의 sample에 대해 $k=n(N)$번째 structure가 대응된다고 하자. 이때 expected best risk $R(\alpha_0)$으로 수렴하는 risk의 열 $\{R(\alpha_N^{n(N)}\}$을 구성하고, 이때 각 단계에서의 근사함수를 $Q(z,\alpha_N^{n(N)})$ 이라고 두면 근사적 수렴속도(asymptotic rate of convergence)는
> 
> $$V(N) = r_{n(N)} + B_{n(N)}\sqrt{h_{n(N)}\ln N\over N}$$
> 
> 으로 주어진다. 이때 $B_n$은 $S_n$에 속한 함수들의 bound를 의미하며
> 
> $$\lim_{n\to\infty}{B_{n(N)}^2 h_{n(N)}\ln N\over N} = 0$$
> 
> 을 만족한다. 또한 $r_n(N)$은 근사의 속도(rate of approximation)
> 
> $$r_n = \inf_{\alpha\in\Lambda_n}\int Q(z,\alpha) dP(z) - \inf_{\alpha\in\Lambda}\int Q(z,\alpha)dP(z) $$
> 
> 를 의미한다.



{% endraw %}