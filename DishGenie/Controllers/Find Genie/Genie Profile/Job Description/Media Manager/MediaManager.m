//
//  MediaManager.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 20/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "MediaManager.h"
#import "FDTakeController.h"

@interface MediaManager () <FDTakeDelegate>

@end

@implementation MediaManager
{
    FDTakeController *takeController;
    
    void(^didCompleteBlock)(UIImage *image);
}

-(FDTakeController *)getTakeController
{
    if (!takeController)
    {
        takeController = [[FDTakeController alloc] init];
        takeController.delegate = self;
        // You can optionally override action sheet titles
        	takeController.takePhotoText = @"Camera";
        //	self.takeController.takeVideoText = @"Take Video";
        //	self.takeController.chooseFromPhotoRollText = @"Choose Existing";
        	takeController.chooseFromLibraryText = @"Library";
        //	self.takeController.cancelText = @"Cancel";
        //	self.takeController.noSourcesText = @"No Photos Available";
        
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"FDTakeTranslations"];
        NSLog(@"%@", myBundle);
        NSString *str = NSLocalizedStringFromTableInBundle(@"noSources",
                                                           nil,
                                                           [NSBundle bundleWithIdentifier:@"FDTakeTranslations"],
                                                           @"There are no sources available to select a photo");
        NSLog(@"%@", str);
    }
    return takeController;
}

-(void)openMedia:(id)delegate withCompletionBlock:(void (^)(UIImage *))completionBlock
{
    didCompleteBlock = completionBlock;
    
    [[self getTakeController] takePhotoOrChooseFromLibrary];
}

#pragma mark - FDTake delegate methods
- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
    if (didCompleteBlock)
    {
        didCompleteBlock(photo);
    }
}

@end
