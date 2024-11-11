//
//  ContentView.swift
//  MVVM
//
//  Created by 김동현 on 10/13/24.
//

/*
// https://velog.io/@chaentopia/iOS-Swift-MVVM-패턴-예제
// https://ios-daniel-yang.tistory.com/entry/iOSSwift-Data-Binding에-대하여-알아보자-Closure-Observable-Combine-MVVM
// https://velog.io/@jyw3927/SwiftUI-MVVM-패턴에-대해
 
 4. mutating 키워드
 struct에서는 프로퍼티를 수정하는 메서드가 있을 때, mutating 키워드가 필요합니다. 이는 구조체가 값 타입이기 때문에, 메서드 내에서 값이 변할 때 새로운 인스턴스를 반환하여 값을 변경하는 방식 때문입니다.
 class에서는 mutating 키워드가 필요하지 않습니다. 참조 타입이기 때문에 메서드에서 값을 수정할 수 있으며, 해당 인스턴스가 참조하는 모든 곳에서 변경된 값을 확인할 수 있습니다.
 성능 비교 요약
 작은 데이터는 구조체가 빠를 수 있습니다. 값 타입이고 스택에서 관리되기 때문에 빠르게 처리할 수 있습니다.
 큰 데이터는 클래스가 유리할 수 있습니다. 복사가 일어나지 않기 때문에 메모리 사용과 성능에서 더 효율적일 수 있습니다.
 클래스는 ARC에 의한 성능 비용이 있을 수 있지만, 참조가 많은 경우 효율적입니다.
 
 */
import SwiftUI

// MARK: - View
struct ContentView: View {
    @ObservedObject private var counterVM: CounterViewModel
    
    init() {
        counterVM = CounterViewModel()
    }
    
    var body: some View {
        Text(counterVM.premium ? "PREMIUM" : "")
            .foregroundColor(Color.green)
           .frame(width: 200, height: 100)
           .font(.largeTitle)

        Text("\(counterVM.value)")
                        .font(.title)
        Button("Increment") {
            self.counterVM.increment()
        }
    }
}

#Preview {
    ContentView()
}


// MARK: - Model
struct Counter {
    var value: Int = 0
    var isPremium: Bool = false
    
    mutating func increment() {
        value += 1
        
        // business logic
        if value.isMultiple(of: 3) {
            isPremium = true
        } else {
            isPremium = false
        }
    }
}

// MARK: - ViewModel
class CounterViewModel: ObservableObject {

    @Published private var counter: Counter = Counter()
    
    var value: Int {
        counter.value
    }
    
    var premium: Bool {
        counter.isPremium
    }
    
    func increment() {
        counter.increment()
    }
}



