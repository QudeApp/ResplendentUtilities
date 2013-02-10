//
//  AsynchronousImageView.m
//  Crapple
//
//  Created by Ben on 5/21/12.
//  Copyright (c) 2012 Resplendent G.P.. All rights reserved.
//

#import "AsynchronousImageView.h"
#import "AsynchronousUIImageRequest.h"
#import "RUConstants.h"

@implementation AsynchronousImageView

@synthesize loadsUsingSpinner;
@synthesize fadeInDuration;
//@synthesize clearOnFail = _hideOnFail;
//@synthesize viewToSetNeedsLayoutOnComplete = _viewToSetNeedsLayoutOnComplete;

-(id)init
{
    if (self = [super init])
    {
        [self setLoadsUsingSpinner:NO];
//        [self setClearOnFail:YES];
    }

    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [_spinner setCenter:CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f)];
}

-(void)removeFromSuperview
{
//    [self setViewToSetNeedsLayoutOnComplete:nil];
    [self cancelFetch];
    [super removeFromSuperview];
}

#pragma mark - Getter method
-(BOOL)isLoading
{
    return _imageRequest != nil;
}

#pragma mark - Public methods
-(void)cancelFetch
{
    [_imageRequest cancelFetch];
    _imageRequest = nil;
}

-(void)fetchImageFromURL:(NSString*)anUrl
{
    [self fetchImageFromURL:anUrl withCacheName:anUrl];
}

-(NSString *)url
{
    return [_imageRequest url];
}

-(void)fetchImageFromURL:(NSString*)anUrl withCacheName:(NSString*)cacheName
{
    [self cancelFetch];

//    if (!_ignoreFetchImageClear)
        [self setImage:nil];

    if (self.loadsUsingSpinner)
    {
        if (!_spinner)
        {
            _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self addSubview:_spinner];
        }

        [_spinner startAnimating];
    }

    _imageRequest = [[AsynchronousUIImageRequest alloc] initAndFetchWithURL:anUrl andCacheName:cacheName withBlock:^(UIImage *image, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _imageRequest = nil;
            
            if (_spinner)
            {
                [_spinner stopAnimating];
                [_spinner removeFromSuperview];;
                _spinner = nil;
            }
            
            [self setImage:image];
            //            [self drawRect:self.bounds];
            
            if (image)
            {
                //                if (self.frame.size.width == 0 || self.frame.size.height == 0)
                //                    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.image.size.width, self.image.size.height);

                [self setAlpha:1.0f];

                CGFloat alpha = self.alpha;
                if (self.fadeInDuration > 0)
                {
                    [self setAlpha:0.0f];
                    [UIView animateWithDuration:self.fadeInDuration animations:^{
                        [self setAlpha:alpha];
                    }];
                }
            }
            //            else if (_hideOnFail)
            //            {
            //                [self setImage:nil];
            //            }
            
            //            [_viewToSetNeedsLayoutOnComplete setNeedsLayout];
        });
    }];
}

@end
