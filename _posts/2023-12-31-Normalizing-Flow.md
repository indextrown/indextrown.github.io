---
title: Normalizing Flow
tags: 
- Deep Learning
- Machine Learning
category: ""
use_math: true
---
# Normalizing flow

변분추론<sup>Variational Inference</sup>에서 사후분포를 근사하는 것은 가장 중요한 문제 중 하나이다. 일반적으로 사후분포를 근사할 때 정규분포 등 다루기 쉬운 분포를 surrogate distribution으로 사용하여 근사를 진행하는데, 이러한 과정의 문제점은 사후분포의 클래스가 제한된다는 점이다. 이러한 문제를 해결하기 위해 제안된 것이 Normalizing flow 인데, 이를 통해 사후분포 클래스의 유연성을 증가시킬 수 있다.

## 정의

Normalizing flow는 한마디로 요약하자면, sequential transformation of random variable이라고 할 수 있을 것이다. 통계학에서 변수변환을 이용하여 새로운 변수에 대한 확률밀도함수를 계산해내는데, 이러한 아이디어를 이용하여 invertible, smooth mapping $f:\mathbb{R}^{d}\to \mathbb{R}^{d}$의 시퀀스로 flow를 정의한다. 확률밀도함수 $q$를 가지는 확률변수 $Z$에 대해 어떠한 변환 $Z'=f(Z)$을 적용한다면, 변수변환 공식으로부터 아래와 같이 새로운 확률변수에 대한 확률밀도함수를 계산할 수 있다.


$$

q(z')= q(z)\bigg\vert\det\frac{\partial f}{\partial z}\bigg\vert^{-1}


$$

이러한 변환을 여러개 연결한다면, 아래와 같이 복잡한 분포를 간단하게 만들어낼 수 있다.


$$

\begin{align}
Z_{K}&= f_{K}\circ\cdots\circ f_{2}\circ f_{1}(Z_{0})\\
\log q_{K}(z_{K}) &= \log q_{0}(z_{0})-\sum_{k=1}^{K} \log\bigg\vert\det\frac{\partial f_{k}}{\partial z_{k-1}}\bigg\vert
\end{align}


$$

이러한 형태로 정의되는 연속적인 변수변환을 **normalizing flow**라고 한다. 다음은 몇 가지 normalizing flow들의 예시이다.

## Affine Flow

Affine flow, 혹은 linear flow라고 부르는 flow는 가장 간단한 형태의 normalizing flow이다. 다음과 같은 형태를 가진 변수변환의 모임을 생각하자.


$$

f(Z) =Z + uh(w^{T}Z+b)


$$

여기서 $\lambda=\{w\in \mathbb{R}^{d}, u\in \mathbb{R}^{d}, b\in \mathbb{R}\}$은 free parameter들이며, 이러한 모수들은 모델의 학습 과정에서 모델의 파라미터들과 마찬가지로 학습된다. 위와 같이 정의되는 linear transformation의 경우, 아래와 같이 자코비안의 계산이 가능하며 이는 $O(d)$ 시간에 계산가능하다.


$$

\begin{align}
\bigg\vert\det\frac{\partial f}{\partial Z}\bigg\vert &=  \bigg\vert \det (\mathbf{I}+u\psi(Z)^{T})\bigg\vert = \vert 1+ u^{T}\psi(Z)\vert.\\
\psi(Z) &= h'(w^{T}Z+b)w
\end{align}


$$

## Inverse Autoregressive Flow

Inverse autoregressive flow<sup>IAF</sup>는 간단한 형태의 가우시안 분포(ex. diagonal covariance matrix)를 복잡한 형태의 가우시안 분포(full covariance matrix)로 변환하는 flow의 일종이다. Flow layer의 초기값은 다음과 같이 reparametrization trick 형태로 제공되며,


$$

Z_{0}=\mu_{0}+\sigma_{0}\odot\epsilon,\quad \epsilon\sim N(0,\mathbf{I})


$$

$T$개의 flow layer들은 각각 다음과 같은 간단한 변수변환으로 이루어진다.


$$

Z_{t} = \mu_{t}+\sigma_{t}\odot Z_{t-1}


$$

이때, flow layer에서 계산되는 자코비안 $\frac{d\mu_{t}}{dZ_{t-1}}, \frac{d\sigma_{t}}{dZ_{t-1}}$ 들은 모두 삼각행렬을 구성하고 대각성분이 0이 된다. 따라서, 이로부터 자코비안 $\frac{dZ_{t}}{dZ_{t-1}}$은 대각성분이 $\sigma_{t}$인 삼각행렬이 되므로, 행렬식은 $\prod_{i=1}^{d}\sigma_{t,i}$가 된다. 이로부터 사후분포의 근사는 다음과 같이 이루어진다.

$$

\log q(z_{T}\vert x)=-\sum_{i=1}^{d}\bigg( \frac{1}{2}\epsilon_{i}^{2} + \frac{1}{2}\log 2\pi  + \sum_{t=0}^{T}\log\sigma_{t,i}\bigg)


$$

이러한 형태로부터 IAF는 full covariance matrix를 갖는 정규분포를 근사해낼 수 있으며, 이를 VAE에 이용하게 될 경우 잠재변수의 사전분포를 인코더의 간단한 output $\mu_{e},\sigma_{e}$ 로부터 근사해낼 수 있게 된다.

### Example Code

간단한 형태의 IAF layer는 다음과 같이 구성할 수 있다. IAF의 특징은 인코더 네트워크로부터 또 다른 output을 받는다는 것인데, 이러한 output $L$과 reparametrization trick으로 얻게 되는 $Z$로부터 다음과 같은 간단한 형태의 Linear IAF를 도출할 수 있다.

```python
class FlowLayer(nn.Module):
    """
    Linear Inverse Autoregressive Flow Layer
    """
    def __init__(self, args):
        super(FlowLayer, self).__init__()
        self.args = args
    
    def forward(self, L, z):
        """
        :param L: batch_size (B) x latent_size^2 (L^2) from encoder output
        :param z: batch_size (B) x latent_size (L) from encoder output z0
        :return: z_new = L * z
        """
        # transform L to lower triangular matrix
        L_matrix = L.view(-1, self.args.z_size, self.args.z_size) # resize to get B x L x L
        LTmask = torch.tril(torch.ones(self.args.z_size, self.args.z_size), diagonal=-1) # lower-triangular mask matrix
	I = Variable(torch.eye(self.args.z_size, self.args.z_size).expand(L_matrix.size(0), self.args.z_size, self.args.z_size))
        LTmask = Variable(LTmask)
        LTmask = LTmask.unsqueeze(0).expand(L_matrix.size(0), self.args.z_size, self.args.z_size)
        LT = torch.mul(L_matrix, LTmask) + I # Lower triangular batches
        z_new = torch.bmm(LT, z) # B x L x L * B x L x 1 = B x L x 1

        return z_new, LT

```


# References

Kingma, D. P., Salimans, T., Jozefowicz, R., Chen, X., Sutskever, I., & Welling, M. (2016). Improved Variational Inference with Inverse Autoregressive Flow. _Advances in Neural Information Processing Systems_, _29_. [https://proceedings.neurips.cc/paper_files/paper/2016/hash/ddeebdeefdb7e7e7a697e1c3e3d8ef54-Abstract.html](https://proceedings.neurips.cc/paper_files/paper/2016/hash/ddeebdeefdb7e7e7a697e1c3e3d8ef54-Abstract.html)

Rezende, D., & Mohamed, S. (2015). Variational Inference with Normalizing Flows. _Proceedings of the 32nd International Conference on Machine Learning_, 1530–1538. [https://proceedings.mlr.press/v37/rezende15.html](https://proceedings.mlr.press/v37/rezende15.html)

Tomczak, J. M., & Welling, M. (2017). _Improving Variational Auto-Encoders using convex combination linear Inverse Autoregressive Flow_ (arXiv:1706.02326). arXiv. [http://arxiv.org/abs/1706.02326](http://arxiv.org/abs/1706.02326)