---
title: "[Paper Review] Differentially Private Grids for Geospatial Data"
tags: 
- Differential Privacy
- Spatial Statistics
- Paper Review
category: ""
use_math: true
---

## Summarize

- Uniform grid approach for balancing the noise error and the non-uniformity error
- Proposed a method for choosing the grid size.
- Traditional differentially private methods for 2D datasets : quadtrees, kd-trees (Cormode et al., 2012; Xiao et al., 2010)
- Uniform grid method : apply grid on domain and execute count queries
- Key problem is the best grid size
- Proposed $m=\sqrt{\dfrac{N\epsilon}{c}}$ where $N$ is the number of data and $c$ is some small const.


## Problem formulation

- $D$ : 2-dimensional geospatial dataset
- Goal : publish a synopsis of the dataset to accurately answer count queries
- Count query : specifies a grid and asks for the number of data points in that grid
- Query rectangle : A set of grid asked by a query
### Two sources of error

#### Noise error

- To satisfy differential privacy, one adds an independent noise to each cell.
- The answer for count query then has sum of the noisy counts.
- If the noise has variance $\sigma^{2}$ and we count $q$ cells then the standard deviation of answer becomes $\sqrt{q}\sigma$.
- That is, if we make the **resolution higher**, more grids are contained for same answer, which results larger variance.

#### Non-uniformity error

- Caused by cells that intersect with the query rectangle but not contained in it.
- If the data points are not distributed uniformly, the non-uniformity error occurs.
- It depends on the number of data points in the intersected cell
- If we make the resolution higher, the non-uniformity error gets **lower**.


## Previous approaches

### Recursive partitioning

- (Xiao et al., 2010) proposed spatial indexing method, KD-trees
- KD tree recursively split along some dimension. Split points were chose to have an uniformity among subregions.
- (Cormode et al., 2012) proposed some method based on KD-trees, using the median of the partiton dimension as the split points.
- or based on quadtree, which recursively divides the nodes into four equal regions.

### Hierarchical Transformations

- Recursive partitioning essentially builds hierarchy over data points.
- (Xiao et al., 2011) proposed the *Privlet* method using wavelet transformation.
- Applies a Haar wavelet transformation to the frequency matrix of the dataset.


## Methodology

### Uniform Grid method

- Partitions the data domain into $m\times m$ grid cells of equal size.
- The grid size(resolution) $m$ is recommended to be


	$$

	m=\sqrt{\dfrac{N\epsilon}{c}} \tag{1}

	$$

where $N$ is the number of data points. $c=10$ worked well.


#### Proof

- Sensitivity $\Delta$ of count query is $1$.
- Thus the noise follows the Laplace distribution $\text{Lap}\left(\dfrac{1}{\epsilon}\right)$, with standard deviation of $\dfrac{\sqrt{2}}{\epsilon}$.
- For $m\times m$ grid, suppose a query selects $r$ proportion of the domain.
- Then, the query has standard deviation of $\dfrac{\sqrt{2r}m}{\epsilon}$.

- For $r$ proportion query, there are $\sqrt{r}m$ cells along the border of the query.
- That is, it includes on the order of $\sqrt{r}m\times \dfrac{N}{m^{2}} = \dfrac{\sqrt{r}N}{m}$ cells, which results the non-uniformity error $\dfrac{\sqrt{r}N}{c_{0}m}$ for some constant $c_0$.

Thus the error becomes


$$

\text{error}= \frac{\sqrt{2r}m}{\epsilon} + \frac{\sqrt{r}N}{mc_{0}}


$$

and to minimize it, we should pick $m$ as equation $(1)$ where $c=\sqrt{2}c_{0}$.

### Adaptive Grid method

- The main disadvantage of UG is that we treat each region without concerning their sparsity.
- Instead of making equipartition, we first lay a coarse $m_{1}\times m_{1}$ grid over the data.
- Then we issue a count query *for each cell* using a privacy budget $\alpha\epsilon$, where $0<\alpha<1$.
- AG then again partitions each cell based on $N'$ which is the noisy count of the cell.


#### Constrained Inference

Let $v$ be the noisy count of a specific first-level cell at AG method. Then, $v$ count is partitioned into $u_{1,1},\ldots,u_{m_{2},m_{2}}$ counts ($m_{2}\times m_{2}$ second-level grid). Then, one obtains more accurate count $v'$ by


$$

v' = \dfrac{\alpha^{2}m_{2}^{2}}{(1-\alpha)^{2}+\alpha^{2}m_{2}^{2}}+\dfrac{(1-\alpha)^{2}}{(1-\alpha)^{2}+\alpha^{2}m_{2}^{2}}\sum u_{i,j}


$$

This value goes to the following update:


$$

u_{i,j}' = u_{i,j}+\left(v'-\sum u_{i,j}\right)


$$

For AG, the second-level grid resolution $m_{2}$ becomes


$$

\left\lceil\sqrt{\dfrac{N'(1-\alpha)\epsilon}{c/2}}\right\rceil


$$

where $(1-\alpha)\epsilon$ indicates the remaining privacy budget,

Choosing $m_{1}$ is not that important than $m_{2}$ since the density of first-level grid affects on the second-level partition. But $m_{1}$ should not be too small, thus it was set to


$$

m_{1}=\max \left(10, \frac{1}{4}, \left\lceil \sqrt{\frac{N\epsilon}{c}}\right\rceil\right)


$$

Also $\alpha$ was set to $0.5$.

### Error

For query $r$, $A(r)$ denotes the correct answer and $Q_\mathcal{M}(r)$ denotes the answered value using the histogram using method $\mathcal{M}$. Then, the **relative error** is defined as


$$

\text{RE}_\mathcal{M}(r) = \dfrac{\vert Q_\mathcal{M}(r)-A(r)\vert}{\max\{A(r),\rho\}}


$$

where $\rho=0.001\cdot \vert D\vert$ were set to avoid division by zero.


## Experiment (GPT summarized)

In the experimental results section, the authors conducted extensive experiments using four real datasets to compare the accuracy of different methods and validate their analysis of parameter choices. The **datasets** include road intersections GPS coordinates, check-ins from a location-based social networking website, landmarks in the United States, and US storage facility locations.

The relative error is primarily considered, defined as the absolute error divided by the maximum of the correct answer or a threshold value. The experiments involve various query sizes, and the errors are computed for $200$ randomly generated queries per size. Two values of epsilon ($\epsilon$) are used ($0.1$ and $1.0$) for privacy considerations.

The authors compare KD-tree-based methods (KD-standard and KD-hybrid) with Uniform Grid (UG), Adaptive Grid (AG), and Privlet methods. They also explore the effect of adding hierarchies to UG and evaluate adaptive grids' performance with varying parameters. The evaluation metrics include line graphs for the arithmetic mean of relative errors and candlesticks for a clearer comparison among different algorithms.

Results show that choosing an appropriate grid size is crucial, and the suggested sizes by the authors generally align well with experimentally observed optimal sizes. The authors compare KD-hybrid with UG and find that UG tends to perform better in most cases. Additionally, the authors investigate the impact of adding hierarchies and find that while it can improve accuracy, the benefit is relatively small.

The AG method consistently outperforms other methods, including KD-hybrid, Quadopt, UG with the lowest observed relative error size, and Privlet on the same grid size. The AG method with suggested grid sizes performs competitively with the experimentally observed best grid sizes. The authors also conduct a final comparison using absolute error, confirming that AG consistently and significantly outperforms other methods across various datasets and privacy settings.


# References

- G. Cormode, C. Procopiuc, D. Srivastava, E. Shen, and T. Yu, “Differentially Private Spatial Decompositions,” in _2012 IEEE 28th International Conference on Data Engineering_, Arlington, VA, USA: IEEE, Apr. 2012, pp. 20–31. doi: [10.1109/ICDE.2012.16](https://doi.org/10.1109/ICDE.2012.16).

- Y. Xiao, L. Xiong, and C. Yuan, _Differentially Private Data Release through Multidimensional Partitioning_. 2010, p. 168. doi: [10.1007/978-3-642-15546-8_11](https://doi.org/10.1007/978-3-642-15546-8_11).

- W. Qardaji, Weining Yang, and Ninghui Li, “Differentially private grids for geospatial data,” in _2013 IEEE 29th International Conference on Data Engineering (ICDE)_, Brisbane, QLD: IEEE, Apr. 2013, pp. 757–768. doi: [10.1109/ICDE.2013.6544872](https://doi.org/10.1109/ICDE.2013.6544872).