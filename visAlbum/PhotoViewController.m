//
//  PhotoViewController.m
//  visAlbum
//
//  Created by Sylvanus on 4/18/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import "PhotoViewController.h"
#import "PHAsset+Utility.h"
#import "MetadataViewController.h"

@interface PhotoViewController () <UIScrollViewDelegate, PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.scrollView addSubview:self.imageView];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateImage];
    
    [self.view layoutIfNeeded];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)targetSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * scale, CGRectGetHeight(self.scrollView.bounds) * scale);
    return targetSize;
}

- (void)updateImage {
    // Prepare the options to pass when fetching the live photo.
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        // Check if the request was successful.
        if (!result) {
            return;
        }
        
        // Show the UIImageView and use it to display the requested image.
        self.imageView.image = result;
        
        [self.imageView sizeToFit];
        self.scrollView.contentSize = self.imageView.image ? self.imageView.image.size : CGSizeZero;
        
        CGSize imageViewSize = self.imageView.bounds.size;
        CGSize scrollViewSize = self.scrollView.bounds.size;
        double scale = MIN(scrollViewSize.width/imageViewSize.width, scrollViewSize.height/imageViewSize.height);
        
        self.scrollView.minimumZoomScale = 0.8*scale;
        self.scrollView.maximumZoomScale = 2*scale;
        [self.scrollView setZoomScale:scale animated:YES];
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[MetadataViewController class]]) {
        MetadataViewController *metadataViewController = (MetadataViewController *)segue.destinationViewController;
        [self.asset requestMetadataWithCompletionBlock:^(NSDictionary *metadata) {
            metadataViewController.metadata = metadata;
        }];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
//    [self.imageView setCenter:CGPointMake(scrollView.bounds.size.width/2, (scrollView.bounds.size.height-44)/2-44)];
//}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        // Check if there are changes to the asset we're displaying.
        PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:self.asset];
        if (changeDetails == nil) {
            return;
        }
        
        // Get the updated asset.
        self.asset = [changeDetails objectAfterChanges];
        
        // If the asset's content changed, update the image and stop any video playback.
        if ([changeDetails assetContentChanged]) {
            [self updateImage];
        }
    });
}

- (UIImageView *)imageView {
    if (!_imageView)
        _imageView = [[UIImageView alloc] init];
    return _imageView;
}

@end
