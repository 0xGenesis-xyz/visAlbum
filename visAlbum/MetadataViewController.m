//
//  MetadataViewController.m
//  visAlbum
//
//  Created by Sylvanus on 4/21/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import "MetadataViewController.h"

@interface MetadataViewController ()

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

@end

@implementation MetadataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSDictionary *exif = [self.metadata valueForKey:@"{Exif}"];
    NSDictionary *gps = [self.metadata valueForKey:@"{GPS}"];
    NSDictionary *tiff = [self.metadata valueForKey:@"{TIFF}"];
    //NSLog(@"%@", self.metadata);
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
