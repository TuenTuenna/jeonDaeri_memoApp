//
//  Memo.swift
//  memo_app_test
//
//  Created by Jeff Jeong on 2021/01/24.
//

import Foundation

// 메모 섹션 - 일반, 즐겨찾기
enum Section {
    case normal, pinned
}

class Memo: NSObject, NSCoding, NSSecureCoding, Codable {
    
    static var supportsSecureCoding: Bool = true
    
    // 고유 아이디
    let uuid: UUID = UUID()
    private (set) var isDone: Bool
    private (set) var content: String
    
    init(content: String,
         isDone: Bool) {
        self.content = content
        self.isDone = isDone
    }
    
    //MARK: 모델 데이터 확인용
    var info : String {
        get{
            return "content: \(content), isDone: \(isDone)"
        }
    }
    // Hashable 프로토콜 준수용
    static func == (lhs: Memo, rhs: Memo) -> Bool {
        lhs.uuid == rhs.uuid
    }
    // NSCoding 을 사용할때 필요한 것들
    func encode(with coder: NSCoder) {
        coder.encode(self.content, forKey: "content")
        coder.encode(self.isDone, forKey: "isDone")
    }
    
    required convenience init?(coder decoder: NSCoder) {
        guard let content = decoder.decodeObject(forKey: "content") as? String,
              let isDone = decoder.decodeObject(forKey: "isDone") as? Bool
              else { return nil }
        self.init(content: content, isDone: isDone)
    }
    
    static func createNewMemo(with newValue: String) -> Memo{
        print("Memo - createNewMemo() called / newValue: \(newValue)")
        return Memo(content: newValue, isDone: false)
    }
    
}

