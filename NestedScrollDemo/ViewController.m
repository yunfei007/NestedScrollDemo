//
//  ViewController.m
//  NestedScrollDemo
//
//  Created by yf on 2019/2/18.
//  Copyright © 2019年 yf. All rights reserved.
//

#import "ViewController.h"
#import "Masonry/Masonry.h"
#import "HGFirstViewController.h"
#import "HGSecondViewController.h"
#import "HGThirdViewController.h"
#import "HGSegmentedPageViewController.h"
#import "HGCenterBaseCollectionView.h"

#import "ListCell.h"

#define HG_STATUS_BAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HGSegmentedPageViewControllerDelegate,HGPageViewControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) HGCenterBaseCollectionView * collectionView;
@property (nonatomic,strong) NSArray * listArr;
@property (nonatomic, strong) HGSegmentedPageViewController *segmentedPageViewController;
@property (nonatomic) BOOL cannotScroll;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //如果使用自定义的按钮去替换系统默认返回按钮，会出现滑动返回手势失效的情况
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [self stepSubView];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)stepSubView
{
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0.0001;// 垂直方向的间距
    flowLayout.minimumLineSpacing = 0.0001; // 水平方向的间距
    HGCenterBaseCollectionView *collectionView = [[HGCenterBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView = collectionView;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:self.collectionView];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
    }];
    
    //注册cell
    [collectionView registerClass:[ListCell class] forCellWithReuseIdentifier:@"ListCell"];
    //注册视图
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FootView"];
}

#pragma mark - UIScrollViewDelegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    [self.segmentedPageViewController.currentPageViewController makePageViewControllerScrollToTop];
    return YES;
}

/**
 * 处理联动
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {    
    //第二部分：处理scrollView滑动冲突
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    //吸顶临界点(此时的临界点不是视觉感官上导航栏的底部，而是当前屏幕的顶部相对scrollViewContentView的位置)
    //因为collectionview flowLayout.minimumInteritemSpacing = 0.0001;// 垂直方向的间距,所以需要减去这个间距
    CGFloat criticalPointOffsetY = scrollView.contentSize.height- 0.0001*4 - SCREEN_HEIGHT ;
    //利用contentOffset处理内外层scrollView的滑动冲突问题
    if (contentOffsetY >= criticalPointOffsetY) {
        /*
         * 到达临界点：
         * 1.未吸顶状态 -> 吸顶状态
         * 2.维持吸顶状态 (pageViewController.scrollView.contentOffsetY > 0)
         */
        //“进入吸顶状态”以及“维持吸顶状态”
        self.cannotScroll = YES;
        scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        [self.segmentedPageViewController.currentPageViewController makePageViewControllerScroll:YES];
    } else {
        /*
         * 未达到临界点：
         * 1.维持吸顶状态 (pageViewController.scrollView.contentOffsetY > 0)
         * 2.吸顶状态 -> 不吸顶状态
         */
        if (self.cannotScroll) {
            //“维持吸顶状态”
            scrollView.contentOffset = CGPointMake(0, criticalPointOffsetY);
        } else {
            /* 吸顶状态 -> 不吸顶状态
             * categoryView的子控制器的tableView或collectionView在竖直方向上的contentOffsetY小于等于0时，会通过代理的方式改变当前控制器self.canScroll的值；
             */
        }
    }
}


#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ListCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCell" forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//  返回脚视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView * view = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FootView" forIndexPath:indexPath];
        
        //清空
        for (UIView * subView in footView.subviews) {
            [subView removeFromSuperview];
        }
        [self addChildViewController:self.segmentedPageViewController];
        [footView addSubview:self.segmentedPageViewController.view];
        [self.segmentedPageViewController didMoveToParentViewController:self];
        [self.segmentedPageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(footView);
        }];
        return footView;
    }
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(self.view.frame.size.width, 60);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(self.view.frame.size.width, SCREEN_HEIGHT);
}

#pragma mark - HGSegmentedPageViewControllerDelegate
- (void)segmentedPageViewControllerWillBeginDragging {
    self.collectionView.scrollEnabled = NO;
}

- (void)segmentedPageViewControllerDidEndDragging {
    self.collectionView.scrollEnabled = YES;
}

#pragma mark - HGPageViewControllerDelegate
- (void)pageViewControllerLeaveTop {
    self.cannotScroll = NO;
}


#pragma mark - Lazy
- (HGSegmentedPageViewController *)segmentedPageViewController {
    if (!_segmentedPageViewController) {
        NSMutableArray *controllers = [NSMutableArray array];
        NSArray *titles = @[@"华盛顿", @"夏威夷", @"拉斯维加斯", @"纽约", @"西雅图", @"底特律", @"费城", @"旧金山", @"芝加哥"];
        for (int i = 0; i < titles.count; i++) {
            HGPageViewController *controller;
            if (i % 3 == 0) {
                controller = [[HGThirdViewController alloc] init];
            } else if (i % 2 == 0) {
                controller = [[HGSecondViewController alloc] init];
            } else {
                controller = [[HGFirstViewController alloc] init];
            }
            controller.delegate = self;
            [controllers addObject:controller];
        }
        _segmentedPageViewController = [[HGSegmentedPageViewController alloc] init];
        _segmentedPageViewController.pageViewControllers = controllers.copy;
        _segmentedPageViewController.categoryView.titles = titles;
        _segmentedPageViewController.categoryView.originalIndex = self.selectedIndex;
        _segmentedPageViewController.categoryView.collectionView.backgroundColor = [UIColor yellowColor];
        _segmentedPageViewController.delegate = self;
    }
    return _segmentedPageViewController;
}

@end
