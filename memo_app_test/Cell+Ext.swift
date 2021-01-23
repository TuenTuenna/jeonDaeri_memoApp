//
//  Cell+Ext.swift
//  memo_app_test
//
//  Created by Jeff Jeong on 2021/01/24.
//

import Foundation
import UIKit

// 프로토콜 설정
protocol ReuseIdentifying {
    static var reuseIdentifier: String { get }
}

// 익스텐션으로 정의
extension ReuseIdentifying {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell : ReuseIdentifying {}
