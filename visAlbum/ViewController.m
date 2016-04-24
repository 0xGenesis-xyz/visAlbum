//
//  ViewController.m
//  visAlbum
//
//  Created by Sylvanus on 4/18/16.
//  Copyright © 2016 Sylvanus. All rights reserved.
//

#import "ViewController.h"
#import "AlbumCollectionViewController.h"
#import "AlbumTableViewController.h"

@interface ViewController ()

@property (strong, nonatomic) AlbumCollectionViewController *albumCollectionViewController;
@property (strong, nonatomic) AlbumTableViewController *albumTableViewController;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIStepper *zoomControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.title = @"Albums";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.albumCollectionViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CollectionVC"];
    self.albumTableViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TableVC"];
    
    CGFloat padding = [[UIApplication sharedApplication] statusBarFrame].size.height+self.navigationController.navigationBar.frame.size.height;
    self.albumCollectionViewController.collectionView.contentInset = UIEdgeInsetsMake(padding, 0, 0, 0);
    self.albumTableViewController.tableView.contentInset = UIEdgeInsetsMake(padding, 0, 0, 0);
    
    self.albumCollectionViewController.zoomControl.value = self.zoomControl.value;
    [self addChildViewController:self.albumCollectionViewController];
    [self.view addSubview:self.albumCollectionViewController.view];
    self.currentViewController = self.albumCollectionViewController;
}

//- (void)viewWillAppear:(BOOL)animated {
//    [self.currentViewController beginAppearanceTransition: YES animated: animated];
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [self.currentViewController endAppearanceTransition];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [self.currentViewController beginAppearanceTransition: NO animated: animated];
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//    [self.currentViewController endAppearanceTransition];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)zoomView:(UIStepper *)sender {
    if (sender.value<1) {
        [self replaceViewController:self.currentViewController withViewController:self.albumTableViewController];
    } else {
        if (![self.currentViewController isKindOfClass:[AlbumCollectionViewController class]]) {
            [self replaceViewController:self.currentViewController withViewController:self.albumCollectionViewController];
        }
        self.albumCollectionViewController.zoomControl.value = self.zoomControl.value;
        [self.albumCollectionViewController zoomView];
    }
}

- (void)replaceViewController:(UIViewController *)oldViewController withViewController:(UIViewController *)newViewController {
    [self addChildViewController:newViewController];
    [self transitionFromViewController:oldViewController toViewController:newViewController duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newViewController didMoveToParentViewController:self];
            [oldViewController willMoveToParentViewController:nil];
            [oldViewController removeFromParentViewController];
            self.currentViewController = newViewController;
        } else {
            self.currentViewController = oldViewController;
        }
    }];
}

@end
