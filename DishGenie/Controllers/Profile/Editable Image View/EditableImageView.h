//
//  EditableImageView.h
//  DigitalDay
//
//  Created by Syed Muhammad Fakhir on 11/9/14.
//  Copyright (c) 2014 Syed Muhammad Fakhir. All rights reserved.
//

#import "NZCircularImageView.h"

@interface EditableImageView : NZCircularImageView

@property (nonatomic) id controller;

-(void)resetImageSelection;

@property (nonatomic) BOOL isImageSelected;

//Camera
- (void)imagePickerControllerDidCancel: (UIImagePickerController *) picker;
- (void)imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info;

@end
