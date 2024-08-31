---
title: "Fit without fear"
tags:
- Opinion
- Paper Review
- Data Science
category: Opinion
use_math: true
---
{% raw %}
## Incomplete mathematical mosaic of DL

이번 글에서는 논문 *Fit without fear: remarkable mathematical phenomena of deep learning through the prism of interpolation*(M.Belkin et al.)을 리뷰해보도록 하겠다. 이 논문은 최근학술적 및 산업적으로 괄목할만한 성과를 내고 있는 딥러닝(DL)의 수학적인 백그라운드를 설명하고자 한다. 딥러닝은 분명 classical ML영역 및 통계학에 어느 정도 기반을 두고있는 것이 사실이지만, 그럼에도 불구하고 이러한 복잡한 신경망이 실제 문제에서 어떻게 잘 작동하는지에 대한 수학적인 근거는 부족한 편이다. 저자는 abstract에서 이를 ‘incomplete mathematical mosaic’라고 표현하는데, Interpolation과 over-parameterization의 두 가지 큰 테마로 이러한 현상의 설명을 시도한다. 저자의 논증 과정에서 깊이 있는 이론통계적 내용이 다소 등장하는데, 각각의 내용 및 참고문헌들에 대해서는 추후에 계속 공부하며 포스팅하도록 하겠다.
### Introduction
저자에 따르면 이론적인 머신러닝은 지난 10년간 위기를 맞이했다. 사실상 딥러닝이 학문 및 실무영역 모두에서 대세로 자리잡으면서 기초과학 영역에서조차 딥러닝이 기용되고 있는 사실이다. 그러나 통계적 학습이론 등 수학적인 기반이 딥러닝의 성과에 대한 설명을 만들어내고자 함에도 이론(theory)과 실무(practice)의 괴리(disconnect)는 여전히 존재한다. 실무영역의 딥러닝은 사실상 연금술에 가깝다고 저자는 표현한다. 이는, 엄밀한 과학 및 이론적 배경보다 practical intuition, 즉 실제로 데이터 분석을 진행해보며 얻는 직관에 의존한다는 점을 강조해서 의미한다. 


#### Trending Phenomena

현재의 머신러닝, 특히 DL 영역이 기존의 통계적 학습이론으로 설명이 되지 않는 가장 큰 이유는 새로이 발견되는 현상들 때문이다. 기존의 통계적 학습이론에서는 모델의 복잡성이 증가할수록 over-fitting(과적합) 현상이 발생하여 training data에 대한 낮은 loss가 test data 혹은 validation data에 대해서는 높은 error(loss)를 수반하였다. 이를 방지하기 위해 다양한 regularization 기법이 개발되었고, 모델의 적합을 통해 얻어진 classifier가 새로운 예측치를 추정하는 과정은 기존의 관측값(training data)에 대한 일반화 과정에 불과하다. 저자는 이를 under-parameterized regimes라고 한다.

반면, 현대의 over-parameterized regimes는 말그대로 필요 이상의 모수를 설정하는 모델, 즉 딥러닝과 같은 모델을 의미한다. 그럼에도 이러한 모델은 기존의 통계적 학습이론에 반하는 현상을 발생시킨다. 즉, training error가 0에 수렴할 정도로 낮거나(overfitting) 혹은 거의 0의 값을 갖는 경우(interpolating)가 발생하더라도 반드시 test error가 unstable하지 않다는 것이다. 이러한 현상을 설명하기 위해서는, 우선 ML의 classical regime(statistical learning)과 modern regime(DL)이 대비되는 특성을 가진다는 점을 알아야 한다. 이에 대해 살펴보도록 하자.

### Classical regime vs. Modern regime of ML

|                        | Classical regime                        | Modern regime                                   |
|------------------------|-----------------------------------------|-------------------------------------------------|
| Generalization curve   | U-shaped                                | Descending                                      |
| Optimal model          | Bottom of U                             | Any large model                                 |
| Optimization landscape | Locally convex                          | Not locally convex, but satisfying PL condition |
| GD/SGD convergence	    | GD converges but not SGD with fixed eta | GD/SGD both converge                            |

위 표는 classical regime과 modern regime의 특징을 비교해서 설명한 것이다(논문 summary 참고). 

{% endraw %}