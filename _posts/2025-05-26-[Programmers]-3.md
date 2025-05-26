---
title: "[Programmers] 3. 두 수를 뽑아서 더하기"
tags: 
- Programmers
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# 문제
https://github.com/dremdeveloper/codingtest_cpp/blob/main/solution/03.cpp  
정수 배열 numbers가 주어진다. numbers에서 서로 다른 인덱스에 있는 2개의 수를 뽑아 더해 만들 수 있는 모든 수를 배열에 오름차순으로 담아 반환하는 solution() 함수를 완성하라.

### 제약조건
- numbers의 길이는 2 이상 100 이하이다.
- numbers의 모든 수는 0 이상 100 이하이다.

### 입출력 예
[2, 1, 3, 4, 1] -> [2, 3, 4, 5, 6, 7]
[5, 0, 2, 7] -> [2, 5, 7, 9, 12]

# 풀이
```swift
/*
     4 2 2 1 1 3 4
     2 2 1 1 3 4
     2 1 1 3 4
     1 1 3 4
     1 3 4
     3 4
     4
*/
func solution(_ numbers: [Int]) -> [Int] {

    // 배열 크기
    let cnt = numbers.count
    
    // 두 수의 합을 저장할 공간
    var set = Set<Int>()
    
    for i in 0..<cnt {
        for j in i+1..<cnt {
            set.insert(numbers[i] + numbers[j]) // O(n^2)
        }
    }
    return Array(set).sorted()                  // Set -> Array O(n)
                                                // sorted() O(n^2 log n)
}

func printSolution(_ vec: [Int]) {
    print(vec.map { String($0) }.joined(separator: " "))
}

func main() {
    printSolution(solution([2, 1, 3, 4, 1])) // 2 3 4 5 6 7
    printSolution(solution([5, 0, 2, 7]))    // 2 5 7 9 12
}

main()
```

```c++
#include <iostream>
#include <vector>
#include <set>
using namespace std;

// 내가한 방법
vector<int> solution2(vector<int> numbers) {
    vector<int> arr;
    for (int i=0; i<numbers.size(); i++) {
        for (int j=i+1; j<numbers.size(); j++)
        arr.push_back(numbers[i] + numbers[j]); // O(n^2)
    }
    sort(arr.begin(), arr.end());               // O(n^2 log n^2) = O(n^2 log n)
    arr.erase(unique(arr.begin(), arr.end()), arr.end()); // O(n^2)
    return arr;
}

// 모범 답안
// set은 중복값을 자동으로 제거해주고, 오름차순으로 데이터를 정렬해준다
vector<int> solution(vector<int> numbers) {
    set<int> sum;
    for (int i=0; i<numbers.size(); i++) {
        for (int j=i+1; j<numbers.size(); j++) {  
            sum.insert(numbers[i] + numbers[j]); // O(n^2 log n)
        }
    }
    vector<int> answer(sum.begin(), sum.end());
    return answer;
}
```