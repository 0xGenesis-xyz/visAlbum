//
//  AlbumTableViewController.m
//  visAlbum
//
//  Created by Sylvanus on 4/23/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import <Photos/Photos.h>
#import "AlbumTableViewController.h"
#import "AlbumTableViewCell.h"
#import "PhotoCollectionViewController.h"

@interface AlbumTableViewController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) NSArray *sectionFetchResults;
@property (nonatomic, strong) NSArray *sectionLocalizedTitles;

@property (strong, nonatomic) NSMutableArray *data;

@end

@implementation AlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    self.sectionLocalizedTitles = @[@"", NSLocalizedString(@"Smart Albums", @""), NSLocalizedString(@"Albums", @"")];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionFetchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    if (section == 0) {
        // The "All Photos" section only ever has a single row.
        numberOfRows = 1;
    } else {
        PHFetchResult *fetchResult = self.sectionFetchResults[section];
        numberOfRows = fetchResult.count;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumTableViewCell *cell = nil;
    NSInteger num;
    PHFetchResult *fetchResult = self.sectionFetchResults[indexPath.section];
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:AllPhotosReuseIdentifier forIndexPath:indexPath];
        cell.name.text = NSLocalizedString(@"All Photos", @"");
        num = fetchResult.count;
    } else {
        PHFetchResult *fetchResult = self.sectionFetchResults[indexPath.section];
        PHCollection *collection = fetchResult[indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
        cell.name.text = [NSString stringWithString:collection.localizedTitle];
        
        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        num = assetsFetchResult.count;
    }
    cell.cover.image = [UIImage imageNamed:self.data[indexPath.item]];
    cell.num.text = [NSString stringWithFormat:@"%ld", (long)num];
    cell.albumTag.text = @"Add album description";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    cell.date.text = [dateFormatter stringFromDate:[NSDate date]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionLocalizedTitles[section];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[PhotoCollectionViewController class]] && [sender isKindOfClass:[UITableViewCell class]]) {
        PhotoCollectionViewController *photoCollectionViewController = segue.destinationViewController;
        AlbumTableViewCell *cell = sender;
        
        // Set the title of the AAPLAssetGridViewController.
        photoCollectionViewController.title = cell.name.text;
        
        // Get the PHFetchResult for the selected section.
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        PHFetchResult *fetchResult = self.sectionFetchResults[indexPath.section];
        
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
            PHCollection *collection = fetchResult[indexPath.row];
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
            [self.tableView reloadData];
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

@end
