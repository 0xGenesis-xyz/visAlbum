//
//  PhotoViewController.h
//  visAlbum
//
//  Created by Sylvanus on 4/18/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PhotoViewController : UIViewController

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end
