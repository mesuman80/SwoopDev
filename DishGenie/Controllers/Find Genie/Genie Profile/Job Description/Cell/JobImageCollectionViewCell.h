//
//  JobImageCollectionViewCell.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 01/05/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobImageCollectionViewCell : UICollectionViewCell

-(void)updateCell:(UIImage *)image withDeletionBlock:(void(^)(void))deletionBlock;

@end
