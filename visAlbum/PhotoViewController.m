//
//  PhotoViewController.m
//  visAlbum
//
//  Created by Sylvanus on 4/18/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import "PhotoViewController.h"
#import "PHAsset+Utility.h"
#import "UIImage+Extensions.h"
#import "MetadataViewController.h"

@interface PhotoViewController () <UIScrollViewDelegate, PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property CGFloat scale;

@property CGPoint location;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *zoom;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.zoom.minimumPressDuration = 0.3;
    self.zoom.numberOfTouchesRequired = 1;
    
    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateRight:)];
    leftEdgeGesture.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:leftEdgeGesture];
    UIScreenEdgePanGestureRecognizer *rightEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateLeft:)];
    rightEdgeGesture.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:rightEdgeGesture];
    
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

- (IBAction)zoomPhoto:(UILongPressGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];
    if ([sender state] == UIGestureRecognizerStateBegan) {
        self.location = location;
    }
    self.scale += 0.1*(self.location.y-location.y);
    [self.scrollView setZoomScale:self.scale animated:YES];
    self.location = location;
}

- (void)rotateRight:(UIScreenEdgePanGestureRecognizer *)sender {
    if ([sender state] == UIGestureRecognizerStateBegan) {
        self.imageView.image = [self.imageView.image imageRotatedByDegrees:90];
        [self resetView];
    }
}

- (void)rotateLeft:(UIScreenEdgePanGestureRecognizer *)sender {
    if ([sender state] == UIGestureRecognizerStateEnded) {
        self.imageView.image = [self.imageView.image imageRotatedByDegrees:-90];
        [self resetView];
    }
}

- (void)resetView {
    [self.imageView sizeToFit];
    
    CGSize imageViewSize = self.imageView.bounds.size;
    CGSize scrollViewSize = self.scrollView.bounds.size;
    self.scale = MIN(scrollViewSize.width/imageViewSize.width, scrollViewSize.height/imageViewSize.height);
    
    //CGFloat paddingLeft = (self.view.frame.size.width-self.imageView.image.size.width*self.scale)/2;
    //CGFloat paddingTop = (self.view.frame.size.height-self.imageView.image.size.height*self.scale-44)/2;
    self.imageView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    self.scrollView.contentSize = self.imageView.image.size;
    
    self.scrollView.minimumZoomScale = self.scale;
    self.scrollView.maximumZoomScale = 3*self.scale;
    [self.scrollView setZoomScale:self.scale animated:YES];
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
        [self resetView];
    }];
}

//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    NSLog(@"move: ");
//    for (UITouch *touch in touches) {
//        NSLog(@"%f, %f, %f", touch.force, [touch locationInView:self.view].y, [touch previousLocationInView:self.view].y);
//    }
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[MetadataViewController class]]) {
        MetadataViewController *metadataViewController = (MetadataViewController *)segue.destinationViewController;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        metadataViewController.identifier = [dateFormatter stringFromDate:self.asset.creationDate];
        
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

//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
//    NSLog(@"scale: %f", scale);
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
