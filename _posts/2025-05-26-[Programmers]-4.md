---
title: "[Programmers] 4. 모의고사"
tags: 
- Programmers
header: 
  teaser: 
typora-root-url: ../

---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

# 문제
https://github.com/dremdeveloper/codingtest_cpp/blob/main/solution/04.cpp  
https://school.programmers.co.kr/learn/courses/30/lessons/42840  
수포자는 수학을 포기한 사람의 준말입니다. 수포자 삼인방은 모의고사에 수학 문제를 전부 찍으려 합니다.   
수포자는 1번 문제부터 마지막 문제까지 다음과 같이 찍습니다.  

1번 수포자가 찍는 방식: 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, ...  
2번 수포자가 찍는 방식: 2, 1, 2, 3, 2, 4, 2, 5, 2, 1, 2, 3, 2, 4, 2, 5, ...  
3번 수포자가 찍는 방식: 3, 3, 1, 1, 2, 2, 4, 4, 5, 5, 3, 3, 1, 1, 2, 2, 4, 4, 5, 5, ...  
1번 문제부터 마지막 문제까지의 정답이 순서대로 들은 배열 answers가 주어졌을 때, 가장 많은 문제를 맞힌 사람이 누구인지 배열에 담아 return 하도록 solution 함수를 작성해주세요.

### 제약조건
- 시험은 최대 10,000 문제로 구성되어있습니다.
- 문제의 정답은 1, 2, 3, 4, 5중 하나입니다.
- 가장 높은 점수를 받은 사람이 여럿일 경우, return하는 값을 오름차순 정렬해주세요.

### 입출력 예
[1, 2, 3, 4, 5]	-> [1]  
[1, 3, 2, 4, 2] -> [1, 2, 3]

# 풀이
```swift
```

```c++
#include <string>
#include <vector>
#include <algorithm>
using namespace std;

vector<int> solution(vector<int> answers) {
    vector<int> firstVec({1, 2, 3, 4, 5});
    vector<int> secondVec({2, 1, 2, 3, 2, 4, 2, 5});
    vector<int> thirdVec({3, 3, 1, 1, 2, 2, 4, 4, 5, 5});
    vector<int> scoreBox(3, 0);  // 실제 정답과 비교하여 수포자들의 패턴을 비교해서 맞춘 개수
    vector<int> answer;          // 가장 문제를 많이 맞춘 사람이 저장될 벡터
    
    for (int i=0; i<answers.size(); i++) {
        if (answers[i] == firstVec[i%firstVec.size()]) {
            scoreBox[0] += 1;
        }
        if (answers[i] == secondVec[i%secondVec.size()]) {
            scoreBox[1] += 1;
        }
        if (answers[i] == thirdVec[i%thirdVec.size()]) {
            scoreBox[2] += 1;
        }
    }
    // 가장 많이 맞춘 수포자가 얻은 점수
    int maxScore = *max_element(scoreBox.begin(), scoreBox.end());
    
    // 가장 많이 맞춘 수포자의 번호를 저장
    for (int i=0; i<3; i++) {
        if (scoreBox[i] == maxScore) {
            answer.push_back(i+1);
        }
    }
    
    return answer;
}

#include <iostream>
void print(vector<int> vec) {
    copy(vec.begin(), vec.end(), std::ostream_iterator<int>(cout, " "));
    cout << endl;
}

int main()
{
    print(solution({1, 2, 3, 4, 5}));     // 1
    print(solution({1, 3, 2, 4, 2}));     // 1, 2, 3
    return 0;
}
```