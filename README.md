# HHScrollView
Swift版无限图片轮播器，UICollectionView实现
先看下效果图：

![Image text](https://github.com/wanghhh/HHScrollView/blob/master/gitHubImage/Untitled2.gif)

轮播器调用方法：
在控制器的viewDidLoad() 中：

    //准备图片数据，就是图片url字符串
    imageDataSource = loadImages()
    
    //提供两种实例化方法：
    //1.通过frame和imageUrls
    //let scrollView = HHScrollView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200), imageUrls: imageDataSource)
    
    //2.通过frame，后根据网络数据设置imgUrls
    let scrollView = HHScrollView.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 200))
    //设置数据源（图片urlStr）******
    //加载本地图片
    //scrollView.isFromNet = false
    //scrollView.imgUrls = ["ic_banner01","ic_banner02","ic_banner03"]
    //默认加载网络图片
    scrollView.imgUrls = imageDataSource
    //设置代理，根据需要要不要监听图片点击
    scrollView.hhScrollViewDelegae = self
功能实现：

1、Swift+UICollectionView实现自动无限轮播，可手动拖动

2、页码显示，可以自定义页码指示器位置、颜色

3、轮播间隔时间等属性设置

基本原理：
充分利用UICollectionView的cell的复用机制，不用自己再去考虑imageView的复用问题，节省内存，有利于性能提升。

详细介绍--简书地址：http://www.jianshu.com/p/fee4d10feefd

先说下大致思路：
我们知道UICollectionView继承自UIScrollView，也就是说UIScrollView的基本属性方法UICollectionView都有，那么UICollectionView也可以分页显示。将item（UITableView对应的cell）的宽和高分别设置成UICollectionView自身的宽和高，数据源返回的item个数就是参与图片的图片个数，那么问题就在于当滚动到最后一张或第一张图片的时候，怎么继续滚动呢？

为了解决这个问题，我们可以通过扩大item的个数的方法解决它，无限轮播的关键就在于此：

1.将数据源方法返回的item个数设置未imgUrls.count（imgUrls是网络图片url或本地图片的数组）的2倍，在collectionView加载完成后默认滚动到索引为imgUrls.count的位置，这样cell就可以向左或右滚动了。

例如：我们想加载3张图片，那么collectionView：初始位置应该在"图片1"的位置，如下图：

![Image text](https://github.com/wanghhh/HHScrollView/blob/master/gitHubImage/QQ20170819-2@2x.png?raw=true)

2.当collectionView滚动到最后一张的时候，即滚到"图片3-2"的位置时，让collectionView回到"图片3-1"的位置，这样就可以继续向右滚动了。同理，当collectionView滚动到第一张的时候，即滚到"图片1-1"的位置时，让collectionView回到"图片1-2"的位置，这样就可以继续向左滚动了。如下图：

![Image text](https://github.com/wanghhh/HHScrollView/blob/master/gitHubImage/QQ20170819-3%402x.png)

以上就是无限轮播的基本实现原理了。

HHScrollView基本属性：

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

var placeholderImage:String = "ic_place"

//设置图片资源url字符串。

var imgUrls = NSArray(){
   didSet{
       pageControl?.numberOfPages = imgUrls.count
       self.reloadData()
   }  
}

fileprivate var itemCount:NSInteger?//cellNum

fileprivate var timer:Timer?//定时器
