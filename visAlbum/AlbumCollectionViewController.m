//
//  AlbumCollectionViewController.m
//  visAlbum
//
//  Created by Sylvanus on 4/19/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import <Photos/Photos.h>
#import "AlbumCollectionViewController.h"
#import "AlbumCollectionViewCell.h"
#import "PhotoCollectionViewController.h"

@interface AlbumCollectionViewController () <PHPhotoLibraryChangeObserver>

@property (strong, nonatomic) NSArray *sectionFetchResults;

@property (strong, nonatomic) NSArray *zoomStep;
@property (strong, nonatomic) NSMutableArray *data;

//@property CGPoint location;
//@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *zoom;

@end

@implementation AlbumCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
//    self.zoom.minimumPressDuration = 0.3;
//    self.zoom.numberOfTouchesRequired = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static NSString * const AllPhotosReuseIdentifier = @"AllPhotosCell";
static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";

static NSString * const AllPhotosSegue = @"showAllPhotos";
static NSString * const CollectionSegue = @"showCollection";

- (void)awakeFromNib {
    // Create a PHFetchResult object for each section in the table view.
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    // Store the PHFetchResult objects and localized titles for each section.
    self.sectionFetchResults = @[allPhotos, smartAlbums, topLevelUserCollections];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)zoomView {
    [self.collectionView reloadData];
}

- (CGFloat)getGridSize {
    NSUInteger index = (int)self.zoomControl.value;
    NSNumber *size = [self.zoomStep objectAtIndex:index];
    return [size floatValue];
}

//- (IBAction)zoomViewByGesture:(UILongPressGestureRecognizer *)sender {
//    CGPoint location = [sender locationInView:self.view];
//    if ([sender state] == UIGestureRecognizerStateBegan) {
//        self.location = location;
//    }
//    self.zoomControl.value += self.location.y-location.y;
//    [self zoomView:self.zoomControl];
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[PhotoCollectionViewController class]] && [sender isKindOfClass:[UICollectionViewCell class]]) {
        PhotoCollectionViewController *photoCollectionViewController = segue.destinationViewController;
        AlbumCollectionViewCell *cell = sender;
        
        // Set the title of the AAPLAssetGridViewController.
        photoCollectionViewController.title = cell.name.text;
        
        // Get the PHFetchResult for the selected section.
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        
        PHFetchResult *allPhotos = self.sectionFetchResults[0];
        PHFetchResult *smartAlbums = self.sectionFetchResults[1];
        PHFetchResult *topLevelUserCollections = self.sectionFetchResults[2];
        
        PHFetchResult *fetchResult;
        NSInteger offset = 0;
        if (indexPath.row<1) {
            fetchResult = allPhotos;
        } else if (indexPath.row<1+smartAlbums.count) {
            fetchResult = smartAlbums;
            offset = 1;
        } else {
            fetchResult = topLevelUserCollections;
            offset = 1+smartAlbums.count;
        }
        
        if ([segue.identifier isEqualToString:AllPhotosSegue]) {
            photoCollectionViewController.assetsFetchResults = fetchResult;
        } else if ([segue.identifier isEqualToString:CollectionSegue]) {
            if ([cell.name.text isEqualToString:@"QQ"]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Private Album" message:@"Please enter password" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //[self performSegueWithIdentifier:@"CollectionSegue" sender:self];
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
                
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.secureTextEntry = YES;
                }];
                [alertController addAction:okAction];
                [alertController addAction:cancelAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
            // Get the PHAssetCollection for the selected row.
            PHCollection *collection = fetchResult[indexPath.row-offset];
            if (![collection isKindOfClass:[PHAssetCollection class]]) {
                return;
            }
            
            // Configure the AAPLAssetGridViewController with the asset collection.
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            
            photoCollectionViewController.assetsFetchResults = assetsFetchResult;
            photoCollectionViewController.assetCollection = assetCollection;
        }
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    PHFetchResult *smartAlbums = self.sectionFetchResults[1];
    PHFetchResult *topLevelUserCollections = self.sectionFetchResults[2];
    return 1+smartAlbums.count+topLevelUserCollections.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCollectionViewCell *cell = nil;
    
    // Configure the cell
    if (indexPath.row == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:AllPhotosReuseIdentifier forIndexPath:indexPath];
        cell.name.text = NSLocalizedString(@"All Photos", @"");
    } else {
        PHFetchResult *smartAlbums = self.sectionFetchResults[1];
        PHFetchResult *topLevelUserCollections = self.sectionFetchResults[2];
        
        PHFetchResult *fetchResult;
        NSInteger offset = 0;
        if (indexPath.row<1+smartAlbums.count) {
            fetchResult = smartAlbums;
            offset = 1;
        } else {
            fetchResult = topLevelUserCollections;
            offset = 1+smartAlbums.count;
        }
        
        PHCollection *collection = fetchResult[indexPath.row-offset];
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
        cell.name.text = collection.localizedTitle;
    }
    cell.cover.image = [UIImage imageNamed:self.data[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([self getGridSize], [self getGridSize]+20);
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Loop through the section fetch results, replacing any fetch results that have been updated.
        NSMutableArray *updatedSectionFetchResults = [self.sectionFetchResults mutableCopy];
        __block BOOL reloadRequired = NO;
        
        [self.sectionFetchResults enumerateObjectsUsingBlock:^(PHFetchResult *collectionsFetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            
            if (changeDetails != nil) {
                [updatedSectionFetchResults replaceObjectAtIndex:index withObject:[changeDetails fetchResultAfterChanges]];
                reloadRequired = YES;
            }
        }];
        
        if (reloadRequired) {
            self.sectionFetchResults = updatedSectionFetchResults;
            [self.collectionView reloadData];
        }
        
    });
}

- (NSMutableArray *)data{
    if (!_data) {
        _data = @[].mutableCopy;
        for (int i = 1; i < 16; i ++) {
            [_data addObject:[NSString stringWithFormat:@"zrx%d.jpg", i]];
        }
        [_data addObjectsFromArray:_data];
        [_data addObjectsFromArray:_data];
    }
    return _data;
}

- (NSArray *)zoomStep {
    if (!_zoomStep) {
        _zoomStep = [NSArray arrayWithObjects:@0, @65, @85, @115, @180, nil];
    }
    return _zoomStep;
}

- (UIStepper *)zoomControl {
    if (!_zoomControl) {
        _zoomControl = [[UIStepper alloc] init];
    }
    return _zoomControl;
}

@end
