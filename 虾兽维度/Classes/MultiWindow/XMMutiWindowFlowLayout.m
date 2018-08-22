//
//  XMMutiWindowFlowLayout.m
//  虾兽维度
//
//  Created by Niki on 2018/8/21.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "XMMutiWindowFlowLayout.h"

@interface XMMutiWindowFlowLayout()

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGFloat itemGap;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attributes;

@end

@implementation XMMutiWindowFlowLayout

- (instancetype)init{
    
    if (self = [super init]) {
        self.attributes = [NSMutableArray array];
    }
    
    return self;
}

- (CGSize)collectionViewContentSize{
    
    return self.contentSize;
}

- (void)prepareLayout{
    
    [super prepareLayout];
    
    // 每个cell之间的距离
    self.itemGap = roundf(self.collectionView.frame.size.height*0.2f);
    
    [self.attributes removeAllObjects];
    NSUInteger cellCount = [self.collectionView numberOfItemsInSection:0];
        
    CGFloat top = -110.0f;  // 首个cell的y坐标
    CGFloat left = 6.0f;
    CGFloat width = roundf(self.collectionView.frame.size.width - 2*left);
    CGFloat height = roundf((self.collectionView.frame.size.height/self.collectionView.frame.size.width)*width);
    
//    BOOL isPanLastCell = self.panCellIndex == cellCount - 1;
    // 记录pan手势左划的比例,越往左,ratio越大
    CGFloat dx = MAX(self.panCellStarP.x - self.panCellCurrentP.x, 0.0f);
    CGFloat ratio = MAX(dx/width, 0);
    
//    CGFloat removeGap = self.itemGap * cellCount / (cellCount - 1);
//    CGFloat gap = self.itemGap + (removeGap - self.itemGap ) * (1 - ratio);
//    CGFloat gap = self.itemGap * (1 - ratio);

    for (NSInteger item = 0; item < cellCount; item++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        CGRect frame = CGRectMake(left, top, width, height);
        attributes.frame = frame;
        // zIndex就是图层的次序,同样位置的图层,zIndex越大,越放在顶部
        attributes.zIndex = item;
        
        // 默认的cell旋转角度
        CGFloat angleOfRotation = -61.0f;
        
        // 与顶部距离在self.collectionView.frame.size.height/10.0f之内,则调整旋转角度,造成一个逐渐平铺的效果
        CGFloat frameOffset = self.collectionView.contentOffset.y - frame.origin.y - floorf(self.collectionView.frame.size.height/10.0f);
        if (frameOffset > 0) {
            frameOffset = frameOffset/5.0f;
            frameOffset = MIN(frameOffset, 30.0f);
            angleOfRotation += frameOffset;
        }
        
        // 旋转
        CATransform3D rotation = CATransform3DMakeRotation((M_PI*angleOfRotation/180.0f), 1.0f, 0.0f, 0.0f);
        
        // perspective:透视效果,即是相当于将cell下移到屏幕底部一个距离,并且添加一个上宽下窄的梯形效果
        CGFloat depth = 300.0f;
        CATransform3D translateDown = CATransform3DMakeTranslation(0.0f, 0.0f, -depth );
        // 经过测试translateUp这个效果去除也没造成影响
        CATransform3D translateUp = CATransform3DMakeTranslation(0.0f, 0.0f, depth);
        // CATransform3D本质上是一个矩阵计算,其中m34能够生成一个上宽下窄梯形的效果
        CATransform3D scale = CATransform3DIdentity;
        scale.m34 = -1.0f/1500.0f;
        CATransform3D perspective =  CATransform3DConcat(CATransform3DConcat(translateDown, scale), translateUp);
        
        // 最终的合成效果
        CATransform3D transform = CATransform3DConcat(rotation, perspective);
        attributes.transform3D = transform;
        
//        CGFloat gap = self.itemGap;
        // 呼应侧滑pan动作,调整x坐标以及透明度
        if (self.panCellIndex == item) {
//            CGFloat dx = MAX(self.panCellStarP.x - self.panCellCurrentP.x, 0.0f);
            frame.origin.x -= dx;
            attributes.frame = frame;
            
            attributes.alpha = MAX(1.0f - ratio, 0);
//            attributes.alpha = MAX(1.0f - dx/width, 0);
            // 当前侧滑的cell的下一个cell的距离应该缩小,造成下一个cell随着当前cell侧滑慢慢靠拢的效果
//            gap = attributes.alpha * self.itemGap;
        }
        
        [self.attributes addObject:attributes];
        
        // 不断累加,在y方向依次排开,但是侧滑的cell的上下距离需要改变
//        if(self.panCellIndex - 1 == item || self.panCellIndex == item){
//            top += self.itemGap * MAX((1 - ratio), 0.5);
//        }else{
//            top += self.itemGap;
//        }
        if(self.panCellIndex == item){
            top += self.itemGap * (1 - ratio);
        }else{
            top += self.itemGap;
        }
//        top += gap;
    }
    
    // 取出最后一个cell,设置contentSize
    if (self.attributes.count) {
        UICollectionViewLayoutAttributes *lastItemAttributes = [self.attributes lastObject];
        self.contentSize = CGSizeMake(self.collectionView.frame.size.width, CGRectGetMaxY(lastItemAttributes.frame));
    }
}

/**
 UICollectionViewLayoutAttributes *attrs;
 1.一个cell对应一个UICollectionViewLayoutAttributes对象
 2.UICollectionViewLayoutAttributes对象决定了cell的frame
 */
/**
 * 这个方法的返回值是一个数组（数组里面存放着rect范围内所有元素的布局属性）
 * 这个方法的返回值决定了rect范围内所有元素的排布（frame）
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{

    NSMutableArray *attributesInRect = [NSMutableArray array];

    for(UICollectionViewLayoutAttributes * attributes in self.attributes) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            [attributesInRect addObject:attributes];
        }
    }

    return attributesInRect;
}

// 返回对应于indexPath的位置的cell的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.item < self.attributes.count) {
        return self.attributes[indexPath.item];
    }
    return nil;
}


/**
 * 当collectionView的显示范围发生改变的时候，是否需要重新刷新布局
 * 一旦重新刷新布局，就会重新调用下面的方法：
 1.prepareLayout
 2.layoutAttributesForElementsInRect:方法
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath{
    if (itemIndexPath.item < self.attributes.count) {
        return self.attributes[itemIndexPath.item];
    }

    return nil;
}

@end
