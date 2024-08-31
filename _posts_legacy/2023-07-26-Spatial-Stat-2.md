---
title: Testing Complete Spatial Randomness
tags:
- Spatial Statistics
- Monte Carlo Test
- Nearest Neighborhood
category: 'Statistics'
use_math: true
---
{% raw %}
## Testing CSR

### Monte Carlo Tests

-   Let $T$ be any test statistic where larger $T$ cast doubt on the
    null hypothesis.

-   Let $t_1$ be the value of $T$ calculated from dataset.

-   For convenience, assume that the null sampling distribution of $T$
    is continuous.

Let $t_2,\ldots,t_s$ be the values of $T$ calculated from $s-1$
independent simulations of $H_0$. Then under $H_0$, the values
$t_1,\ldots,t_s$ are exchangeable, i.e.

$$P(t_i=t_{(j)})=\frac{1}{s}, j=1,\ldots,s$$ 

Hence, if $R$ denotes the
number of $t_i>t_1$ then $$P(R\leq r) = \frac{r+1}{s}.$$ Which means
that the *p-value* of Monte Carlo test is $(r+1)/s$.

### Inter-event distance based Test 

-   Let $T$ be the distance between two events independently and
    uniformly distributed in $A$.

-   For a unit square of $A$ 

    $$\begin{aligned}
        H(t) &= P(T\leq t) \\
        &= 
        \begin{cases}
        \pi t^2 - {8\over 3}t^3+{1\over 2}t^4,\quad 0\leq t\leq 1 \\
        {1\over3}-2t^2-{1\over2}t^4+{4\over3}(t^2-1)^{1\over2}(2t^2+1)+2t^2\sin^{-1}(2t^{-2}-1),\quad 1\leq t\leq \sqrt{2}
        \end{cases}
    \end{aligned}$$

-   For a circle of unit radius $A$, 

    $$\begin{aligned}
            H(t) = 1+\pi^{-1}[2(t^2-1)\cos^{-1}({t\over2})-t(1+{t^2\over2})\sqrt{1-{t^2\over4}}],\quad 0\leq t\leq2
        
    \end{aligned}$$

-   Consider empirical distribution function(EDF) of inter-event
    distances as:
    
    $$\hat{H}_1(t)={2\over n(n-1)}\sum_{i<j}I(t_{ij}\leq t)$$ 
    
    where
    $t_{ij}$ are observed inter-event distances from data.

-   Monte Carlo-based approach is used for this test.

-   Generating Monte-Carlo Samples

> -   Generate $s-1$ times of $n$ events in $A$ under CSR assumption
>
> -   Calculate $\hat{H}_i(t), i=2,\ldots,s$
>
> -   Calculate *envelopes*: 
>    
> $$
> \begin{aligned}
> U(t) &=\max_{2\leq i\leq s}\{\hat{H}_i(t)\}\\
> L(t) &=\min_{2\leq i\leq s}\{\hat{H}_i(t)\}
> \end{aligned}
> $$

-   Two common MC test approaches

    1.  Choose appropriate $t_0$ and define $u_i=\hat{H}_i(t_0)$ under
        CSR. Note that under $H_0$ at MC test, 
        
        $$P(u_1=u_{(j)})=1/s$$
        
        If $u_1$ ranks $k$th largest or higher than $k$th, the test that rejects CSR based on that gives an exact one-sided test of size
        $k/s$.
        
        > example : $k=5, s=100, u_1\geq u_{(5)}$ then size = 0.05

    2.  Define 
        
        $$u_i = \int(\hat{H}_i(t)-H(t))^2 dt.\tag{*}$$ 
        
        Then proceed to a test based on the rank of $u_1$.

-   Note that the approach 2 is more objective but known to have weak
    power.

### Nearest neighbor distance based Test 

-   Let $Y$ be the nearest neighbor distance under CSR when there are
    $n$ events in a region $A$

-   Theorical distribution of $Y$ is quite difficult, instead use an
    approximation.

-   Note that an event being within distance $y$ from known(specified)
    event is 
    
    $$\frac{\pi y^2}{|A|}$$ 
    
    Then, the CDF can be approximated by as follows: 
    
    $$\begin{aligned}
            G(y)=P(Y\leq y)&\approx 1-(1-\pi y^2|A|^{-1})^{n-1} \\        
            &\approx 1-\exp(-\lambda\pi y^2),\quad y\geq 0
        
    \end{aligned}$$ 
    
    where (2) is a further approximation with large $n$ with $\lambda=n\vert A\vert^{-1}$.

-   Empirical CDF is gien as:

    $$\hat{G}_1(y) = \frac{1}{n}\sum_i I(y_i\leq y)$$

-   Let $$\bar{G}_i(y)=\frac{1}{s-1}\sum_{j\neq i}\hat{G}_j(y)$$ then the MC test is given as same as (\*) where
    
    $$u_i = \int(\hat{G} _i(y)-\bar{G}_i(y))^2 dt.$$

{% endraw %}