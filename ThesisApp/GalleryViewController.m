//
//  ViewController.m
//  ThesisPhotoEditor
//
//  Created by Mehul Chopda on 21/07/15.
//  Copyright (c) 2015 Mehul Chopda. All rights reserved.
//

#import "GalleryViewController.h"
#import "DollarDefaultGestures.h"
#import "AAPLAssetGridViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TableViewController.h"
#import "GPUImage.h"

@implementation CIImage (Convenience)
- (NSData *)aapl_jpegRepresentationWithCompressionQuality:(CGFloat)compressionQuality {
    static CIContext *ciContext = nil;
    if (!ciContext) {
        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        ciContext = [CIContext contextWithEAGLContext:eaglContext];
    }
    CGImageRef outputImageRef = [ciContext createCGImage:self fromRect:[self extent]];
    UIImage *uiImage = [[UIImage alloc] initWithCGImage:outputImageRef scale:1.0 orientation:UIImageOrientationUp];
    if (outputImageRef) {
        CGImageRelease(outputImageRef);
    }
    
    NSData *jpegRepresentation = UIImageJPEGRepresentation(uiImage, compressionQuality);
    return jpegRepresentation;
}
@end
@import CoreLocation;
@import Photos;


@interface GalleryViewController ()<PHPhotoLibraryChangeObserver>
@property (assign) CGSize lastImageViewSize;
@end

@implementation GalleryViewController

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
   
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUpdatedData:)
                                                 name:@"DataUpdated"
                                               object:nil];
    [self.view bringSubviewToFront:result];
    // Do any additional setup after loading the view, typically from a nib.
    dollarPGestureRecognizer = [[DollarPGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(gestureRecognized:)];
    [dollarPGestureRecognizer setPointClouds:[DollarDefaultGestures defaultPointClouds]];
    [dollarPGestureRecognizer setDelaysTouchesEnded:NO];
    
    [gestureView addGestureRecognizer:dollarPGestureRecognizer];
    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didSwipe:)];
   
    [[self view ]addGestureRecognizer:swipeRight];
 
    UISwipeGestureRecognizer *swipeLeft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didSwipe:)];
    swipeLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.numberOfTouchesRequired=2;
     swipeRight.numberOfTouchesRequired=2;
    [[self view] addGestureRecognizer:swipeLeft];
    [_imageView addGestureRecognizer:swipeLeft];
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewDidLoad];
  
    
    
    
    [super viewWillAppear:animated];
    
    [self.view layoutIfNeeded];
    [self updateImage];
    
}
-(void)didSwipe:(UISwipeGestureRecognizer *)sender{
    
    
    UISwipeGestureRecognizerDirection direction=sender.direction;
 
    switch (direction) {
        case UISwipeGestureRecognizerDirectionRight:
        {NSLog(@"Swipe Right Detetcted");
            
            //UIView *view= [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
            //UIImageView *myImageView = (UIImageView *)[view viewWithTag:15];
            self.imageView.alpha=1;
            
            [self.navigationController popViewControllerAnimated:YES];
            break;}
        case UISwipeGestureRecognizerDirectionLeft:
        {
                        NSLog(@"Swipe Left Detetcted");
            AAPLAssetGridViewController *assetGridViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"galleryView"];
            assetGridViewController.delegate = self;
            [self.navigationController pushViewController:assetGridViewController animated:YES];
            self.imageView.alpha=1;
            break;
        }
        default:
            break;
            
            
    }
}

-(void)handleUpdatedData:(NSNotification *)notification {
    
    
    [dollarPGestureRecognizer recognize];
    [gestureView clearAll];
    recognized = !recognized;
    // [gestureView setUserInteractionEnabled:!recognized];
    
    
    
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    AAPLAssetGridViewController *assetGridViewController = segue.destinationViewController;
    assetGridViewController.delegate = self;
    // Fetch all assets, sorted by date created.
    
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([self.stopWatchTimer isValid])
    {
        [self.stopWatchTimer invalidate];
        self.stopWatchTimer = nil;
    }
    
    if(self.stopWatchTimer==nil)
    {
        self.startDate = [NSDate date];
        
        // Create the stop watch timer that fires every 10 ms
        self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                               target:self
                                                             selector:@selector(updateTimer)
                                                             userInfo:nil
                                                              repeats:YES];
    }
    
    
}

- (void)updateTimer
{
    // Create date from the elapsed time
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Format the elapsed time and set it to the label
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    // UILabel *result2 = (UILabel *)[view1 viewWithTag:13];
    result.text = timeString;
    
    
    //stopWatch.text = timeString;
}
-(void)stopTimer
{
    if([self.stopWatchTimer isValid])
    {
        NSLog(@"Come for the Invalidate");
        [self.stopWatchTimer invalidate];
        self.stopWatchTimer = nil;
        [self updateTimer];
    }
}

- (void)gestureRecognized:(DollarPGestureRecognizer *)sender {
    DollarResult *result = [sender result];
    NSLog(@"Gesture name=%@",[result name]);
    self.imageView.alpha=1;
   
    if ([[result name] isEqualToString:@"Delete"]) {
        
       
        [self imageDelete:self];
        [self stopTimer];
    }
    if ([[result name] isEqualToString:@"Favourites"]) {
        
        
       
        

       
        [self favouriteImage:self];
        [self stopTimer];
        [[[UIAlertView alloc] initWithTitle:@"Message!"
                                    message:@"Image was added to favourite sucesfully"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
      

//        [self grabImageDataFromAsset:self.asset];
        
        
    }
    if ([[result name] isEqualToString:@"Share"]) {
        
        
        [self shareButton:self];
        [self stopTimer];
    }
   
    
    if ([[result name] isEqualToString:@"Plus"]) {
        
        
        [self addAlbum:self];
        [self stopTimer];
    }
    if ([[result name] isEqualToString:@"Filter"]) {
        
       
         [self applyImageFilter:self ];
        [self stopTimer];
    }
    if ([[result name] isEqualToString:@"Info"]) {
        
                       PHImageRequestOptions *reqoptions = [[PHImageRequestOptions alloc] init];
                reqoptions.networkAccessAllowed = YES;
                reqoptions.synchronous = YES;
                reqoptions.version = PHImageRequestOptionsVersionOriginal;
                [[PHImageManager defaultManager] requestImageDataForAsset:self.asset
                                                                  options:reqoptions
                                                            resultHandler:
                 ^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                     CIImage* ciImage = [CIImage imageWithData:imageData];
                     NSDictionary *gpsDictionary = info[(NSString*)kCGImagePropertyGPSDictionary];
        
                     if(gpsDictionary){
                         NSLog(@"GPS: %@", gpsDictionary.description);
                     }
                     //  NSLog(@"Metadata : %@", ciImage.properties);
        
        
                     NSDictionary *dictionary=ciImage.properties;
                    // NSLog(@"Metadata%@",dictionary);
                     //[self imagePickerController];
                     NSDictionary *exifDictionaary=dictionary[@"{Exif}"];
                TableViewController *tableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tableView"];
        
                     tableViewController.exifDictionary= exifDictionaary;
                
                [self.navigationController pushViewController:tableViewController animated:YES];
                     [self stopTimer];
                     
                 }];
       

    }
    
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!CGSizeEqualToSize(self.imageView.bounds.size, self.lastImageViewSize)) {
        [self updateImage];
    }
}

- (void)updateImage
{
    if(self.asset!=NULL){
        self.lastImageViewSize = self.imageView.bounds.size;
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize targetSize = CGSizeMake(CGRectGetWidth(self.imageView.bounds) * scale, CGRectGetHeight(self.imageView.bounds) * scale);
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        
        // Download from cloud if necessary
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //            self.progressView.progress = progress;
                //            self.progressView.hidden = (progress <= 0.0 || progress >= 1.0);
            });
        };
        
        [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result) {
                self.imageView.image = result;
            }
        }];
    }
    else
    {
        
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
        PHAsset *lastAsset = [fetchResult lastObject];
        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                   targetSize:self.imageView.bounds.size
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:PHImageRequestOptionsVersionCurrent
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        self.imageView.image=result;
                                                        
                                                        
                                                    });
                                                }];
        self.asset=lastAsset;
        
        
    }
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //check if there are changes to the album we're interested on (to its metadata, not to its collection of assets)
        PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:self.asset];
        if (changeDetails) {
            // it changed, we need to fetch a new one
            self.asset = [changeDetails objectAfterChanges];
            [self updateImage];
            if ([changeDetails assetContentChanged]) {
                
                
                //                if (self.playerLayer) {
                //                    [self.playerLayer removeFromSuperlayer];
                //                    self.playerLayer = nil;
                //                }
            }
        }
        
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Add an image to Favourites

- (void)toggleFavoriteForAsset:(PHAsset *)asset {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // Create a change request from the asset to be modified.
        PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:asset];
        // Set a property of the request to change the asset itself.
        request.favorite = !asset.favorite;
        
    } completionHandler:^(BOOL success, NSError *error) {
        NSLog(@"Finished updating asset. %@", (success ? @"Success." : error));
        
    }];
}
- (void)deleteAssets:(PHAsset *)asset {
    
    void (^completionHandler)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self navigationController] popViewControllerAnimated:NO];
            });
        } else {
            NSLog(@"Error: %@", error);
        }
    };
    
    if (self.assetCollection) {
        // Remove asset from album
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.assetCollection];
            [changeRequest removeAssets:@[self.asset]];
        } completionHandler:completionHandler];
        
    } else {
        // Delete asset from library
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:@[asset]];
            
        } completionHandler:completionHandler];
        
    }
    
    
    
    
}

// Deleting an Image....
- (IBAction)imageDelete:(id)sender {
    
    
    void (^completionHandler)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //[[self navigationController] popViewControllerAnimated:YES];
            });
        } else {
            NSLog(@"Error: %@", error);
        }
    };
    
    if (self.assetCollection) {
        // Remove asset from album
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.assetCollection];
            [changeRequest removeAssets:@[self.asset]];
        } completionHandler:completionHandler];
        
    } else {
        // Delete asset from library
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest deleteAssets:@[self.asset]];
        } completionHandler:completionHandler];
        
    }
    
    
}


- (IBAction)favouriteImage:(id)sender {
    [self toggleFavoriteForAsset:self.asset];
    NSLog(@"Added as Favourite");
    
}


//Create New Album...

- (IBAction)addAlbum:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Album" message:@"Please enter album name" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        NSString *title = textField.text;
        
        //         Create new album.
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error creating album: %@", error);
            }
        }];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter album name:";
            }];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
    
    
//    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New Album", @"") message:nil preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:NULL]];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        textField.placeholder = NSLocalizedString(@"Album Name", @"");
//    }];
//    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        UITextField *textField = alertController.textFields.firstObject;
//        NSString *title = textField.text;
//        
////         Create new album.
//        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
//        } completionHandler:^(BOOL success, NSError *error) {
//            if (!success) {
//                NSLog(@"Error creating album: %@", error);
//            }
//        }];
//    }]];
//    
//    [self presentViewController:alertController animated:YES completion:NULL];
}

- (IBAction)shareButton:(id)sender {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.imageView.image]
                                                                             applicationActivities:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    //if iPad
    else {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width, self.view.frame.size.height, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
    
}
//image metadata

- (IBAction)applyImageFilter:(id)sender
{
    UIActionSheet *filterActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Filter"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"Grayscale", @"Sepia", @"Sketch", @"Pixellate", @"Color Invert", @"Toon", @"Pinch Distort", nil];
    
//    [filterActionSheet showFromBarButtonItem:sender animated:YES];
//    nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // In this case the device is an iPad.
       // [filterActionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
                [filterActionSheet showInView:self.view];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [filterActionSheet showInView:self.view];
    }

}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    GPUImageFilter *selectedFilter=NULL;
    
    switch (buttonIndex) {
        case 0:
            selectedFilter = [[GPUImageGrayscaleFilter alloc] init];
            break;
        case 1:
            selectedFilter = [[GPUImageSepiaFilter alloc] init];
            break;
        case 2:
            selectedFilter = [[GPUImageSketchFilter alloc] init];
            break;
        case 3:
            selectedFilter = [[GPUImagePixellateFilter alloc] init];
            break;
        case 4:
            selectedFilter = [[GPUImageColorInvertFilter alloc] init];
            break;
        case 5:
            selectedFilter = [[GPUImageToonFilter alloc] init];
            break;
        case 6:
            selectedFilter = [[GPUImagePinchDistortionFilter alloc] init];
            break;
        case 7:
           // selectedFilter = [[GPUImage alloc] init];
            break;
        default:
            break;
    }
    if (selectedFilter!=NULL) {
        UIImage *filteredImage = [selectedFilter imageByFilteringImage:self.imageView.image];
        [self.imageView setImage:filteredImage];
    }
    
}
//- (void)imagePickerController
// {
//     ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//     
//     // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
//     [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
//                            usingBlock:^(ALAssetsGroup *group, BOOL *stop)
//      {
//          
//          // Within the group enumeration block, filter to enumerate just photos.
//          [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//          
//          // For this example, we're only interested in the first item.
//          [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:0]
//                                  options:0
//                               usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop)
//           {
//               
//               // The end of the enumeration is signaled by asset == nil.
//               if (alAsset) {
//                   ALAssetRepresentation *representation = [alAsset defaultRepresentation];
//                   NSDictionary *imageMetadata = [representation metadata];
//                   // Do something interesting with the metadata.
//                   NSLog(@"Metadata from Trail=%@",imageMetadata);
//               }
//           }];
//      }
//                          failureBlock: ^(NSError *error)
//      {
//          // Typically you should handle an error more gracefully than this.
//          NSLog(@"No groups");
//      }];
//     
//     }
@end
