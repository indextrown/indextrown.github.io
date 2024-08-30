---
title: Point Process
tags:
- Spatial Statistics
- Point Process
- Poisson Point Process
- Probability Theory
category: 'Statistics'
use_math: true
---
{% raw %}

# Point Process

## Definition

### Notation

-   $\mathcal{S}$ : a metric space with metric $d$

-   $X$ : point process on $\mathcal{S}$

-   $x$ : realization of a point process $X$

-   $x$ is said to be locally finite if $n(x_B)<\infty$ whenever
    $B\subset\mathcal{S}$ is bounded. $n(x_B)$ is the number of points
    in $x_B=x\cap B$

**Definition 2** (Point Process). A point process $X$ defined on $\mathcal{S}$ is a measurable mapping defined on some probability space $(\Omega,\mathcal{F},P)$ and taking values in $$(\mathbb{N}_{lf},\mathcal{N}_{lf})$$

- $\mathbb N_{lf}=\{x\subset\mathcal{S}:n(x_B)<\infty,\;\;\forall\;\mathrm{bounded}\;\; B\subset\mathcal{S}\}$

- $$\mathcal{N}_{lf}$$ is a $$\sigma$$-algebra on $$\mathbb N_{lf}$$ such that

$$
\mathcal{N}_{lf}=\sigma(\{x\in\Bbb N_{lf}:n(x_B)=m)\}:B\in\mathcal{B}_0,m\in\Bbb{N}_0)
$$

where $\mathcal{B}_0$ is the class of bounded Borel sets of Borel $\sigma$-algebra on $\mathcal{S}$

The distribution $P_X$ of point process $X$ is given by

$$P_X(F) = P(\{\omega\in\Omega:X(\omega)\in F\})\quad\forall F\in\mathcal{N}_{lf}$$


**Remarks 1**.

-   $X$ is measurable is equivalent to : **count function** $N(B):=n(x_B)$ is a random variable for any $B\in\mathcal{B}_0$

-   The distribution of a point process $X$ is determined by the finite dimensional distributions of its count function.

-   $$\mathcal{N}_{lf}=\sigma(\mathcal{N}^\circ_{lf})$$ where
    $$\mathcal{N}^\circ_{lf} = \{\{x\in\mathcal{N}_{lf}:n(x_B)=0\}:B\in\mathcal{B}_0\}$$
    is the class of void events

-   $v(B):=P(N(B)=0)$ for $B\in\mathcal{B}_0$ is a void probability

-   If $\mathcal{S}$ is polish space, $\mathcal{N}_{lf}$ is separable

 
**Definition 3** (Marked Point Process). *Marked point process $X$ with points in $T$ and mark space $\mathcal{M}\subset\mathbb R^p$ (or marked point pattern) means a point process with extra information attached to
each point.*

$X=\{(\xi,m_\xi):\xi\in Y\}$, where $Y$ is a point process on $T$ and $m_\xi\in \mathcal{M}$ is called a **mark**.
  

## Poisson Point process

### Binomial point process

 
**Definition 4** (Binomial point process). *Binomial point process $X\sim binomial(B,n,f)$ for a density function $f$ on $B\subset\mathcal{S}$ is defined when it consists of $n$ iid points with
density $f$ on $B$.*
  

### Poisson point process

-   Poisson point process serves as a model for CSR

-   Also it serves as a reference point process for advanced models

-   Poisson point process $X$ on $\mathcal{S}\subset\mathbb R^d$ is specified by locally integrable intensity function
    $\rho:\mathcal{S}\to[0,\infty)$

 
**Definition 5** (Poisson point process). *Poisson point process
$X\sim\textrm{poisson}(\mathcal{S},\rho)$ is defined if*

1.  *$\forall B\subset\mathcal{S}$ with
    $\mu(B)=\int_B\rho(\xi)d\xi<\infty$

    $$N(B)\sim\textrm{Poisson}(\mu(B))$$*

2.  *$\forall n\in\mathbb N$ and $\forall B\subset\mathcal{S}$ with
    $0<\mu(B)<\infty$, conditional on $N(B)=n$,
    $x_B\sim binomial(B,n,f)$ with $f(\xi)=\rho(\xi)/\mu(B)$*

*$\mu(\cdot)$ above is called an intensity measure.*
  
**Remarks 2**.
  

-   $\Bbb{E}N(B) = \mu(B)$ : intensity measure determines the expected
    number of points

-   When $\rho(\xi)\equiv\rho$, the process is called *homogeneous*.
    Otherwhise, the poisson point process is *inhomogeneous*.

-   When $\rho(\xi)\equiv 1$, it is called as standard Poisson point
    process.

-   If the distribution of process is invariant under translation, the
    process is called as *stationary*

    $$X+s=\{\xi+s:\xi\in X\} \equiv X\quad\forall s\in\mathbb R^d$$

-   If the distribution of process is invariant under rotations about
    the origin in $\mathbb R^d$ then the process is called as
    *isotropic*.

    $$\mathcal{O}X=\{\mathcal{O}\xi:\xi\in X\}\equiv X\quad\forall\mathcal{O}\text{  is rotation }$$

## Properties of Poisson point process

**Proposition 1**.
  
1.  $X\sim poisson(\mathcal{S},\rho)$ if and only if
    $\forall B\subset\mathcal{S}$ with
    $\mu(B)=\int_B\rho(\xi)d\xi<\infty$ and
    $\forall F\in\mathcal{N}_{lf}$

    $$P(x_B\in F) = \sum_{n=0}^\infty\frac{\exp(-\mu(B))}{n!}\int_B\cdots\int_B\mathbf{1}[\{\xi_1,\ldots,\xi_n\}\in F]\times\prod_{i=1}^n\rho(\xi_i)d\xi_1\cdots d\xi_n$$

2.  If $X\sim poisson(\mathcal{S},\rho)$, then for functions
    $h:\Bbb N_{lf}\to[0,\infty)$ and $B\subset \mathcal{S}$ with
    $\mu(B)<\infty$,

    $$\Bbb Eh(x_B) = \sum_{n=0}^\infty\frac{\exp(-\mu(B))}{n!}\int_B\cdots\int_Bh(\{\xi_1,\ldots,\xi_n\})\times\prod_{i=1}^n\rho(\xi_i)d\xi_1\cdots d\xi_n$$


**Theorem 1** (Existence). *$X\sim poisson(\mathcal{S},\rho)$ exists and
is uniquely determined by its void probability $$v(B)=\exp(-\mu(B))$$
for bounded $B\subset \mathcal{S}$.*
  


**Proposition 2** (Independent scattering). *If $X$ is a Poisson process
on $\mathcal{S}$, then $x_{B_1},\cdots$ are independent for disjoint
sets $B_1,B_2,\cdots\subset \mathcal{S}$*
  


**Proposition 3** (Generating functional). If
$X\sim poisson(\mathcal{S},\rho)$,

$$G_X(u)=\Bbb E\bigg[\prod_{\xi\in X}u(\xi)\bigg] = \exp\bigg(\int_\mathcal{S}(1-u(\xi))\rho(\xi)d\xi\bigg)$$

for functions $u:\mathcal{S}\to[0,1]$
  

**Proposition 4** (Construction of stationary Poisson point process).
Let $s_1,u_1,s_2,u_2,\ldots$ be mutually independent, where each $u_i$
is uniformly distributed on $\{u\in\Bbb R^d:\Vert u\Vert = 1\}$ and
$s_i\sim Exp(\rho w_d)$ with mean $1/(\rho w_d)$ for $\rho>0$.
$w_d=\pi^{d/2}/\Gamma(1+d/2)$ is the volume of the $d$-dimensional unit
ball. Let $R_0=0$ and $R_i^d=R^d_{i-1}+s_i, i=1,2,\cdots$. Then,

$$X=\{R_1u_1,R_2u_2,\cdots\} \sim poisson(\mathbb R^d,\rho)$$*\
  

**Theorem 2** (Slivnyak-Mecke). If $X\sim poisson(\mathcal{S},\rho)$,
for function $h:\mathcal{S}\times\Bbb N_{lf}\to[0,\infty)$,

$$\Bbb E\bigg[\sum_{\xi\in X}h(\xi,X\backslash\xi)\bigg] = \int_\mathcal{S}\Bbb E[h(\xi,X)]\rho(\xi)d\xi$$
  
**Theorem 3** (Extended Slivnyak-Mecke's Theorem). If
$X\sim poisson(\mathcal{S},\rho)$, for any $n\in\Bbb N$ and any function
$h:\mathcal{S}^n\times\Bbb N_{lf}\to[0,\infty)$,

$$\Bbb E\bigg[\sum_{\xi_1,\cdots,\xi_n\in X}^{\neq} h(\xi_1,\cdots,\xi_n,X\backslash\{\xi_1,\cdots,\xi_n\})\bigg] = \int_\mathcal{S} \Bbb E[h(\xi_1,\cdots,\xi_n,X]\prod_{i=1}^n\rho(\xi_i)d\xi_1,\cdots d\xi_n$$

where $\neq$ means the $n$ points $\xi_1,\cdots,\xi_n$ are pairwise
distinct.
  

### Two basic operations for point processes

-   Superposition : A disjoint union $\cup_{i=1}^\infty X_i$ of point processes

    **Proposition 5**. *If
    $X_i\sim poisson(\mathcal{S},\rho_i), i=1,2,\cdots$ are mutually
    independent and $\rho=\sum_i\rho_i$ is locally integrable, then with
    probability one, $X=\sum_{i=1}^\infty X_i$ is a disjoint union and
    $X\sim poisson(\mathcal{S},\rho)$*
      

-   Thinning

    -   $X_{thin}$, independent thinning of $X$ with retention
        probability $p(\xi)$, is obtained by including $\xi\in X$ in
        $X_{thin}$ with probability $p(\xi)$, where points are
        included/excluded independently each other.

    -   $X_{thin}=\{\xi\in X:R(\xi)\leq p(\xi)\}$ where
        $R(\xi)\sim uniform(0,1), \xi\in\mathcal{S}$ are mutually
        independent and independent of $X$.

    **Theorem 4**. *Suppose $X_i\sim poisson(\mathcal{S},rho_i)$. Then,
    $X_{thin}$ with retention probability $p(\xi)$, and
    $X\backslash X_{thin}$ are independent Poisson point process with
    intensity functions $\rho_{thin}(\xi)=p(\xi)\rho(\xi)$ and
    $(\rho-\rho_{thin})(\xi)$ respectively.*
      

-   Inhomogeneous Poisson point process from homogeneous Poisson point
    process by thinning

    **Corollary 1**. *Suppose that $X\sim poisson(\Bbb R^d,\rho)$ with
    $|\rho(\xi)|<c$ for some $0<c<\infty$. Then, $X$ is distributed as
    an independent thinning of $poisson(\Bbb R^d,c)$ with retention
    probability $p(\xi)=\rho(\xi)/c$*
      

## Simulation of Poisson point process

### Homogeneous case

Simulation of $X\sim poisson(\Bbb R^d,\rho)$ within bounded $B$

1.  if $B=b(0,r)$ :

    Use proposition 4 : i.e. generate $$s_1,\ldots,s_m\sim Exp(\rho w_d)$$ and $$u_1,\ldots,u_m\sim uniform(\{u:\Vert u\Vert = 1\})$$, where $m$ is given by $R_{m-1}\leq r\leq R_m$. Then, return 
    
    $$x_B = \{R_1u_1,\cdots,R_{m-1}u_{m-1}\}$$

1.  if $B=[0,a_1]\times\cdots\times[0,a_d]$ :

    generate $N(B)=Poisson(\rho a_1\cdots a_d)$, and generate $N(B)$ points uniformly in $B$.

2.  if $B$ is none of 1 and 2 :

    Simulate $X$ on a ball or box $B_0$ containing $B$ and disregard the points falling outside of the ball or box

### Inhomogeneous case

When $X$ is inhomogeneous with $\rho(\xi),\xi\in B$ and
$\rho(\xi)\leq \rho_0$ for a constant $\rho_0>0$, by Corollary 1,

1.  Generate a homogeneous Poisson point process $Y$ on $B$ with
    intensity function $\rho_0$.

2.  Obtain $X_B$ as an independent thinning of $Y_B$ with retention
    probability $p(\xi)=\rho(\xi)/\rho_0,\xi\in B$

## Density of Poisson point process

-   Suppose that $X_1, X_2$ are two point processes on $\mathcal{S}$ and
    $X_1$ is absolutely continuous w.r.t. $X_2$. i.e.

    $$P(X_2\in F)=0\Rightarrow P(X_1\in F)=0\quad \forall F\in\mathcal{N}_{lf}$$

-   By Radon-Nikodym theorem, there exists a function
    $f:\Bbb N_{lf}\to[0,\infty]$ such tat $\forall F\in\mathcal{N}_{lf}$

    $$P(X_1\in F) = \Bbb E[I(X_2\in F)f(X_2)]$$

-   We call $f$ a density of $X_1$ w.r.t. $X_2$.

**Proposition 6**.

1.  *For any numbers $\rho_1,\rho_2>0$, $poisson(\Bbb R^d,\rho_1)$ is
    absolutely continuous w.r.t. $poisson(\Bbb R^d,\rho_2)$ iff
    $\rho_1=\rho_2$.*

2.  *For $i=1,2,$, suppose that $\rho_i:\mathcal{S}\to[0,\infty)$ such
    that $\mu_i(\mathcal{S})=\int_\mathcal{S}\rho_i(\xi)d\xi$ is finite
    and $\rho_2(\xi)>0$ whenever $\rho_1(\xi)>0$. Then
    $poisson(\mathcal{S},\rho_1)$ is absolutely continuous w.r.t.
    $poisson(\mathcal{S},\rho_2)$ with density

    $$f(x)=\exp(\mu_2(\mathcal{S})-\mu_1(\mathcal{S}))\prod_{\xi\in x}\frac{\rho_1(\xi)}{\rho_2(\xi)}$$

    for finite point configurations $x\subset \mathcal{S}$.*
  

From 2 at Proposition, we can let $\rho_2\equiv 1$ and suppose
$\mathcal{S}$ is bounded. Then, such Poisson point process, say, $X_1$
is always absolutely continuous w.r.t. $poisson(\mathcal{S},1)$ and

$$f(x)=\exp(|\mathcal{S}|-\mu_1(\mathcal{S}))\prod_{\xi\in X}\rho_1(\xi)$$

## Marked Poisson Point process

 
**Definition 6**. *$X=\{(\xi,m_\xi):\xi\in Y\}$,
$(\xi,m_\xi)\in\mathcal{T\times M}$ is a marked Poisson point process if
$Y\sim poisson(\mathcal{T},\phi)$ where $\phi$ is locally integrable
intensity function, and the *marks* $\{m_\xi,\xi\in Y\}$ are mutually
independent condional on $Y$.*
  

-   If the marks are identically distributed with a common distribution
    $Q$, then $Q$ is called the mark distribution.

-   If $\mathcal{M}=\{1,\cdots,K\}$, it is called multitype Poisson
    point process.

**Proposition 7**. *Let $X$ be a marked Poisson point process with
$\mathcal{M}\subset \Bbb R^p$, where conditional on $Y$, each mark
$m_\xi$ has a discrete or continuous density $p_\xi$, which doesn't
depend on $Y\backslash\xi$. Let $\rho(\xi,m)=\phi(\xi)p_\xi(m)$. Then,*

1.  $X\sim poisson(\mathcal{T\times M},\rho)$

2.  If $\kappa(m)=\int_\mathcal{T}\rho(\xi,m)d\xi$ is locally
    integrable, then

$$\{m_\xi:\xi\in Y\}\sim poisson(\mathcal{M},\kappa)$$
  

## Multivariate Poisson process and random labeling

-   Multitype point process $X$ with $\mathcal{M}=\{1,\ldots,K\}$ is
    equivalent to multivariate point process $(X_1,\ldots,X_K)$

-   The following two statements are equivalent.

    1.  $P(m_\xi=i\Vert Y=y)=p_\xi(i)$ depends only on $\xi$ for
        realizations $y$ of $Y$ and $\xi\in y$

    2.  $(X_1,\cdots,X_K)$ is a multivariate Poisson point process with
        independent components $X_i\sim poisson(\mathcal{T},\rho_i)$,
        where $$\rho_i(\xi)=\phi(\xi)p_\xi(i),\quad i=1,\cdots,K$$

-   Random labeling means that conditional on $Y$, the marks $m_{\xi}$
    are mutually independent and the distribution of $m_\xi$ does not
    depend on $Y$.

# References
- 서울대학교 공간자료분석 강의노트
- Handbook of Spatial Statistics

{% endraw %}