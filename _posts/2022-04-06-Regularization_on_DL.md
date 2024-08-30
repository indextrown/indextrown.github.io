---
title: "Regularization on Neural Network"
tags:
- Deep Learning
- Regularization
- Neural Network
category: Deep Learning
use_math: true
---
{% raw %}
## Regularization on Neural Network

Neural Network는 기본적인 feedforward network조차도 학습해야 할 파라미터 개수가 많다. MNIST 데이터셋을 사용하는 네트워크에서, input layer의 값을 받는 첫번째 fully-connected hidden layer의 경우 노드가 30개라면 $784\times30 = 23520$ 개의 parameter를 갖는다. 심층 신경망이나, convolutional layer 같이 더 깊은 연산을 요구하는 신경망의 경우는 추정해야 할 파라미터가 많게는 수백만, 수천만개 까지 증가한다.

따라서, 신경망은 특정 훈련 세트에서 overfitting이 일어나기 쉬우므로, 규제<sup>regularization</sup>를 통한 과적합 방지가 필요하다. Linear regression과 같은 일반적인 머신러닝에서의 규제방법 역시 사용되며, 신경망 학습과정에 특수하게 사용되는 몇 가지 방법들도 있다. 여기서는 대표적인 방법들만 대략적으로 다루어보도록 하고, 깊이 있는 공부가 필요한 내용들은 추후 관련 논문 리뷰를 통해 살펴보도록 하겠다.

### Early Stopping

Early Stopping<sup>조기 종료</sup> 방법은 경사하강법과 같이 반복적인 학습이 이루어지는 알고리즘을 규제하는 방식이다. Stochastic Gradient Descent 알고리즘은 말 그대로 그래디언트와 학습률을 토대로 전역 최솟값을 찾는 방법인데, 조기종료 방법은 전역최소 도달 이전에 **Validation error**, 즉 검증 오차가 최솟값에 도달하면 훈련을 중지시키는 것이다. 즉, 학습 과정의 epoch마다 validation error을 계산하게 하고, 최솟값 변수 `minimum_val_error`가 일정 시간(epoch)동안 유지되면 훈련을 중지하는 방법이다.

`tensorflow`에서는 `callback` 메서드 중 하나로 `EarlyStopping` callback을 사용할 수 있게끔 마련해놓았다. `keras.callbacks.EarlyStopping()` callback은 매개변수로 `patience` 를 받는데(정수), 이는 앞서 설명한 것처럼 몇 번의 에포크 동안 점수 향상이 일어나지 않으면 중지할 것인지를 지정하는 변수이다. EarlyStopping을 이용하면 모델이 향상되지 않는 상황에서 자동으로 훈련이 중지되므로, epoch 초기값을 크게 설정해도 문제가 없다는 장점이 있다.

### L1, L2 Regularization

이전에 Linear Regression에서의 대표적인 규제 방법으로 Lasso, Ridge 방법을 살펴보았다([링크](https://ddangchani.github.io/linear%20model/linearreg1/)). 이때 사용된 방법이 L1, L2 Norm을 이용한 규제인데, 이는 신경망에서도 마찬가지로 사용될 수 있다. 다만, 신경망에서는 parameter가 행렬로 주어지므로, 행렬에 대해 L1,L2 노음을 어떻게 정의할 것인지에 대한 논의가 우선되어야 한다.

#### Matrix Norm

행렬에 대해 노음을 정의한다면, 노음의 성질을 만족할 수 있어야 한다.

> For $\forall \alpha\in\mathbb R$ and $\forall \mathbf A,\mathbf B\in\mathbf M_{m\times n}(\mathbb R)$,
>
> 1. $\Vert\alpha\mathbf A\Vert = \vert \alpha\vert \Vert\mathbf A\Vert$
> 2. $\mathbf{\Vert A+B\Vert \leq \Vert A\Vert +\Vert B\Vert}$
> 3. $\Vert\mathbf A\Vert\geq0$
> 4. $\Vert\mathbf A\Vert = 0 \iff \mathbf A=\mathbf O$

이는 해석학에서 살펴본 [노음공간의 성질](https://ddangchani.github.io/mathematics/실해석학10/)을 행렬 공간에 대해 그대로 적용한 것이다. 다만, 행렬에서 노음을 정의하기 위해서는 행렬곱셈이 정의될 때 아래와 같이 하나의 특성을 더 추가해야 한다.

$$

\mathbf{\Vert AB\Vert \leq \Vert A\Vert\cdot\Vert B\Vert}

$$

$m\times n$ 행렬 $\mathbf A$의 열벡터가 $\{\mathbf a_i:i=1,\ldots,n\}$ 들로 주어진다고 하자, 그러면 벡터공간에 정의된 L1 노음을 이용해 행렬노음공간의 위 성질들을 만족하도록 다음과 같이 L1 Matrix Norm을 정의할 수 있다.

$$

\Vert\mathbf A\Vert_1 = \max_{1\leq i\leq n}\Vert \mathbf a_i\Vert = \max\sum_{k=1}^m\vert a_{ik}\vert 

$$

L2 Norm을 정의하기 위해서는, 우선 Operator Norm(Induced Norm)에 대해 알아두어야 한다. 선형대수학에서 행렬은 Linear Operator, 즉 행렬 $A$ 뒤에 곱해지는(Linear operation) 벡터 $x\in V$ 를($V$는 vector space) 다른 벡터공간으로 이동시키는 것으로 여겨진다. 이때 Linear operator $A$ 에 대한 노음 $\Vert A\Vert_{\text{op}}$ 을 정의하기 위해 vector space의 노음을 유도해서 사용하는데, 정의는 다음과 같다.

$$

\begin{aligned}
\Vert A\Vert_{\text{op}} &=\inf\{c\geq 0: \Vert Ax\Vert\leq c\Vert x\Vert\;\; \forall x\in\mathbb R^n\}\\
&=\sup\{\Vert Ax\Vert : x\in \mathbb R^n,\;\;\Vert x \Vert=1\}

\end{aligned}

$$

이를 이용하면, 다음과 같이 L2 Matrix Norm을 유도할 수 있다.

$$

\Vert A\Vert_2 = \sup_{\Vert x\Vert=1}\Vert Ax\Vert_2\\
=\sup\biggl\{ \frac{\Vert Ax\Vert}{\Vert x\Vert} : x\in \mathbb R^n,\;\; x\neq 0 \biggr\}

$$

이때, 아래 식은 Rayleigh quotient의 꼴이므로, 아래 집합의 supremum을 찾는 것은 행렬 $A$의 최대 고유값을 찾는 것과 같다. 따라서, 행렬의 L2 Norm은 최대 고유값(Largest Eigenvalue)으로 정의된다.

신경망에서 L1, L2 규제를 이용한다는 것은 Loss function $L(W,b)$의 계산과정에 $\Vert W\Vert_1$ 또는 $\Vert W\Vert_2$를 더한다는 것을 말한다. 또한, Linear regression의 Lasso, Ridge penalty term과 마찬가지로 규제 강도값을 설정해 이를 노음에 곱하여 사용하는데, 이는 어느 정도로 노음 규제를 허용할 것인지 정하는 hyperparmeter이다. keras에서는 `keras.regularizers.l1()`과 `keras.regularizers.l2() `가 사용가능하고, 각각 매개변수로 규제강도 값(기본값은 0.01)을 받는다.

### Dropout

드롭아웃에 대한 기본적인 내용은 [AlexNet](https://ddangchani.github.io/deep%20learning/AlexNet/) paper review에서 다룬 것을 살펴보면 되고, 자세한 내용은 다른 논문 리뷰에서 다루도록 하겠다.

### Max-Norm Regularization

Max-norm regularization 기법은 신경망에서 널리 사용되는 기법 중 하나이다. 이는 노음을 사용하긴 하지만, L1이나 L2 노음 규제항을 손실함수에 직접 추가해서 계산하는 것이 아닌, 해당 가중치 행렬의 노음을 계산해서 이것이 특정 값을 넘지 않도록 조절하는 규제방법을 의미한다. 즉, 가중치행렬의 max-norm을 $r$로 설정했다면, $\Vert W\Vert_2\leq r$ 이 되도록 제한하며 만일 특정 레이어가 max-norm을 초과한다면, 이를 만족시키도록 $W$의 스케일을 조절한다. 일반적으로 max-norm regularization을 이용하면 불안정한 그래디언트 문제를 완화하는 데 효과적이라는 것이 알려져있다.



# References

- Hands on Machine Learning, 2e.
- https://hichoe95.tistory.com/58
{% endraw %}