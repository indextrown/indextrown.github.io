---
title: "Causal Inference (6) - Multivariate Causal Model (2)"
tags:
- Causal Inference
- Graphical Model
- Markov Property
category: Causal Inference
use_math: true
header: 
 teaser: /assets/img/Causal Inference (6).assets/Causal_Inference_(6)_1.jpeg
---
{% raw %}
# Multivariate Causal Model (2)

이번 글에서는 저번에 이어 노드가 여러개인 multivariate causal model에 대해 계속 다루어보도록 할텐데, 그래피컬 모델과 관련된 중요한 개념중 하나인 Markov property, equivalence, blanket 등 개념에 대해 다루어보도록 할 것이다.

## Markov Property

Markov property는 그래피컬 모델을 다룰 때 사용되는 가정으로, 어떤 그래프가 Markovian이라는 것은 그래프 내에 특정한 독립성이 존재한다는 것을 의미한다. Markov property는 다음과 같이 정의된다.

### Definition

Directed Acyclic Graph(DAG) $\cal G$ 와 이에 대한 joint distribution $P_\bf X$가 주어진다고 하자. 이때 distribution $P_\bf X$에 다음과 같은 세 종류의 markov property가 $\cal G$에 대해 존재한다.

#### 1. Global Markov Property

모든 disjoint한 노드집합 $\bf A,B,C$ 에 대해

$$

\bf A\bot_\cal G\bf B\;\vert \;C \Rightarrow A\bot B\;\vert \;C

$$

를 만족하는 것을 의미한다. 이때 좌변은 d-separation(아래 정의 참고)을 의미한다.(우변은 conditional independence를 의미)

> **d-separation** : DAG $\cal G$의 disoint한 부분 노드집합 $\bf A,B$에 대해 $\bf A$의 노드와 $\bf B$의 노드를 잇는 모든 경로가 집합 $\bf E$의 노드에 의해 가로막혀있다면(**blocked**) 이를 $\bf E$에 의해 d-separated 되었다고 한다.
> 
> $$
> 
> \bf A\bot_\cal G \bf B\vert E
> 
> $$
> 
> 이때 d-separation의 경우는 다음과 같은 세 가지 중 하나 이상의 형태로 나타난다.
>
> 1. pipe : $s\to m\to t$ or $s\leftarrow m\leftarrow t$ where $m\in E$
> 2. fork : $s\leftarrow m\to t$ where $m\in E$
> 3. v-structure : $s\to m\leftarrow t$ where $m\notin E$

#### 2. Local Markov Property

변수(노드) $x_i$가 해당 변수의 parent node $x_k\in\bf PA_\it i$ 가 주어졌을 때(조건부), non-descendant 노드들과 독립임을 의미한다.

#### 3. Markov Factorization Property

joint distribution $P_\bf X$가 밀도함수 $p$를 가질 때,

$$

p(\mathbf x) = p(x_1,\ldots,x_d) = \prod_{j=1}^d p(x_j\vert \bf pa\it_j^\cal G\rm)

$$

을 만족하는 것을 의미한다. 이때 우변 곱의 각 인수를 conditional distribution $P_{X_j\vert \bf PA_\it j^\cal G}$ 의 **causal Markov kernel** 이라고 정의한다.

위 세개의 Markov property들은 얼핏 보면 별개의 것처럼 보이지만, 실제로는 결합확률밀도($p$)가 주어지기만 한다면 모두 **동치관계**에 있다. 아래 그림과 같은 그래프 $\mathcal G$의 예시를 살펴보자.(자세한 증명 생략)

![](/assets/img/Causal Inference (6).assets/Causal_Inference_(6)_0.png){: .align-center width="40%" height="40%"}

1. 우선 그래프 관계에 의해

    $$

    X_2\bot X_3\vert X_1\;\;\text{and}\;\;X_1\bot X_4\vert X_2,X_3

    $$

    이 성립한다. 따라서, joint distribution $P_{X_1,X_2,X_3,X_4}$는 graph $\cal G$에 대해 위 global/local markov property를 만족한다.

2. 또한, 그래프 노드간 관계를 분석해보면

    $$

    p(x_1,x_2,x_3,x_4) = p(x_3)p(x_1\vert x_3)p(x_2\vert x_1)p(x_4\vert x_2,x_3)

    $$

    이 성립하는데, 이는 joint distribution이 위 그래프에 대한 Markov Factorization Property를 만족함을 의미한다.

추후 다룰 예정이지만, 일반적으로 SCM에 수반되는 결합분포는 해당 SCM의 그래프에 대해 Markovian이다. 그런데, 위 markov factorization처럼 노드 간 조건부 독립성은 각 그래프에 대해 일대일대응되지 않는다. 오히려 서로 다른 그래프임에도, 동일한 조건부 독립성을 나타낼 수 있다. 따라서 다음과 같이 동치관계를 정립할 필요가 있다.

### Markov Equivalence

DAG $\cal G$에 대해 Markovian인 (결합)분포들의 모임을 $\mathcal M(\mathcal G)$ 라고 하자. 이때 두 DAG $\mathcal G_1,\mathcal G_2$가 $\cal M(G_1) = M(G_2)$ 를 만족한다면 이를 **Markov equivalent**하다고 정의한다. 여타 동치관계와 마찬가지로, 동치인 DAG들의 집합을 Markov equivalence class라고 한다. 하지만 앞서 말한것 처럼 두 그래프가 동치인지 아닌지 확인하기는 쉽지 않은데, 이에 대해 다음과 같은 보조정리가 존재한다.

> 두 DAG $\cal G_1, G_2$가 마코프 동치일 **필요충분조건**은 두 그래프가 같은 뼈대(skeleton)와 **immortality**를 가지는 것이다.

이때, 어떤 DAG의 세 노드 $A,B,C$ 가 immortality(v-structure라고도 한다)를 형성한다는 것은 연결구조 $A\rightarrow B\leftarrow C$ 를 만족하면서 $A,C$가 직접 연결되어있지 않는 것을 의미한다.

![](/assets/img/Causal Inference (6).assets/Causal_Inference_(6)_1.jpeg){: .align-center width="70%" height="70%"}

예를 들어 위 두 그래프는 같은 뼈대와 유일한 immortality($X\rightarrow Z\leftarrow V$)를 가지므로 Markov 동치이다.

### Markov Blanket

Markov Blanket은 반응변수 Y의 값을 예측하는 과정에서 어떤 다른 변수들을 포함해야 하는지와 관련된 개념이다. DAG $\mathcal G = (V,\cal E\rm )$ 가 주어지고 $\cal G$에서의 반응변수(target node)를 $Y$라고 두자. 이때 $Y$의 Markov blanket은 다음을 만족하는 집합 $M$ 중 **가장 작은 집합**이다.

$$

Y\bot_\mathcal G\;V\backslash(\{Y\}\cup M)\,\vert \,M

$$

만약 joint distribution $P_\bf X$가 $\cal G$에 대해 Markovian이라면(마코프 성질을 만족한다면), 위 조건은

$$

Y\bot_\mathcal \;V\backslash(\{Y\}\cup M)\,\vert \,M

$$

가 된다.

위 Markov blanket의 개념을 직관적으로 이해하면, 관심의 대상이 되는 노드($Y$)를 둘러싼 덮개($M$)이며, 이 덮개를 제외한 나머지 노드들은 Y에 실질적으로 영향을 미치지 않는 노드임을 의미한다고 보면 된다(조건부 독립). 특히, DAG에 대해서는 타겟 노드 $Y$의 Markov blanket은 부모 노드, 자식 노드와 자식노드의 부모노드의 합집합으로 구성된다.

$$

M= \rm PA_\rm Y\cup CH_Y \cup PA_{CH_Y}

$$

# References
- Shanmugam, R. (2018). Elements of causal inference: Foundations and learning algorithms. _Journal of Statistical Computation and Simulation_, _88_(16), 3248–3248. [https://doi.org/10.1080/00949655.2018.1505197](https://doi.org/10.1080/00949655.2018.1505197)

{% endraw %}