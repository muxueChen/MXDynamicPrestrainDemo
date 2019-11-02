//
//  ViewController.m
//  MXDynamicPrestrainDemo
//
//  Created by 陈学明 on 2019/11/2.
//  Copyright © 2019 陈学明. All rights reserved.
//

#import "ViewController.h"

// 预伽载临界值
static CGFloat const Threshold = 0.6;

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger totalNumber;
@property (nonatomic, assign) NSInteger page;
// 下拉强制刷新所有接口数据
@property (nonatomic, assign) BOOL isPull;
// 是否正在加载更多
@property (nonatomic, assign) BOOL isLoadingMore;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.totalNumber = 20;
    self.page = 1;
    [self.view addSubview:self.tableView];
}

- (void)loadMore {
    if (self.isLoadingMore) {
        return;
    }
    self.isLoadingMore = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.page += 1;
        self.totalNumber += 20;
        self.isLoadingMore = NO;
        [self.tableView reloadData];
    });
}

#pragma mark -- lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.rowHeight = 100;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.totalNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}

// 预加载方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 如果已经在加载更多，则返回
    if (self.isLoadingMore) {
        return;
    }
    // 第一次网络请求失败的情况下避免奔溃
    if (self.page <= 0) {
        return;
    }
    // 动态临界值
    CGFloat newThreshold = Threshold + (((1-Threshold)*(self.page - 1))/(CGFloat)self.page);
    // 总的偏移量
    CGFloat currentBottomOffSetY = scrollView.contentOffset.y + scrollView.frame.size.height;
    CGFloat totalContentSizeY = scrollView.contentSize.height;
    // 取得当前滑动视图的底边的偏移量
    CGFloat ratio = currentBottomOffSetY/totalContentSizeY;
    // 比较临界值大小
    if (ratio > newThreshold) {
        // 执行预加载数据。。。。
        [self loadMore];
    }
}

@end
