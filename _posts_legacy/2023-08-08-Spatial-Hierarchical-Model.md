---
title: Hierarchical modeling for spatial data
tags:
- Spatial Statistics
- Bayesian
- Hierarchical Modeling
category: ''
use_math: true
---
{% raw %}

The contents are mainly based on *"Handbook of Spatial Statistics"*(2010) textbook. In this
chapter, we introduce some basic concept related to hierarchical modeling strategies for handling and modeling spatial data.

# Hierarchical Modeling

## An overview for hierarchical modeling

Statistical modeling often becomes simpler by modeling a series of conditional models. Suppose there are random variables $A,B,C$. Then, we can write the joint distribution in terms of *factorizations*, for example, 

$$
p(A,B,C)=p(A\vert B,C)p(B\vert C)p(C).
$$

We can broaden this process in the statistical modeling situation in the presence of data, as follows:

1.  Data Model: $[\textrm{data\vert process, parameters}]$

2.  Process Model: $[\textrm{process\vert parameters}]$

3.  Parameter model: $[\textrm{parameters}]$ - for Bayesian Hierarchical modeling

With each stage, update the posterior distribution of the process and parameters using the data.

### Data model

-   Let $Y$ be the data observed for a spatial process $\eta$
-   Let $\theta_Y$ be the parameters for $Y$. Note that $Y\neq\eta$ due to measurement errors

Then, the data model distribution can be written as $[Y\vert\eta,\theta_Y]$. Usually, this conditional distribution is much simpler than the unconditional, since the most of the complicated dependence structure
comes from the process $\eta$. Also, it is possible to decompose the data model into two parts(\*), for example in the case with missing values or predictive values. 

$$
\begin{align}\\
&Y=(Y_a,Y_b), \theta_Y=(\theta_{Y_a},\theta_{Y_b}) \\
&[Y\vert\eta,\theta_Y]=[Y_a\vert\eta,\theta_{Y_a}][Y_b\vert\eta,\theta_{Y_b}]\tag{*}
\end{align}
$$

### Process model and Parameter model

Likewise, process model and parameter model can be written and decomposed as follows: 

$$\begin{aligned}
    &\textrm{Process model: } [\eta\vert\theta_\eta]=[\eta_a\vert\eta_b,\theta_\eta][\eta_b\vert\theta_\eta] \\
    &\textrm{Parameter model: } [\theta_{Y_a},\theta_{Y_b},\eta_{\eta_a},\eta_{\eta_b}]=[\theta_{Y_a}][\theta_{Y_b}][\eta_{\eta_a}][\eta_{\eta_b}]
\end{aligned}$$

## Hierarchical Gaussian geostatical model

### Definition

Suppose there are $m$ observations $\mathbf{Y}=(Y(\bar s_1),\cdots,Y(\bar s_m))^T$. Define a latent spatial vector $\mathbf{\eta}=(\eta(s_1),\cdots,\eta(s_n))^T$ where $\eta(s)$ is a Gaussian Process. Then the hierarchical model is given as follows.

-   Data model: $\mathbf{Y}\vert\beta,\mathbf{\eta},\sigma_\epsilon^2\sim GP(\mathbf X\beta+\mathbf{H\eta},\sigma_\epsilon^2 I)$
-   Process model: $\mathbf{\eta\vert\theta}\sim GP(0,\Sigma(\theta))$
-   Parameter model: $[\beta,\sigma_\epsilon^2,\theta]$
-   Note that $\{\bar s_1,\cdots,\bar s_m\}$ may not coincide with $\{s_1,\cdots,s_n\}$
-   If observation locations coincide with process locations, then $\mathbf{H}=I$

By Bayes' rule, the posterior can be estimated as

$$\propto[\mathbf Y\vert\mathbf \eta,\beta,\sigma_\epsilon^2][\mathbf\eta\vert\theta][\beta\sigma_\epsilon^2,\theta].$$

The normalizing constant in this case cannot be obtained in closed form. Instead, Monte Carlo approaches are utilized. Also suppose that the observed spatial process vector is given as $\eta_d$ and those unobserved are given as $\eta_0$. Then the posterior predictive
distribution can be calculated as 

$$=\int[\eta_d,\eta_0,\theta,\beta,\sigma_\epsilon^2\vert\mathbf{Y}]d\eta_d d\theta d\beta d\sigma_\epsilon^2$$


### Prior distribution

It is usually the case that the parameters are considered to be *independent*, i.e. 

$$
[\beta,\sigma_\epsilon^2,\theta]=[\beta][\sigma_\epsilon^2][\theta]
$$

Note that the independence in prior distribution does not imply the
independence in posterior distribution.

### Choice of prior

-   $\beta$: flat($p(\beta)\propto 1$) or Normal with large variance
-   $\theta$: Spatial covariance function 
		ex. $\Sigma(\theta)=\sigma^2_\eta R(\rho,\alpha)$
-   $\sigma_\eta^2$: inverse Gamma or Jeffrey's prior
-   $R(\rho,\alpha)$: spatial correlation matrix with range parameter
	- $\rho$ (Gamma or uniform on a bounded interval) and other parameters
	- $\alpha$ (known or discrete prior)
-   $\sigma_\epsilon^2$: similar to the prior choice of $\sigma_\eta^2$

For computational purpose, it is possible to reparameterize the data model as follows: 

$$\begin{aligned}
    \mathbf{Y}\vert \beta,\sigma_\epsilon^2,\theta &\sim GP(\mathbf{X}\beta,\Sigma(\theta)+\sigma^2_\epsilon I) \\
    \Sigma(\theta)+\sigma^2_\epsilon I &= \sigma_\eta^2 R(\rho,\alpha) +\sigma_\epsilon^2 I \\
    &= \sigma_\eta^2(R(\rho,\alpha)+\tau^2 I),\;\;\tau^2 = \frac{\sigma_\epsilon^2}{\sigma_\eta^2}
\end{aligned}$$

# Bayesian spatial prediction

## Bayesian Kriging

This section is about constructing a spatial prediction i.e. $\Bbb E(Z_0\vert\mathbf{Z})$, in a bayesian method.

### Assumption

Assume $\mathbf{Z}$ and $Z_0$ are jointly normal with mean and variance as follows: 

$$\begin{pmatrix}
        \mathbf{Z} \\ Z_0
    \end{pmatrix}
    \sim
    N\bigg(
    \begin{pmatrix}
        \mathbf{X}\beta \\ x_0^T\beta
    \end{pmatrix}
    ,
    \begin{pmatrix}
        \Sigma & \delta \\ \delta^T & \sigma_0^2
    \end{pmatrix}
    \bigg)
$$

Also, further assume that $\Sigma=\sigma^2 V(\theta),\delta=\sigma^2 W(\theta)$ and $\sigma_0^2=\sigma^2$.

### Prior

Define prior distribution on $\beta,\sigma^2,\theta$ as

$$\pi(\beta,\sigma^2,\theta)\propto\pi(\theta)\frac{1}{\sigma^2}$$

To minimize the contribution from the prior, we use such non-informative
priors.

### Posterior and Predictive

From the conditional distribution $Z_0\vert\mathbf{Z},\beta,\sigma^2,\theta$, we can calculate $\Bbb E(Z_0\vert\mathbf{Z})$ as follows. First, note that the conditional distribution is given as

$$Z_0\vert\mathbf{Z},\beta,\sigma^2,\theta \sim N(x_0^T\beta+W(\theta)^TV^{-1}(\theta)(\mathbf{Z-X\beta}),\sigma^2-\sigma^2W(\theta)^T V^{-1}(\theta)W(\theta))$$

Using conditional probability argument, first remove $\beta$ as:

$$\begin{aligned}
    \pi(Z_0\vert\mathbf{Z},\sigma^2,\theta) &= \int\pi(Z_0,\beta\vert\mathbf{Z},\sigma^2,\theta)d\beta \\
    &= \int\pi(Z_0\vert\mathbf{Z},\beta,\sigma^2,\theta)\pi(\beta\vert\mathbf{Z},\sigma^2,\theta)d\beta
\end{aligned}$$ 

Since the posterior distribution is proportional to the product of likelihood and prior i.e.

$$\pi(\beta\vert\mathbf{Z},\sigma^2,\theta)\propto\pi(\mathbf{Z}\vert\beta,\sigma^2,\theta)\pi(\beta,\sigma^2,\theta)$$

using the prior previously defined we can show that

$$\beta\vert\mathbf{Z},\sigma^2,\theta \sim N((\mathbf{Z}^TV^{-1}\mathbf{X})^{-1}\mathbf{X}^TV^{-1}\mathbf{Z},\sigma^2(\mathbf{X}^TV^{-1}\mathbf{X})^{-1})$$

Then, $Z_0\vert\mathbf{Z},\sigma^2,\theta\sim N(A,B)$ where

$$\begin{aligned}
    A &= (x_0-\mathbf{X}^T V^{-1}W)^T\hat\beta+ W^T V^{-1}\mathbf{Z} \\
    B &= (x_0-\mathbf{X}^TV^{-1}W)^T(\mathbf{X}^T(\sigma^2V)^{-1})^{-1}(x_0-\mathbf{X}^TV^{-1}W)+\sigma^2-\sigma^2W^TV^{-1}W
\end{aligned}$$

Next, remove $\sigma^2$ as: 

$$\begin{aligned}
    \pi(Z_0\vert\mathbf{Z},\theta) &= \int \pi(Z_0,\sigma^2\vert\mathbf{Z},\theta)d\sigma^2 \\
    &=\int \pi(Z_0\vert\mathbf{Z},\sigma^2,\theta)\pi(\sigma^2\vert\mathbf{Z},\theta)d\sigma^2
\end{aligned}$$

Then finally we can get the predictive density as
follows: 

$$\begin{aligned}
    \pi(Z_0\vert\mathbf{Z}) &=\int \pi(Z_0,\theta\vert\mathbf{Z})d\theta \\
    &=\int \pi(Z_0\vert\mathbf{Z},\theta)\pi(\theta,\mathbf{Z})d\theta
\end{aligned}$$

Usually, $\theta$ is a set of one or two parameters, one can numerically compute this. Also, depending on the prior of $\theta$, one can get an explicit expression of the predictive distribution. It is possible to approximate the predictive density by

$$\pi(Z_0\vert\mathbf{Z})\approx \frac{1}{m}\sum_{i=1}^m\pi(Z_0\vert\mathbf Z,\delta^{(i)})$$

where $\delta^{(i)}$ is the $i$-th draw from the posterior distribution
and $\delta$ is the set of all parameters.

# Spatial GLMM

## Rationale

Usually data in the real world are not Gaussian, but at spatial data, spatial dependence structure exist still. Thus it is natural to consider the previous Gaussian model as a linear mixed model, with a spatial random effect. i.e. 

$$\begin{aligned}
    Y &=X\beta+H\eta+\epsilon\\
    \eta &\sim N(0,\Sigma(\theta))\\
    \epsilon &\sim N(0,\sigma_\epsilon^2 I)
\end{aligned}$$

## Assumption

Suppose $[Y(s)\vert Z(s),\theta]$ follows an exponential family. i.e.

$$\exp\bigg(\frac{Y(s)Z(s)-\psi(Z(s))}{\phi(\theta)}+c(Y(s),\theta)\bigg)$$

Also assume the conditional independence for $s_i,i=1,\cdots,n$ i.e.

$$= \prod_{i=1}^n[Y(s_i)\vert Z(s_i),\theta]$$

Spatial dependence structure is embedded in the conditional mean through the *link function*

$$\mu=\Bbb E(\mathbf{Y\vert Z,\theta})=\dot\psi(\mathbf{Z})$$ 

where $\mu=h(\mathbf{X\beta+H\eta}), h^{-1}=g$. Also note that

$$g(\mu)=\mathbf{Z=X\beta+H\eta}$$

-   For count data, Poisson distribution is used and the function $g(\cdot)$ is log function.
-   For binomial data, Binomial distribution is used and the function $g(\cdot)$ is logit or probit function.

## Parameter estimation

-   In Bayesian approach, MCMC method is widely used.
-   MCMC method obtains posterior samples of parameters through a  constructed Markov Chains.
-   The goal is to find samples from $[\theta\vert data]$. This can be done by sampling from $[\theta_i\vert\theta_{-i}^{(r-1)}, data]$ for $i=1,\cdots,k$ where $\theta_{-i}=\{\theta_1,\cdots,\theta_{i-1},\theta_{i+1},\cdots,\theta_k\}$ iteratively.
-   If the distribution $[\theta_i\vert\theta_{-i},data]$ is a known distribution then the MCMC process is *Gibbs sampler*.
-   If the distribution is not available, *Metropolis-Hastings algorithm*
    is used by introducing a proposal density.


# REFERENCES

- Alan E. Glefand et al. - Handbook of Spatial Statistics (2010)

{% endraw %}