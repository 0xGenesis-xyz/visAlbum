//
//  AlbumTableViewCell.h
//  visAlbum
//
//  Created by Sylvanus on 4/24/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *num;
@property (weak, nonatomic) IBOutlet UILabel *albumTag;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
