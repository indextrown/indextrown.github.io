---
title: "[TableView] 12. 테이블뷰 제네릭 CustomCombineDataSource"
tags: 
- UIKit
- TableView
header: 
  teaser: 
typora-root-url: ../
---

<!-- <img src="/assets/img/2025-05-08-[UIKit]-tableView2/1.png" alt="1" width="50%"> -->

<!-- <img src="{{ '/assets/img/2025-05-08-[UIKit]-tableView2/1.png' | relative_url }}" alt="이미지" width="30%"> -->

## 테이블뷰 제네릭 CustomCombineDataSource

### CustomCombineDataSource.swift

 ```swift
 //
 //  CustomCombineDataSource.swift
 //  UITableViewTutorial
 //
 //  Created by 김동현 on 5/15/25.
 //
 
 import UIKit
 
 /*
 class CustomCombineDataSource<T, G>: NSObject, UITableViewDataSource {
     
     // 멤버 변수
     var dataList: [T] = []
     
     var testDataList: [G] = []
 */
 
 class CustomCombineDataSource<Item>: NSObject, UITableViewDataSource {
     
     // 셀을 만드는 클로저
     
     // 멤버 변수
     var dataList: [Item] = []
     
     override init() {
         super.init()
     }
     
     // MARK: - Combine 이벤트로 들어온 데이터랑 테이블뷰랑 연결시켜주는 지점
 
     /// 변경된 데이터를 받아서 테이블뷰에 적용한다
     /// - Parameters:
     ///   - updatedDataList: 외부에서 변경된 Combine Publisher로 들어온 데이터를 내 DataSource가 가진 data로 변경하기 위한 매개변수
     ///   - tableView: 리로드 대상 테이블뷰
     func pushDataList(_ updatedDataList: [Item], to tableView: UITableView) {
         tableView.dataSource = self
         self.dataList = updatedDataList
         tableView.reloadData()
     }
     
     // MARK: - 테이블뷰 데이터 소스 관련(변경이 된 데이터를 데이터소스로 넘겨받아서 reloadData를 하는 목적 
     
     /// 하나의 섹션에 몇개의 rows가 있냐
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return dataList.count
     }
 
     /// 각 셀에 대한 내용을 구성하여 반환 -> 셀의 종류를 정하기 - 테이블뷰 셀을 만들어서 반환해라
     /// - indexPath: 셀의 위치를 나타내는 인덱스 경로
     /// - returns: 구성된 UITableViewCell 객체
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 //        /// 기본 스타일의 셀 생성 (textLabel과 detailTextLabel 포함)
 //        /// let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
 //
 //        // [guard let] 방식
 //        guard let cell = tableView.dequeueReusableCell(withIdentifier: CodeCell.reuseIdentifier, for: indexPath) as? CodeCell else {
 //            return UITableViewCell()
 //        }
 //        
 //        if let dataList = dataList as? [DummyData] {
 //            let cellData: DummyData = dataList[indexPath.row]
 //
 //            /// 셀의 주 텍스트를 더미 데이터에서 가져오기
 //            cell.titleLabel.text = cellData.title
 //
 //            /// 셀의 서브 타이틀 설정
 //            cell.bodyLabel.text = cellData.body
 //
 //            cell.detailTextLabel?.numberOfLines = 0
 //        }
 //        
 //        if let dataList = dataList as? [IndexData] {
 //            let cellData: IndexData = dataList[indexPath.row]
 //
 //            /// 셀의 주 텍스트를 더미 데이터에서 가져오기
 //            cell.titleLabel.text = cellData.title
 //
 //            /// 셀의 서브 타이틀 설정
 //            cell.bodyLabel.text = cellData.body
 //
 //            cell.detailTextLabel?.numberOfLines = 0
 //        }
 //        
 //        return cell
     }
 }
 
 
 
 ```

tableView()의 각 매개변수 tableView, indexPath, 그리고 셀에 대한 데이터 cellData을 조합을 하여 UITableViewCell 즉 셀을 만들자. 기존 tableView() 내부를 전부 주석처리를 하고 주석분을 만드는 클로저를 두자. 함수 = 클로저 = 논리이다.  즉 논리 = 로직이다. 다시말해 로직을 클로저로 빼자.

