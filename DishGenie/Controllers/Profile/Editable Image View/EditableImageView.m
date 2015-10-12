//
//  EditableImageView.m
//  DigitalDay
//
//  Created by Syed Muhammad Fakhir on 11/9/14.
//  Copyright (c) 2014 Syed Muhammad Fakhir. All rights reserved.
//

#import "EditableImageView.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface EditableImageView () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation EditableImageView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[[UIActionSheet alloc] initWithTitle:@"Select Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:(self.isImageSelected ? @"Delete" : nil) otherButtonTitles:@"Camera", @"Library", nil] showInView:self];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!self.isImageSelected)
    {
        buttonIndex++;
    }
    
    if (buttonIndex == 0)
    {
        //delete
        [self resetImageSelection];
    }
    else if (buttonIndex == 1)
    {
        //camera
        [self startCameraControllerFromViewController:self.controller usingDelegate:self];
    }
    else if (buttonIndex == 2)
    {
        //gallery
        [self startMediaBrowserFromViewController:self.controller usingDelegate:self];
    }
}

#pragma mark - UIImagePickerController delegate methods
// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    if ([info objectForKey:UIImagePickerControllerReferenceURL])
    {
        NSURL *imageURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            CGImageRef iref = [rep fullResolutionImage];
            if (iref)
            {
                UIImage *image = [UIImage imageWithCGImage:iref scale:0.5 orientation:(UIImageOrientation)[rep orientation]];
                
                [self setImage:image];
                self.isImageSelected = YES;
                
                [self uploadImageToServer:image];
                
                //[self setImageOnServer:image];
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"%@",[myerror localizedDescription]);
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:imageURL resultBlock:resultblock failureBlock:failureblock];
    }
    else
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        [self setImage:image];
        self.isImageSelected = YES;
        
        
        [self uploadImageToServer:image];
        
        //[self setImageOnServer:image];
        
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        
        UIImage *originalImage, *editedImage, *imageToSave;
        
        // Handle a still image capture
        if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
        {
            editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
            
            originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
            
            if (editedImage)
            {
                imageToSave = editedImage;
            }
            else
            {
                imageToSave = originalImage;
            }
            
            // Save the new image (original or edited) to the Camera Roll
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil , nil);
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Media utilities
-(BOOL)startCameraControllerFromViewController:(UIViewController*) controller usingDelegate:(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) || (delegate == nil) || (controller == nil))
        return NO;
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    
    // movie capture, if both are available:
    
    //    cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    if ([UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera])
    {
        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    }
    
    // Hides the controls for moving & scaling pictures, or for
    
    // trimming movies. To instead show the controls, use YES.
    
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

-(BOOL)startMediaBrowserFromViewController: (UIViewController*) controller usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) || (delegate == nil) || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    
    // Camera Roll album.
    
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    
    // trimming movies. To instead show the controls, use YES.
    
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    
    return YES;
}


-(void)resetImageSelection
{
    [self setImage:[UIImage imageNamed:@"img_placeholder"]];
    self.isImageSelected = NO;
}


-(void)uploadImageToServer:(UIImage *)image{
    
    //NSData * data  = [image getCompressedImageData];
    //NSString * str = [[NSString alloc] initWithData: [data bytes] encoding: NSUTF8StringEncoding];
    
    
    
    NSData *dataImage = [[NSData alloc] init];
    dataImage = UIImageJPEGRepresentation(image, .3);
    NSString *stringImage = [dataImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      @"id":@"1",
                                                                                      @"AuthToken" : @"AUT-PWD",
                                                                                      @"image_data":stringImage,
                                                                                      @"imagethumbnail_data":@"dcba"}];
    
    [NetworkClient putRequest:kN_Registration withParameters:parameters shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
         {
             [Utility hideHUD];
             
             if ([model isSuccess])
             {
                 NSLog(@"model  %@", model);
                 
                 //[Utility saveObjectInDefaults:[[model records] firstObject] withKey:@"User"];
             }
             else
             {
                 [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
             }
         }
         andErrorBlock:^(NSString *requestMethod, NSError *error){
             
              NSLog(@"error  %@", error);
         }];

}


-(void)setImageOnServer:(UIImage *)image
{
     Record *rcd = [Utility getObjectFromDefaultsWithKey:@"User"];
     NSString* userName=rcd.username ;
     NSString *postStr = [NSString stringWithFormat:@"%@/?userid=%@&flag=2",kN_UserProfilePic, @"4"];
    
    [NetworkClient requestMultiPart:postStr withParameters:@{@"id":[[Utility getUser] idd], @"is_image":@"yes"} shouldShowProgressIndicator:YES imageInfo:@{@"images":@[[image getCompressedImageData]]} responseBlock:^(NSString *requestMethod, id model)
    {
        [Utility hideHUD];
        
        if ([model isSuccess])
        {
            [self setImageWithResizeURL:[[[model records] firstObject] thumb_image] placeholderImage:[UIImage imageNamed:@"img_placeholder"] usingActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
        }
        else
        {
            [self resetImageSelection];
        }
        
        [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
    }
    andErrorBlock:nil];
}

@end
