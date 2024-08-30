---
title: "[실해석학] 위상공간(Topological Spaces)"
tags:
- Mathematics
- Real Analysis
- Topological spaces
category: Mathematics
use_math: true
---
{% raw %}

## 위상공간<sup>Topological Spaces</sup>
위상공간은 집합의 일종으로, 위상(토폴로지, topology)이 부여된 공간을 의미한다. 앞서 살펴본 [거리공간](https://ddangchani.github.io/mathematics/realanalyis_metricspaces) 역시 위상공간의 일종인데, 거리공간에서의 거리의 개념이 위상을 정의하기 때문이다. 이 장에서 다루고자 하는 위상공간은, 거리공간보다 더 일반적인 개념이며 이를 바탕으로 가산성, 사상의 연속성과 같은 내용을 다룰 것이다.   

### 정의
우선, 공집합이 아닌 집합 X의 부분집합들의 모임 $\mathcal{T}$를 X의 **토플로지**라고 한다 (*모든 부분집합의 모임은 아님!* ). 이때 토폴로지가 주어진 집합 X를 위상공간이라고 하며 이를 $(X,\mathcal{T})$ 라고 표기한다. 위상공간을 정의하는 방법에는 대표적으로 근방을 이용한 정의, 열린집합을 이용한 정의, 닫힌집합을 이용한 정의가 있다. 각 정의들은 모두 동치이며, 일반적으로는 열린집합을 이용한 정의가 널리 사용된다.   
#### 열린집합을 이용한 위상공간의 정의 
위상공간은 순서쌍 $(X,\mathcal{T})$ 이며, $X$는 집합이고 $\mathcal{T}$는 $X$의 부분집합들의 모임 이며, 다음 공리를 만족한다.
> 1. 전체집합 X와 공집합 $\emptyset$ 이 열린집합이며 $\mathcal{T}$ 에 속한다.
> 2. 임의의 **유한**개의 $\mathcal{T}$의 원소들의 교집합은 $\mathcal{T}$의 원소이다. 
> 3. 임의의 (유한 혹은 무한개의) $\mathcal{T}$의 원소들의 합집합은 $\mathcal{T}$의 원소이다.       

이때 $\mathcal{T}$의 원소들을 열린집합이라하며, 모임 $\mathcal{T}$를 $X$에서의 토폴로지라고 한다. 닫힌집합을 이용한 정의는 열린집합을 이용한 정의에 드모르간의 정리를 적용한다.

#### 근방을 이용한 위상공간의 정의
X의 어떤 점 $x\in X$ 에 대해 $x$ 를 포함하는 열린 집합을 $x$의 근방<sup>neighborhood</sup>이라고 한다. 더 자세하게는, X의 한 원소 $x$에 대해 $X$의 부분집합들의 모임 $\mathcal{N(x)}$을 대응시키는 함수 $\mathcal{N}$ 를 **근방 토폴로지**<sup>neighborhood topology</sup> 라고 하며 집합 $\mathcal{N(x)}$의 원소를 $x$의 **근방**이라고 정의한다. 이때 근방 토폴로지 $\mathcal{N}$ 은 다음 네 가지 공리를 만족해야한다 *(Felix Hausdorff)*.   
> 1. $N\in \mathcal{N(x)} \Rightarrow x\in N$
> 2. $N$이 $X$의 부분집합이고 $x\in X$의 근방을 포함한다면 $N$도 $x$의 근방이다.
> 3. $x\in X$의 두 근방의 교집합도 $x$의 근방이다. 
> 4. $x\in X$의 근방 $N$은 다른 $x$의 근방 $M$을 포함하는데, 이때 $N$은 $M$의 각 원소들의 근방이다.

이때 토폴로지 $\mathcal{N}$이 주어진 집합 $X$, 즉 순서쌍 $(X,\mathcal{N})$ 을 **위상공간**이라고 한다. 다음 명제는 앞서 살펴본 두 정의간의 동치관계를 의미한다.

**명제 1** 위상공간 X의 부분집합 $E$ 가 열려있는 것과 X의 각 점 $x\in X$ 에 대해 $E$에 속한 $x$의 근방이 존재한다는 것과 동치이다.    

#### 토폴로지의 예시
> 1. Metric Topology
> 거리공간 $(X,\rho)$ 에 대해 부분집합 $\mathcal{O}$ 를, 임의의 $x\in \mathcal{O}$ 에 대해 열린 근방 $N(x,\epsilon)\subseteq \mathcal{O}$ 이 존재한다는 것으로 정의하자. 그러면 열린집합 간의 합집합 역시 열린집합이므로, 거리공간에서 열린집합들의 모임은 X에 대한 토폴로지이다.
> 2. Discrete Topology
> 공집합이 아닌 X에 대해 $\mathcal{T}$를 X의 모든 집합들의 모임이라 정의하자. 이를 discrete topology라 하며, 모든 집합은 그 집합에 속한 점의 근방이다.

### 위상부분공간
위상공간 $(X,\mathcal{T})$ 와 공집합이 아닌 부분집합 $E\subset X$ 에 대해 토폴로지 $\mathcal{T}$를 상속<sup>inherit</sup>하는 것을 생각해보자. $\mathcal{T}$에 대해 상속된 $E$의 토폴로지 $\mathcal{S}$를 다음과 같이 정의하자.   
> $\mathcal{O}$를 $\mathcal{T}$의 원소라고 할 때, 집합 $E\cap \mathcal{O}$ 의 모임들   

이때 위상공간 $(E,\mathcal{S})$ 를 위상공간 $(X,\mathcal{T})$ 의 부분공간(부분위상공간) 이라고 정의한다.   

### 토폴로지의 기저<sup> base for the topology</sup>
**토폴로지에 대한 기저**   
위상공간 $(X,\mathcal{T})$ 와 $X$의 한 점 $x$를 생각하자. 다음을 만족하는 $x$의 근방들의 모임 $\mathcal{B_x}$를 $x$에서의 **토폴로지에 대한 기저**라고 정의한다.   
>점 $x$의 임의의 근방 $\mathcal{U}$가 주어질 때 $B\subseteq \mathcal{U}$ 를 만족하는 $B \in \mathcal{B_x}$가 존재한다.   

만약 열린집합들의 모임 $\mathcal{B}$ 가 X의 모든 점에서의 기저들을 포함한다면 $\mathcal{B}$ 를 토폴로지 $\mathcal{T}$의 기저라고 정의한다. 즉, X의 임의의 점에을 포함하는 X의 부분집합을 생각하면 이에 대한 부분집합이 $\mathcal{B}$의 원소임을 의미한다.   
 이때, $\mathcal{T}$의 부분집합 $\mathcal{B}$가 $\mathcal{T}$의 기저가 되기 위해서는 모든 (공집합이 아닌) 열린집합이 $\mathcal{B}$의 부분집합의 합집합으로 표현되어야 한다.(집합족의 원소집합들의 합집합을 의미) 이를 역으로 생각하면, 토폴로지에 대한 어떤 기저가 주어진다면 해당 토폴로지를 정의할 수 있음을 알 수 있다.   

**명제 2**   
(공집합이 아닌) 집합 $X$에 대해 $\mathcal{B}$가 $X$의 부분집합들의 모임이라고 하자. 이때 $\mathcal{B}$가 $X$의 토폴로지의 기저가 되기 위한 필요충분조건은 다음과 같다.   
> 1. $\mathcal{B}$가 $X$를 덮는다. ($X=\bigcup_{B\in\mathcal{B}}B$ )
> 2. $B_1,B_2 \in \mathcal{B}$ 에 대해 $x\in B_1\cap B_2$ 이면 $x\in B\subseteq B_1\cap B_2$ 인 $\exists B\in \mathcal{B}$ 이다.

각각의 기저는 유일한 토폴로지를 결정하지만 하나의 토폴로지는 여러 기저를 가질 수 있다. 수직선 $\mathbb{R}$의 유클릐드 토폴로지를 생각해보면, 열린구간들의 모임은 이의 기저가 되며, 동시에 양 끝점이 유리수인 구간들(열림/닫힘)의 모임 역시 기저가 되는 것을 알 수 있다.    

**부분기저<sup>subbsse</sup>**   
위상공간 $(X,\mathcal{T})$에 대해 $\mathcal{T}$의 부분모임 $\mathcal{S}$가 $X$를 덮는다고 하자. 이때 $\mathcal{S}$의 유한 부분모임들의 교집합들이 $\mathcal{T}$ 의 기저이면 $\mathcal{S}$를 토폴로지 $\mathcal{T}$의 **부분기저**라고 한다.   
유계닫힌구간 $[a,b]$에 $\mathbb{R}$로부터의 토폴로지를 상속하여 이를 위상공간으로 하자. 그렇다면 $a<c<b$ 인 $c$에 대해 $[a,c)$나 $(c,b]$ 형태로 구성된 모임은 부분기저가 된다. (두 반열린구간의 교집합을 열린구간이 되게끔 잡으면, 열린구간들의 모임은 토폴로지이기 때문이다.)   

#### 폐포<sup> closure</sup>
위상공간 $X$의 부분집합 $E$에 대해 점 $x\in X$의 모든 근방이 $E$의 점을 포함한다면 $x$를 $E$의 **폐포점**<sup>point of closure</sup>이라고 한다. 또한, $E$의 폐포점들의 모임을 $E$의 페포라고 하며, $\bar{E}$ 라고 표기한다.   

거리공간에서 다루는 폐포와 같은 개념이지만, 위상공간에서는 근방의 개념을 $N(x,\epsilon)$ 의 거리개념으로 정의되지 않으므로(대신 근방 토폴로지 공리에 의해 정의됨) 정의 방식에 차이가 있다. 또한, 정의에 의해, 원래 $E$에 포함된 점은 $E$의 폐포점임이 자명하다. 따라서 $E\subseteq\bar{E}$ 가 성립한다. 만약 $E=\bar{E}$ 가 성립하면 $E$를 **닫혀있다**고 정의한다.   

**명제 4** 위상공간 $X$의 부분집합 $E$가 열려있는 것과 $E$의 여집합이 닫혀있는 것은 동치이다.   
> 증명. $E$가 열림이라 가정하자. 점 $x$가 $X\backslash E$의 폐포의 원소라고 하면, $x\notin E$ 임은 자명하다. 따라서 $x\in X\backslash E$ 역시 성립한다. 이때 $X\backslash E = \overline{X\backslash E}$ 이므로 $X\backslash E = E^C$는 닫혀있다. 역도 비슷한 방식으로 증명가능하다.

# References
 - Real Analysis 4th edition, Royden
 - Topology and Groupoids, Brwon(2006)
{% endraw %}