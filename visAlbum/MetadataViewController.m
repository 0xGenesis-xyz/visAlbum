//
//  MetadataViewController.m
//  visAlbum
//
//  Created by Sylvanus on 4/21/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import "MetadataViewController.h"

@interface MetadataViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *colorModel;
@property (weak, nonatomic) IBOutlet UILabel *pixelHeight;
@property (weak, nonatomic) IBOutlet UILabel *pixelWidth;
@property (weak, nonatomic) IBOutlet UILabel *depth;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *apertureValue;
@property (weak, nonatomic) IBOutlet UILabel *brightnessValue;
@property (weak, nonatomic) IBOutlet UILabel *exposureTime;
@property (weak, nonatomic) IBOutlet UILabel *altitude;
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
@property (weak, nonatomic) IBOutlet UILabel *dateTime;
@property (weak, nonatomic) IBOutlet UILabel *device;
@property (weak, nonatomic) IBOutlet UITextField *tag;

@property (strong, nonatomic) NSMutableDictionary *photoTags;

@end

@implementation MetadataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"metadata";
    
    [self createEditableCopyOfDatabaseIfNeeded];
    self.photoTags = [[NSMutableDictionary alloc] initWithContentsOfFile:[self applicationDocumentsDirectoryFile]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSDictionary *exif = [self.metadata valueForKey:@"{Exif}"];
    NSDictionary *gps = [self.metadata valueForKey:@"{GPS}"];
    NSDictionary *tiff = [self.metadata valueForKey:@"{TIFF}"];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    self.colorModel.text = [self.metadata valueForKey:@"ColorModel"];
    self.pixelHeight.text = [numberFormatter stringFromNumber:[self.metadata valueForKey:@"PixelHeight"]];
    self.pixelWidth.text = [numberFormatter stringFromNumber:[self.metadata valueForKey:@"PixelWidth"]];
    self.depth.text = [numberFormatter stringFromNumber:[self.metadata valueForKey:@"Depth"]];
    self.profileName.text = [self.metadata valueForKey:@"ProfileName"];
    self.apertureValue.text = [numberFormatter stringFromNumber:[exif valueForKey:@"ApertureValue"]];
    self.brightnessValue.text = [numberFormatter stringFromNumber:[exif valueForKey:@"BrightnessValue"]];
    self.exposureTime.text = [numberFormatter stringFromNumber:[exif valueForKey:@"ExposureTime"]];
    self.altitude.text = [numberFormatter stringFromNumber:[gps valueForKey:@"Altitude"]];
    self.latitude.text = [numberFormatter stringFromNumber:[gps valueForKey:@"Latitude"]];
    self.longitude.text = [numberFormatter stringFromNumber:[gps valueForKey:@"Longitude"]];
    self.dateTime.text = [tiff valueForKey:@"DateTime"];
    self.device.text = [tiff valueForKey:@"Model"];
    self.tag.text = [self.photoTags valueForKey:self.identifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)applicationDocumentsDirectoryFile {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"photoTags.plist"];
    return path;
}

- (void)createEditableCopyOfDatabaseIfNeeded {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *writableDBPath = [self applicationDocumentsDirectoryFile];
    if (![fileManager fileExistsAtPath:writableDBPath]) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"photoTags.plist"];
        NSError *error;
        BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        if (!success) {
            NSAssert1(0, @"fail: '%@'. ", [error localizedDescription]);
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.photoTags setValue:textField.text forKey:self.identifier];
    [self.photoTags writeToFile:[self applicationDocumentsDirectoryFile] atomically:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 280.0); //key board height: 216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
