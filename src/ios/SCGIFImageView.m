/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "SCGIFImageView.h"
#import <ImageIO/ImageIO.h>

@implementation SCGIFImageFrame
@synthesize image = _image;
@synthesize duration = _duration;


@end

@interface SCGIFImageView ()

- (void)resetTimer;

- (void)showNextImage;

@end

@implementation SCGIFImageView
@synthesize imageFrameArray = _imageFrameArray;
@synthesize timer = _timer;
@synthesize animating = _animating;


- (void)resetTimer {
    if (_timer && _timer.isValid) {
        [_timer invalidate];
    }

    self.timer = nil;
}

- (void)setData:(NSData *)imageData {
    if (!imageData) {
        return;
    }
    [self resetTimer];
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
size_t count = CGImageSourceGetCount(source);

    NSMutableArray* tmpArray = [NSMutableArray array];

    for (size_t i = 0; i < count; i++) {
        SCGIFImageFrame* gifImage = [[SCGIFImageFrame alloc] init];

        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        gifImage.image = [UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];

        NSDictionary* frameProperties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, i, NULL));
        gifImage.duration = [[[frameProperties objectForKey:(NSString*)kCGImagePropertyGIFDictionary] objectForKey:(NSString*)kCGImagePropertyGIFDelayTime] doubleValue];
        gifImage.duration = MAX(gifImage.duration, 0.01);

        [tmpArray addObject:gifImage];

        CGImageRelease(image);
    }
    CFRelease(source);

    self.imageFrameArray = nil;
    if (tmpArray.count > 1) {
        self.imageFrameArray = tmpArray;
        _currentImageIndex = -1;
        _animating = YES;
        [self showNextImage];
    } else {
        self.image = [UIImage imageWithData:imageData];
    }
}


- (void)setImage:(UIImage *)image {
    [super setImage:image];
    [self resetTimer];
    self.imageFrameArray = nil;
    _animating = NO;
}

- (void)showNextImage {
    if (_sumCount > 0) {
        _animating = _sumCount - 1 == _currentImageIndex ? NO : YES;
    }
    if (!_animating) {
        return;
    }
    _currentImageIndex = (++_currentImageIndex) % _imageFrameArray.count;
    SCGIFImageFrame* gifImage = [_imageFrameArray objectAtIndex:_currentImageIndex];
    [super setImage:[gifImage image]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:gifImage.duration target:self          selector:@selector(showNextImage) userInfo:nil repeats:NO];
}

- (void)setAnimating:(BOOL)animating {
    if (_imageFrameArray.count < 2) {
        _animating = animating;
        return;
    }

    if (!_animating && animating) {
        //continue
        _animating = animating;
        if (!_timer) {
            [self showNextImage];
        }
    } else if (_animating && !animating) {
        //stop
        _animating = animating;
        [self resetTimer];
    }
}

@end
