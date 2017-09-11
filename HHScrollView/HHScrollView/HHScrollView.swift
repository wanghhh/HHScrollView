//
//  HHScrollView.swift
//  HHScrollView
//
//  Created by 王龙辉 on 2017/8/13.
//  Copyright © 2017年 onePieceDW. All rights reserved.
//  http://www.jianshu.com/p/fee4d10feefd

import UIKit
fileprivate let placeholder:String = "ic_bannerPlace"
@objc protocol HHScrollViewDelegate:NSObjectProtocol {
    //点击代理方法
    @objc optional func hhScrollView(_ scrollView: HHScrollView, didSelectRowAt index: NSInteger)
}

fileprivate let collectionViewCellId = "collectionViewCellId"
class HHScrollView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource {
    
    //代理
    weak var hhScrollViewDelegae:HHScrollViewDelegate?
    
    //分页指示器页码颜色
    var pageControlColor:UIColor?
    
    //分页指示器当前页颜色
    var currentPageControlColor:UIColor?
    
    //分页指示器位置
    var pageControlPoint:CGPoint?
    
    //分页指示器
    fileprivate var pageControl:UIPageControl?
    
    //自动滚动时间默认为3.0
    var autoScrollDelay:TimeInterval = 3 {
        didSet{
            removeTimer()
            setUpTimer()
        }
    }
    
    //图片是否来自网络,默认是
    var isFromNet:Bool = true
    
    //占位图
    var placeholderImage:String = placeholder
    
    //设置图片资源url字符串。
    var imgUrls = NSArray(){
        didSet{
            pageControl?.numberOfPages = imgUrls.count
            self.reloadData()
        }
    }
    fileprivate var itemCount:NSInteger?//cellNum
    fileprivate var timer:Timer?//定时器
    //便利构造方法
    convenience init(frame:CGRect) {
        self.init(frame: frame, collectionViewLayout: HHCollectionViewFlowLayout.init())
    }
    
    convenience init(frame:CGRect,imageUrls:NSArray) {
        self.init(frame: frame, collectionViewLayout: HHCollectionViewFlowLayout.init())
        imgUrls = imageUrls
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = UIColor.white
        self.dataSource = self
        self.delegate = self
        self.register(HHCollectionViewCell.self, forCellWithReuseIdentifier: collectionViewCellId)
        
        setUpTimer()
        //在collectionView加载完成后默认滚动到索引为imgUrls.count的位置，这样cell就可以向左或右滚动
        DispatchQueue.main.async {
            //注意：在轮播器视图添加到控制器的view上以后，这样是为了将分页指示器添加到self.superview上(如果将分页指示器直接添加到collectionView上的话，指示器将不能正常显示)
            self.setUpPageControl()
            let indexpath = NSIndexPath.init(row: self.imgUrls.count, section: 0)
            //滚动位置
            self.scrollToItem(at: indexpath as IndexPath, at: .left, animated: false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //itemNum 设置为图片数组的n倍数(n>1)，当未设置imgUrls时，随便返回一个数6
        return imgUrls.count > 0 ? imgUrls.count*1000 : 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:HHCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellId, for: indexPath) as! HHCollectionViewCell
        cell.backgroundColor = UIColor.lightGray
        
        if imgUrls.count > 0 {
            if let urlStr = self.imgUrls[indexPath.row % imgUrls.count] as? String {
                if isFromNet {
                    let url:URL = URL.init(string: urlStr)!
                    cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage.init(named: placeholderImage), options: SDWebImageOptions.refreshCached)
                }else{
                    cell.imageView?.image = UIImage.init(named: urlStr)
                }
            }
        }
        
        itemCount = self.numberOfItems(inSection: 0)
        return cell
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if imgUrls.count != 0 {
            hhScrollViewDelegae?.hhScrollView!(self, didSelectRowAt: indexPath.row % imgUrls.count)
        }else{
            print("图片数组为空！")
        }
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //当前的索引
        var offset:NSInteger = NSInteger(scrollView.contentOffset.x / scrollView.bounds.size.width)
        
        //第0页时，跳到索引imgUrls.count位置；最后一页时，跳到索引imgUrls.count-1位置
        if offset == 0 || offset == (self.numberOfItems(inSection: 0) - 1) {
            if offset == 0 {
                offset = imgUrls.count
            }else {
                offset = imgUrls.count - 1
            }
        }
        //跳转方式一：
        //        let indexpath = NSIndexPath.init(row: offset, section: 0)
        //        //滚动位置
        //        self.scrollToItem(at: indexpath as IndexPath, at: .left, animated: false)
        //跳转方式二：
        scrollView.contentOffset = CGPoint.init(x: CGFloat(offset) * scrollView.bounds.size.width, y: 0)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        removeTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        setUpTimer()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 设置分页指示器索引
        let currentPage:NSInteger = NSInteger(scrollView.contentOffset.x / scrollView.bounds.size.width)
        let currentPageIndex = imgUrls.count > 0 ? currentPage % imgUrls.count : 0
        self.pageControl?.currentPage = currentPageIndex
    }
    
    //MARK: - ACTIONS
    @objc private func setUpPageControl(){
        pageControl = UIPageControl.init()
        pageControl?.frame = (pageControlPoint != nil) ? CGRect.init(x: (pageControlPoint?.x)!, y: (pageControlPoint?.y)!, width: self.bounds.size.width - (pageControlPoint?.x)!, height: 8) : CGRect.init(x: 0, y: self.frame.maxY - 16, width: self.bounds.size.width, height: 8)
        pageControl?.pageIndicatorTintColor = pageControlColor ?? UIColor.lightGray
        pageControl?.currentPageIndicatorTintColor = currentPageControlColor ?? UIColor.orange
        pageControl?.numberOfPages = imgUrls.count
        pageControl?.currentPage = 0
        
        //一定要将指示器添加到superview上
        self.superview?.addSubview(pageControl!)
    }
    //添加定时器
    @objc private func setUpTimer(){
        timer = Timer.init(timeInterval: autoScrollDelay, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .commonModes)
    }
    //移除定时器
    @objc private func removeTimer(){
        if (timer != nil) {
            timer?.invalidate()
            timer = nil
        }
    }
    
    //自动滚动
    @objc private func autoScroll(){
        //当前的索引
        var offset:NSInteger = NSInteger(self.contentOffset.x / self.bounds.size.width)
        
        //第0页时，跳到索引imgUrls.count位置；最后一页时，跳到索引imgUrls.count-1位置
        if offset == 0 || offset == (itemCount! - 1) {
            if offset == 0 {
                offset = imgUrls.count
            }else {
                offset = imgUrls.count - 1
            }
            
            self.contentOffset = CGPoint.init(x: CGFloat(offset) * self.bounds.size.width, y: 0)
            //再滚到下一页
            self.setContentOffset(CGPoint.init(x: CGFloat(offset + 1) * self.bounds.size.width, y: 0), animated: true)
        }else{
            //直接滚到下一页
            self.setContentOffset(CGPoint.init(x: CGFloat(offset + 1) * self.bounds.size.width, y: 0), animated: true)
        }
    }
    
    deinit {
        removeTimer()
    }
}

//MARK: - 用CollectionViewFlowLayout布局cell
class HHCollectionViewFlowLayout:UICollectionViewFlowLayout{
    //prepare方法在collectionView第一次布局的时候被调用
    override func prepare() {
        super.prepare()//必须写
        collectionView?.backgroundColor = UIColor.white
        //通过打印可以看到此时collectionView的frame就是我们前面设置的frame
        print("self.collectionView:\(String(describing: self.collectionView))")
        // 通过collectionView 的属性布局cell
        self.itemSize = (self.collectionView?.bounds.size)!
        self.minimumInteritemSpacing = 0 //cell之间最小间距
        self.minimumLineSpacing = 0 //最小行间距
        self.scrollDirection = .horizontal;
        
        self.collectionView?.bounces = false //禁用弹簧效果
        self.collectionView?.isPagingEnabled = true //分页
        self.collectionView?.showsHorizontalScrollIndicator = false
        self.collectionView?.showsVerticalScrollIndicator = false
    }
}

//MARK: -自定义cell
class HHCollectionViewCell:UICollectionViewCell{
    var imageView:UIImageView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        //通过打印可以看到此时cell的frame就是我们在flowLayout中设置的结果
        print("self.collectionView:\(String(describing: self))")
        imageView = UIImageView.init(frame: self.bounds)
        imageView?.image = UIImage.init(named: placeholder)
        imageView?.contentMode = .scaleAspectFill
        contentView.addSubview(imageView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
