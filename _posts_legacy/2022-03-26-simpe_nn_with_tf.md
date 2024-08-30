---
title: Simple Neural Network with Tensorflow
tags:
- Deep Learning
- Tensorflow
- Neural Network
category: Deep Learning
use_math: true
header: 
 teaser: /assets/img/simpe_nn_with_tf.assets/simpe_nn_with_tf_0.png
---
{% raw %}
## Simple Neural Network with Tensorflow

Tensorflow를 이용해, 이전까지 알아본 신경망의 기본적인 내용을 바탕으로 간단한 신경망을 구현해보자. 우선, 필자는 M1 Macbook Air에 python 3.9버전을 올려 apple tensorflow 2.8 버전 환경을 사용하고 있음을 알린다. M1 환경에서 tensorflow를 설치하는 방법은 [Apple Developer 문서](https://developer.apple.com/metal/tensorflow-plugin/)를 참고하면 된다.*(자세한 설치방법 등은 구글링하면 많이 나오는데 댓글에 남기면 답변드리도록 하겠습니다😃)*

`tensorflow`에는 이를 기반으로 한 `keras`라는 매우 간편하면서도, 간단한 딥러닝 라이브러리가 존재한다. 그러나 `keras`로 구현하는 코드는 신경망이 작동되는 기본적인 원리를 파악하기 힘들기 때문에, 우선은 직접 구현하는 것을 살펴보도록 하자. 텐서플로의 사용법 등 기본적인 내용은 다루지 않고, 신경망을 구현하는 것만 우선 다루어보도록 하자. 이와 관련하여 역전파 등 간단한 딥러닝 메커니즘을 직접 구현한 글(Reference 참고)이 있어서, 이번 글은 이를 번역하고 추가적인 설명을 덧붙이는 방식으로 썼다.

### MNIST 데이터셋 불러오기

거의 대부분의 딥러닝/머신러닝 관련 책을 구입하면 첫 장에 예제로 사용되는 데이터가 MNIST 데이터셋이다. MNIST는 한자리 숫자 이미지를 분류하는 문제로 텐서플로와 케라스를 설치하면 기본적으로 불러올 수 있게끔 되어있다.

~~~py
import tensorflow as tf
from tensorflow import keras
from keras.datasets import mnist
~~~

필요한 모듈을 로드하고, 데이터셋을 다음과 같이 불러올 수 있다.

~~~python
(X_train, y_train), (X_test, y_test) = mnist.load_data()
X_train.shape
~~~

위 코드를 실행하면 `(60000, 28, 28)` 이라는 결과값이 출력되는데, 이는 각 MNIST 데이터셋의 이미지가 $28\times 28$ 픽셀로 구성된 이미지이고 Training set의 $N=60000$ 이라는 것을 나타낸다. 실제로 어떻게 구성되었는지 확인하기 위해, 다음의 코드를 실행하면

```python
import matplotlib.pyplot as plt
img = X_train[0]
img_reshaped = img.reshape(28,28)
img_reshaped.shape

plt.figure(figsize=(4,4))
plt.title('sample of ' + str(y_train[0]))
plt.imshow(img_reshaped, cmap='gray')
plt.show()
```

아래와 같은 훈련 데이터셋의 첫 번째 이미지(그래프)를 얻을 수 있다.

<img src="/assets/img/simpe_nn_with_tf.assets/simpe_nn_with_tf_0.png" alt="스크린샷 2022-03-26 오후 2.28.16">

### Simple Feedfoward Neural Network

#### Initializing Network

앞서 살펴본 MNIST 데이터를 처리할 수 있는 신경망을 만들어보도록 하자. 여기서는 가장 단순한 Feedfoward Neural Network만을 다루며, 이는 신경망 내의 노드끼리 순환이 일어나지 않는 것을 의미한다. 이전 글에서 살펴본 신경망들과 같은 형태이다. 우선 신경망을 구축하기 위해서는 Layer 개수와, Layer별 노드 수를 설정해서(hyperparameter) 이에 맞는 Weight matrix, Bias matrix 변수를 설정할 수 있게끔 해야할 것이다. 여기서는 python의 클래스(`class`)로 특별히 **2개의 hidden layer**를 갖는 **Fully-connected** MLP를 구현해보도록 하자. (Fully-connected인 이유는 레이어간 연산을 행렬연산으로 쉽게 구현할 수 있기 때문이다❗️)

```py
class Network(object):
    def __init__(self, n_layers):
        self.params = [ ]

        self.W1 = tf.Variable(
        tf.random.normal([n_layers[0],n_layers[1]],stddev=0.1), name='W1'
        )
        self.b1 = tf.Variable(tf.zeros([1,n_layers[1]]))

        self.W2 = tf.Variable(
				tf.random.normal([n_layers[1], n_layers[2]], stddev=0.1), name='W2'
				)
        self.b2 = tf.Variable(tf.zeros([1,n_layers[2]]))

        self.W3 = tf.Variable(
				tf.random.normal([n_layers[2], n_layers[3]],stddev=0.1), name='W3'
        )
        self.b3 = tf.Variable(tf.zeros([1, n_layers[3]]))

        self.params = [self.W1, self.b1, self.W2, self.b2, self.W3, self.b3]
```

위 코드는 2-hidden layer mlp에 필요한 변수(W1,W2,W3,b1,b2,b3) 들을 텐서플로의 변수객체 `tf.Variable`으로 설정하며 동시에 가중치행렬($\mathbf{W_1,W_2,W_3}$) 은 정규분포에서 임의로, 편향벡터($\mathbf{b_1,b_2,b_3}$) 는 영벡터로 생성한다(변수들을 텐서<sup>tensor</sup>라고도 부른다). 또한, 각 행렬과 벡터의 크기는 Hyperparmeter로 받은 `n_layers`(Input layer, 두 개의 hidden layer, Output layer의 각 노드개수를 리스트 형태로 받는다✅) 에 의해 결정된다. 

신경망에서 처리되는 데이터 행렬은 모두 행<sup>row</sup>이 샘플개수, 열<sup>column</sup>은 특성 개수를 의미한다. 예를 들어, MNIST의 경우 Input layer의 Data Matrix를 살펴보면, 각 데이터(이미지)가 784개의 특성을 가지므로 (이는 노드 개수를 의미한다❗️) Input layer는 784개 노드로 구성되며, Input Matrix는 $60000\times784$ 행렬이 된다. 만일 첫번째 hidden layer가 30개의 노드를 가지고 fully-connected인 경우 Input Matrix $\mathbf X_1$과 hidden layer의 데이터 $\mathbf X_2\in \mathbf M_{60000,30}(\mathbb R)$ 에 대해

$$

\mathbf X_2 = h(\mathbf X_1 \mathbf W_1+\mathbf b_1)\tag{1}

$$

를 만족하는 $784\times 30$ 가중치행렬 $\mathbf W_1$과 편향행렬 $\mathbf b_1\in\mathbf M_{60000,1}(\mathbb R)$이 주어지고, 초기값은 각각 표준정규분포로부터의 random matrix와 영행렬($0$)로 주어진다. 여기서 함수 $h$는 활성함수를 의미한다. 만일 한 개의 데이터가 처리되는 신경망을 표현하고 싶다면, 각 데이터행렬 대신 행벡터를 사용하면 될 것이다.

#### Forward & Backward Pass

```python
def forward(self, x):
    X_tf = tf.cast(x, dtype=tf.float32)
    Z1 = tf.matmul(X_tf, self.W1) + self.b1
    Z1 = tf.nn.relu(Z1)
    Z2 = tf.matmul(Z1, self.W2) + self.b2
    Z2 = tf.nn.relu(Z2)
    Z3 = tf.matmul(Z2, self.W3) + self.b3
    Y = tf.nn.sigmoid(Z3)
    return Z3
```

이제 위와 같이 Forward pass를 처리하는 함수 `forward`를 정의할 수 있다. 이때 코드를 보면 알 수 있듯이, 각각의 Z들은 각 레이어에서 처리된 데이터를 의미하며, 행렬곱 `tf.matmul`이 사용되어 위의 식 (1)처럼 계산된다. 또한, 위 코드의 경우 두 hidden layer에서는 활성함수로 ReLU를, 마지막 출력층에서는 시그모이드 함수를 사용했다. 여기서 함수의 출력값으로 세번째 출력값을 사용하는 이유는, 손실함수에서 sigmoid를 구현하도록 할 것이기 때문이다!

다음으로, backward pass와 역전파를 통한 학습을 정의하기 위해 우선 손실함수를 계산하는 코드를 다음과 같이 작성해야 한다.

```python
def loss(self, y_true, logits):
    y_true_tf = tf.cast(tf.reshape(y_true, (-1,1)), dtype = tf.float32)
    logits_tf = tf.cast(tf.reshape(logits, (-1,1)), dtype = tf.float32)
    return tf.nn.sigmoid_cross_entropy_with_logits(y_true_tf,logits_tf)
```

여기서 `tf.reshape`는 추정하는 라벨 데이터(y)의 형태를 변환하는데, 앞서 정의한 신경망에서 모든 텐서는 $N\times\text{특성 수}$ 형태로 정의되므로 출력값 Y 텐서가 한 개의 열만 가지도록 설정하는 것이다(*행 성분이 -1인 것은 열을 1개로 설정하고 나머지는 알아서 원래크기를 보존하도록 함을 의미한다*). 또한 여기서 손실함수를 sigmoid entropy 함수를 구현하는 `tf.nn.sigmoid_cross_entropy_with_logits`로 설정했다. 이를 바탕으로, 다음과 같이 역전파 함수도 구현할 수 있다.

```python
def backward(self, x, y):
    optimizer = tf.keras.optimizers.SGD(learning_rate=0.01)
    with tf.GradientTape() as tape:
        predicted = self.forward(x)
        current_loss = self.loss(y, predicted)
    grads = tape.gradient(current_loss, self.params)
    optimizer.apply_gradients(zip(grads, self.params))
```

여기서 `tf.GradientTape`는 Forward pass 과정(`self.forward`)의 모든 연산의 순서와 결과를 저장하고, 이를 바탕으로 Backward pass 과정(`self.backward`)에서 역순으로 연산을 수행하며 각 노드의 그래디언트를 계산하게끔 해주는 모듈이다([Tensorflow 문서](https://www.tensorflow.org/guide/autodiff?hl=ko) 참조).  위 모델에서 Optimization은 가장 기본적인 SGD([Tensorflow 공식 문서](https://www.tensorflow.org/api_docs/python/tf/compat/v1/train/Optimizer))를 활용하도록 했으며, 학습률(eta)는 0.01로 설정한 것을 확인할 수 있다. 이를 바탕으로 `tape.gradient`에서 그래디언트를 계산할 수 있으며, 이를 바탕으로 `optimizer.apply_gradients`를 통해 계산한 그래디언트로 경사하강이 이루어진다. 사실 이렇게 정의된 `backward` 함수는 모델 학습 함수인 `model.fit()`과 동일하게 작동한다.

이렇게 구현한 모든 함수들을 `Network` 클래스로 함께 묶어주면 된다*(최종코드 참고)*.

### Model Fitting

먼저 모델을 적합시키기 위한 기본 작업을 진행해보도록 하자. 앞서 `Network` 클래스를 실행시키기 위해서는 레이어별 노드 개수인 `n_layers`가 필요했고, 이에 맞추어 손실함수 등을 계산하기 위해 데이터 역시 변환해야 한다.

```python
n_layers = [784, 100, 30, 10]
epochs = 5
X_train = tf.reshape(X_train,[60000,784])
y_one_hot = tf.one_hot(y_train, depth = 10)

net = Network(n_layers)
```

첫번째 hidden layer는 100개의 노드를, 두번째는 30개의 노드를 갖도록 설정했다. 또한, 기존의 Input data는 $28\times 28$ 픽셀 이미지이므로 이를 벡터로 처리하기 위해 784열을 갖는 data matrix로 `tf.reshape`를 이용해 변환하였다. 레이블인 `y_train`는 한 데이터당 0부터 10까지의 숫자를 갖는 스칼라로 구성되는데, 우리가 필요한 것은 한 레이블당 계산되는 스코어(확률) 이므로 10개의 열을 갖는 벡터로 변환하여아 한다. 이를 원-핫 인코딩<sup>one-hot encoding</sup>이라고 한다. 이렇게 처리한 데이터를 바탕으로 네트워크를 구성하면 준비는 마쳤다.

모델의 성능을 평가하기 위해 어떤 성능지표를 사용해야할 지 정해야 하는데, 여기서는 분류에서 가장 단순하게 사용되는 precision<sup>정밀도</sup>를 사용해보도록 하자. 참고로 한 클래스에 대한 정밀도는 $TP\over{TP+FP}$ 로 계산되며, TP<sup>True positive</sup>는 해당 클래스를 정확히 예측한 데이터 수를, FP<sup>False positive</sup>는 해당 클래스가 아님에도 그 클래스로 예측해버린 데이터 수를 의미한다. 정밀도를 비롯해 재현율<sup>recall</sup>, f1 score 등은 모두 scikit-learn 패키지에서 찾을 수 있다.

```python
from sklearn.metrics import precision_score, f1_score
for epoch in range(epochs):
    net.backward(X_reshape,y_one_hot)
    acc =f1_score(y_true = tf.math.argmax(y_one_hot,1), y_pred = tf.math.argmax(net.forward(X_reshape),1),average='micro')
    if epoch % 10 == 0:
        print('accuracy score : {score}'.format(score = acc * 100))
```

이를 바탕으로 위 코드처럼 정해진 `epoch`만큼 forward-backward pass를 진행시켜 모델을 다음과 같이 학습하게 할 수 있다(성능은 매우 구리다😅 단순한 딥러닝 모델을 직접 구현해보는데 의의가 있다!).

전체 코드 : [https://github.com/ddangchani/braverep/blob/main/Supplyments/simplenn.ipynb](https://github.com/ddangchani/braverep/blob/main/Supplyments/simplenn.ipynb)

# References

- https://medium.com/analytics-vidhya/how-to-write-a-neural-network-in-tensorflow-from-scratch-without-using-keras-e056bb143d78
- 핸즈온 머신러닝 2e
{% endraw %}