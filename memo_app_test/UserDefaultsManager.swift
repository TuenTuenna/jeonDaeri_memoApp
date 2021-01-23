//
//  UserDefaultsManager.swift
//  memo_app_test
//
//  Created by Jeff Jeong on 2021/01/24.
//

import Foundation

class UserDefaultsManager {
    
    enum Key: String, CaseIterable {
        case memoList
    }
    
    static let shared: UserDefaultsManager = {
        return UserDefaultsManager()
    }()
    
    
    //MARK: - 메모 관련
    
    /// 메모 목록 추가 및 저장하기
    /// - Parameter newValue: 저장할 값
    func setMemoList(with newValue: [Memo]){
        print("UserDefaultsManager - setMemoList() called / newValue: \(newValue.count)")
        do {
            let data = try PropertyListEncoder().encode(newValue)
            newValue.forEach{ print("저장될 데이터: \($0.info)") }
            UserDefaults.standard.set(data, forKey: Key.memoList.rawValue)
            UserDefaults.standard.synchronize()
            print("UserDefaultsManager - setMemoList() 메모가 저장됨")
        } catch {
            print("에러발생 setMemoList - error: \(error)")
        }
    } // setMemoList()
    
    
    /// 저장된 메모 목록 가져오기
    /// - Returns: 저장된 값
    func getMemoList() -> [Memo]? {
        print("UserDefaultsManager - getMemoList() called")
        if let data = UserDefaults.standard.object(forKey: Key.memoList.rawValue) as? NSData {
            print("저장된 data: \(data.description)")
            do {
                let memoList = try PropertyListDecoder().decode([Memo].self, from: data as Data)
                return memoList
            } catch {
                print("에러발생 getMemoList - error: \(error)")
            }
        }
        return nil
    } // getMemoList()
    
//    func clearMemo()
    
    func clearMemoList(){
        print("UserDefaultsManager - clearMemoList() called")
        UserDefaults.standard.removeObject(forKey: Key.memoList.rawValue)
    }
    
    func clearAll(){
        print("UserDefaultsManager - clearAll() called")
        Key.allCases.forEach{
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        }
    }
    
}
