//
//  ListCell.m
//  NestedScrollDemo
//
//  Created by yf on 2019/2/18.
//  Copyright © 2019年 yf. All rights reserved.
//

#import "ListCell.h"
#import "Masonry/Masonry.h"

@interface ListCell ()

@property (nonatomic,strong) UIView * titleView;
@property (nonatomic,strong) UIView * lineView;

@end

@implementation ListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self stepSubView];
    }
    return self;
}

-(void)stepSubView
{
    _titleView = [[UIView alloc] init];
    _titleView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:_titleView];
    
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-1);
    }];
    
    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_lineView];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
}

@end
