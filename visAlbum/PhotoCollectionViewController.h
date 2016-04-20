//
//  PhotoCollectionViewController.h
//  visAlbum
//
//  Created by Sylvanus on 4/18/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PhotoCollectionViewController : UICollectionViewController

@property (strong, nonatomic) PHFetchResult *assetsFetchResults;
@property (strong, nonatomic) PHAssetCollection *assetCollection;

@end
