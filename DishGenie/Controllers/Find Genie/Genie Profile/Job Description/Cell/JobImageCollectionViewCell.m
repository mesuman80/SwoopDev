//
//  JobImageCollectionViewCell.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 01/05/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "JobImageCollectionViewCell.h"

@implementation JobImageCollectionViewCell
{
    void(^didDeleteBlock)(void);
}

-(void)updateCell:(UIImage *)image withDeletionBlock:(void(^)(void))deletionBlock
{
    didDeleteBlock = deletionBlock;
    
    UIImageView *imgView = (UIImageView *)[[self contentView] viewWithTag:1];
    [imgView setImage:image];
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return action == @selector(delete:);
}

-(void)delete:(id)sender
{
    if (didDeleteBlock)
    {
        didDeleteBlock();
        didDeleteBlock = nil;
    }
}

@end
