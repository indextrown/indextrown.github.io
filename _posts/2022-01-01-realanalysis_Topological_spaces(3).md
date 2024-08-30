---
title: "[실해석학] 위상공간에서 연속사상(Continuous mapping)"
tags:
- Mathematics
- Real Analysis
- Topological spaces
category: Mathematics
use_math: true
---
{% raw %}

## 위상공간에서의 연속사상
### 정의
위상공간 $(X,\mathcal{T})$와 $(Y,\mathcal{S})$ 를 연결하는 사상 $f:X\to Y$ 가 점 $x_0$에서 **연속**이기 위한 조건은 다음과 같다.   
> $f(x_0)$의 임의의 근방 $\mathcal{O}$ 에 대해 $x_0$의 근방 $\mathcal{U}$ 가 존재하여 $f(\mathcal{U)}\subseteq\mathcal{O}$ 가 성립한다.   

마찬가지로, $X$의 모든 점에서 연속이면 $f$를 연속사상이라고 한다. 실연속함수의 성질과 유사하게, 위상공간의 연속사상에 대해서도 다음 명제가 성립한다.    

**명제 10** 위상공간에서의 사상 $f:X\to Y$ 가 연속인 것과 $Y$의 임의의 열린부분집합 $\mathcal{O}$ 에 대해 $f^{-1}(\mathcal{O})$ 가 $X$의 열린부분집합인 것은 **동치**이다.   
> $(\because)$ 이전 포스팅에서 살펴본 [명제 1](https://ddangchani.github.io/mathematics/realanalysis_Topological_spaces(1))로부터 열림을 보이는 것은 각 점에 대한 근방의 존재성과 동치임을 알 수 있다. 이때 위상공간의 연속사상은 근방을 통해 정의했으므로, 위 동치관계는 쉽게 보일 수 있다.   

#### 토폴로지의 강약관계
어떤 집합 $X$에 대한 토폴로지는, $X$의 부분집합들을 모아놓은 것으로 정의했다. 만약 $\mathcal{T_1},\mathcal{T_2}$ 가 $X$의 토폴로지이고 이때 $\mathcal{T_1}\subseteq\mathcal{T_2}$ 가 성립한다면 $\mathcal{T_2}$ 를 더 **약한**(weaker), 반대로 $\mathcal{T_1}$ 을 더 **강한**(stronger) 토폴로지라고 한다. 

**정의** 공집합이 아닌 집합 X에 대해    

$$

\mathcal{F} = \{f_\alpha:X\to X_\alpha\}

$$   

로 정의된 사상들의 모임 형태를 생각하자. 이때 각 $X_\alpha$ 는 위상공간이다. 만약 사상들의 모임을 다음과 같이 정의한다면,   

$$

\mathcal{F}=\{f_\alpha^{-1}(\mathcal{O_\alpha}):f_\alpha\in \mathcal{F},\mathcal{O_\alpha}\text{  open  in   }X_\alpha\}

$$   

$\mathcal{F}$를 포함하는 $X$의 토폴로지 중, 가장 약한 토폴로지를 $\mathcal{F}$애 의한 $X$의 **weak topology(약한 토폴로지)** 라고 정의한다.   

**명제 13** 만약 약한 토폴로지를 정의하는 과정에서, $\mathcal{F}$의 각 사상 $f_\alpha$ 들이 연속이라면, $\mathcal{F}$에 의한 $X$의 약한 토폴로지는 $X$의 모든 토폴로지들 중에 **가장 적은** 집합을 갖는다.    

### 위상동형사상<sup>Homeomorphism</sup>
#### 정의
위상공간 $X$에서 위상공간 $Y$로의 연속사상 $f$가 **일대일**(단사, one-to-one)이고, 전사(onto)이며, 연속인 역사상 $f^{-1}:Y\to X$ 가 존재할 때 이를 **위상동형사상(Homeomorphism)** 이라고 한다.   

위상동형사상이라는 의미는, 동형사상(isomorphism)아면서 동시에 위상적 성질을 보존한다는 것이다. 즉, 어떤 두 위상공간 $X,Y$ 사이에 위상동형사상이 존재한다는 것은 두 공간이 위상적으로 동일하다는 것을 의미한다. 즉, 이는 동치관계(equivalence relation)이다.   

**예시 : L1 space to L2 space**    
르벡가측집합 $E\subset \mathbb{R}$ 에 대해, $L^1(E)$와 $L^2(E)$ 공간을 잇는 함수   

$$

\Phi(f)(x) = sgn(f(x))\vert f(x)\vert ^{1/2}

$$    

를 생각하자($f\in L^1(E)$). 그러면 임의의 두 수 $a,b$에 대해 다음 부등식이 성립하므로   

$$

\vert sgn(a)\cdot\vert a\vert ^{1/2}-sgn(b)\cdot\vert b\vert ^{1/2}\vert ^2 \leq 2\vert a-b\vert 

$$

임의의 $f,g\in L^1$ 에 대해서도 아래 부등식이 성립하여 $\Phi(f)\in L^2(E)$ 이다.   

$$

\Vert \Phi(f)-\Phi(g)\Vert_2^2\leq 2\Vert f-g\Vert_1

$$    

이렇게 정의된 사상 $\Phi$ 는 위상동형사상의 조건을 만족하고 $L^1$ 공간과 $L^2$ 공간은 위상동형임을 알 수 있다.   

## 위상공간의 컴팩트성
위상공간의 컴팩트성은 거리공간에서 살펴본 것과 같은 방식으로 정의된다.   
#### 정의
위상공간 $X$가 컴팩트하다는 것은 $X$가 유한부분덮개를 가진다는 것이다. $K\subseteq X$가 컴팩트하다는 것은 $K$가 $X$의 토폴로지를 상속받으며(위상공간으로 여겨짐) 컴팩트하다는 것을 의미한다.

**명제 15** 컴팩트위상공간 $X$의 닫힌부분집합 $K$는 컴팩트하다.   

**명제 16** [하우스도르프](https://ddangchani.github.io/mathematics/realanalysis_Topological_spaces(2)) 위상공간 $X$의 컴팩트한 부분공간 $K$는 닫혀있다.
> $X\backslash K$가 열림을 보이자. $y\in X\backslash K$를 잡으면 하우스도르프 분리성질에 의해 각 $x\in K$와 $y$에 대해 각각 서로소인 근방 $\mathcal{O_x,U_x}$ 가 존재한다. 이를 $$\{\mathcal{O_x}\}_{x\in K}$$ 로 두면 이는 $K$의 열린 덮개이다. 컴팩트성에 의해 유한부분덮개 $$\{\mathcal{O_{x_1}\ldots O_{x_n}}\}$$ 이 존재한다. 이때 $\mathcal{N}=\cap_{i=1}^n\mathcal{U_{x_i}}$ 로 두면 이는 $y$의 근방이고 각 $O_x$들과 서로소이므로 이는 $X\backslash K$에 속한다. 따라서 $X\backslash K$는 열려있다.   

또한, 하우스도르프 공간과 관련해서, 컴팩트한 하우스도르프 위상공간은 normal하다(일반 분리 성질을 만족시킨다).   

#### 점열컴팩트
위상공간에서 정의된 각각의 수열이 수렴하고, 그 수렴값이 해당 위상공간의 점이면 그 위상공간을 **점열컴팩트**하다고 한다.   
[거리공간](https://ddangchani.github.io/mathematics/realanalysis_metricspaces)에서는 컴팩트성과 점열컴팩트성이 동치임을 확인했었는데, 위상공간에서는 [제2가산성](https://ddangchani.github.io/mathematics/realanalysis_Topological_spaces(2))을 갖는 위상공간에 대해 성립한다.     

**명제 17** 제2가산위상공간에서 컴팩트성과 점열컴팩트성은 동치이다.   

### 연속사상과 컴팩트성
**명제 20** 컴팩트위상공간 $X$의 연속사상 $f$에 의한 상(image) $f(X)$는 컴팩트하다.   
> 증명. $f(X)$의 열린덮개 $$\{O_i\}_{i\in N}$$ 을 생각하자. 이때 연속사상의 성질에 의해 $$\{f^{-1}(O_i)\}_i$$는 $X$의 열린덮개이고, $X$가 컴팩트하므로 유한부분덮개를 잡을 수 있다. 따라서 이 덮개들의 상을 다시 취하면, 이는 $f(X)$의 유한부분덮개가 된다.   


**명제 19** 컴팩트위상공간 X에서 하우스도르프 위상공간 Y로의 연속인 사상 $f:X\to Y$ 가 전단사일때, 이는 동형사상이다.    
> 증명. $f$가 동형사상임을 보이는 것은 열린집합의 $f$에 의한 상(image)이 열림을 보이는 것으로 충분하다. $F$가 $X$의 닫힌 부분집합이면, $F$도 컴팩트하고 위 명제에 의해 $f(F)$ 도 컴팩트하다. 따라서 명제 16에 의해 $Y$는 하우스도르프공간이고, $f(F)$는 닫혀있다.



# References
 - Real Analysis 4th edition, Royden

{% endraw %}