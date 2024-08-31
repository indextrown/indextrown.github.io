---
title : "[실해석학] 위상공간의 분리(Separation)"
tags:
- Mathematics
- Real Analysis
- Topological spaces
category: Mathematics
use_math: true
---
{% raw %}

## 위상공간의 분리<sup> Separation</sup>
위상공간 X의 부분집합 $A,B \subset X$ 가 서로소라고 하자. 만일 $A,B$ 각각의 서로소인 근방이 존재한다면, 이를 근방에 의해 분리된다고 표현한다. 이 장에서는 네 가지의 주요 분리 성질을 바탕으로 위상공간을 분류하는 것을 다룬다.   

### 티호노프<sup>Tychonoff</sup> 분리 성질
> 위상공간 $X$의 두 점 $u,v \in X$에 대해 $v$를 포함하지 않는 $u$의 근방이 존재하며, $u$를 포함하지 않는 $v$의 근방 역시 존재한다.   

위 성질을 티호노프 분리 성질이라고 하며, 이를 만족하는 위상공간을 **티호노프 공간**이라고 한다. 

**명제 6**  위상공간 $X$가 티호노프 공간일 필요충분조건은 $X$의 단 한점으로 구성된 모든 집합이 닫혀있는 것이다.   
> 증명. $x\in X$에 대해 집합 {$x$}이 닫힘과 여집합 $X\backslash${$x$} 이 열림은 동치이다 ([이전포스팅](https://ddangchani.github.io/mathematics/realanalysis_Topological_spaces(1)) 참조). 이때, $X\backslash${$x$} 가 열려있기 위해서는 각 점 $y\in X\backslash${$x$} 에 대해 $y$의 어떤 근방이 존재해 $X\backslash${$x$}에 포함되어야 하고, 이는 티호노프 분리 성질을 만족시킨다.   

### 일반 분리 성질<sup>Normal Separation Property</sup>
> 티호노프 분리 성질을 만족하며, 두 개의 서로소인 닫힌 집합들은 서로소인 근방에 의해 분리될 수 있다.

이때 위 성질을 만족하는 위상공간을 normal 하다고 한다.
 
**명제 7** 모든 거리공간은 normal하다.   
> 증명. 거리공간이 $(X,\rho)$로 주어지며 다음과 같이 $X$의 부분집합 $F$와 $x\in X$을 대응시키는 거리함수를 정의하자.   
> 
> $$dist(x,F)=\inf\{\rho(x,x'):x' \in F\}$$   
> 
> 일반분리성질을 확인하기 위해 두 개의 서로소인, $X$의 닫힌 부분집합 $F_1,F_2$를 잡자. 이때 두 $X$의 부분집합   
> 
> $$\mathcal{O_1}=\{x\in X: dist(x,F_1)<dist(x,F_2)\}$$
> 
> $$\mathcal{O_2}=\{x\in X: dist(x,F_2)<dist(x,F_1)\}$$   
> 
> 을 잡으면 $F_1\subseteq\mathcal{O_1}$, $F_2\subseteq\mathcal{O_2}$ 이고 $\mathcal{O_1\cap O_2} = \emptyset$ 이다. (if $x\in F_1$ then $x\in\mathcal{O_1}$) 이는 서로소인 근방에 의해 $F_1,F_2$ 가 분리되는 것을 의미하므로 거리공간 X가 normal 함을 알 수 있다.   

### 하우스도르프 분리 성질<sup>Hausdorff Separation Property</sup>
> 위상공간 $X$에서 각각의 두 점은 서로소인 근방들로 분리될 수 있다.   

### 정규 분리 성질<sup>Regular Separation Property</sup>
>티호노프 분리 성질이 성립하며, 각각의 닫힌집합 $F\subset X$와 $x\notin F$는 서로소인 근방에 의해 분리될 수 있다.

**명제 8** $X$가 티호노프 위상공간이라고 하자. 이때 X가 normal할 필요충분조건은 임의의 닫힌부분집합 $F\subset X$의 근방 $\mathcal{U}$에 대해 열린집합(근방) $\mathcal{O}$가 존재하여 다음을 만족하는 것이다.   

$$

F\subseteq \mathcal{O} \subseteq \overline{\mathcal{O}} \subseteq \mathcal{U}

$$

> ($\Rightarrow$). X가 normal하다고 가정하자. $\mathcal{U}$가 $F$의 근방이므로 $F$와 $X\backslash\mathcal{U}$는 서로소인 닫힌 집합이다. 따라서 normal의 정의로부터 서로소인 열린집합 $\mathcal{O,V}$ 가 존재하여 $F\subseteq\mathcal{O},X\backslash\mathcal{U}\subseteq\mathcal{V}$ 가 성립한다. 따라서 $\overline{\mathcal{O}}\subseteq X\backslash\mathcal{V}\subseteq\mathcal{U}$ 임을 알 수 있다.   
> ($\Leftarrow$) 위 성질이 성립한다고 가정하자. $A,B$가 $X$의 서로소인 닫힌 부분집합이라고 하면, $A\subseteq X\backslash B$ 이고 $X\backslash B$는 열린집합이다. 따라서 $A\subseteq\mathcal{O}\subseteq\overline{\mathcal{O}}\subseteq X\backslash B$ 인 열린집합 $\mathcal{O}$ 가 존재한다.   

## 위상공간의 가산성과 분리가능성

가산성과 분리가능성을 논하기 이전에 먼저 위상공간에서 수열의 수렴을 정의할 필요가 있다.   
**Def** 위상공간 $X$의 수열 {$x_n$}이 $x\in X$로 수렴한다는 것은 $x$의 각 근방 $\mathcal{U}$ 에 대해 자연수 $N$이 존재하여 $n\geq N$일 때 $x_n\in \mathcal{U}$가 성립함을 말한다.   

주의할 것은, 거리공간에서와는 다르게 위상공간에서의 수열은 두개 이상의 극한을 가질 수 있다. 예를 들어 위상공간 $X$에 대한 **Trivial Topology**

$$\mathcal{T}=\{\emptyset,X\}$$

를 생각하면 $(X,\mathcal{T})$에서 정의된 모든 수열은 모든 점으로 수렴하는데, 모든 점에 대한 근방은 전체집합 $X$로만 정의되기 때문이다. 반면, [하우스도르프](#하우스도르프-분리-성질suphausdorff-separation-propertysup) 위상공간에서는 각 점들을 서로소인 근방들로 분리할 수 있으므로 수열들은 각각 오직 하나의 극한만을 갖는다.   

### 가산성<sup>countability</sup>
**Def** 위상공간 $X$의 각 점에 대한 기저가 가산일때, 이를 **제1가산공간**<sup>first countable topological space</sup>이라고 한다. 만약 $X$의 토폴로지 $\mathcal{T}$의 기저가 가산이면, 공간 $X$를 **제2가산공간**<sup>second countable topological space</sup>이라고 한다.    
정의로부터 제2가산공간이 제1가산공간임은 명확하다(토폴로지에 대한 기저는 모든 점에서의 기저를 포함하므로). 예시로 거리공간을 살펴보자. 모든 거리공간 $X$는 제1가산공간임을 알 수 있는데, $x\in X$에 대해 열린근방들의 모임   

$$

\{N(x,1/n)\}^\infty_{n=1}

$$   

을 생각하면 이는 점 $x$에 대한 기저가 되고, 가산모임이다.   
제1가산공간에 대해서는 다음 명제가 성립한다.   
**명제 9** 제1가산공간 $X$와 부분집합 $E$를 생각하자. 점 $x\in X$가 $E$의 폐포에 속할 필요충분조건은 $x$가 $E$에서의 수열의 극한값이어야 한다는 것이다.   
또한, 이를 이용하면 $E$가 닫혀있는 것과 $E$에서의 수열의 극한값이 $E$에 속하는 것이 동치임을 알 수 있다.   

### 분리가능성<sup>separability</sup>
분리가능성은 거리공간 등에서 살펴본 개념과 동일하게, 조밀성과 함꼐 정의된다.   
**Def** 위상공간 $X$의 모든 열린집합이 $E\subset X$의 점을 포함하면, $E$가 $X$에서 **조밀**하다고 한다. 이때 $E$가 가산이면 $X$를 **분리가능**하다고 정의한다.   

폐포점의 정의를 생각해보면, $x$가 $E$의 폐포점일 경우 $x$의 모든 근방이 $E$의 점을 포함한다. 이는 위에서 정의한 조밀성과 동치이므로,   

$$

\overline{E}=X

$$   

임을 알 수 있다.



# References
 - Real Analysis 4th edition, Royden

{% endraw %}