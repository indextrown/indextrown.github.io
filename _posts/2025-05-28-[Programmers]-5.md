---
title: "[Programmers] 5. 행렬의 곱셈"
tags: 
- Programmers
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# 문제
https://github.com/dremdeveloper/codingtest_cpp/blob/main/solution/05.cpp  
https://school.programmers.co.kr/learn/courses/30/lessons/12949
2차원 배열 arr1과 arr2를 입력받아 arr1에 arr2를 행렬 곱한 결과를 반환하는 solution() 함수를 완성하라

### 제약조건
- 배열 arr1, arr2의 행과 열의 길이는 2이상 100 이하이다.
- 배열 arr1, arr2의 데이터는 -10 이상 20 이하인 자연수다.
- 행렬 곱 할 수 있는 배열만 주어진다.

### 입출력 예
[[1, 4], [3, 2], [4, 1]] 
[[3, 3], [3, 3]]
-> [[15, 15], [15, 15], [15, 15]]

[[2, 3, 2], [4, 2, 4], [3, 1, 4]]
[[5, 4, 3], [2, 4, 1], [3, 1, 1]]
-> [[22, 22, 11], [36, 28, 18], [29, 20, 14]]

# 풀이
행렬 \( A \) (크기 \( m \times n \))와 행렬 \( B \) (크기 \( n \times p \))의 곱은 행렬 \( C = AB \) (크기 \( m \times p \))로 정의된다.

$$
C_{ij} = \sum_{k=1}^{n} A_{ik} \cdot B_{kj}
$$

즉, \( C \)의 \( i \)행 \( j \)열 원소는 \( A \)의 \( i \)행과 \( B \)의 \( j \)열의 내적이다.

---

## 🔢 예시 1: 2x2 행렬 곱셈

$$
A =
\begin{bmatrix}
1 & 2 \\\\
3 & 4
\end{bmatrix},
\quad
B =
\begin{bmatrix}
5 & 6 \\\\
7 & 8
\end{bmatrix}
$$

$$
AB =
\begin{bmatrix}
1 \cdot 5 + 2 \cdot 7 & 1 \cdot 6 + 2 \cdot 8 \\\\
3 \cdot 5 + 4 \cdot 7 & 3 \cdot 6 + 4 \cdot 8
\end{bmatrix}
=
\begin{bmatrix}
19 & 22 \\\\
43 & 50
\end{bmatrix}
$$

---

## 🔢 예시 2: 3x3 행렬 곱셈

$$
A =
\begin{bmatrix}
1 & 2 & 3 \\\\
4 & 5 & 6 \\\\
7 & 8 & 9
\end{bmatrix},
\quad
B =
\begin{bmatrix}
9 & 8 & 7 \\\\
6 & 5 & 4 \\\\
3 & 2 & 1
\end{bmatrix}
$$

$$
AB =
\begin{bmatrix}
30 & 24 & 18 \\\\
84 & 69 & 54 \\\\
138 & 114 & 90
\end{bmatrix}
$$


A 행렬의 크기가 (M*K)이고, B 행렬의 크기가 (K*N)일 때 두 행렬의 곱 연산은 행렬 A의 행의 개수(K)와 행렬 B의 열의 개수(k)가 같아야 하며 K를 기준으로 곱하기 때문에 행렬 곱 결과는 M * N이 된다.

```swift
import Foundation

func solution(_ arr1: [[Int]], _ arr2: [[Int]]) -> [[Int]] {
    
    let rows = arr1.count
    let cols = arr2[0].count

    // 최종 행렬 곱 결과를 저장할 배열 선언
    var answer = Array(repeating: Array(repeating: 0, count: cols), count: rows)
    
    // arr1의 각 행과 arr2의 각 열에 대해 반복문 수행
    for row in 0..<rows {
        for col in 0..<cols {
            for k in 0..<arr2.count {
                answer[row][col] += arr1[row][k] * arr2[k][col]
            }
        }
    }        
    return answer
}

func print2D(_ vec: [[Int]]) {
    for row in vec {
        print(row.map { String($0) }.joined(separator: " "))
    }
    print()
}

func main() {
    print2D(solution(
        [
            [1, 4],
            [2, 3],
            [4, 1]
        ],
        [
            [3, 3],
            [3, 3]
        ]))
    
    print2D(solution(
        [
           [2, 3, 2],
           [4 ,2, 4],
           [3, 1, 4]
        ],
        [
            [5, 4, 3],
            [2, 4, 1],
            [3, 1, 1]
        ]))
}

main()
```

```c++
#include <string>
#include <vector>

using namespace std;

vector<vector<int>> solution(vector<vector<int>> arr1, vector<vector<int>> arr2) {
    
    // 최종 행렬 곱 결과를 저장할 벡터 선언
    vector<vector<int>> answer;
    
    // arr1, arr2 행렬 곱을 수행했을 때 최종 행렬의 크기만큼 공간을 할당
    answer.assign(arr1.size(), vector<int>(arr2[1].size(), 0));
    
    // arr1의 각 행과 arr2의 각 열에 대해 반복문 수행
    for (int i=0; i<arr1.size(); i++) {
        for (int j=0; j<arr2[0].size(); j++) {
            for (int k=0; k<arr2.size(); k++) {
                answer[i][j] += arr1[i][k] * arr2[k][j];
            }
        }
    }
    
    return answer;
}
```