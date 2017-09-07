//
//  AlbumsListController.swift
//  PhotosDemo
//
//  Created by ChenGuangchuan on 2017/8/11.
//  Copyright © 2017年 CGC. All rights reserved.
//

import UIKit
import Photos

class AlbumsListController: UITableViewController {

    var models: [AlbumsModel] = []
    
    convenience init(models: [AlbumsModel]) {
        self.init(style: .plain)
        self.models = models
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: AlbumsListCell.reusedId, bundle: nil), forCellReuseIdentifier: AlbumsListCell.reusedId)

        tableView.rowHeight = 58
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        tableView.tableFooterView = UIView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
        
        title = "所有相册"
        navigationItem.rightBarButtonItem = rightCancleItem
    
        models = SAAssetsManager.shared.fetchAllAlbums()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
        tableView.cellForRow(at: indexPath)?.isSelected = false
		
		let model = models[indexPath.row]
		
        let ctr = AlbumSelectionController(model: model)
		
		navigationController?.pushViewController(ctr, animated: true)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = models[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumsListCell.reusedId, for: indexPath) as! AlbumsListCell
        cell.albumModel = model
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = .zero
        cell.separatorInset = .zero
    }

}



