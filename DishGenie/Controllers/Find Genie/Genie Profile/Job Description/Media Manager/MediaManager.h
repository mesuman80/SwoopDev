//
//  MediaManager.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 20/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaManager : NSObject

-(void)openMedia:(id)delegate withCompletionBlock:(void (^)(UIImage *image))completionBlock;

@end
