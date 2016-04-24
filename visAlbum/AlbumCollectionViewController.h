//
//  AlbumCollectionViewController.h
//  visAlbum
//
//  Created by Sylvanus on 4/19/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCollectionViewController : UICollectionViewController

@property (strong, nonatomic) UIStepper *zoomControl;

- (void)zoomView;

@end
