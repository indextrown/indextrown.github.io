---
title: "[Paper Review] Differentially Private Markov Random Field"
tags: 
- Differential Privacy
- PGM
- Spatial Statistics
- Paper Review
category: ""
use_math: true
---

## Introduction

### Markov random field
Let $G=(V,E)$ be a graph with $p$ nodes and $C_{t}(G)$ be the set of cliques of size at most $t$ in $G$. A **Markov random field** with alphabet size $k$ and $t$-order interactions is a distribution $\mathcal{D}$ over $[k]^{p}$ such that 

$$

p(\mathbf{x}) \propto \exp \left(\sum_{c\in C_{t}(G)}\psi_{c}(\mathbf{x}_{c})\right). \tag{1}


$$

where $\mathbf{x}_{c}$ is the subset of $\mathbf{x}$ that belongs to clique $c$. The equation $(1)$ is also known as **Hammersley-Clifford** theorem.

- $t=2$ : MRF is **pairwise**.
- $k=2$ : **binary** MRF
- $k=t=2$ : **Ising** model (binary and pairwise)

It is easy to think that for pairwise MRF, $$\psi_{c}(\mathbf{x}_{c})$$ is given as $$w_{i}x_{i}x_{j}$$ for $$\mathbf{x}_{c}=\{x_{i},x_{j}\}$$ since the maximal clique size is $2$.

### Learning problem

1. Structure learning : Recover the set of non-zero edges in $G$ (learning adjacency).
2. Parameter learning : Learn the structure and $\psi_{I}$ for all cliques $I$ of size at most $t$.

## Preliminaries

### Markov random field
#### Ising model

The $p$-variable **Ising** model is a distribution $\mathcal{D}(A,\theta)$ on $\{-1,1\}^{p}$ that satisfies


$$

p(\mathbf{x}) \propto \exp \left(\sum_{1\leq i\leq j\leq p}A_{i,j}x_{i}x_{j}+\sum_{i\in [p]}\theta_{i}x_{i}\right),


$$

where $A$ is symmetric weight matrix with $A_{ii}=0$ for $i=1,\ldots,p$ and $\theta\in \mathbb{R}^{p}$ is a mean-field vector. The corresponding graph is MRF $G=(V,E)$.

The **width** of $\mathcal{D}(A,\theta)$ is defined as 


$$

\lambda(A,\theta) = \max_{i\in[p]} \left(\sum_{j\in[p]} \vert A_{i,j}\vert +\vert \theta_{i}\vert \right)


$$

The **minimum edge weight** is defined as


$$

\eta(A,\theta) = \min_{i,j\in[p], A_{i,j}\ne 0}|A_{i,j}|


$$

#### Pairwise graphical model

For a set of weight matrices $\mathcal{W}$, the $p$-variable **pairwise** graphical model is a distribution $\mathcal{D}(\mathcal{W},\theta)$ on $[k]^{p}$ that satisfies


$$

p(\mathbf{x})\propto \exp \left(\sum_{1\le i\le j\le p}W_{i,j}(x_{i},x_{j})+\sum_{i\in[p]}\theta_{i}(x_{i})\right),


$$

and $\Theta=\{\theta_{i}\in \mathbb{R}^{k}:i\in[p]\}$ is a set of mean-field vectors. The width and minimum edge weight are defined as below.


$$

\begin{align}
\lambda(\mathcal{W},\theta) &= \max_{i\in[p],a\in[k]}\left(\sum_{j\in[p]\backslash i}\max_{b\in[k]}\vert W_{i,j}(a,b)\vert + \vert\theta_{i}(a)\vert \right)\\
\eta(\mathcal{W},\Theta) &= \min_{(i,j)\in E} \max_{a,b}\vert W_{i,j}(a,b)\vert
\end{align}


$$

#### Parameter learning

Given samples $X_{1},\ldots,X_{n}\sim \mathcal{D}$, the parameter learning algorithm outputs a matrix $\hat A$ such that


$$

\max_{i,j\in[p]}\vert A_{i,j}-\hat A_{i,j}\vert\leq \alpha.


$$

### Privacy

#### Concentrated Differential Privacy(zCDP)

A randomized algorithm $\mathcal{A}:\mathcal{X}^{n}\to\mathcal{S}$ satisfies $\rho$-zCDP if for every neighboring datasets $X,X'\in\mathcal{X}^{n}$,


$$

\forall \alpha\in (1,\infty)\quad D_{\alpha}\left(M(X)\Vert M(X')\right) \leq \rho\alpha


$$

where $D_{\alpha}$ is the $\alpha$-Rényi divergence.

The **Rényi divergence** of order $\alpha$ (or called $\alpha$-divergence) is defined as below.


$$

D_\alpha(P\Vert Q) = \frac{1}{\alpha-1}\log \left(\sum_{i=1}^{n} \frac{p_{i}^{\alpha}}{q_{i}^{\alpha-1}}\right)


$$

where $P,Q$ are discrete probability distribution with $p_{i}=\Pr(X=x_{i}), X\sim P$.

#### (Bun & Steinke, 2016)
1. If $\mathcal{A}$ satisfies $\epsilon$-DP, then $\mathcal{A}$ is $\dfrac{\epsilon^{2}}{2}$-zCDP.
2. If $\mathcal{A}$ satisfies $\dfrac{\epsilon^{2}}{2}$-zCDP, then $\mathcal{A}$ satisfies $\left(\dfrac{\epsilon^{2}}{2}+\epsilon\sqrt{2\log(\dfrac{1}{\delta}}),\delta\right)$-DP for every $\delta>0$.

#### (Dwork et al., 2010)

For a sequence of DP algorithms $$\mathcal{A}_{1},\cdots,\mathcal{A}_{T}$$ and $$\mathcal{A}=\mathcal{A}_{T}\circ\cdots\circ \mathcal{A}_{1}$$, the following hold.

1.  If $$\mathcal{A}_{1},\cdots,\mathcal{A}_{T}$$ are $$(\epsilon_{0},\delta_{1}),\cdots,(\epsilon_{0},\delta_{T})$$-DP respectively, then for every $\delta_{0}>0$, $\mathcal{A}$ is $(\epsilon,\delta)$-DP for $$\epsilon=\epsilon_{0}\sqrt{6T\log(\frac{1}{\delta_{0}})}$$ and $$\delta=\delta_{0}+\sum_{t}\delta_{t}$$.
2. If $$\mathcal{A}_{1},\cdots,\mathcal{A}_{T}$$ are $$\rho_{1},\cdots,\rho_{T}-z$$CDP respectively, then $\mathcal{A}$ is $\rho$-zCDP for $$\rho=\sum_{t}\rho_{t}$$.

## Parameter Learning of Pairwise MRF

### Private sparse logistic regression

Consider training data $D=\{d^{1},\ldots d^{n}\}\overset{iid}{\sim} P$ where $d^{i}=(x^{i},y^{i}), \Vert x^{i}\Vert_{\infty}\leq 1, y^{i}\in\{-1,1\}$. To minimize population logistic loss $\mathrm{E}\left[\log(1+e^{-Y\langle w,X\rangle}\right]$, consider the following empirical risk minimization.


$$

w = \arg\min_{w} \mathcal{L}(w:D) = \frac{1}{n}\sum_{j}\log \left(1+e^{-y^{j}\langle w,x^{j}\rangle}\right)


$$

Then, the following algorithm satisfies $\rho-z$CDP. At spatial statistics this model is so-called as **auto-logistic model**.

#### Algorithm


$$

\begin{align}
&\textbf{Algorithm } \text{Private Frank-Wolfe algorithm}\\
&\textbf{Input: } \text{D}, \mathcal{L}, \text{convex set }\mathcal{C}=\{w\in \mathbb{R}^{p}:\Vert w\Vert_{1}\le \lambda\}\\
&\textbf{For } t=1 \text{ to } T-1 \textbf{ do:}\\
&\quad \forall s\in S, \alpha_{s} \leftarrow \langle s,\nabla \mathcal{L}(w;D)\rangle+\text{Laplace}\left(0, \dfrac{L_{1}\Vert C\Vert_{1}\sqrt{T}}{n\sqrt{\rho}}\right)\\
&\quad \tilde w_{t}\leftarrow \arg\min_{s\in S}\alpha_{s}\\
&\quad w_{t+1}=(1-\mu_{t})w_{t}+ \mu_{t}\tilde w_{t}\quad \text{where } \mu_{t}=\frac{2}{t+2}\\
&\textbf{end for}\\
&\textbf{Output: } w^{priv} = w_{T}
\end{align}


$$

#### Theorem
For $w^{priv}$ from algorithm above, with probability at least $1-\beta$ the following holds.


$$

\mathrm{E}\left[l(w^{priv};(X,Y))\right]-\min_{w\in C}\mathrm{E}\left[l(w;(X,Y))\right] \le O \left( \frac{\lambda^{\frac{4}{3}}\log\left(\frac{np}{\beta}\right)}{(n\sqrt{\rho})^{\frac{2}{3}}} + \frac{\lambda\log(\frac{1}{\beta})}{\sqrt{n}} \right)


$$

### Privately Learning Ising Models

#### Lemma (Klivans & Meka, 2017)

Let $Z\sim \mathcal{D}(A,\theta)$ and $Z\in\{-1,1\}^{p}$, then for all $i\in[p]$,


$$

\Pr(Z_{i}=1\vert Z_{-i}=x) = \sigma \left(\sum_{j\ne i}2A_{i,j}x_{j}+2\theta_{i}\right) =: \sigma(\langle w,x'\rangle)


$$

From this lemma, it is possible to estimate the weight matrix by solving logistic regression for each node. 

#### Algorithm


$$

\begin{align}
&\textbf{Algorithm } \text{Privately Learning Ising Models}\\
&\textbf{Input: } \{z^{1},\cdots,z^{n}\},\text{ upper bound on }\lambda(A,\theta)\le \lambda,\text{ privacy parameter }\rho\\
&\textbf{For } \text{$i=1$ to $p$} \textbf{ do:}\\
&\quad \forall m\in[n],x^{m}=(z_{-i}^{m},1), y^{m}=z_{i}^{m}\\
&\quad w^{priv}\leftarrow \mathcal{A}_{PFW}(D,\mathcal{L},\rho',\mathcal{C}),\quad \rho'=\frac{\rho}{p}\\
&\quad \forall j\in p, \hat A_{i,j}=\frac{1}{2}w_{\tilde j}^{priv}\;\text{where } \tilde j=j - \mathbf{1}_{(j>i)}\\
&\textbf{end for}\\
&\textbf{Output: } \hat A \in \mathbb{R}^{p\times p}
\end{align}


$$

It can be proved that the algorithm above satisfies $\rho$-zCDP.

### Privately Learning general pairwise model

Given $n$ i.i.d samples $\{z^{1},\cdots,z^{n}\}$ drawn from unknown $\mathcal{D}(\mathcal{W},\Theta)$, the purpose is to design $\rho$-zCDP estimator $\hat{\mathcal{W}}$ such that w.p. at least $\frac{2}{3}$,


$$

	\left\vert W_{i,j}(u,v)-\hat W_{i,j}(u,v)\right\vert\leq \alpha


$$

for $i\ne j\in[p]$ and $\forall u,v \in[k]$.

#### Lemma 
Like the Ising model, a pairwise MRF $Z\sim \mathcal{D}(\mathcal{W},\Theta)$ shows the following property.


$$

\Pr(Z_{i}=u\vert Z_{i}\in\{u,v\},Z_{-i}=x) =
\sigma \left(\sum_{j\neq i} \left(W_{i,j}(u,x_{j})-W_{i,j}(v,x_{j})\right)+\theta_{i}(u)-\theta_{i}(v)\right)


$$

for any $i\in[p]$ and $u\neq v\in[k]$.


The implementation algorithm is based on the private FW algorithm, and it satisfies $\rho$-zCDP.

### Structure Learning of Graphical Models

#### Theorem (Wu et al., 2019)
There exists an algorithm that learns the structure of a pairwise graphical model w.p. at least $\frac{2}{3}$. It requires $n=O \left(\dfrac{\lambda^{2}k^{4}e^{14\lambda}\log(pk)}{\eta^{4}}\right)$ samples.

From the theorem above, for $(\epsilon-\delta)$-DP structure learning algorithm the sample size is given as follows.


$$

n = O \left(\dfrac{\lambda^{2}k^{4}\log(pk)\log(\frac{1}{\delta})}{\epsilon\eta^{4}}\right)


$$

### Lower Bounds

#### Theorem
Any $\epsilon$-DP structure learning algorithm of an Ising model with minimum edge weight $\eta$ requires


$$

n = \Omega \left(\frac{\sqrt{p}}{\eta \epsilon}+ \frac{p}{\epsilon}\right)


$$

samples. Also, for $\rho$-zCDP algorithm $n=\Omega \left(\sqrt{\dfrac{p}{\rho}}\right)$ samples are required.

For $p$-variable pairwise MRF, $\epsilon$-DP algorithm requires $n=\Omega \left(\dfrac{\sqrt{p}}{\eta\epsilon}+ \dfrac{k^{2}p}{\epsilon}\right)$ samples and $\rho$-zCDP algorithm requires $n=\Omega \left(\sqrt{\dfrac{k^{2}p}{\rho}}\right)$ samples.


# References

- C. Dwork, G. N. Rothblum, and S. Vadhan, “Boosting and Differential Privacy,” in _2010 IEEE 51st Annual Symposium on Foundations of Computer Science_, Las Vegas, NV, USA: IEEE, Oct. 2010, pp. 51–60. doi: [10.1109/FOCS.2010.12](https://doi.org/10.1109/FOCS.2010.12).
- H. Zhang, G. Kamath, J. Kulkarni, and S. Wu, “Privately learning Markov random fields,” in _International conference on machine learning_, PMLR, 2020, pp. 11129–11140. Accessed: Jan. 17, 2024. [Online]. Available: [http://proceedings.mlr.press/v119/zhang20l.html](http://proceedings.mlr.press/v119/zhang20l.html)
- S. Wu, S. Sanghavi, and A. G. Dimakis, “Sparse Logistic Regression Learns All Discrete Pairwise Graphical Models.” arXiv, Jun. 18, 2019. doi: [10.48550/arXiv.1810.11905](https://doi.org/10.48550/arXiv.1810.11905).