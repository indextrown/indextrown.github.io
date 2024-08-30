---
title: "State-Space Model"
tags:
- Time Series
- Kalman Filter
category: Time Series
use_math: true
---
{% raw %}
상태공간모형(State-Space Model, 이하 SSM)은 Markov chain을 기반으로 하는 시계열 모형의 일종이지만, 실제 관측가능한 observation 데이터와 hidden state data가 결합하여 만들어진다.

## Definition

상태공간모형은 다음과 같이 정의된다. 각 t 시점에서는 세 종류의 벡터가 주어지는데, 먼저 벡터 $$\mathbf{x}_t \in \mathbb{R}^p$$ 는 각 시점의 hidden state vector로, 관측할 수 없다. 반면 $$\mathbf{y}_{t}\in \mathbb{R}^{p}$$ 와 $$\mathbf{u}_{t}\in\mathbb{R}^{r}$$ 는 각각 observation vector, exogenous vector(외생변수)로 이들은 관측가능한 데이터로 주어진다. 이때 다음과 같은 관계식으로 주어지는 모형을 **상태공간모형**이라고 한다.

$$

\begin{cases}
\mathbf{x}_{t} = \Phi\mathbf{x}_{t-1}+\gamma \mathbf{u}_{t}+w_{t}\\
\mathbf{y}_{t} = A_{t}\mathbf{x}_{t}+\Gamma\mathbf{u}_{t}+ v_{t} 
\end{cases}

$$

여기서 noise vector $w_{t}, v_{t}$ 는 각각 정규분포 $N_{p}(0,Q), N_q(0,R)$ 을 따르며 각각 독립이다. 이러한 **정규성 가정**(Gaussian assumption)은 상태공간모형에서 매우 중요하다.

## Kalman Filter
### Filtering

SSM 사용의 주된 목적은 주어진 관측가능한 데이터 $$Y_{s}=\{\mathbf{y}_{1},\ldots,\mathbf{y}_{s}\}$$ 를 바탕으로 underlying, unobserved signal $$\mathbf{x}_{t}$$ 를 추정하는 것이다. 이때 각 index $s,t$ 의 관계에 따라

$$

\begin{aligned}
& s<t : \text{forecasting}\\
& s=t : \text{filtering}\\
& s>t : \text{smoothing}
\end{aligned}

$$

각 추정 과정에 대해 위와 같은 명칭을 사용한다.

#### Definition
Kalman Filter의 전개 과정에서 prediction, expectation error는 다음과 같이 정의된다.

$$

\begin{aligned}
&\mathbf{x}_{t}^{s}=\mathbf{E}[\mathbf{x}_t\vert Y_s]\\
&P_{t_{1},t_{2}}^{s}=\mathbf{E}[(\mathbf{x}_{t_{1}}-\mathbf{x}_{t_{1}}^{s})(\mathbf{x_{t_{2}}}-\mathbf{x}_{t_{2}}^{s})]
\end{aligned}

$$

이때 위 정의들에서 기댓값 연산을 선형공간 $\text{span}(Y_s)$ 으로의 정사영 연산으로 볼 수 있는데, 이 경우 $P_{t}^{s}$를 projection의 MSE로 볼 수도 있다.

### Definition of Kalman Filter
State-Space Model([위 정의와 동일](##Definition))

$$

\begin{aligned}
&\mathbf{x}_{t} = \Phi\mathbf{x}_{t-1}+\gamma \mathbf{u}_{t} + w_{t}\\
&\mathbf{y}_{t}= A_{t}\mathbf{x}_{t}+\Gamma\mathbf{u}_{t}+v_{t}
\end{aligned}

$$

에 대해 초기조건

$$

\begin{aligned}
& \mathbf{x}_{0}^{0}=\mathbf{E}[\mathbf{x}_0\vert Y_{0}]=\mu_0\\
& P_{0}^{0}=\Sigma_0
\end{aligned}

$$

이 주어진다고 하자. 그러면 위 모형에 대한 **Kalman Filter**는 다음과 같이 주어진다.

$$

\text{For}\;\; t=1,\ldots,n,\;\;
\begin{cases}
\mathbf{x}_{t}^{t-1}=\Phi\mathbf{x}_{t-1}^{t-1}+\gamma\mathbf{u}_t \\
P_t^{t-1}=\Phi P_{t-1}^{t-1}\Phi^T+Q
\end{cases}

$$

$$

\text{with}\;\;\begin{cases}
\mathbf{x}_{t}^{t}=\mathbf{x}_{t}^{t-1}+K_{t}(\mathbf{y}_{t}-A_{t}\mathbf{x}_{t}^{t-1}-\Gamma\mathbf{u}_{t} \\
\\
P_{t}^{t}=[I-K_{t}A_{t}]P_{t}^{t-1}
\end{cases}

$$

$$

\text{where}\;\;K_{t}=P_{t}^{t-1}A_{t}^{T}[A_{t}P_{t}^{t-1}A_{t}^{T}+R]^{-1}

$$

즉, 여기서 Kalman filter란 관측불가능한 underlying signal $\mathbf{x}_{t}$ 들을 재귀적인(recursive) 방법으로 추정하는 과정을 의미한다.  이 과정에서 다음과 같이 부가적인 정의를 생성하는데, 각각 예측오차(prediction error)와 예측오차의 분산이다.

$$

\begin{cases}
\epsilon_{t}=\mathbf{y}_{t}-\mathbf{E}[\mathbf{y}_{t}\vert Y_{t-1}]=\mathbf{y}_{t}-A_{t}\mathbf{x}_{t}^{t-1}-\Gamma\mathbf{u}_{t}\\
\\
\text{Var}(\epsilon_{t})= A_{t}P_{t}^{t-1}A_{t}^{T}+R = \Sigma_{t}
\end{cases}

$$

### Proof of Kalman Filter
우선 SSM의 $$\mathbf{x}_{t}=\Phi\mathbf{x}_{t-1}+\gamma\mathbf{u}_{t}+w_{t}$$ 로부터,

$$

\begin{aligned}
\mathbf{x}_{t}^{t-1} &= E[\mathbf{x}_{t}\vert Y_{t-1}]\\
&= E[\Phi\mathbf{x}_{t-1}+\gamma\mathbf{u}_{t}+w_{t}\vert Y_{t-1}]\\
&= \Phi\mathbf{x}_{t-1}+\gamma\mathbf{u}_{t}
\end{aligned}

$$

이고, 이와 유사하게

$$

\begin{aligned}
P_{t}^{t-1} &= E[(\mathbf{x}_{t}-\mathbf{x}_{t}^{t-1})(\mathbf{x}_{t}-\mathbf{x}_{t}^{t-1})^{T}]\\
&= \Phi P_{t-1}^{t-1}\Phi ^{T}+Q
\end{aligned}

$$

임을 보일 수 있다.

또한, t시점에서의 오차는 이전 시점까지의 데이터셋과 orthogonal, 즉 $E[\epsilon_{t}\mathbf{y}_{s}^{T}]=0$ 이고

$$

\mathrm{Cov}(\mathbf{x}_{t},\epsilon_{t}\vert Y_{t-1})=P_{t}^{t-1}A_{t}^{T}

$$

가 성립하므로, $t-1$ 시점까지 관측치 $Y_{t-1}$ 이 주어졌을 때 위 상태벡터와 오차벡터의 결합분포는 다음과 같다.

$$

\begin{pmatrix} \mathbf{x}_{t}\\ \epsilon_{t} \end{pmatrix}
\vert Y_{t-1} 
\sim 
\mathrm{N}\biggl(\begin{pmatrix}\mathbf{x}_{t}^{t-1}\\0\end{pmatrix},
\begin{pmatrix}P_{t}^{t-1}& P_{t}^{t-1}A_{t}^{T}\\A_{t}P_{t}^{t-1}&\Sigma_{t}\end{pmatrix}\biggr)

$$

이때 $$\mathbf{x}_{t}^{t} = \mathrm{E}[\mathbf{x}_{t}\vert Y_{t}] = \mathrm{E}[\mathbf{x}_{t}\vert Y_{t-1},\epsilon_{t}]$$ 이므로 정규분포의 marginal distribution 공식을 이용하면 다음과 같이 유도할 수 있다.

$$

\begin{aligned}
\mathbf{x}_{t}^{t}&= \mathbf{x}_{t}^{t-1}+P_{t}^{t-1}A_{t}^{T}\Sigma^{-1}\\
&= \mathbf{x}_{t}^{t-1}+P_{t}^{t-1}A_{t}^{T}(A_{t}P_{t}^{t-1}A_{t}^{T}+R)^{-1}
\end{aligned}

$$

# References
- Time Series Analysis with its applications
{% endraw %}