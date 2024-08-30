---
title: "0709 KISS Summer school DL Lecture"
tags:
- Deep Learning
- Machine Learning
category: Deep Learning
use_math: true
---
{% raw %}

# Introduction to DL

Traditional Linear Model > suffers at specific tasks(ex. MNIST)
	- Why : Designed to use at low-dimensional data
	- At higher dimension(ex. Image, Video data) : curse of dimensionality occurs
	- How about Principal component?
		: First PC finds overall mean usually(cannot capture small-scale feature)
How to overcome > Use Basis function $f:R^{p}\to R^{d}$ (kernel function)

## Neural Network
### 1-layer Neural Network

$$

\begin{aligned}
H^{(1)} &= g^{(1)}(W^{(1)}x + w_{0}^{(1)})\\
\Lambda&= g^{(\lambda)}(W^{(\lambda)}H^{(1)}+w_{0}^{(\lambda)})\\
Y &\sim p(y,\lambda) 
\end{aligned}

$$

Output layer $g^{(\lambda)}$ is determined as dist of $Y$

> Neural Network is equivalent to GLM with **Data-Driven** Basis function
> PCA is also data driven but it is (1) linear (2) do not consider Y.

- $g$ is nonlinear (Ex. ReLU : piecewise linear)

### Deep Neural Network : Multilayer Neural Network

- General Approximation Theory
- Model Fitting : MLE
let $W$ vector contains every weight matrices, $(x_{1},y_{1}),\ldots,(x_{n}, y_{n})$ training data.

Then, cost function of $Y\sim N(\Lambda,\sigma^{2})$

$$

C(W)=-l(W)\propto \frac{1}{n}\sum_{i=1}^{n}(y_{i}-\Lambda(x_{i}:W))^{2}

$$

If $Y\sim \text{Multi}(\Lambda)$ , the negative loglik becomes

$$

C(W) \propto \sum_{i}\sum_{k}y_{k}\log p_{k}(x_{i}:W)

$$

### How to optimize?
- At neural net : Newton-Raphson impossible(impossible to calculate Hessian)
- Backpropagation : easy to calculate Gradient and also easy to code

#### Gradient Descent
- Adam, AdaGrad, RMSprop
- Neural Net depends on Gradient i.e. the activation function should have good property
- Gradient Saturation Problem
  - At Sigmoid, Hyperbolic tangent activation function 
: the product of partial derivatives conv to 0
  - Solution
: Rectified Linear Unit(ReLU)


### What kind of Hidden Layer then?

> Image, Video : CNN
> Text : LSTM, Transformer
> Density estimation : Normalizing Flow

# Lecture 2

## Overfitting Problem

Neural Net has high flexibility, but easy to suffer overfitting problem.
Solutions : 
	- Shrinkage penalty
	- Dropout
	- Batch training
	- Early Stopping

### Penalization
L1, L2 Regularization(Ridge, Lasso) : add a regularization term to negative loss
ex) L1 Term at Categorical response

$$

-l(W) \propto -\sum_{i}\sum_{k}y_{ik}\log p_{k}(x_{i}:W)+\lambda\Vert W\Vert^{2}

$$

: work as Shrinkage estimator

### Dropout
- Slap and spike
- add a Bernoulli random variable to every layer

### Batch Training
Split the whole training data into $B$ batches, and do the gradient descent at every batch
- epoch : One cycle over all batches
- Batch : Sampling idea >> for statisticians?

#### Stochastic Gradient Descent(SGD)
Due to dropout and batch training, likelihood and cost function changes at every training with randomness

#### Data Split
- Training data : Used to calculate gradient
- Validation data : Not used to calculate gradient, instead used to calculate cost function and determine if overfitting occur or not

### Early Stopping
- If validation cost doesn't improve during specific number of epochs(patience), stop training

## Algorithm Summary
- Initialize : Generate $W_{0}$ from probability distribution(prior)

### Validation Method for Binary Y
- Classification rule to 0 or 1
- From Model : We acquire $P(Y=1\vert X)$ 
- How to determine prediction of Y as 0 or 1? 
- By : Threshold setting
	: Large Threshold  - both TPR, FPR lower
> We should not make threshold constant, instead observe change of ROC curve as threshold changes

- **ROC Curve** is important : AUC-ROC

### For Continuous Y
- MSE alone cannot explain the full result
- **Draw scatter plot at test data**

# Lecture 3. CNN and Transformers

## Convolutional Neural Network
- If Input data $X$ is spatial data
- Feedforward DNN : Input > Feature Extraction Layer > Fully connected(Dense) Layer > Output

### Convolution
: Taking local weighted averages to create a summary image
> Preserve spatial properties with much less parameters

### Pooling
: Downsampling for translational invariance(?)
Traditional kernel (ex. Gaussian) : Smoothing i.e. maybe not useful for image classification or etc.

### Channel and Filter
Input Channels : ex. RGB image > 3 channel for layer
Filter's Kernel values > Also estimated during training process
- N output Channel produces N output image for convolutional layer

### Stride, Filter(kernel size), Padding
- Stride : Step size for each slide
- Filter or kernel size : width and height of kernel
- Padding : Additional rows and columns to adjust the resulting images

## Transformer

- Setting
$\mathbf{x} = [x_{1},\ldots,x_{T}]$ : T is number of words in the text $\mathrm{x}$
- Embedding : Transform each word into vector
- At deep learning : Get Embedded vector as parameter in DL model, with just SGD

- Text data analysis is just a special case of time series analysis.

### Self-Attention Layer
- $x_{t}$ is d-dimensional vector at $t$ word
- Linear transformation for $x_t$ :  

$$

V_{t}=W_{v}x_{t}+w_{v}

$$

- Self-attention:

$$

sa(x_{t}) = \sum_{u=1}^T a(x_{u},x_{t})V_{u}

$$

where $a(X_{t},X_{u})>0, \sum_{u}a(x_{u},x_{t})=1$ is an attention which $t$-word gives to $X_{u}$.

- Calculating $a(X_{u},X_{t})$
> query $Q_{t} = W_{q}x_{t}+ w_{q}$
> Key $K_{t}=W_{k}x_{t}+w_{k}$
> Then, we calculate as follows:

$$

a(x_{u},x_{t}) = \mathrm{softmax}(K_{u}^{T}Q_{t})

$$

### Position Encoding
: The locational information of words are not contained at $x_{t}$.
- Make Absolute position embedding(embedding matrix w.r.t. order of words)
- Relative position embedding

### Multi-head Self Attention
Define various number of self attention for $h=1,\cdots,H$ 
> able to extract various kind of relationship of text

### Transformer Layer
- Residual multi-head attention > Layer Normalization > Residual Dense Layers > Layer Normalization

{% endraw %}