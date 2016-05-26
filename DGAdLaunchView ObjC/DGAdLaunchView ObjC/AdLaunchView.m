//
//  AdLaunchView.m
//  DGAdLaunchView ObjC
//
//  Created by 段昊宇 on 16/5/26.
//  Copyright © 2016年 Desgard_Duan. All rights reserved.
//

#import "AdLaunchView.h"
#import "DACircularProgressView.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"

@interface AdLaunchView() 

@property(nonatomic, strong) UIView *adBackground;
@property(nonatomic, strong) NSString *imageURL;
@property(nonatomic, strong) UIImageView *adImageView;
@property(nonatomic, strong) DACircularProgressView *progressView;
@property(nonatomic, strong) UIButton *progressButtonView;


@end

@implementation AdLaunchView

#pragma mark - override
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    [self addSubview: self.adBackground];
    [self displayCachedAd];
    [self requestBanner];
    [self showProgressView];
    
    dispatch_time_t show = dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC);
    dispatch_after(show, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
    });
    
    return self;
}

- (void) removeFromSuperview {
    [UIView animateWithDuration:0.8
                     animations:^{
        self.alpha = 0;
    }
                     completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

#pragma mark - 获取本地图片缓存，如果没有广告结束
- (void) displayCachedAd {
    SDWebImageManager *manage = [[SDWebImageManager alloc] init];
    NSURL *url = [[NSURL alloc] initWithString: self.imageURL];
    if ([manage cacheKeyForURL: url] == NO) {
        self.hidden = YES;
    } else {
        [self showImage];
    }
}

#pragma mark - 展示图片
- (void) showImage {
    self.adImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 128)];
    [self.adImageView sd_setImageWithURL: [[NSURL alloc] initWithString: self.imageURL]];
    [self.adImageView setUserInteractionEnabled: YES];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(singleTap)];
    [self.adImageView addGestureRecognizer: singleTap];
    [self addSubview: _adImageView];
}

#pragma mark - 图片点击事件
- (void) singleTap {
    [self._delegate adLaunch: self];
    [self toHidenState];
}

#pragma mark - 下载图片
- (void) requestBanner {
    [[SDWebImageManager sharedManager] downloadImageWithURL: [[NSURL alloc] initWithString: self.imageURL]
                                                    options: SDWebImageAvoidAutoSetImage
                                                   progress: nil
                                                  completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      NSLog(@"图片下载成功");
                                                  }];
}

#pragma mark - 展示跳过按钮
- (void) showProgressView {
    self.progressButtonView = [[UIButton alloc] initWithFrame: CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 20, 40, 40)];
    [self.progressButtonView setTitle: @"跳" forState: UIControlStateNormal];
    self.progressButtonView.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.progressButtonView.backgroundColor = [UIColor clearColor];
    [self.progressButtonView addTarget: self
                                action: @selector(toHidenState)
                      forControlEvents: UIControlEventTouchUpInside];
    [self addSubview: self.progressButtonView];
    
    self.progressView = [[DACircularProgressView alloc] initWithFrame: CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 20, 40, 40)];
    self.progressView.userInteractionEnabled = NO;
    self.progressView.progress = 0;
    [self addSubview: self.progressView];
    [self.progressView setProgress: 1 animated: YES initialDelay: 0 withDuration:4];
    

}

#pragma mark - 消失动画
- (void) toHidenState {
    [UIView animateWithDuration: 0.4
                     animations:^{
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = true;
                     }];
}

#pragma mark - 懒加载
- (UIView *) adBackground {
    CGRect  scr = [UIScreen mainScreen].bounds;
    CGFloat wid = scr.size.width;
    CGFloat hei = scr.size.height;
    
    UIView *footer = [[UIView alloc] initWithFrame: CGRectMake(0, hei - 128, wid, 128)];
    footer.backgroundColor = [UIColor whiteColor];
    
    UIImageView *slogan = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"KDTKLaunchSlogan_Content"]];
    [footer addSubview: slogan];
    
    [slogan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(footer);
    }];
    
    UIView *view = [[UIView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor whiteColor];
    [view addSubview: footer];
    return view;

    return nil;
}

- (NSString *) imageURL {
    NSString *str = @"http://mg.soupingguo.com/bizhi/big/10/258/043/10258043.jpg";
    return str;
}

@end
