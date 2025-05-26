---
title: "[Programmers] 1. 배열 정렬하기"
tags: 
- Programmers
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# 문제
https://github.com/dremdeveloper/codingtest_cpp/blob/main/solution/01.cpp  
정수 배열 arr을 오름차순으로 정렬해서 반환하는 solution() 함수를 완성하라.

### 제약조건
- arr의 길이는 2 이상 10^5 이하이다.
- arr의 원소 값은 -100,000 이상 100,000 이하이다.

### 입출력 예
[1, -5, 2, 4, 3] -> [-5, 1, 2, 3, 4]  
[2, 1, 1, 3, 2, 5,4] -> [1, 1, 2, 2, 3, 4, 5]  
[6, 1, 7] -> 1, 6, 7

# 풀이
기본적인 정렬 사용법이 요구되었다.
```swift
import Foundation

func solution(_ arr: [Int]) -> [Int] {
    return arr.sorted()
}

// 결과를 출력하는 함수
func printSolution(_ vec: [Int]) {
    print(vec.map { String($0) }.joined(separator: " "))
}

// 메인 함수
func start() {
    printSolution(solution([1, -5, 2, 4, 3]))
    printSolution(solution([2, 1, 1, 3, 2, 5, 4]))
    printSolution(solution([6, 1, 7]))
}

@main
struct Main {
    static func main() {
        start()
    }
}
```

```c++
#include <iostream>
#include <vector>
using namespace std;

vector<int> solution(vector<int> arr) {
    sort(arr.begin(), arr.end());
    return arr;
}

// 테스트 코드
#include <iostream>
void print(vector<int> vec)
{
    copy(vec.begin(), vec.end(), std::ostream_iterator<int>(cout, " "));
    cout << endl;
}

int main()
{
    print(solution({1, -5, 2, 4, 3}));      // -5 1 2 3 4
    print(solution({2, 1, 1, 3, 2, 5, 4})); // 1 1 2 2 3 4 5
    print(solution({6, 1, 7}));             // 1 6 7
    
    return 0;
}
```