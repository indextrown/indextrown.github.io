---
title: "Causal Inference (2) : Structural Causal Model"
tags:
- Causal Inference
- Statistics
- Structural Causal Model
category: Causal Inference
use_math: true
---
{% raw %}
## Cause-Effect Model
### Structural Causal Model
줄여서 SCM이라고 하는 **Structural Causal Model**은 인과관계모델을 구조화한 표현이다. 여기서는 우선 원인(C)과 결과(E) 두 변수로 구성된 Cause-Effect 모델만을 다루고, 이에 대한 SCM을 다음과 같이 정의한다.
> Def. $C\to E$에 대한 SCM $\mathfrak C$는 두 assignment로 구성된다.
> 
> $$
> 
> C:= N_C,\;\;E:=f_E(C, N_E)\\
> \text{where} \;\;N_C \bot N_E
> 
> $$
> 
> 이때 $C\to E$로 표기한 것을 **causal graph**라고 하며, effect에 직접적으로 연결된 cause 변수를 direct cause라고도 한다.

### Intervention

[이전 글](https://ddangchani.github.io/causal inference/Causal_Inference_1)에서도 잠시 언급했다시피, intervention은 causal model의 한 변수를 변화시키는 것을 의미한다. 이때 interevention이 이루어지면 해당 시스템은 또 다른 분포를 취하는데, 이는 기존의 observational distribution과 별개의 것이다. 예를 들어 SCM $\mathfrak C: C\to E$ 에서 effect의 값을 4로 변경시키는 intervention이 이루어진다고 하자. 이렇게 직접적으로 값을 변경시키는 것을 *hard intervention*이라고도 부르는데, 이를 $do(E:=4)$ 로 표현한다.

$$

E:=4 \to do(E:=4)

$$


이때 이러한 intervention이 이루어지면, C의 확률분포 역시 변화될 수 있다. 이를

$$

P_C^{do(E:=4)}

$$


로 표기하며, 이때 확률밀도함수를 편의상 $p^{do(E:=4)}(c)$ 로 나타낸다. 반면, *soft intervention*은 좀 더 일반적인 형태로 intervention이 이루어지는 것을 의미한다. 예를 들면 앞서 정의한 SCM $\mathfrak C$에 대해 아래와 같이 Noise distribution을 변경하는 것이다($N_E \to \tilde N_E$).

$$

\text{ex.}\;\;do(E:=g_E(C) + \tilde N_E)

$$

위 경우 E의 C에 대한 functional dependence term $g_E(C)$는 그대로이고, Noise distribution만 변화된 것을 알 수 있다. 
Cause-Effect model의 intervention에서 중요한 것은, cause variable에 대한 개입이 이루어진 경우 effect variable에 영향이 미친다는 것이다. 즉,

$$

P_E^\mathfrak C \neq P_E^{\mathfrak C:do(C)}

$$


가 성립한다. 그러나 반대로 effect variable에 대한 개입이 이루어진 경우, cause variable은 E에 무관한 Noise variable만으로 주어지므로 확률분포의 변화가 없다. 즉,

$$

P_C^\mathfrak C = P_C^{\mathfrak C:do(E)}

$$


이 성립한다. 따라서 SCM의 개입 문제를 다룰 때, 우리는 개입이 어떤 변수에 대해 이루어지는지 면밀히 살펴볼 필요가 있다.

### Counterfactual
Counterfactual은 한국어로 번역하면 *’반사실적인 문장’* 정도로 해석되는데, 이는 고등학교 영어 문법시간에 배우는 가정법을 생각하면 편하다. 가정법에서 조건부에 과거시제를 쓰는 경우는 현재사실과 반대되는 가정(ex. If I were ~)이라는 것을 배운적 있을 것이다. Counterfactual은 이러한 상황을 의미하며, 구체적으로 여기서는 SCM을 통해 counterfactual한 진술을 수치적으로 계산할 수 있음을 살펴보고자 한다. 교재의 예시를 통해 살펴보도록 하자.
어떤 안과에서 특정 증상을 가진 환자들을 진료하는데, 99%의 환자에 대해서는 치료법(T)를 쓸 경우(T=1) 완치되고(B=0), 치료를 놔두면(T=0) 눈이 멀게 된다(B=1). 반면, 특이한 케이스인 1%의 환자에 대해서는 그 반대로 치료를 하지 않아야 눈이 완치된다고 한다. 이를 SCM으로 표현하면 다음과 같다.

$$

\mathfrak C:\begin{cases} T:= N_T \\ B:= T\cdot N_B + (1-T)(1-N_B)\end{cases} \\
\text{where} \;\;N_T\bot N_B,\;\; N_B\sim\text{Bernoulli}(0.01)

$$


이때, 어떤 환자 A씨가 병원에 와서 치료를 받고 눈이 멀게되었다고 하자(observation). 그러면 이에 대한 counterfactual statement인 *만일 의사가 치료를 하지 않았다면(T=0) 어땠을까?* 라는 물음에 다음과 같은 방식으로 답을 추정할 수 있다. 

우선, 환자 A씨의 경우에 대해 관측된 사실은 $T=B=1$ 이라는 것이고, 이로부터 $T=B=1$ 조건 하에서 $N_B,N_T$의 확률분포가 1에서 point mass 1을 갖는다는 것이다. 즉,

$$

P_{N_B\vert T=B=1}= P_{N_T\vert T=B=1} = \delta_1

$$


이다. 이로부터 다음과 같은 수정된 SCM

$$

\mathfrak C\;\vert \;B=T=1 :\begin{cases} T:=1\\ B:= T+ (1-T)\cdot 0 = T\end{cases}

$$


을 얻을 수 있는데, 이때 counterfactual에 해당하는 진술은 $T=0$이므로, 이에 대한 intervention $do(T:=0)$에 대한 SCM은

$$

\mathfrak C\;\vert \; B=T=1 : do(T:=0) :\begin{cases} T:=0\\ B:= T = 0\end{cases}

$$


이 된다. 즉, (0,0)에서 point mass 1을 가지므로 counterfactual probability(만일 의사가 치료를 하지 않았을 경우)는

$$

P^{\mathfrak C:do(T:=0)}(B=0) = 1

$$


이 된다. 즉, 치료를 하지 않았을 경우 실명이 되지 않을 확률이 1이다.

### Canonical representation of SCM
Assignment $E=f_E(C,N_E)$ 에 대해, noise variable $N_E$가 고정값 $n_E$를 갖는다면

$$

E= f_E(C,n_E)

$$


의 꼴로 쓸 수 있으며, 이는 $C$에 대한 deterministic function이다(C에서 E로의 함수). 이때 $C,E$가 각각 집합 $\mathcal{C,E}$ 에서 값을 취한다면 $N_E$는

$$

\mathcal{E^C} = \{f\;\vert \; f:C\to E\}

$$


에 속한 함수로부터 값을 취한다. 따라서, 위 함수는 $n_E$ 값에 의존하므로

$$

E= n_E(C)

$$


의 형태로 간추릴 수 있는데, 이를 *canonical representation* of structural equation이라고 한다.

만일 $\mathcal C = \{1,\ldots,k\}$, 즉 finite 하다면

$$

\mathcal E^k := \mathcal E\times\cdots\times \mathcal E

$$


이므로, 이는 k차원 벡터공간이고 각 벡터의 j번째 성분은 $C=j$ 값을 취할 때 $E$의 값을 의미한다. 따라서, 확률분포 $P_{N_E}$는 $\mathcal E^k$에서의 joint distribution인데, j번째 marginal distribution에 대해

$$

P_{E\vert C=j} = P_E^{do(C:=j)}

$$


가 성립한다. 식의 좌변은 observational conditional probability이고, 식의 우변은 interventional probability이다. 이는 cause-effect SCM의 causal intervention(변수 C에 대한 intervention, 우변)이 noise variable $N_E$의 원소에 대한 marginal distribution(좌변)에 의해 결정된다는 것을 의미한다.

#### Dependencies between noise vector
만일 앞서 살펴본 $\mathcal E^k$의 원소인 Noise variable vector의 각 성분이 확률적으로 독립이 아니라면 어떻게 될지 살펴보도록 하자. 각 성분이 종속일 경우 SCM의 구조에는 큰 영향을 주지 않지만, counterfactual statement 판단에는 영향을 줄 수 있다. 다음 예시를 살펴보도록 하자.

앞선 두 집합이 $\mathcal{C=E}=\{0,1\}$ 로 주어진다면

$$

\mathcal E^\mathcal C = \{\mathbf {0, 1}, I, NOT\}

$$

으로 주어진다. 여기서 $\mathbf{0,1}$ 은 각각 0, 1로의 상수함수를, $I$는 항등함수(identity function)를, NOT은 0을 1로, 1을 0으로 mapping하는 함수를 의미한다. 이때 $\mathbf{0,1}$의 uniform mixture(동일한 확률로 섞은 확률분포)을 $P_{N_E}^1$, $I, NOT$의 uniform mixture을 $P_{N_E}^2$ 라고 두면 두 경우 모두 동일한 marginal distribution을 갖는다.
그러나, 임의의 결과(ex. $C=0, E=0$)에 대해 counterfactual *’만일 C가 다른값을 취했다면 E가 다른 값을 나타냈을 것이다’* 를 생각해보면
$P_{N_E}^1$에 대해서는 함수가 $(C,E)=(0,0)$으로 결정되어 counterfactual에 대해 $E=1$이 도출된다. 반면, $P_{N_E}^2$에 대해서는 함수가 $(0,1)$로 결정되는데, 이에 반대되는 함수는 $(1,0)$이므로 $E=0$이 도출된다. 즉, counterfactual statement에 대한 두 진술이 다르게 나타나고, 이는 Noise variable vector의 성분이 서로 종속이기 때문에 발생한 현상이다.

# References

- Elements of Causal Inference, Jonas Peters et al.




{% endraw %}