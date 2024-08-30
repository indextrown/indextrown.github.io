---
title: "Causal Inference (5) : Multivariate Causal Models"
tags:
- Causal Inference
- Statistics
- Graphical Model
category: Causal Inference
use_math: true
header: 
 teaser: /assets/img/Causal Inference (5).assets/Causal_Inference_(5)_0.jpg
---
{% raw %}
## Multivariate Causal Models
이전까지는 변수가 2개인 SCM, 즉 원인-결과의 SCM을 살펴보았었다. 이제부터는 변수가 여러개인(multivariate) causal model들에 대해 살펴보도록 하자. 우선, cause-effect 모델도 포함되지만 다변량 causal model은 일반적으로 그래프(graph)의 형태로 표현된다.

## Graph의 정의
**그래프**란, 확률변수 $\mathbf X = (X_1,\ldots,X_d)$의 index set $V=\{1,\ldots,d\}$와 $V^2$의 부분집합 $\mathcal E\subseteq\{(v,w): v,w\in V, v\neq w\}$ 로 이루어진 순서쌍 $\mathcal G = (V,\mathcal E)$을 의미한다. 이때 $V$의 각 원소를 그래프의 노드(node)라고 하며, $\mathcal E$의 각 원소 $(i,j)$를 변(edge)이라고 한다. 또한, 변 $(i,j)$가 존재한다는 것은 i번째 노드에서 j번째 노드로 가는 화살표(**방향**을 포함하는 의미)가 존재한다는 것을 의미한다. 

만일 노드 i,j에 대해 $(i,j)\in\mathcal E$가 성립하지만 $(j,i)\notin\mathcal E$인 경우, 즉 i에서 j의 방향으로만 연결이 존재하는 경우 노드 i를 j의 부모 노드(**parent node**)라고 하고 j를 i의 자식 노드(**child node**)라고 한다. 또한, 만일 $(i,j)\in\mathcal E$이고 $(j,i)\in\mathcal E$가 동시에 성립하면 노드 i,j를 인접(**adjacent**)하다고 한다.

또한 그래프 $\mathcal G$에 대해 **경로(path)**를 정의할 수 있는데, 그래프의 노드 $i_1,\ldots,i_m$가 각 $k=1,\ldots,m-1$ 에 대해 $i_k,i_{k+1}$를 잇는 변이 존재한다면 노드 1부터 m까지의 경로가 존재한다고 한다. 또한, 만일 경로상의 모든 변의 방향이 일치한다면 이를 **directed path**라고 한다. 이때 directed path 경로의 시작 노드를 **ancestor**, 종점 노드를 **descendant**라고 정의한다.

만일 그래프 $\mathcal G$에 대해 j에서 k로의 directed path와 k에서 j로의 directed path가 동시에 존재하는 노드 쌍 $(j,k)$가 **없다면** $\mathcal G$를 **PDAG(Partially directed acylic graph)** 라고 하며, PDAG이며 동시에 그래프의 모든 변이 방향을 가진다면 **DAG(Directed acylic graph)** 라고 정의한다.

### Pearl’s d-separation
DAG $\mathcal G$에 대해 다음 두 경우 중 하나를 만족하는 노드 $i_k$가 존재한다면 $i_1$에서 $i_m$ 사이의 경로가 집합 $S$에 의해 가로막혀있다고(**blocked**) 정의한다.

1. $i_k\in S$ 이고

    $$
    \begin{aligned}
    &i_{k-1} \to i_k\to i_{k+1}\\
    \text{or}\;\; &i_{k-1}\leftarrow i_k\leftarrow i_{k+1}\\
    \text{or}\;\; &i_{k-1}\leftarrow i_k\to i_{k+1}
    \end{aligned}
    $$

    중 하나를 만족한다.

2. 노드 $i_k$나 $i_k$의 어떤 descendant도 집합 $S$에 포함되지 않으며

    $$

    i_{k-1}\to i_k\leftarrow i_{k+1}

    $$

    을 만족한다.

    또한, DAG $\mathcal G$의 서로소인 세 노드 집합 $A,B,S$에 대해, $A$의 원소와 $B$의 원소를 잇는 모든 경로가 $S$의 원소에 의해 가로막혀있다면 이를

    $$

    A\perp_\mathcal G B\;\vert \;S

    $$

    로 표기한다.

## Multivariate SCM

이전까지는 cause-effect 모델에 관해 SCM을 살펴보았는데, 이를 일반화하여 다변량 모델에 대한 SCM을 정의하고 이를 살펴보도록 하자. 우선 다변량 SCM은 다음과 같이 정의한다.

### Definition

노드가 $d$개로 주어지는 SCM $\mathfrak C =(S,P_N)$은 다음 $d$개의 **structural assignments**로 구성된 collection $S$와

$$

X_j = f_j(\text{PA}_j,N_j), \;\; j=1,\ldots,d

$$

및, 각 i.i.d인 Noise variable $N_j$들의 joint distribution $P_N$으로 구성된다. 여기서 $\text{PA}_j$는 노드 $j$의 부모 노드들의 집합이며, 자기 자신은 제외한다.

위와 같이 정의된 SCM은 확률변수 $\mathbf X=(X_1,\ldots,X_d)$에 대한 유일한 확률분포를 결정하는데, 이를 **entailed distribution**이라고 하며 $P_\mathbf X^\mathfrak C$ 혹은 $P_\mathbf X$ 라고 표기한다. 이는 i.i.d noise variable으로부터 생성된 표본으로 i.i.d random sample $\mathbf{X^1,\ldots.X^n \sim} P_\mathbf X$ 를 구성할 수 있다는 의미이다.
#### Example
다음과 같은 SCM

![](/assets/img/Causal Inference (5).assets/Causal_Inference_(5)_0.jpg)

에 대해 

$$

\begin{aligned}
&f_1(x_3,n) = 2x_3+n\\
&f_2(x_1,n) = (0.5x_1)^2+n\\
&f_3(n) = n\\
&f_4(x_2,x_3,n) = x_2 + 2\sin(x_3+n)
\end{aligned}

$$

으로 주어지며, 각 noise variable이 모두 i.i.d인 정규분포를 따른다고 가정하자. 그러면 다음과 같이 $\mathbf X$의 random sample을 생성할 수 있다(Code on Github).

![](/assets/img/Causal_Inference_(5)_1.jpg){: .align-center}

## Intervention
이전에 다루었던 Cause-Effect 모델에서의 intervention과 마찬가지로, multivariate SCM에 대해서도 intervention distribution을 생각해볼 수 있다. SCM $\mathfrak C = (S,P_N)$ 이 주어졌을 때, 새로운 assignment

$$

X_k = \tilde f(\widetilde{\text{PA}}_k, \tilde N_k)

$$

에 대응하는 intervention이 일어났다고 하자. 그러면 이에 대한 intervention distribution을 다음과 같이 표기한다.

$$

P_\mathbf X^\tilde{\mathfrak{C}} = P_\mathbf X^{\mathfrak C;do(X_k=\tilde f(\widetilde{\text{PA}}_k, \tilde N_k))}

$$

단, intervention으로 새롭게 대치되는 noise variable $\tilde N_k$과 기존 noise variable $N$은 모두 서로 독립이어야 한다.

### Total cause effect
확률변수 $X,Y$와 $X$에 대한 어떤 random variable $\tilde N_X$에 대해

$$

X\;\not\bot \;Y \;\;\text{in}\;\;P_\mathbf X^{\mathfrak C:do(X=\tilde N_X)}

$$

이면, 즉 $X$가 noise variable로 intervened 된 상황에서 $X,Y$가 독립이라면 $X$에서 $Y$로의 **total causal effect**가 존재한다고 정의한다. 이 정의의 조건은 쉽게 이해할 수 있지만, total causal effect의 실제 의미를 파악하는데는 어려움이 있을 수 있다. 이에 대해, 동치인 다른 명제들이 다음과 같이 존재한다.

#### 동치관계
확률변수 $X,Y$를 포함하는 SCM $\mathfrak C$에서 $X$에서 $Y$로의 total causal effect가 존재한다는 것과 다음 각각은 **동치**이다.
1. $P_Y^{\mathfrak C:do(X=x_1)} \neq P_Y^{\mathfrak C:do(X=x_2)}$ 인 $x_1,x_2$가 존재한다.
2. $P_Y^{\mathfrak C:do(X=x_3)}\neq P_Y^\mathfrak C$ 인 $x_3$가 존재한다.

1번과 2번이 total causal effect의 정의와 동치인 것은 쉽게 연상할 수 있다. $X$에 대해 noise variable로 intervention이 이루어진 경우 $X,Y$가 독립이라면 1번과 2번 식 모두 등호(=)가 성립할 것이지만, 그렇지 않으므로 그 역이 된다는 것을 알 수 있다. 

Total causal effect가 존재한다는 것은, SCM에 대응하는 그래프에서 $X\to Y$의 directed path가 존재한다는 것과 관련된다. 그러나 역으로 directed path가 존재한다고 해서 total causal effect가 존재하지는 않는다. 

### Counterfactuals

이전에 bivariate causal model에 대한 Counterfactual을 다룬 적이 있었다. 간단히 말해서, causal model의 특정 노드 혹은 noise variable이 변화될 때 causal model을 가정하는 것이다. 마찬가지로, multivariate causal model $\frak C\rm=(\bf S,\rm P_N)$ 에 대해서도 다음과 같이 Counterfactual을 정의할 수 있다.

$$

\frak C_{\bf X=x} = \big (\bf S, \rm P_N^{\frak C\vert \bf X=x}\big )

$$

여기서 $\bf X=x$는 노드 벡터 $\bf X$의 관측값을 의미하며, noise distribution에 대해 $P_\bf N^{\frak C\vert \bf X=x}=\rm P_{\bf N\vert X=x}$ 가 성립한다. 또한, counterfactual에 의한 새로운 noise variable들은 서로 독립일 필요가 없다.

#### Example

$\bf X=\rm(X,Y,Z)$에 대한 다음 SCM

$$

\begin{aligned}
& X= N_X\\
& Y = X^2 + N_Y\\
& Z= 2Y+X+N_Z
\end{aligned}

$$

를 생각하자. 또한, noise distribution은 $N_X,N_Y,N_Z\sim\bf U\rm(\{-5,-4,\ldots,4,5\})$, 즉 uniform (discrete) distribution으로 주어진다고 하자. 만일 관측값 $\rm(X,Y,Z) = (1,2,4)$가 주어진다면 $P_\bf N^{\frak C\vert \bf X=x}$에 대한 새로운 noise distribution은 $(N_X,N_Y,N_Z) = (1,1,-1)$, 즉 point mass 1을 갖는다. 따라서, 주어진 관측 아래 다음과 같은 명제

> “$Z$ would have been $11$ if had X been *set to* $2$”

가 성립한다. 즉,

$$

P_Z^{\frak C\vert \bf X=x\rm;do(X=2)}

$$

이 성립한다.

# References

- Shanmugam, R. (2018). Elements of causal inference: Foundations and learning algorithms. _Journal of Statistical Computation and Simulation_, _88_(16), 3248–3248. [https://doi.org/10.1080/00949655.2018.1505197](https://doi.org/10.1080/00949655.2018.1505197)


{% endraw %}