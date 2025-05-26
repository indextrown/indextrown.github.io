---
title: "[Programmers] 2. 배열 제어하기"
tags: 
- Programmers
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# 문제
https://github.com/dremdeveloper/codingtest_cpp/blob/main/solution/02.cpp  
정수 배열 lst가 주어진다. 배열의 중복값을 제거하고 배열 데이터를 내림차순으로 정렬해서 반환하는 solution()함수를 구현하라.

### 제약조건
- lst의 길이는 2이상 1,000 이하이다.
- lst의 원소 값은 -100,000이상 100,000 이하이다.

### 입출력 예
[4, 2, 2, 1, 3, 4] -> [4, 3, 2, 1]
[2, 1, 1, 3, 2, 5, 4] -> [5, 4, 3, 2, 1]

# 풀이
배열과 Set 사용법이 요구되었다.

```swift
func compare(_ a: Int, _ b: Int) -> Bool {
    return a > b
}

func solution(_ lst: [Int]) -> [Int] {
    let setList = Array(Set(lst))                // O(n) 
    let sortedList = setList.sorted(by: compare) // O(n logn) -> Timsort
    return sortedList
}

// 결과를 출력하는 함수
func printSolution(_ vec: [Int]) {
    print(vec.map { String($0) }.joined(separator: " "))
}

// 메인 함수
func main() {
    printSolution(solution([4, 2, 2, 1, 1, 3, 4])) // 4 3 2 1
    printSolution(solution([2, 1, 1, 3, 2, 5, 4])) // 5 4 3 2 1
}

main()
```

```c++
#include <iostream>
#include <vector>
using namespace std;

bool compare(int a, int b) {
    return a > b;
}

// sort(시작 반복자, 끝 반복자)
// sort(시작 반복자, 끝 반복자, 비교 함수)    비교 함수는 반환값이 false일 때 원소의 위치를 바꾼다
// sort(v.rbegin(), v.rend())
vector<int> solution(vector<int> lst) {
    //sort(lst.rbegin(), lst.rend());
    sort(lst.begin(), lst.end(), compare);                // O(n log n) -> IntroSort
    lst.erase(unique(lst.begin(), lst.end()), lst.end()); // O(n)
    return lst;
}

#include <iterator>
void print(vector<int> vec)
{
    copy(vec.begin(), vec.end(), std::ostream_iterator<int>(cout, " "));
    cout << endl;
}

int main()
{
    print(solution({4, 2, 2, 1, 1, 3, 4})); // 4 3 2 1
    print(solution({2, 1, 1, 3, 2, 5, 4})); // 5 4 3 2 1
    
    return 0;
}
```