---
title: Disease mapping
tags:
- Spatial Statistics
- Public Health
- Mapping
category: ''
use_math: true
---
{% raw %}

The contents are mainly based on Professor ChaeYoung Lim's lecture materials and \"Handbook of Spatial Statistics\"(2010) textbook. In this chapter, we introduce some spatial methodology for disease mapping.

# Disease mapping

Disease mapping is about estimating local disease risk based on counts of observed cases of infection. The goals for disease mapping is twofold, one is to make a prediction statistically precise(i.e. lower variance) and the other one is to make the mapping in high resolution. This is the difference of disease mapping from typical geostatistics in that in geostatistics, spatial prediction at an unobserved site is of interest.

## Setting

First of all, let us define some notations and typical settings for disease mapping.

#### Notation

-   $Y_i$ : Counts of disease at region $i$

-   $n_i$ : The number of individuals at risk in region $i$.

-   $E_i$ : Expected number of cases under null model.

For $n_i$ and $E_i$s, those numbers are usually assumed to be known(i.e. not a parameter). Also, for binomial model we use $n_i$ and for Poisson model we use $E_i$.

#### Binomial Model

The binomial model is given as follows: 

$$\begin{aligned}
    Y_i&\sim\mathrm{Binomial}(n_i,p_i) \\
    \mathrm{logit}(p_i)&=x_i\beta + u_i
\end{aligned}$$

where $u_i$ are random effects which include spatial dependence structure as well.

#### Poisson model

The Poisson model is given as follows: 

$$\begin{aligned}
    Y_i&\sim\mathrm{Poisson}(E_i\theta_i) \\
    \log(\theta_i)&=\eta_i=x_i\beta+u_i
\end{aligned}$$ 

where $\theta_i$ is the relative risk of disease in region $i$ and $\eta_i$ is called as log relative risk. For a disease with a smaller rate of occurrence, $Y_i$ is small and binomial model is close to Poisson model. So in this chapter, we focus on the Poisson model.

#### Relative risk

The relative risk $E_i$s can be estimated or calculated in one of the followings.

1.  $E_i=n_i\times r$, where $r$ is constant or baseline risk per individual under some null model. Use average rate over region $\hat r=\frac{\sum_i Y_i}{\sum_i n_i}$ as $r$.

2.  $E_i=\sum_j n_{ij}r_j$, where $n_{ij}$ is person-year at risk in region $i$ for the age group $j$ and $r_j$ is disease rate in the age group $j$. This is the *standardized risk* over age to adjust age-effect.

Spatial variation can be modeled in term $u_i$. Usually, we assume the spatial term follows multivariate normal, i.e.
$$\mathbf{u}=(u_1,\ldots,u_n)^T \sim N(\mathbf{0},\Sigma_u)$$ where the covariance matrix models extra variability from spatial dependence than the original Poisson model. It is possible to use a spatial covariance function to construct $\Sigma_u$, but GMRF(Gaussian Markov Random Field) model with neighboring structure is more popular. In disease mapping, the interest mainly lies on prediction of stable risk(or relative risk, $\theta_i$). MLE of relative risk $Y_i/E_i$ is called SMR(Standardized mortality ratio), and it is unstable in that it doesn't take account of the differences in population sizes. Instead, we estimate the relative risk using the neighboring information from spatial random effect $u_i$s.

## GMRF models

Recall auto-normal model by Besag using the conditional specification of mean and precision matrix: 

$$\begin{aligned}
    \Bbb E[x_i\vert x_{-i}] &= \mu_i +\sum_{j\neq i}\beta_{ij}(x_j-\mu_j)\\
    Q_{i|-i} &= \sigma_i^{-2} > 0,
\end{aligned}$$

where $\beta_{ii}=0$.

### Intrinsic CAR model

With a weight matrix $\mathbf{W}$, we further assume as follows at the auto-normal model: 

$$\begin{aligned}
    \Bbb E[x_i\vert x_{-i}] &= \sum_{j\neq i}\frac{W_{ij}}{W_{i+}}x_j\\
    Q_{i|-i} &= \tau^2 W_{i+}, \;\;\tau^2 > 0
\end{aligned}$$

where $W_{i+}=\sum_{j\neq i}W_{ij}$ and the weights $W_{ij}\geq 0, \forall i\neq j$ are predetermined. In this case, the weight matrix $\mathbf{W}$ can be interpreted as an information of a neighboring structure of the data. For instance, if we suppose a first order neighboring structure, we define $W_{ij}=1$ if $i,j$ are neighbors and zero otherwise.

The precision matrix $\mathbf Q$ can be expressed as

$$\tau^2(\mathbf{M-W})$$

where $\mathbf{M}$ is a diagonal matrix whose entries are $M_{ii}=W_{i+}$. Since

$$\mathbf{Q1}=\tau^2\mathbf{(M-W)1}=0,$$

$\mathbf{Q}$ is not a full rank matrix. Thus, resulting joint distribution with the precision matrix is improper and such CAR(conditional autoregressive) model is called as **intrinsic CAR model**. Also, note that there is no parameter to control spatial dependence.

### Proper CAR model

From the intrinsic CAR model, we can construct a *proper CAR model* with a mixture type precision matrix such that

$$\mathbf{Q_0} = \gamma(\mathbf{M-W})+(1-\gamma)\mathbf{I},\quad 0\leq\gamma\leq 1$$

-   $\gamma=0$ : no spatial dependence but it is not easy to estimate

-   $\gamma=1$ : returns to the intrinsic CAR model

Another proper CAR model is to introduce a correlation parameter as

$$\mathbf{Q}=\tau^2(\mathbf{M}-\mathbf{\gamma W})$$

where parameter $\gamma$ should be in an appropriate range to make sure positive definiteness, i.e. $\mathbf{M-\gamma W}> 0$. Then, the conditional mean and the variance is given as follows. 

$$\begin{aligned}
    \mathbb E[x_i|x_{-i}]&=\sum_{j\neq i}\gamma\frac{W_{ij}}{W_{i+}}x_j \\
    Q_{i|-i}&=\tau^2 W_{i+}
\end{aligned}$$

-   $\gamma=0$ : Also implies no spatial dependence
-   $\gamma=1$ : corresponds to the intrinsic CAR model, which implies spatial dependence.
-   The difference between this model and the former is that while the former assume the same variability($1/\tau^2$), this model allows a different level of variability($1/\tau^2W_{i+}$).

Also, note that the positive definiteness of $\mathbf{Q}$ is equivalent to 

$$\gamma\in(\lambda_{\min}^{-1},\lambda_{\max}^{-1})$$ 

where $\lambda$s are the eigenvalues of $\mathbf{M^{-1/2}WM^{-1/2}}$. Since $tr(\mathbf{M^{-1/2}WM^{-1/2}})=0$ and the trace of a matrix is equivalent to the sum of all eigenvalues, the interval contains 0 as well. However, note that larger $\gamma$ does not imply always a stronger spatial dependence.

### Multivariate CAR

When the data are available for multiple diseases at the same areas and want to investigate their relationship concurrently, MCAR can be considered.

We denote $\mathrm{MCAR}(\gamma,\Lambda)$ as

$$\mathbf{x}\sim N_{np}(\mathbf{0},(\Lambda\otimes(\mathbf{M-\gamma W})^{-1})$$

where $$\mathbf{x}=(\mathbf{x}_1^T,\cdots,\mathbf{x}_p^T))^T$$ with $$\mathbf{x}_j=(x_{1j},\cdots,x_{nj})^T$$ is $np$ dimensional vector, and $p\times p$ matrix $\lambda$ is a positive definite matrix which is interpreted as the non-spatial precison between variables. When $\gamma=1$, the model is intrinsic MCAR and when $\gamma=0$, there is no spatial dependence.

### Zero inflated models

Some diseases are rare in that the ordinary Poisson or Binomail model might not be able to capture the extra zeros. To account for those, a mixture of a point mass and Poisson/Binomial model is considered.


$$\begin{aligned}
    Y_i|\theta_i &\sim \pi_i\delta_{Y_i=0}+(1-\pi_i)\mathrm{Poisson}(E_i e^{\theta_i}) \\
    \theta_i &= x_i^T\beta+u_i \\
    \mathbf{u} &\sim N(\mathbf{0},\Sigma_u)
\end{aligned}$$

$\pi_i$ is a proportion(probability) that the region $i$ is a structural zero. Also, one can further model

$$\mathrm{logit}(\pi_i)=z_i^T\gamma +v_i$$

where $\mathbf{v}\sim N(0,\Sigma_v)$. Covariates $z_i$ can be the same as $x_i$ or may depend on the population size. A simple model can be fitted using EM and for a complex model, full Bayesian MCMC can be considered.

## Spatio-temporal model

### Example

-   $Y_{ijkt}$ : lung cancer death counts in county $i$, during year $t$ for gender $j$ and race $k$ in state A.
-   $i=1,\cdots, I$, $j=1,2$, $k=1,2$, $t=1,\cdots, T$

Then, we assume the following structure for the spatio-temporal model.

$$\begin{aligned}
Y_{ijkt} &\overset{\mathrm{ind}}{\sim} \mathrm{Poisson}(E_{ijkt}e^{\mu_{ijkt}})\\
E_{ijkt}&= n_{ijkt}\hat r\\
\hat r&= \bar Y=\frac{\sum_{ijkt}Y_{ijkt}}{\sum_{ijkt}n_{ijkt}}\\
\mu_{ijkt}&= \alpha_{j}+\beta_{k}+\xi_{jk}+u_{i}^{(t)}+v_{i}^{(t)}
\end{aligned}$$


-   $\mathbf{u}^{(t)}=(u_{1}^{(t)},\cdots,u_{I}^{(t)})^{T},\;\mathbf{u}^{(t)}\vert_{\lambda_{t}}\sim CAR(\lambda_{t})$ which represents spatial random effect.
-   $\mathbf{v}^{(t)}=(v_{1}^{(t)},\cdots,v_{I}^{(t)}),\;\mathbf{v}^{(t)}\vert_{\tau_{t}}\sim N(\mathbf{0},\tau_{t}^{-1}I)$ which represents heterogeneity by bringing extra variability in mean.
-   $\alpha_j,\beta_k$ are main effects for gender and race and $\xi_{jk}$ is the interaction term between gender and race.
-   With appropriate priors, full Bayesian MCMC can be done.

## Inferential method

### Clayton, Kalder(1987)

Recall that the MLE of relative risk $\hat\theta_i=Y_i/E_i$ does not take into account the population size so that $\{\hat\theta_1,\cdots,\hat\theta_n\}$ may not be the best estimates. Suppose a Poisson-CAR model

$$\theta_i=\exp(\beta_i),\quad\beta\sim N(\mathbf{0},\Sigma)$$

where $\Sigma$ is from CAR model. What we want to estimate is the posterior expectation(MAP estimate) of $\theta_i$ given $Y_i$. However, there is no closed form. Instead, use the following approximation.


Let $\psi(\beta)$ be the Poisson log likelihood and approximate $\psi(\beta)$ by expanding about a suitable $\tilde{\beta}$, i.e.

$$\psi(\beta)\approx \psi(\tilde{\beta})+\psi^\prime(\tilde{\beta})(\beta-\tilde{\beta})+\frac{1}{2}(\beta-\tilde{\beta})^\prime\psi^{\prime\prime}(\tilde{\beta})(\beta-\tilde{\beta})$$

-   Obvious choice is $\tilde{\beta}_i=\log(Y_i/E_i)$ but $Y_i=0$ can cause a problem.

-   Biased-corrected version $\tilde{\beta}_i=\log((Y_i+1/2)/E_i)$ can be used.

Then the approximated posterior distribution is given as follows.

$$\begin{aligned}
\pi(\beta|\mathbf{Y})&\propto \exp\bigg(\psi(\beta)- \frac{1}{2}(\beta-\mu)^{T}\Sigma^{-1}(\beta-\mu)\bigg)\\
&\approx\exp\bigg(\psi^{\prime}(\tilde\beta)\beta+ \frac{1}{2}(\beta-\tilde\beta)^{\prime}\psi^{\prime\prime}(\tilde\beta)(\beta-\tilde\beta)- \frac{1}{2}(\beta-\mu)^{T}\Sigma^{-1}(\beta -\mu)\bigg)
\end{aligned}$$
The approximate MAP of $\beta$ given $\mathbf{Y}$ is

$$\hat\beta = (\Sigma^{-1}-\psi^{\prime\prime}(\tilde\beta))^{-1}(\Sigma^{-1}\mu-\psi^{\prime\prime}(\tilde\beta)\tilde\beta+\psi^\prime(\tilde\beta))$$

Posterior variance-covariance matrix is given as $S=(\Sigma^{-1}-\psi^{\prime\prime}(\tilde\beta))^{-1}$ and the additional parameters in $\mu=x_i\alpha$ and $\Sigma(\delta)$ can be estimated by EM algorithm.

### Other inferential methods

-   For Gaussian : MLE is possible
-   For non-Gaussian : Bayesian inference or INLA(Integrated nested Laplace approximation) as approximate Bayesian approach

## REFERENCES

-   Alan E. Gelfand et al. - Handbook of Spatial Statistics (2010)
-   Lance A. Waller - Disease mapping (2010)

{% endraw %}