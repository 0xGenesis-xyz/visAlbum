//
//  PhotoCollectionViewCell.m
//  visAlbum
//
//  Created by Sylvanus on 4/18/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import "PhotoCollectionViewCell.h"
#import "UIImage+Extensions.h"

@implementation PhotoCollectionViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    
    CGFloat width = thumbnailImage.size.width;
    CGFloat height = thumbnailImage.size.height;
    if (width>height) {
        CGPoint origin = CGPointMake((width-height)/2, 0);
        CGRect rect = CGRectMake(origin.x, origin.y, height, height);
        self.imageView.image = [thumbnailImage imageAtRect:rect];
    } else {
        CGPoint origin = CGPointMake(0, (height-width)/2);
        CGRect rect = CGRectMake(origin.x, origin.y, width, width);
        self.imageView.image = [thumbnailImage imageAtRect:rect];
    }
}

@end
