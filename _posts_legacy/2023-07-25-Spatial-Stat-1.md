---
title: Complete Spatial Randomness
tags:
- Spatial Statistics
- Statistics
- Complete Spatial Randomness
category: ''
use_math: true
---
{% raw %}
# Complete Spatial Randomness

As the first step to analyze spatial point pattern data, we need to
check **CSR**, the **complete spatial randomness**.

## Preliminaries 1
Consider a point process $N$, as a random counting measure on a space $\mathcal{S}\subseteq\mathbb{R}^d$, usually $d=2, 3$ at spatial context.

- $N$ takes non-negative integer values, is finite on bounded sets, and is countably additive.

- That is, if $A=\cup_{i=1}^\infty A_i$ then $N(A)=\sum_i N(A_i)$

## **Definition 1** (The homogeneous Poisson process).

The most fundamental point process is the homogeneous Poisson process.
For this, if $A$, $A_i(i=1,\ldots,k)$ are bounded Borel subsets of
$\mathcal{S}$, and are disjoint then the following hold.

1.  $N(A)$ follows a Poisson distribution as
    $$N(A) \sim \mathrm{Poisson}(\lambda|A|)$$ where $|A|$ is the volume(Lebesgue measure) of $A$, and the constant $\lambda$ is called *intensity* which indicates the mean number of events per unit area.

2.  $N(A_1),\ldots,N(A_k)$ are independent random variables.

## Why interested in CSR?

-   Property 2 at the definition above is known as the property of
    *complete spatial randomness*.

-   If a test of CSR is not rejected, any further formal analysis may
    not be necessary(except estimating the intensity).

-   Distinguish whether the point pattern has some aggregated patterns
    or not.

# References
- 서울대학교 공간자료분석 강의노트
- Handbook of Spatial Statistics

{% endraw %}