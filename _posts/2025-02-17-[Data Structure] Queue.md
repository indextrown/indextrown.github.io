---
title: "[자료구조] Queue"
tags: 
- Data Structure
use_math: true
header: 
  teaser: 
typora-root-url: ../
---


## Queue

```swift
struct DoubleStackQueue<T> {
    private var enqueueStack: [T] = []
    private var dequeueStack: [T] = []
    
    var size: Int {
        return enqueueStack.count + dequeueStack.count
    }
    
    var isEmpty: Bool {
        return enqueueStack.isEmpty && dequeueStack.isEmpty
    }
    
    mutating func enqueue(_ element: T) {
        enqueueStack.append(element)               // O(1)
    }
    
    @discardableResult
    mutating func dequeue() -> T? {
        if dequeueStack.isEmpty {
            dequeueStack = enqueueStack.reversed() // O{n}
            enqueueStack.removeAll()               // O(1)
        }
        return dequeueStack.popLast()              // O(1)
    }
}

@main
struct Main {
    static func main() {
        let times = 1_000_000 // 100만 개 삽입
        var myQueue = DoubleStackQueue<Int>()

        // 🔹 Enqueue 시간 측정
        var startTime = CFAbsoluteTimeGetCurrent()
        for i in 1...times {
            myQueue.enqueue(i) // ✅ 변수명 수정
        }
        var durationTime = CFAbsoluteTimeGetCurrent() - startTime
        print("DoubleStackQueue enqueue time: \(durationTime) seconds")

        // 🔹 Dequeue 시간 측정
        startTime = CFAbsoluteTimeGetCurrent()
        for _ in 1...times {
            myQueue.dequeue() // ✅ 변수명 수정
        }
        durationTime = CFAbsoluteTimeGetCurrent() - startTime
        print("DoubleStackQueue dequeue time: \(durationTime) seconds\n")
    }
}
```

## Result
```bash
DoubleStackQueue enqueue time: 0.25131893157958984 seconds
DoubleStackQueue dequeue time: 0.34246695041656494 seconds
```