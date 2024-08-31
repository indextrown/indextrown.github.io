---
title: Sensitivity Analysis
tags:
- Causal Inference
- Sensitivity Analysis
- Unconfoundedness
category: ""
use_math: true
---

# Sensitivity Analysis

관측 자료로부터 인과추론을 하기 위해서는 unconfoundedness, Overlap의 두 가지 가정이 필요하다. Overlap 가정은 각 처치대상을 기반으로 하므로, 관측 자료로부터 검정이 가능<sup>testable</sup>하다. 반면, unconfoundedness(혹은 ignorability) 가정은 본질적으로 검정은 불가능하지만, 간접적으로 검정할 수는 있다. Sensitivity Analysis<sup>민감도 분석</sup>이란, unconfoundedness 가정의 불만족을 어느 정도 수준까지 허용가능한지 분석하는 기법이다.

## Unconfoundedness

$$
\{Y(1),Y(0)\} \perp\!\!\!\perp Z\;\vert \;X\tag{1}
$$

Unconfoundedness 가정(식 1)은 본질적으로 측정되지 않은 자료에 대한 가정이다. 왜냐하면 우리가 관측하는 자료들은 대상이 처치집단에 속하는 경우 $Y(0)$에 대한 정보를 알려주지 않고, 그 반대의 경우도 마찬가지이기 때문이다. 따라서, 이 가정은 검정이 불가능하다. 그렇지만, **balance**의 개념에서 간접적으로 측정할 수 있다.

결국 unconfoundedness 가정은 처치 여부에 대한 random assignment에 대한 것이고, 여기서 우리가 균형잡고자 하는 것은
$$
\begin{align}
\mathrm{P}(Y(0)\vert Z=1)\;\;\mathrm{vs.}\;\;\mathrm{P}(Y(0)\vert Z=0) \\
\mathrm{P}(Y(1)\vert Z=1)\;\;\mathrm{vs.}\;\;\mathrm{P}(Y(1)\vert Z=0)
\end{align}
$$
이다. 즉, 처치여부에 따라 달라지는 잠재적 결과를 밸런싱하는 것이 실제 관측 자료를 바탕으로 연구를 진행하는 목적이다.

### Assessing unconfoundedness

추가적인 자료를 가정하면, unconfoundedness 가정을 측정할 수 있다. 다음은 그에 대한 몇 가지 방법이다.

#### Multiple Control Groups

다변량 대조군 (ex. $T_{i}\in \{-1,0,1\}$)을 가정하고, 처치변수는 1에만 대응된다고 하자. 그러면 처치변수는 $Z_{i}=I(T_{i}=1)$ 이 되고 결과변수는 다음과 같이 쓸 수 있다.
$$
Y_{i}=\begin{cases}
Y_{i}(0) & \text{if } T_{i}\in\{-1,0\} \\
Y_{i}(1) & \text{if } T_{i}=1
\end{cases}
$$
이때, unconfoundedness 가정을 확장하여 다음과 같이 결과변수와 다변량 대조군 지시함수 $T_{i}$의 독립으로 나타내자.
$$
\{Y_{i}(0),Y_{i}(1)\}\perp\!\!\!\perp T_{i}\;\vert\;X_{i}
$$
그런데, 만일 $T_{i}$를 $\{-1,0\}$으로 제한하면 다음과 같은 검정가능한 가정을 얻을 수 있다.
$$
Y_{i}(0)\perp\!\!\!\perp I(T_{i}=0)\;\vert\;X_{i},T_{i}\in\{-1,0\}
$$
따라서, 관측치에 대한 가정
$$
Y_{i}^{obs}\perp\!\!\!\perp I(T_{i}=0)\;\vert\;X_{i},T_{i}\in\{-1,0\}
$$
은 관측치로 측정할 수 있는 unconfoundedness 가정이 된 것이다.

#### Lagged Outcomes(Crump et al., 2008)

시차가 적용된 결과변수(이하 시차변수) $Y_{lag}$을 상정하는데, 이때 $Y_{lag}$는 처치변수 이전에 관측되어 처치에 의해 영향을 받지 않는다. 이 경우 시차변수는 unconfoundedness 가정의 $Y(0)$를 대신할 수 있다.  따라서, 만일 나머지 공변량들($\mathbf{V}:=\mathbf{X}\backslash Y_{lag}$)에 대해 시차변수에 대한 ATE가 0이라면 unconfoundedness 가정을 만족한다고 볼 수 있다. 즉, 다음을 검정하게 되는 것이다.

$$
\begin{align}
\mathrm{H}_{0}&:\mathrm{E}[Y_{lag,z=1}-Y_{lag,z=0}\vert\mathbf{V=v}]=0\quad \forall \mathbf{v}\\\\

\mathrm{H}_{1}&: \exists\mathbf{v}\;\;\mathrm{s.t}\;\;\mathrm{E}[Y_{lag,z=1}-Y_{lag,z=0}\vert \mathbf{V=v}]\neq0
\end{align}
$$

공통적으로 시차의 존재가 필요하기 때문에, 횡단적 연구<sup>cross-sectional</sup>보다 패널 연구<sup>panel</sup> 혹은 반복측정된 횡단적 자료에 대해 더 적합하다. 또한, 이 방법은 DID<sup>Difference-in-Difference</sup>방법과도 큰 연관성을 가지고 있다.

#### Negative Control Outcomes(Sofer et al., 2016)

NCO의 아이디어는 대상 결과변수 $Y$ 외에 또 다른 결과변수 $W$를 상정하는 것이다. 이때 새로운 결과변수는 연구 대상인 처치변수에 의해 인과적 영향이 없다는 것이 **선험적으로** 알려져있어야 한다. 앞서 살펴본 시차변수도 NCO의 특수한 경우로 볼 수 있다.  예를 들어, 독감예방접종여부가 처치변수이고 독감으로 인한 입원여부가 결과변수일 때, 외상<sup>injury</sup>으로 인한 입원여부를 NCO로 설정할 수 있다(Shi et al.).

이때 $W=ZW(1)+(1-Z)W(0)$을 NCO로 두면 unconfoundedness 가정은
$$
\{W(1),W(0)\}\perp Z\;\vert \;X
$$
와 같고, 이는 검정가능하다. ($\mathrm{E}[W(1)-W(0)\vert X] =0$ 이기 때문)

## Sensitivity Analysis

앞서 다룬 세 가지 방법들은 추가적인 실험적 장치를 바탕으로 unconfoundedness 가정을 간접적으로 검정하고자 했다. 이와 달리 민감도 분석은, 검정에 초점을 두기보다는 모형에 대한 일종의 성능을 측정한다고 생각하면 된다.

### Assumption

민감도 분석의 기본 아이디어는 측정되지 않은 confounder가 하나 존재한다고 가정하는 것이다. 즉, 중심이 되는 가정은 다음과 같다.
$$
P(Z\vert Y(0),Y(1),X)\neq P(Z\vert X)
$$
이는 곧 unconfoundedness 가정이 관측된 공변량 $X$만으로는 만족되지 않음을 나타낸다. 또한, 관측되지 않은 공변량 $U$가 존재하여, 만일 이를 추가적으로 관측하면 가정을 만족한다. 즉, 다음과 같다.
$$
P(Z\vert Y(0),Y(1),X,U)=P(Z\vert X,U)
$$

또한, $Y,Z,U$는 binary variable로 가정하고(각각 결과, 처치, 관찰되지 않은 교란변수), 공변량 $X$를 범주형 변수로 두자($X=x, x\in \{1,\ldots,k\}$).

이후, 다음과 같이 전체 변수들에 대한 결합분포를 분해하도록 하자.
$$
P(Y(1),Y(0),Z,X,U) = P(Y(1),Y(0)\vert X, U)P(Z\vert X,U)P(U\vert X)P(X)
$$

### Parameters

각 변수들에 대해 다음과 같은 분포를 가정하자. 이때 모수벡터 $(\pi,\alpha,\delta_{1},\delta_{0})$ 를 **sensitivity parameters**
라고 부른다.

> $U\sim \mathrm{Ber}(\pi)$
> $\mathrm{logit} P(Z=1\vert u)=\gamma +\alpha u$ : Assignment mechanism model
> $\mathrm{logit} P(Y(z)=1\vert u) = \beta_{z}+\delta_{z}u$ : Outcome model

각 모수는 다음과 같은 의미를 가지고 있다.

- $\alpha=\log[\frac{P(Z=1\vert U=1)/P(Z=0\vert U=1)}{P(Z=1\vert U=0)/P(Z=0\vert U=0)}]$ : 처치변수와 교란변수 간의 로그 오즈비<sup>log odds ratio</sup>
- $\delta_{z}=\log[\frac{P(Y(z)=1\vert U=1)/P(Y(z)=0\vert U=1)}{P(Y(z)=1\vert U=0)/P(Y(z)=0\vert U=0)}]$ : 결과 $Y(z)$와 교란변수 간의 로그 오즈비

실제로는, 각 모수들은 공변량 $X$나 propensity score에 조건을 두고있다.

### Procedure

민감도 분석의 과정은 다음과 같다(Rosenbaum and Rubin, 1983).

1. $\tau,\alpha,\delta_{0},\delta_{1}$ 들에 대해, 각각의 모수가 가질 수 있는 값들의 집합에 대해 격자를 설정한다.
2. 각 격자점에 대해 처치효과를 추정한다.
3. 해당 값들의 변동성을 측정한다. 만일 관측되지 않은 교란변수 $U$에 대해 추정치들이 민감하지 않다면 인과추론이 더 *defensible*하다.


### Limitations

민감도 분석에는 다음과 같은 한계들이 있다.
- 분석을 진행하기 위해 confounding에 대한 검정가능하지않은 추가적인 가정이 필요함.
- 관측되지 않은 교란변수를 하나만 가정해야 함.
- 모수적 모형임
- 대부분의 경우 homogeneity $\delta_{1}=\delta_{0}$를 가정함.

## Advanced Sensitivity Analysis

### Ding and VanderWeele, 2014

Rosenbaum의 민감도분석 방법 외에도 대부분의 민감도분석 기법은 추가적인 untestable assumption을 요구한다. 그러나 Ding and VanderWeele은 오직 두 개의 민감도 모수를 활용하여 측정되지 않은 교란변수에 대한 가정 없이 민감도 분석을 진행하는 방법을 고안하였다.

#### Relative Risk

우선, 분석을 위해 여러 방향에서의 relative risk<sup>상대위험</sup>를 정의하는데, 먼저 처치변수와 결과변수 간의 상대위험은 다음과 같이 두 가지로 정의된다.

- Observed Relative Risk

$$
\begin{align}
\mathrm{RR}_{ZY\vert x}^{obs} &=  \frac{P(Y=1\vert Z=1,x)}{P(Y=1 \vert Z=0,x)}\\
&= \frac{\sum_{u}P(Y=1\vert Z=1,x,u)P(u\vert Z=1,x)}{\sum_{u}P(Y=1\vert Z=0,x,u)P(u\vert Z=0,x)}
\end{align}
$$

- Causal Relative Risk
$$
\begin{align}
\mathrm{RR}_{ZY\vert x}^{\mathrm{true}} &= \frac{P(Y(1)=1\vert x)}{P(Y(0)=1\vert x)}\\
&= \frac{\int P(Y(1)=1\vert x,u)F(du\vert x)}{\int P(Y(0)=1\vert x,u)F(du\vert x)}\\
&= \frac{\sum_{u}P(Y=1\vert Z=1,x,u)P(u\vert x)}{\sum_{u} P(Y=1\vert Z=0,x,u)P(u\vert x)}
\end{align}
$$

이때, $Z \not\perp (Y(1),Y(0))\;\vert\; X$ 이므로  두 상대위험은 같지 않다. 그 다음으로, 처치변수와 교란변수 $U$ 간의 상대위험은 다음과 같이 정의된다.
$$
\mathrm{RR}_{ZU\vert x}(u) = \frac{\mathrm{P}(u\vert Z=1,x)}{\mathrm{P}(u\vert Z=0,x)}
$$
또한, $U$에 대한 $Z$의($Z$ on $U$) 최대상대위험은 다음과 같이 정의한다.
$$
\mathrm{RR}_{ZU\vert x} = \max_{u}\mathrm{RR}_{ZU\vert x}(u)
$$

마찬가지로, 교란변수와 결과변수의 관계에서도 상대위험을 다음과 같이 정의한다.

- Unexposed인(처치가 이루어지지 않은) 대상에 대한 최대상대위험

$$
\mathrm{RR}_{UY(0)\vert x}=\frac{\max_{u}\mathrm{P}(Y(0)=1\vert x,u)}{\min_{u}\mathrm{P}(Y(0)=1\vert x,u)}
$$

- Exposed인 대상에 대한 최대상대위험
$$
\mathrm{RR}_{UY(1)\vert x}=\frac{\max_{u}\mathrm{P}(Y(1)=1\vert x,u)}{\min_{u}\mathrm{P}(Y(1)=1\vert x,u)}
$$
- $Y$에 대한 $U$의 상대위험
$$
\mathrm{RR}_{UY\vert x}=\max\{\mathrm{RR}_{UY(0)\vert x}, \mathrm{RR}_{UY(1)\vert x}\}
$$

이때, 주어진 인과모형에서 교란의 세기<sup>strength of confounding</sup>에 대한 측도로 다음을 사용한다(편의를 위해 아래부터 조건 $X=x$ 생략).
$$
(\mathrm{RR}_{ZU},\mathrm{RR}_{UY})
$$

#### Analysis

민감도 분석의 목적은 다음과 같다.

> Observed relative risk $\mathrm{RR}_{ZY}^{\mathrm{obs}}$ 와 교란의 세기 측도 $(\mathrm{RR}_{ZU},\mathrm{RR}_{UY})$으로부터 causal risk ratio $\mathrm{RR}_{ZY}^{\mathrm{true}}$ 를 부분적으로 파악하는 것이다.

이때, causal risk ratio에 대해 다음의 **하한**이 존재한다.
$$
\mathrm{RR}_{ZY}^{\mathrm{true}}\geq \mathrm{RR}_{ZY}^{\mathrm{obs}} \bigg/\frac{\mathrm{RR}_{ZU}\times\mathrm{RR}_{UY}}{\mathrm{RR}_{ZU}+\mathrm{RR}_{UY}-1}
$$
이때 나누어주는 항 $\frac{\mathrm{RR}_{ZU}\times\mathrm{RR}_{UY}}{\mathrm{RR}_{ZU}+\mathrm{RR}_{UY}-1}$ 을 **bounding factor**라고 정의하고 $\mathrm{BF}_{U}$ 라고 나타낸다.





# References
- STA 640 Lecture Notes of Duke University, Fan Li.