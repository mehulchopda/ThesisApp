/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  A view controller displaying a grid of assets.
  
 */
#import "GalleryViewController.h"
@import UIKit;
@import Photos;

@interface AAPLAssetGridViewController : UICollectionViewController
@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;
@property (nonatomic, weak) id<GalleryViewControllerProtocol> delegate;
@end
