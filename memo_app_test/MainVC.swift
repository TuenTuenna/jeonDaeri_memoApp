//
//  ViewController.swift
//  memo_app_test
//
//  Created by Jeff Jeong on 2021/01/24.
//

import UIKit
import SwipeCellKit

class MainVC: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var writeMemoBtn: UIBarButtonItem!
    
    
    //MARK: - Properties
    // 데이터 소스 - 기존의 uitableViewDataSource를 대체함
    var dataSource : UITableViewDiffableDataSource<Section, Memo>!
    
    // 스냅샷 - 현재 데이터 상태
    var snapshot : NSDiffableDataSourceSnapshot<Section, Memo>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("MainVC - viewDidLoad() called ")
//        dummyData.forEach{ print($0.info) }
//
//        for index in (0...30) {
//            dummyData.append(Memo(content: "하핫! - index: \(index)", isDone: false))
//        }

        // UI 초기 설정
        configUI()
        
        // 테이블뷰 설정
        configTableView()
        
        // 데이터 소스 설정
        configDatasource()
        
        
        // 저장된 데이터 가져오기
        if let fetchedMemos = UserDefaultsManager.shared.getMemoList() {
            print("fetchedMemos.count : \(fetchedMemos.count)")
            // 데이터 넣고 화면에 보여주기
            self.setDataAndApply(with: fetchedMemos, false)
        }

    }// viewDidLoad()

    
    @IBAction func writeMemoAction(){
        print("MainVC - writeMemoAction() called")
        self.showNewMemoAC()
//        UserDefaultsManager.shared.setMemoList(with: dummyData)
    }
    
    @IBAction func clearAllMemos(){
        print("MainVC - clearAllMemos() called")
        UserDefaultsManager.shared.clearMemoList()
        clearAllDataAndApply()
    }
    
    fileprivate func configUI(){
        print("MainVC - configUI() called")
        title = "빡코딩 메모"
    }
    
    fileprivate func configTableView(){
        print("MainVC - configTableView() called")
        
        let cellNib = UINib(nibName: MemoItemCell.reuseIdentifier, bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: MemoItemCell.reuseIdentifier)
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        self.tableView.refreshControl = refreshControl
        
    }
    
    @objc fileprivate func handleRefresh(){
        print("MainVC - handleRefresh() called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33, execute: { [weak self] in
            guard let self = self else { return }
            // 저장된 데이터 가져오기
            if let fetchedMemos = UserDefaultsManager.shared.getMemoList() {
                print("fetchedMemos.count : \(fetchedMemos.count)")
                // 데이터 넣고 화면에 보여주기
                self.setDataAndApply(with: fetchedMemos, true)
            }
            self.tableView.refreshControl?.endRefreshing()
        })
    }
    
    fileprivate func configDatasource(){
        print("MainVC - configDatasource() called")
        
        dataSource = UITableViewDiffableDataSource<Section, Memo>(tableView: self.tableView, cellProvider: { (tableView: UITableView, indexPath: IndexPath, item: Memo) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: MemoItemCell.reuseIdentifier, for: indexPath) as! MemoItemCell
            cell.delegate = self
            cell.updateUI(with: item)

            return cell
        })
    }
    
    fileprivate func viewWithImageName(_ imageName: String) -> UIView {
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        return imageView
    }
    
    fileprivate func clearAllDataAndApply(){
        print("MainVC - clearAllDataAndApply() called")
//        snapshot = NSDiffableDataSourceSnapshot<Section, Memo>()
        snapshot.deleteAllItems()
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    fileprivate func deleteMemoAndApply(memoToDelete : Memo){
        print("MainVC - deleteMemoAndApply() called / memoToDelete: \(memoToDelete.info)")
        snapshot = NSDiffableDataSourceSnapshot<Section, Memo>()
        snapshot.deleteItems([memoToDelete])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    fileprivate func setDataAndApply(with data: [Memo], _ animated: Bool){
        print("MainVC - setDataAndApply() called / data: \(data.count)")
        data.forEach{ print($0.info) }
        
        // 스냅샷 준비
        // 빈 스냅샷
        snapshot = NSDiffableDataSourceSnapshot<Section, Memo>()
        
        // 섹션 추가
        snapshot.appendSections([.normal])
        
        // 방금 추가한 섹션에 아이템 넣기
        snapshot.appendItems(data, toSection: .normal)
        
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    fileprivate func showNewMemoAC(){
        print("MainVC - showNewMemoAC() called")
        let ac = UIAlertController(title: "메모 추가하기", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "추가", style: .default) { [unowned ac] _ in
            guard let addedMemo = ac.textFields![0].text else {
                print("작성된 내용이 없습니다")
                return
            }
            print("addedMemo : \(addedMemo)")
            self.addMemo(with: Memo.createNewMemo(with: addedMemo))
        }
        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    /// 추가 얼럿 컨트롤러 보여주기
    fileprivate func showEditAC(){
        print("MainVC - showEditAC() called")
        let ac = UIAlertController(title: "메모 추가하기", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "추가", style: .default) { [unowned ac] _ in
            guard let addedMemo = ac.textFields![0].text else {
                print("작성된 내용이 없습니다")
                return
            }
            print("addedMemo : \(addedMemo)")
            self.addMemo(with: Memo.createNewMemo(with: addedMemo))
        }
        ac.addAction(submitAction)
        ac.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    fileprivate func addMemo(with data: Memo){
        print("MainVC - addMemo() called / data: \(data)")
        
        // 저장된 데이터 가져오기
        
        var fetchedMemos : [Memo] = []
        
        fetchedMemos = UserDefaultsManager.shared.getMemoList() ?? []

        // 가져온 데이터에 새 메모 추가하기
        fetchedMemos.append(data)
        
        // 업데이트 된 데이터 저장하기
        UserDefaultsManager.shared.setMemoList(with: fetchedMemos)
        
        // 테이블뷰 갱신
        self.setDataAndApply(with: fetchedMemos, false)
    }
    
    fileprivate func deleteMemo(at index: Int){
        print("MainVC - deleteMemo() called / index: \(index)")

        var fetchedMemos : [Memo] = []
        
        fetchedMemos = UserDefaultsManager.shared.getMemoList() ?? []
        
        
        
        fetchedMemos.remove(at: index)
        
        // 업데이트 된 데이터 저장하기
        UserDefaultsManager.shared.setMemoList(with: fetchedMemos)
        // 테이블뷰 갱신
        self.setDataAndApply(with: fetchedMemos, false)
    }
    
}

//MARK: - 스와이프 액션들
extension MainVC : SwipeTableViewCellDelegate{
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        switch orientation {
        case .right:
            let deleteAction = SwipeAction(style: .destructive, title: "지우기") { [weak self] action, indexPath in
                guard let self = self else { return }
              // handle action by updating model with deletion
                print("지우는 액션")
                self.deleteMemo(at: indexPath.row)
            }
            deleteAction.image = UIImage(systemName: "trash.fill")
            return [deleteAction]
        case .left:
            let editAction = SwipeAction(style: .default, title: "수정하기") { [weak self] action, indexPath in
                guard let self = self else { return }
              // handle action by updating model with deletion
                print("수정하는 액션")
    //            self.deleteMemo(at: indexPath.row)
            }
            // customize the action appearance
            editAction.image = UIImage(systemName: "pencil.circle")
            return [editAction]
        }
    }
    
  
}

//MARK: - UITableViewDelegate
extension MainVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        let itemToBeDeleted = self.dataSource.itemIdentifier(for: indexPath)
        print("itemToBeDeleted: \(itemToBeDeleted?.info)")
    }
}

//MARK: -  delegate
