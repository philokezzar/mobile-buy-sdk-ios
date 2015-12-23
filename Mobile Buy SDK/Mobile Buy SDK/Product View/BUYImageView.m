//
//  BUYImageView.m
//  Mobile Buy SDK
//
//  Created by Shopify.
//  Copyright (c) 2015 Shopify Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "BUYImageView.h"
#import "BUYTheme+Additions.h"
#import <SDWebImage/UIImageView+WebCache.h>

float const imageDuration = 0.1f;

@interface BUYImageView ()

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation BUYImageView

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.showsActivityIndicator = YES;
		
		self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
		self.activityIndicatorView.hidesWhenStopped = YES;
		[self addSubview:self.activityIndicatorView];
		
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView
														 attribute:NSLayoutAttributeCenterY
														 relatedBy:NSLayoutRelationEqual
															toItem:self
														 attribute:NSLayoutAttributeCenterY
														multiplier:1.0
														  constant:0]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView
														 attribute:NSLayoutAttributeCenterX
														 relatedBy:NSLayoutRelationEqual
															toItem:self
														 attribute:NSLayoutAttributeCenterX
														multiplier:1.0
														  constant:0]];
	}
	return self;
}

- (void)loadImageWithURL:(NSURL *)imageURL completion:(void (^)(UIImage *image, NSError *error))completion
{
	[self loadImageWithURL:imageURL setImage:YES completion:completion];
}

- (void)loadImageWithURL:(NSURL *)imageURL animateChange:(BOOL)animateChange completion:(void (^)(UIImage *image, NSError *error))completion
{
    NSURL *newUrl = [self manipulateImageUrl:imageURL.absoluteString];

    [self sd_setImageWithURL:newUrl placeholderImage:[UIImage imageNamed:@"loading-squared"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (animateChange) {
            [UIView transitionWithView:self
                              duration:0.15f
                               options:(UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionBeginFromCurrentState)
                            animations:^{
                                self.image = image;
                            }
                            completion:^(BOOL finished) {
                                if (completion) {
                                    completion(image, error);
                                }
                            }];
        } else {
            self.image = image;
            if (completion) {
                completion(image, error);
            }
        }
        
    }];
  }

- (void)loadImageWithURL:(NSURL *)imageURL setImage:(BOOL)setImage completion:(void (^)(UIImage *image, NSError *error))completion
{
 
    if([self isSmallThumbnail:imageURL.absoluteString]){
        // ignore and don't process
        // immediately return completion
        if(completion){
            completion(nil, nil);
        }
        return;
    }
    
    
    NSURL *newUrl = [self manipulateImageUrl:imageURL.absoluteString];
    

    [self sd_setImageWithURL:newUrl placeholderImage:[UIImage imageNamed:@"loading-squared"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self.activityIndicatorView stopAnimating];
        if (completion) {
            completion(image, error);
        }
    }];
    
}

- (void)cancelImageTask {
	[self.task cancel];
	self.task = nil;
}

- (void)setTheme:(BUYTheme *)theme
{
	self.activityIndicatorView.activityIndicatorViewStyle = [theme activityIndicatorViewStyle];
}

- (BOOL)isPortraitOrSquare
{
	return self.image.size.height >= self.image.size.width;
}

- (NSURL*)manipulateImageUrl:(NSString*)imageUrl {
    
    NSString *newURL = imageUrl;
    newURL = [NSString stringWithFormat:@"https://res.cloudinary.com/drnl3gnpa/image/fetch/t_mobile_shopify_detail/%@",newURL];
    newURL = [self searchAndReplaceText:newURL replacedWith:@""];
    NSURL *url = [NSURL URLWithString:newURL];
    
    return url;
}

- (NSString*)searchAndReplaceText:(NSString *)originalString replacedWith:(NSString*)replacement
{
    NSString *string = originalString;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\?v=\\d*)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:replacement];
    NSLog(@"%@", modifiedString);
    return modifiedString;
    
    
}

- (BOOL)isSmallThumbnail:(NSString*)path{
    return ([path rangeOfString:@"_small"].location != NSNotFound);
}

@end