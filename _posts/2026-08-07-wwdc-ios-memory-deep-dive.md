---
title: "[WWDC] iOS Memory Deep Dive"
date: 2026-08-07
tags: []
---

## Why reduce memory

메모리를 줄여야 하는 이유는 사용자 경험이 좋아지기 때문입니다. 앱 실행 속도가 빨라지고 시스템 전체의 속도도 향상됩니다. 메모리를 줄인다는 것은 실질적으로 메모리 사용량(footprint)을 줄인다는 뜻입니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T050932-2.png)

메모리 페이지는 프로세스가 사용하는 가상 메모리를 일정 크기의 블록으로 나눈 것을 의미합니다. 페이지는 heap에서 여러 객체를 포함할 수 있고 어떤 객체는 여러 페이지에 걸쳐 존재하기도 합니다. 일반적으로 16KB 크기를 가지며 clean하거나 dirty해질 수 있습니다.



&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T045950-2.png)

Pages 앱 기준 앱의 메모리 사용은 실제로 페이지 수에 페이지 크기를 곱한 값입니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T051111-2.png)

그렇다면 클린 페이지와 더러운 페이지가 무엇일까요?

예로 들자면 위처럼 20,000개의 정수를 저장하는 배열을 할당한다고 가정해봅시다. 해당 배열을 위해 6개의 페이지가 할당되었고, 할당되었을 초기를 꺠끗한 상태라고부릅니다.

하지만 배열에서 어떠한 인덱스에 데이터를 write 한다면 (데이터를 버퍼에 쓰기 시작한다면) 해당 페이지는 더러워집니다. 데이터가 쓰이지 않은 곳은 클린한 상태로 남아있지만 쓰인 곳은 더러운 페이지라고 부릅니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T051357-2.png)

**메모리 매핑된 파일(memory-mapped files)**라는 개념도 있습니다.

memory-mapped files는 디스크에 존재하는 파일을 메모리에 직접 매핑해서, 마치 메모리에서 데이터를 읽고 쓰는 것처럼 파일을 다루는 기술입니다. 즉 운영체제가 파일을 가상 메모리에 매핑하고, 이를 통해 애플리케이션이 디스크 데이터를 직접 접근하는 것처럼 사용하는 것입니다.

읽기 전용 파일은 언제나 클린 페이지로 유지되고(언제나 삭제 가능, 필요시 디스크에서 다시 읽음) 쓰는 것이 가능한 파일은 더러운 페이지가 되어 이후 디스크에 기록됩니다. 커널은 이러한 파일들을 RAM으로 로드하거나 디스크로 내리는 작업을 관리합니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T051739-2.png)

일반적인 앱의 메모리 프로필에는 더러운 메모리(dirty memory), 압축된 메모리(compressed memory), 그리고 깨끗한 메모리(clean memory) 섹션이 있습니다.

&nbsp;

#### Clean Memory

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T051803-2.png)

깨끗한 메모리는 시스템이 페이지에서 제거할 수 있는 데이터입니다. 앞서 설명한 memory-mapped files들이 해당되며, 이미지, 데이터 블롭, 트레이닝 모델 등이 포함될 수 있습니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T051953-2.png)

또한 프레임워크도 깨끗한 메모리를 포함할 수 있습니다.

모든 프레임워크는 DATA CONST 섹션을 가지고 있는데, 변경되지 않는 상수 데이터를 저장하는 메모리 영역이기 때문에 일반적으로 깨끗한 상태입니다.

하지만 런타임에서 특정 조작을 수행하면 더러워질 수 있습니다. 예를 들어 메서드 스위즐링(Method Swizzling)은 런타임에 기존 메소드를 다른 메서드로 교체하는 런타임 변형 기법입니다.

&nbsp;

#### Dirty memory

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T052230-2.png)

더러운 메모리는 앱이 직접 데이터를 기록한 메모리입니다. 즉, 앱이 메모리에 데이터를 썼기 때문에 시스템이 이를 페이지에서 제거할 수 없습니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T052312-2.png)

더러운 메모리에 포함될 수 있는 데이터는 다음과 같습니다.

- 객체(Object): 앱에서 할당한 객체들 (예: 문자열, 배열 등)
- 디코딩된 이미지 버퍼(Decoded Image Buffers): 이미지는 저장될 때 압축된 상태로 존재하지만, 디코딩되면 더러운 메모리가 됨
- 프레임워크(Frameworks): 프레임워크에는 data 섹션과 data-dirty 섹션이 있고, 항상 더러운 메모리로 계산됨

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T052533.png)

프레임워크와 앱이 사용하는 메모리는 더러운 메모리로 남을 수밖에 없습니다. 그래서 싱글톤을 사용하거나 Global initializer를 최소화해서 더러운 메모리 사용량을 최대한 줄이는 것이 좋습니다.

- 싱글톤은 생성된 이후 메모리에서 계속 유지되고 추가적인 할당을 줄일 수 있음.
- Global initializer는 프레임워크가 링크되거나 클래스가 로드될 때 실행됨. 이를 최소화하면 메모리 사용량을 줄이는 데 도움됨.

&nbsp;

#### Compressed Memory

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T052816-2.png)

일반적으로 운영체제들은 Swap 방식을 사용합니다.

Swap은 물리 메모리가 부족한 경우 RAM의 데이터를 디스크에 저장하는 방식을 말합니다. iOS는 7부터 이러한 Swap 대신 **메모리 압축기(Memory Compressor)**를 사용합니다. (Swap의 경우, 느리고, SSD에 데이터를 자주 쓰면 수명이 줄어들 수 있다는 단점 존재)

Memory Compressor는 RAM이 부족할 때 사용하지 않는 메모리를 압축해서 저장하는 기술입니다. 그렇지만, **해당 데이터에 접근하게 되면 압축했던 메모리가 다시 풀려나기 때문에**, 메모리 사용량이 증가할 수도 있습니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T052950-2.png)

예시로 캐싱을 위해 사용된 딕셔너리를 생각해 봅시다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T053008-2.png)

- 딕셔너리는 3개의 페이지를 차지하고 있었습니다.
- 그런데, 이 데이터에 한동안 접근하지 않았던 시스템은 이를 압축하여 하나의 페이지로 줄일 수 있습니다.
- 압축된 덕분에 추가적인 메모리 공간이 확보됩니다.
- 하지만, 추후 이 데이터에 접근하면 다시 압축이 풀리면서 원래 크기로 복원됩니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T053149-2.png)

메모리 경고는 항상 앱 자체의 문제로 인해 발생하는 것이 아닙니다.

예를 들어, 메모리가 적은 기기에서 전화와 같은 어떠한 기능이 수행될 경우, 메모리 경고가 발생할 수 있습니다. 이 때, 앱이 강제로 종료되는 문제가 발생할 수 있습니다. iOS에서는 Memory Compressor를 사용하기 때문에, **메모리를 해제하는 것이 반드시 메모리 사용량을 줄이는 것이 아닙**니다. 어떤 경우에는 메모리를 해제한 이후에 더 많은 메모리를 사용하게 되는 상황도 발생할 수도 있습니다.

따라서 메모리 해제를 어떻게 해야 하는가도 중요한 쟁점입니다.

&nbsp;

#### 좋은 방식

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T053329-2.png)

예를 들어 일정 기간 동안 캐싱을 중지하거나, 백그라운드 작업을 조절하는 방식으로 메모리 사용량을 관리할 수 있습니다.

&nbsp;

#### 잘못된 메모리 관리 방식

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T053418-2.png)

메모리 해제가 오히려 더 많은 메모리 사용량을 야기하는 케이스를 살펴보겠습니다. 많은 개발자들이 메모리 경고를 받으면 캐시를 완전히 비우는 방식을 사용합니다. 그러나 앞서 이야기한 압축된 딕셔너리 예제를 떠올려 봅시다.

- 캐시에서 모든 객체를 제거하면 시스템은 다시 압축을 풀면서 메모리를 원래 크기로 확장합니다.
- 따라서, 오히려 메모리 사용량이 증가할 수 있습니다.

이러한 점을 고려해서, 메모리 경고가 발생하면 캐시를 조금씩 줄이거나, 일정한 비율로 줄이는 방식을 선택하는 것이 좋습니다.

&nbsp;

#### 캐싱의 중요성

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T053811-2.png)

캐싱은 CPU가 동일한 연산을 반복하지 않도록 하는 것이 목적입니다.

그러나 너무 많은 데이터를 캐싱하면 메모리 사용량이 증가하면서 시스템 성능이 저하될 수 있기에 적절한 균형을 이루는 것이 중요합니다. NSCache를 이용하면 효율적으로 캐싱을 관리할 수 있습니다.

- NSCache는 Thread-Safe한 방식으로 객체를 캐싱할 수 있음
- 자동으로 캐시된 객체를 삭제할 수 있는 기능 존재
- 메모리 부족 상황에서는 시스템이 알아서 NSCache에 저장된 데이터를 제거할 수도 있음

&nbsp;

#### Memory FootPrint

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054100-2.png)

앞서 이야기한 것처럼, 앱의 메모리는 더러운 메모리(Dirty Memory)와 압축된 메모리(Compressed Memory)가 차지하고 있습니다. 깨끗한 메모리(Clean Memory)는 실제로 시스템 메모리에 포함되지 않기 때문에, 신경쓰지 않아도 됩니다.

모든 앱은 **메모리 사용량 제한(Footprint Limit)**이 존재합니다. 일반적인 앱에서는 이 제한이 상대적으로 높지만, 기기에 따라 다르다고 합니다. 예를 들어, 1GB RAM을 가진 기기에서 사용할 수 있는 메모리는 당연히 4GB RAM을 가진 기기보다 적습니다. 또한, Extensions의 경우에는 훨씬 적은 limit를 가지고 있습니다.

만약 앱이 이 제한을 초과한다면 아래처럼 됩니다.

- 시스템이 EXC\_RESOURCE EXCEPTION를 발생시킵니다.
- 이 예외가 발생하면, 앱이 강제 종료될 수 있습니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054412-2.png)

앱의 메모리 사용량을 프로파일링할 수 있는 도구들입니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054439-2.png)

앱을 실행하다가 Xcode에서 메모리 사용량이 증가하는 것이 확인된다면 Instruments를 활용해 앱의 메모리 프로파일을 조사할 수 있습니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054514-2.png)

다음과 같이 네 가지 기능이 있습니다.

- Allocations → 앱에서 힙(heap) 할당을 프로파일링
- Leaks → 메모리 누수(leaks) 감지
- VM Tracker (가상 메모리 트래커)
- Virtual Memory Trace (가상 메모리 추적기)

&nbsp;

#### **VM Tracker (가상 메모리 트래커)**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054557-2.png)

앞서 계속 설명했던 것처럼, iOS의 메모리는 더러운 메모리(Dirty Memory)와 압축된 메모리(Compressed Memory)로 구분됩니다. VM Tracker는 이를 효과적으로 프로파일링하는 데 아주 유용하고, 앱이 실제로 얼마나 많은 더러운 메모리를 차지하는지 살펴볼 수 있습니다.

- Dirty (더러운 메모리)
- Swapped (압축된 메모리, iOS에서는 Compressed Memory)
- Resident Size (현재 앱이 사용하는 실제 메모리 크기)

&nbsp;

#### **VM Memory Trace (가상 메모리 추적기)**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054703-2.png)

VM Memory Trace로 앱의 가상 메모리 시스템의 성능을 분석할 수 있습니다.  By Operation 탭을 확인하면,

- 페이지 캐시 히트(Page Cache Hits): 요청한 데이터가 이미 메모리에 있음
- 페이지 제로 필(Page Zero Fills): 새로운 메모리를 할당할 때, 0으로 초기화하는 과정

과 같은 가상 메모리 시스템의 동작을 상세히 볼 수 있습니다.

&nbsp;

#### **EXC\_RESOURCE 예외 발생 시**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054737-2.png)

앱이 메모리 한계를 초과하면 EXC\_RESOURCE EXCEPTION이 발생합니다. Xcode 10에서는 이 예외를 자동으로 감지하고 앱을 일시 정지하는데, 이 때 Memory Debugger를 실행해서 문제를 바로 살필 수 있습니다.

&nbsp;

#### **메모리 디버거 (Memory Debugger)**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054757-2.png)

메모리 디버거(Memory Debugger)로 앱의 객체 간의 참조(reference), 순환 참조(retain cycles), 메모리 누수(leaks) 등을 조사할 수 있습니다. Memgraph 파일으로는 앱의 메모리 사용량을 시각적으로 분석할 수 있습니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054811.png)

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054811-2.png)

만약 앱이 실행되던 중 EXC\_RESOURCE EXCEPTION이 발생했다면 먼저, 가장 기본적인 도구인 vmmap을 사용할 수 있습니다. 앱의 전체적인 메모리 사용량을 요약(Summary)해서 출력해 줍니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054834.png)

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054834-2.png)

- 가상 메모리 크기(Virtual Size): 가상 메모리는 실제 메모리 사용량과 무관할 수 있음, 중요치 않음
- 더러운 메모리(Dirty Memory)
- 압축된 메모리(Swapped, iOS에서는 Compressed) 

앱의 실제 메모리 사용량은 더러운 메모리 + 압축된 메모리이기 때문에, 이 두 값을 확인하는 것이 중요합니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054903-2.png)

여기에서 앱의 메모리 사용량이 급증하는 원인을 알고 싶다면, 특정 라이브러리(dylib)가 원인인지 확인해야 합니다. 이때 grep과 awk를 활용하여 특정 라이브러리의 메모리 사용량을 분석할 수 있습니다. 이렇게 하면, 앱이 사용하는 동적 라이브러리(dylib)들의 전체 더러운 메모리 사용량을 확인할 수 있습니다.

&nbsp;

#### **Leaks 도구 활용**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T054945-2.png)

leaks 명령어는 힙(heap)에서 루트 노드가 없는 객체들을 추적합니다. 즉, 더러운 메모리이면서 절대 해제되지 않는 객체를 찾을 수 있습니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055015-2.png)

  이제 메모리 디버거에서 순환 참조가 발생한 객체를 확인해보겠습니다. 위와 같이 누수된 객체들과 해당 객체들이 속한 retain cycle을 표시해줍니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055035-2.png)

또한, malloc stack logging이 활성화된 경우, 메모리 할당 당시의 호출 스택(Backtrace)을 확인할 수도 있습니다.

&nbsp;

#### **Heap(힙 분석)**

메모리가 많이 사용되고 있을 때 vmmap을 확인해보면 heap의 크기가 매우 클 수 있습니다. 이때 heap 툴을 사용해서 어떤 객체들이 얼마나 할당되었는지 확인할 수 있습니다.   
(기본적으로 객체 개수 기준으로 정렬되며, 특정 객체의 크기가 너무 클 경우 sortBySize로 객체 크기 기준으로 정렬을 수행할 수 있습니다.)

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055224-2.png)

메모리 누수의 원인을 찾고 싶다면, heap 명령어에 addresses 플래그를 사용하면 특정 클래스의 모든 인스턴스 주소를 확인할 수 있습니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055233-2.png)

malloc stack logging을 활성화하면 메모리 할당 시점의 backtrace를 기록할 수 있습니다. 

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055247.png)

이를 활용해서 malloc history 명령어로 특정 메모리 주소가 어디에서 할당되었는지 추적할 수 있습니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055300-2.png)

(예제에서는 NoirFilter의 apply 메서드가 NSConcreteData 객체를 생성하면서 메모리를 과도하게 사용하고 있음이 발견되었습니다.)

&nbsp;

#### **메모리 분석을 위한 3가지 접근 방식**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055326-2.png)

1. 객체가 언제 생성되었는가? → malloc history
2. 특정 객체를 참조하는 것은 무엇인가? → leaks
3. 객체의 크기가 얼마나 큰가? → vmmap 또는 heap

우선 vmmap -summary \[Memgraph 파일\]를 실행한 뒤, 가장 큰 값을 차지하는 메모리 영역을 찾아 분석을 시작하면 됩니다.

&nbsp;

#### **Images**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055357-2.png)

이미지는 메모리 관점에서 중요합니다. 이미지에서 가장 중요한 점은 메모리 사용량이 파일 크기와 관련이 없다는 것입니다. 이미지의 메모리 사용량은 이미지 크기(픽셀 단위)에 따라 결정되기 때문입니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055454-2.png)

예를 들어 iPad 앱의 배경화면으로 사용할 이미지를 가지고 있다고 가정하겠습니다. 이 이미지의 크기는 2048 x 1536 픽셀이며, 파일 크기는 590KB입니다.그렇다면 이 이미지가 메모리에서 차지하는 크기는 590KB일까요?

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055532-2.png)

정답은 10MB입니다. 이미지를 GPU에서 사용할 수 있도록 변환하는 과정이 필요하기 때문인데요.

&nbsp;

#### 이미지 처리 과정

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055612-2.png)

iOS에서 이미지를 사용하려면 3단계를 거칩니다.

1. 로딩(Load) → JPEG 파일을 메모리에 로드 (590KB)
2. 디코딩(Decode) → GPU에서 사용할 수 있도록 압축 해제 (10MB)
3. 렌더링(Render) → 최종적으로 화면에 표시

이때 디코딩 단계에서 이미지가 압축 해제되면서 메모리 사용량이 급증하게 되는 것입니다.

&nbsp;

#### **Image-rendering formats**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T055955-2.png)

이미지의 메모리 사용량은 픽셀당 사용되는 바이트 수(bytes per pixel)에 따라 달라집니다. 가장 일반적인 포맷은 SRGB (Standard RGB)이며, 각 픽셀당 4바이트(1바이트씩 R, G, B, Alpha)를 차지합니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060011-2.png)

그러나, 더 많은 메모리를 사용하는 광색역(Wide Color Format) 포맷도 있습니다. 더 정밀한 색 표현을 위해 픽셀당 8바이트를 사용합니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060239-2.png)

반대로, 메모리를 절약할 수 있는 포맷도 있습니다.

- Grayscale + Alpha (1픽셀당 2바이트) → 메모리 50% 절약
- Alpha Only (A8 포맷) (1픽셀당 1바이트) → 메모리 75% 절약

&nbsp;

#### **Picking the right format**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060317-2.png)

이러한 이미지 포맷을 수동으로 선택할 필요 없이, 이를 자동으로 최적화하는 UIImageGraphicsRenderer API를 사용할 수 있습니다. 기존 사용했던 UIGraphicsBeginImageContextWithOptions은 무조건 4바이트(SRGB) 포맷을 사용했는데, iOS 10부터 제공되는 UIGraphicsImageRenderer API를 사용하면 iOS가 자동으로 가장 적절한 포맷을 선택해줍니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060348-2.png)

위와 같이, 불필요한 메모리 사용 없이 최적의 포맷(A8 포맷 등)을 자동으로 적용합니다.

&nbsp;

#### **이미지 다운샘플링 (Downsampling)**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060420-2.png)

고해상도 이미지를 축소할 때는 어떻게 해야 할까요?

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060516-2.png)

UIImage는 전체 이미지를 메모리에 로드한 후 축소하기 때문에, 직접 사용해서 축소하면 메모리 사용량이 급증할 수 있습니다. 이를 방지하려면, ImageIO 프레임워크를 사용하여 이미지를 스트리밍 방식으로 축소하면 됩니다.

&nbsp;

#### **Optimizing when in background**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060557-2.png)

앱이 백그라운드로 전환될 때 여전히 메모리에 큰 이미지가 남아 있다면, 불필요한 메모리 사용이므로 자동으로 해제하는 것이 좋습니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060607-2.png)

첫번째는 앱이 백그라운드로 갈 때 불필요한 메모리를 자동으로 해제하는 방식으로, 시스템 리소스를 절약할 수 있습니다.

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060710-2.png)

두번째로는 탭뷰나 네비컨에서 화면 전환 후 보이지 않는 이미지가 계속 메모리에 남아 있다면, 불필요한 메모리 사용이므로 뷰가 사라질 때 해제하는 것이 좋습니다. 위와 같이, 사용자가 화면을 이동할 때 불필요한 메모리를 자동으로 해제하는 방식입니다.

&nbsp;

#### **Demo**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060816.png)

NASA에서 제공하는 고해상도 태양계 이미지를 가져와, 필터를 적용하는 데모 앱이 소개되었는데요. 강연에서 주목한 세 가지 문제점은 다음과 같습니다.

- 모든 기기가 2GB RAM을 가지고 있는 건 아니다.
  - 개발 환경에서는 2GB의 메모리가 있지만, 1GB RAM을 가진 기기에서 실행하면 앱이 이미 강제 종료될 가능성이 크다.
- iOS는 단순히 앱의 메모리 사용량만 보고 강제 종료를 결정하지 않는다.
  - 시스템에서 다른 프로세스가 차지하는 메모리와 전체적인 리소스 사용량을 함께 고려한다.
  - 현재 빨간색 영역이 아니라고 해도 앱이 종료될 수 있다.
- 앱이 과도한 메모리를 차지하면 사용자 경험이 최악이 된다.
  - vmmap을 확인해 보니, 앱이 실행되면서 다른 앱들은 모두 운영체제에 의해 종료되었다.
  - 즉, 사용자가 다른 앱으로 전환할 때 모든 앱이 다시 실행되어야 한다.
  - 결과적으로 앱 전환 속도가 느려지고 사용자의 불만을 초래할 수 있다.

&nbsp;

#### **Memgraph**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060937-2.png)

Memgraph 파일을 확인하기 위해 몇 가지 디버깅 방법을 사용할 수 있겠습니다.

1. 메모리 누수(Leaks) 확인

- Leaks 필터를 적용해봤는데 누수는 발견되지 않음
- 누수가 없다면, 불필요한 객체가 많거나 특정 객체가 너무 커서 메모리를 많이 차지하는 경우일 가능성이 큼

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T060958-2.png)

2. 객체 개수 확인

- 각 클래스별로 딱 한 개의 객체만 존재하여 불필요한 객체가 많지는 않음

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061015-2.png)

3. 객체 크기 확인

- Memory Inspector를 통해 각 객체의 크기를 확인했지만, 모두 작은 크기(32바이트 \~ 1500바이트)임

Memgraph에서 직접적인 문제를 찾을 수 없을 때, command line으로 더 깊이 분석합니다.

&nbsp;

#### **command line 메모리 분석 (vmmap, leaks, malloc history)**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061037-2.png)

**1. vmmap 요약 (vmmap -summary)**

- vmmap 명령어를 사용하여 어떤 부분이 가장 많은 메모리를 사용하고 있는지 확인
- 주의 깊게 봐야 할 두 가지 열
  1. Dirty - 앱이 실제로 사용하는 메모리 크기
  2. Swapped (Compressed) - 압축된 상태로 저장된 메모리
- 분석
  - CG Image 영역이 가장 많은 메모리를 차지하고 있음
  - IOSurface, MALLOC LARGE도 다수 사용 중이지만, 주요 문제는 CG Image임

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061112-2.png)

**2. CG Image 관련 가상 메모리 영역 확인 (vmmap | grep CGImage)**

- grep을 사용하여 CG Image와 관련된 메모리 블록만 필터링
- 가장 큰 CG Image 영역의 시작 주소를 확인하여 추가 분석 진행

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061137-2.png)

**3. 해당 메모리 블록을 참조하는 객체 찾기 (leaks --traceTree)**

- leaks --traceTree 명령어를 사용하여, CG Image 메모리 블록을 참조하고 있는 객체 트리 출력

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061143-2.png)

- Core Image 필터 관련 클래스(CIImage, CIFilter 등)가 참조 중
- Core Image 관련 객체들이 계속 유지되고 있음

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061214-2.png)

**4. 객체의 생성 시점 확인 (malloc history)**

- malloc history 명령어를 사용하여, 해당 메모리 블록이 언제, 어디서 생성되었는지 백트레이스를 추적
- 결과적으로 NoirFilter의 apply() 메서드에서 메모리를 과도하게 사용하고 있음을 확인

&nbsp;

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061225-2.png)

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061228-2.png)

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061235-2.png)

&nbsp;

#### **메모리 최적화 방법**

 원인을 알았으니, 이제는 메모리를 최적화할 수 있습니다.

&nbsp;

**1. 이미지 크기 줄이기**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061251-2.png)

- 원본 이미지 크기가 15,000 x 13,000 이었기 때문에,
- iPhone X에서 3x 해상도이므로, 실제 메모리 사용량은 15,000 × 13,000 × 3 × 3 × 4 = 7.5GB

   

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061321-2.png)

따라서, 필터를 적용하기 전 이미지 크기를 뷰 크기로 축소하여 메모리 사용량을 줄이고, CGImageSourceCreateThumbnailAtIndex API를 사용하여 이미지를 바로 다운샘플링하는 방법으로 수정하고자 했습니다.

**2. UIGraphics API 최적화**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061333-2.png)

- as-is: UIGraphicsBeginImageContextWithOptions() 사용
- to-be: UIGraphicsImageRenderer() 사용

&nbsp;

**3. 불필요한 이미지 메모리 해제**

- 백그라운드로 전환될 때 불필요한 이미지 해제

&nbsp;

#### **Summary**

![붙여넣은 이미지](/assets/img/2026-08-07-wwdc-ios-memory-deep-dive/pasted-image-20260807T061404-2.png)

1. 메모리는 한정되어 있고 공유되기에, 앱이 필요 이상으로 메모리를 사용하면 시스템 전체에 영향을 줌
2. 메모리 리포트로, 디버깅 중 메모리 사용량 변화를 감지하기
3. UIImage는 OS에서 적절한 포맷을 선택하도록 UIImage GraphicsRenderer를 사용할 것
4. ImageIO를 활용한 다운샘플링
5. 화면에 보이지 않는 이미지는 unload해야 됨, 불필요한 메모리를 유지하면 사용자 경험이 저하되므로

&nbsp;

## Reference

- [https://developer.apple.com/kr/videos/play/wwdc2018/416/](https://developer.apple.com/kr/videos/play/wwdc2018/416/)

&nbsp;