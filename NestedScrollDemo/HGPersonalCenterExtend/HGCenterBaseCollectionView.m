//
//  MyCollectionView.m
//  NestedScrollDemo
//
//  Created by yf on 2019/2/22.
//  Copyright © 2019年 yf. All rights reserved.
//

#import "HGCenterBaseCollectionView.h"
#import "HGPersonalCenterMacro.h"

@implementation HGCenterBaseCollectionView

//是否让手势透传到子视图
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    CGFloat segmentViewContentScrollViewHeight = HG_SCREEN_HEIGHT - self.categoryViewHeight ?: HGCategoryViewDefaultHeight;
    CGPoint currentPoint = [gestureRecognizer locationInView:self];
    if (CGRectContainsPoint(CGRectMake(0, self.contentSize.height - segmentViewContentScrollViewHeight, HG_SCREEN_WIDTH, segmentViewContentScrollViewHeight), currentPoint)) {
        return YES;
    }
    return NO;
}
@end
