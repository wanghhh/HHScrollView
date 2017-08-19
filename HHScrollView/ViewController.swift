//
//  ViewController.swift
//  HHScrollView
//
//  Created by wanglh on 2017/8/13.
//  Copyright © 2017年 onePieceDW. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,HHScrollViewDelegate {

    fileprivate lazy var imageDataSource = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        //准备图片数据，就是图片url字符串
        imageDataSource = loadImages()
        
        //提供两种实例化方法：
        //1.通过frame和imageUrls
//         let scrollView = HHScrollView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200), imageUrls: imageDataSource)
        
        //2.通过frame，后根据网络数据设置imgUrls
        let scrollView = HHScrollView.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 200))
        //设置数据源（图片urlStr）
        //加载本地图片
//        scrollView.isFromNet = false
//        scrollView.imgUrls = ["ic_banner01","ic_banner02","ic_banner03"]
        //默认加载网络图片
        scrollView.imgUrls = imageDataSource
        //设置代理，根据需要要不要监听图片点击
        scrollView.hhScrollViewDelegae = self
        //**********已下属性不设置将按照默认设置显示*************
//        //设置滚动间隔时间
//        scrollView.autoScrollDelay = 3.0
////        //设置页码默认颜色
//        scrollView.pageControlColor = UIColor.darkGray
////        //设置当前页码颜色
//        scrollView.currentPageControlColor = UIColor.orange
//        //设置占位图
//        scrollView.placeholderImage = "ic_place"
//          //设置页码指示器位置
//        scrollView.pageControlPoint = CGPoint.init(x: scrollView.frame.maxX - 130, y: scrollView.frame.maxY - 16)
        
        self.view.addSubview(scrollView)
        
        //模拟延迟8秒设置图片资源
//        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
//            scrollView.imgUrls = self.imageDataSource
//        }
        
        //实例化一个tableview,测试tableview滚动对轮播器的影响
        createTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    @objc private func loadImages() -> NSArray {
        //举个栗子，加载3张网络图片
        return ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1502904177239&di=248e850857f3cf2439e49df2fcbb81bc&imgtype=0&src=http%3A%2F%2Fimg4q.duitang.com%2Fuploads%2Fitem%2F201410%2F26%2F20141026170404_vPBsP.jpeg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1502904177238&di=1d450db9590ee00d6f2f69cb69db2515&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201410%2F26%2F20141026170452_szPAW.jpeg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1502904177237&di=553618513c7e59b99c7e27840d4e2507&imgtype=0&src=http%3A%2F%2F06.imgmini.eastday.com%2Fmobile%2F20160719%2F20160719093731_6b3cbd4a26257b07579859a9b6673839_2.jpeg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1503125647888&di=549cfbda66d5cca96e46308e05b5edfd&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F9%2F5897d10c9e72a.jpg"]
    }
    
    @objc private func createTableView(){
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 264, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 264), style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCellId")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }
    
    //MARK: - HHScrollViewDelegate
    func hhScrollView(_ scrollView: HHScrollView, didSelectRowAt index: NSInteger) {
        print("点击了第\(index)张图片")
    }
    
    //MARK: - UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCellId", for: indexPath)
        cell.textLabel?.text = "我是第\(indexPath.row)行数据，哈哈哈"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("点击了第\(indexPath.row)行数据")
    }
}

