//
//  MemoItemCell.swift
//  memo_app_test
//
//  Created by Jeff Jeong on 2021/01/24.
//

import Foundation
import UIKit
import SwipeCellKit

class MemoItemCell: SwipeTableViewCell {
    
    @IBOutlet var checkBtn: UIButton!
    @IBOutlet var contentLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("MemoItemCell - awakeFromNib() called")
        selectionStyle = .none
        
    }
    
    
    
    func updateUI(with data: Memo){
        print("MemoItemCell - updateUI() called / data: \(data.info)")
        contentLabel.text = data.content
        checkBtn.setImage(UIImage(systemName: data.isDone ? "checkmark.circle.fill" : "checkmark.circle"), for: .normal)
    }
    
}
