//
//  AccountSettingsViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 21/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "AccountSettingsViewController.h"

#import "ActionSheetStringPicker.h"
#import "PaymentManager.h"

typedef NS_ENUM(NSUInteger, AccountSettingsTextfieldsTag)
{
    AccountSettingsTextfieldsTagUsername,
    AccountSettingsTextfieldsTagAbout,
    AccountSettingsTextfieldsTagEmail,
    AccountSettingsTextfieldsTagGender,
    AccountSettingsTextfieldsTagDebitCardNo,
};

typedef NS_ENUM(NSUInteger, AccountSettingsAlertViewsTag)
{
    AccountSettingsAlertViewsTagSuccess,
    AccountSettingsAlertViewsTagChangePassword,
    AccountSettingsAlertViewsTagLogout,
};

@interface AccountSettingsViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tf_Username;
@property (weak, nonatomic) IBOutlet UITextField *tf_About;
@property (weak, nonatomic) IBOutlet UITextField *tf_Email;

@property (weak, nonatomic) IBOutlet UITextField *tf_Gender;
@property (weak, nonatomic) IBOutlet UIButton *btn_Gender;

@property (weak, nonatomic) IBOutlet UITextField *tf_DebitCardNo;

@property (nonatomic) PaymentModel *payment;

@end

@implementation AccountSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureUIComponents];
    
    Record *user = [Utility getUser];
    [self updateSettings:user];
}

- (IBAction)changePassword:(id)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change Password" message:@"Please enter the new password here" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
    [alertView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    
//    UITextField *tf = [alertView textFieldAtIndex:0];
//    [tf setDelegate:self];
    
    [alertView setTag:AccountSettingsAlertViewsTagChangePassword];
    [alertView show];
}

- (IBAction)logout:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Confirm" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alertView setTag:AccountSettingsAlertViewsTagLogout];
    [alertView show];
}

- (IBAction)save:(id)sender
{
    NSString *username = [[self.tf_Username text] length] ? [self.tf_Username text] : @"";
    NSString *about = [[self.tf_About text] length] ? [self.tf_About text] : @"";
    NSString *email = [[self.tf_Email text] length] ? [self.tf_Email text] : @"";
    NSString *gender = [[self.tf_Gender text] length] ? [[self.tf_Gender text] lowercaseString] : @"";
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"id":[[Utility getUser] idd], @"fname":username, @"about":about, @"email":email, @"gender":gender}];
    
    if (self.payment)
    {
        if ([self.payment isPaypal])
        {
            [parameters setValue:kPaypal forKey:@"payment_method"];
            [parameters setValue:[self.payment authToken] forKey:@"auth_token"];
        }
        else
        {
            [parameters setValue:kDebitCard forKey:@"payment_method"];
            [parameters setValue:[self.payment cardNumber] forKey:@"card_number"];
            [parameters setValue:[self.payment ccvCode] forKey:@"ccv"];
            [parameters setValue:[self.payment expiryDate] forKey:@"expiry"];
            [parameters setValue:[self.payment cardType] forKey:@"card_type"];
        }
    }
    
    [NetworkClient request:kN_EditProfile withParameters:parameters shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
    {
        [Utility hideHUD];
        
        if ([model isSuccess])
        {
            [Utility saveObjectInDefaults:[[model records] firstObject] withKey:@"User"];
            
            [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:self];
        }
        else
        {
            [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
        }
        
    }
    andErrorBlock:nil];
}

#pragma mark - Paypal button event
-(IBAction)paypal:(id)sender
{
    [[PaymentManager sharedManager] startPaypalProcess:self withCompletionBlock:^(PaymentModel *paymentModel)
    {
        //Send paypal auth_token from here
        self.payment = paymentModel;
    }];
}

- (IBAction)gender:(id)sender
{
    NSArray *gender = @[@"Male",
                        @"Female",
                        @"Other"];
    
    NSString *text = [self.tf_Gender text];
    NSInteger index_sel = 0;
    
    if ([text length])
    {
        index_sel = [gender indexOfObject:text];
    }
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Gender" rows:gender initialSelection:index_sel doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        [self.tf_Gender setText:[gender objectAtIndex:selectedIndex]];
    }
    cancelBlock:nil origin:sender];
}

#pragma mark - Textfield delegate method
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField tag] == AccountSettingsTextfieldsTagDebitCardNo)
    {
        [textField resignFirstResponder];
        
        [[PaymentManager sharedManager] startCardProcess:self withCompletionBlock:^(PaymentModel *paymentModel)
         {
             //Send credit card parameters from here
             self.payment = paymentModel;
             
             [self.tf_DebitCardNo setText:[paymentModel cardNumber]];
         }];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField tag] == AccountSettingsTextfieldsTagEmail)
    {
        if (![Utility isValidEmail:[textField text] Strict:YES])
        {
            [Utility showAlertWithTitle:@"Validation Error" message:@"Please enter correct email address or leave it blank" andDelegate:nil];
            [textField setText:@""];
        }
    }
}

#pragma mark - AlertView delegate method
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch ([alertView tag])
    {
        case AccountSettingsAlertViewsTagSuccess:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case AccountSettingsAlertViewsTagChangePassword:
        {
            if (buttonIndex != alertView.cancelButtonIndex)
            {
                NSString *password = [[alertView textFieldAtIndex:0] text];
                
                [NetworkClient request:kN_ChangePassword withParameters:@{@"user_id":[[Utility getUser] idd], @"password":password} shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
                {
                    [Utility hideHUD];
                    
                    [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
                }
                andErrorBlock:nil];
            }
            break;
        }
        case AccountSettingsAlertViewsTagLogout:
        {
            if (buttonIndex != alertView.cancelButtonIndex)
            {
                [Utility deleteObjectFromsDefaultsWithKey:@"User"];
                
                [self switchToLogin];
            }
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    /* Retrieve a text field at an index -
     raises NSRangeException when textFieldIndex is out-of-bounds.
     
     The field at index 0 will be the first text field
     (the single field or the login field),
     
     The field at index 1 will be the password field. */
    
    /*
     1> Get the Text Field in alertview
     
     2> Get the text of that Text Field
     
     3> Verify that text length
     
     4> return YES or NO Based on the length
     */
    
    if ([alertView tag] == AccountSettingsAlertViewsTagChangePassword)
    {
        return [[[alertView textFieldAtIndex:0] text] length] > 0;
    }
    return YES;
}

-(void)updateSettings:(Record *)user
{
    [self.tf_Username setText:[user fname]];
    [self.tf_About setText:[user about]];
    [self.tf_Email setText:[user email]];
    [self.tf_Gender setText:[[user gender] capitalizedString]];
}

-(void)configureUIComponents
{
    [self addLeftViewsInTextfields:@[self.tf_Username, self.tf_About, self.tf_Email, self.tf_Gender, self.tf_DebitCardNo] withImageNames:@[@"reg_user_icon", @"abt_icon", @"msg_icon", @"reg_user_icon", @"debit_icon"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
