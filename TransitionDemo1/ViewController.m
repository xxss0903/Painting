//
//  ViewController.m
//  TransitionDemo1
//
//  Created by xxss0903 on 16/4/25.
//  Copyright © 2016年 rry. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) CAGradientLayer *leftShadow;
@property (nonatomic, strong) CAGradientLayer *rightShadow;
@property (nonatomic, strong) UIView *imageView;

@end

@implementation ViewController
{
    CGFloat initialPointX;
}

- (void)setupSubViews
{
    UIImage *rainDrop = [UIImage imageNamed:@"雨滴"];
    UIView *imageView = [[UIView alloc] init];
    self.imageView = imageView;
    [self.view addSubview:imageView];
    imageView.center = self.view.center;
    imageView.bounds = CGRectMake(0, 0, 200, 150);
    
    // 将图片分成两半
    UIImageView *leftImageView = [[UIImageView alloc] init];
    self.leftImageView = leftImageView;
    leftImageView.backgroundColor = [UIColor blueColor];
    leftImageView.userInteractionEnabled = YES;
    leftImageView.frame = CGRectMake(0, 0, imageView.bounds.size.width/2, imageView.bounds.size.height);
    
    UIImageView *rightImageView = [[UIImageView alloc] init];
    self.rightImageView = rightImageView;
    rightImageView.backgroundColor = [UIColor redColor];
    rightImageView.userInteractionEnabled = YES;
    rightImageView.layer.anchorPoint = CGPointMake(0.0, 0.5); // 右边图片的⚓️点
    rightImageView.frame = CGRectMake(imageView.bounds.size.width/2, 0, imageView.bounds.size.width/2, imageView.bounds.size.height);

    
    // 将左和右边的图片切半
    leftImageView.image = [self clipImage:rainDrop withLeft:YES];
    rightImageView.image = [self clipImage:rainDrop withLeft:NO];
    
    // 添加阴影层
    self.leftShadow = [CAGradientLayer layer];
    self.leftShadow.opacity = 0;
    self.leftShadow.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor];
    self.leftShadow.frame = leftImageView.bounds;
    self.leftShadow.startPoint = CGPointMake(1, 1);
    self.leftShadow.startPoint = CGPointMake(0, 1);
    [self.leftImageView.layer addSublayer:self.leftShadow];
    
    // 右边阴影
    self.rightShadow = [CAGradientLayer layer];
    self.rightShadow.opacity = 0;
    self.rightShadow.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor];
    self.rightShadow.frame = rightImageView.bounds;
    self.rightShadow.startPoint = CGPointMake(0, 1);
    self.rightShadow.startPoint = CGPointMake(1, 1);
    [self.rightImageView.layer addSublayer:self.rightShadow];
    
    // 初始动画从0度开始
    self.rightImageView.layer.transform = [self getTransform3DWithAngle:0];
    
// 给左边的图像添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [rightImageView addGestureRecognizer:pan];
    
    [imageView addSubview:leftImageView];
    [imageView addSubview:rightImageView];
}

// 移动手势
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.imageView];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        initialPointX = location.x;
    }

    //  开始拖动
    if (([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.y"] floatValue] > -M_PI_2) && // x轴旋转的值大于于 PI_2
        ([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] != 0))    // y轴旋转的值不为0
    {
        self.rightImageView.alpha = 1;
        self.rightShadow.opacity = 0;
        
        CGFloat opacity = (location.x - initialPointX) / (CGRectGetWidth(self.imageView.frame) - initialPointX);
        self.leftShadow.opacity = fabs(opacity);
        
    } else if (([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.y"] floatValue] > -M_PI_2) &&
               ([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.y"] floatValue] < 0) &&
               ([[self.rightImageView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] == 0)) {
        
        CGFloat opacity = (location.x - initialPointX) / (CGRectGetWidth(self.imageView.bounds) - initialPointX);
        self.rightShadow.opacity = fabs(opacity) * 0.5;
        self.leftShadow.opacity = fabs(opacity) * 0.5;
    }
    // 旋转右边视图
    if ([self isLocation:location inView:self.imageView]) {
        CGFloat converseFactor = M_PI / (CGRectGetWidth(self.imageView.bounds) - initialPointX);
        
        // 旋转角度
        CGFloat angle = (location.x - initialPointX)*converseFactor;
        if (angle < -M_PI || angle > 0) {
            self.leftShadow.opacity = 0;
            self.rightImageView.layer.transform = [self getTransform3DWithAngle:0];

            self.leftImageView.alpha = 1;
        } else {
            self.rightImageView.layer.transform = [self getTransform3DWithAngle:angle];
        }
        
        
        NSLog(@"%f", converseFactor);
    } else {
        gesture.enabled = NO;
        gesture.enabled = YES;
    }
}

// 转动图片
- (CATransform3D)getTransform3DWithAngle:(CGFloat)angle
{
    NSLog(@"angle = %f", angle);
    CATransform3D  transform = CATransform3DIdentity;
    transform.m34 = 4.5/-2000;
    transform  = CATransform3DRotate(transform,angle, 0, 1, 0);
    return transform;
}

// 关闭view
- (void)closeView:(UIView *)fromView toView:(UIView *)toView
{
    
}

// 打开view
- (void)flodView:(UIView *)view
{
    
}

// 判断移动是否超出 imageview
- (BOOL)isLocation:(CGPoint)location inView:(UIView *)view
{
    if ((location.x>0 && location.x<CGRectGetWidth(view.frame))&&(location.y>0&&location.y<CGRectGetHeight(view.frame))) {
        return YES;
    } else {
        return NO;
    }
}

// 剪切图片为两半
- (UIImage *)clipImage:(UIImage *)image withLeft:(BOOL)isLeft
{
    CGRect imageRect = CGRectMake(0, 0, image.size.width/2, image.size.height);
    if (!isLeft) {
        imageRect.origin.x = image.size.width/2;
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, imageRect);
    
    UIImage *clippedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return clippedImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
