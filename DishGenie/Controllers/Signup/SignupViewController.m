//
//  SignupViewController.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 22/03/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "SignupViewController.h"
#import "HMSegmentedControl.h"
#import "PaymentManager.h"
#import "LocationManager.h"
#import "CountryTableView.h"


#define ACCEPTABLE_CHARECTERS @"0123456789"


@interface SignupViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tf_Countrycode;

@property (weak, nonatomic) IBOutlet UITextField *tf_Username;
@property (weak, nonatomic) IBOutlet UITextField *tf_Password;
@property (weak, nonatomic) IBOutlet UITextField *tf_RetypePassword;

@property (weak, nonatomic) IBOutlet UITextField *tf_DebitCardNo;

//@property (weak, nonatomic) IBOutlet HMSegmentedControl *segmentedControl;

@property (nonatomic) PaymentModel *payment;

@end

@implementation SignupViewController
{
    BOOL isGeneralUser;
    UITextField *emailTextField;
    UITextField *activeTextField;
    UITextField *countryCodeTextField;
    
    NSString *userName ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tf_DebitCardNo.tag=5;
    
    [self setInputView];
    
    [self configureUIComponents];
}

-(void)setInputView{
    
    
    
    [self.tf_Countrycode setText:[self countryCode]];
    [self.tf_Countrycode setDelegate:self];
    self.tf_Countrycode.textAlignment = NSTextAlignmentLeft;
    [self.tf_Countrycode setUserInteractionEnabled:YES];
    
    
        
    [self.tf_Username setPlaceholder:@"(000) 000-0000"];
    [self.tf_Username setKeyboardType:UIKeyboardTypeNumberPad];
    self.tf_Username.delegate = self;
    self.tf_Username.tag=1;
   // objectType =
}


- (IBAction)submit:(id)sender
{
    [self.view endEditing:YES];
    
    if ([[self.tf_Username text] length] && [[self.tf_Password text] length] && [[self.tf_RetypePassword text] length])
    {
        if ([[self.tf_Password text] isEqualToString:[self.tf_RetypePassword text]])
        {
            if (!self.payment)
            {   
                [[LocationManager sharedManager] fetchLocationWithCompletionBlock:^(NSString *lat, NSString *lon)
                {
                    
                    NSString *phoneNumberWithCountryCode = [NSString stringWithFormat:@"%@-%@",self.tf_Countrycode.text,self.tf_Username.text];
                    
                    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
                    userName = [[phoneNumberWithCountryCode componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
                    
                    phoneNumberWithCountryCode = [phoneNumberWithCountryCode stringByTrimmingCharactersInSet: [NSCharacterSet symbolCharacterSet]];

                    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"username":userName,
                                                            @"password":[self.tf_Password text], @"LoginType": kGeneralUser,
                                                            @"latitude":lat, @"longitude":lon, @"device_type":kDeviceType,
                                                            @"device_token":[Utility getObjectFromDefaultsWithKey:@"DeviceToken"],
                                                            @"AuthToken" : @"AUT-PWD",
                                                            @"image_data":@"abcd",
                                                            @"imagethumbnail_data":@"dcba"}];
                    
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
                    
                    [NetworkClient request:kN_Registration withParameters:parameters shouldShowProgressIndicator:YES responseBlock:^(NSString *requestMethod, id model)
                    {
                        [Utility hideHUD];
                        
                        if ([model isSuccess])
                        {
                            [Utility saveObjectInDefaults:[[model records] firstObject] withKey:@"User"];
                            [self switchToTabbar];
                        }
                        else
                        {
                            [Utility showAlertWithTitle:[model messageStatus] message:[model messageContent] andDelegate:nil];
                        }
                    }
                    andErrorBlock:nil];
                }];
            }
            else
            {
                [Utility showAlertWithTitle:@"Error" message:@"Please specify payment method" andDelegate:nil];
            }
        }
        else
        {
            [Utility showAlertWithTitle:@"Validation Error" message:@"Mismatched password" andDelegate:nil];
        }
    }
    else
    {
        [Utility showAlertWithTitle:@"Validation Error" message:@"Please enter all required fields" andDelegate:nil];
    }
}

#pragma mark - Textfield delegate method
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if(textField.tag==5){
        [textField resignFirstResponder];
        [[PaymentManager sharedManager] startCardProcess:self withCompletionBlock:^(PaymentModel *paymentModel)
         {
             //Send credit card parameters from here
             self.payment = paymentModel;
             [self.tf_DebitCardNo setText:[paymentModel cardNumber]];
         }];
    }
    
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

-(void)configureUIComponents
{
    
    //self.segmentedControl.alpha=0.0;
    
//    [self.segmentedControl commonInit];
//    [self.segmentedControl setBackgroundColor:[UIColor clearColor]];
//    
//    [self.segmentedControl setSectionImages:@[[UIImage imageNamed:@"dish_btn_inactive"], [UIImage imageNamed:@"general_btn_inactive"]]];
//    [self.segmentedControl setSectionSelectedImages:@[[UIImage imageNamed:@"dish_btn_active"], [UIImage imageNamed:@"general_btn_active"]]];
//    
//    [self.segmentedControl setType:HMSegmentedControlTypeImages];
//    [self.segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleFullWidthStripe];
//    [self.segmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationNone];
//    
//    [self.segmentedControl setIndexChangeBlock:^(NSInteger index)
//    {
//        isGeneralUser = index;
//    }];
    
    isGeneralUser = index;
    
    [self addLeftViewsInTextfields:@[self.tf_Countrycode, self.tf_Username, self.tf_Password, self.tf_RetypePassword, self.tf_DebitCardNo] withImageNames:@[@"reg_user_icon",@"reg_user_icon", @"log_lock_icon", @"log_lock_icon", @"debit_icon"]];
}

- (IBAction)openCOuntryTable:(id)sender {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"]];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];

    CountryTableView *countryTableView =  [[CountryTableView alloc]init];
    [countryTableView  setDelegate:self];
    countryTableView.countryList =(NSArray *)parsedObject;
    [self presentViewController:countryTableView animated:YES completion:nil];
    
}


-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];

    int length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        //NSLog(@"%@", mobileNumber);
    }
    return mobileNumber;
}


- (BOOL)textField:(UITextField *)textField1 shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField1.tag==1)
    {
        
        if (self.tf_Username.keyboardType == UIKeyboardTypeNumberPad)
        {
            if ([string rangeOfCharacterFromSet:[[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet]].location != NSNotFound)
            {
                // BasicAlert(@"", @"This field accepts only numeric entries.");
                return NO;
            }
        }
        
        
        int length = [self getLength:textField1.text];
        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }
        
        if(length == 3)
        {
            NSString *num = [self formatNumber:textField1.text];
            textField1.text = [NSString stringWithFormat:@"(%@) ",num];
            if(range.length > 0)
                textField1.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField1.text];
            textField1.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                self.tf_Username.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }

        return YES;
    }
    else
    {
        return YES;
    }
    return NO;
}

-(int)getLength:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    
    return length;
    
    
}

-(void)setCountryCode:(NSString *)countryCode
{
    // [countryCodeTable removeFromSuperview];
    self.tf_Countrycode.text = countryCode;
    //[self.tf_Countrycode sizeThatFits:CGSizeMake(self.tf_Countrycode.frame.size.width, self.tf_Countrycode.frame.size.height)];
}

-(NSString *)countryCode
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSDictionary *dict=[self dictCountryCodes];
    NSString *numberString = [NSString stringWithFormat:@"+%@",[dict objectForKey:countryCode]];
    return numberString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(NSDictionary *)dictCountryCodes
{
    NSDictionary *dictCodes = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"93", @"AF",@"20",@"EG", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                               @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                               @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                               @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                               @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                               @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                               @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                               @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                               @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                               @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                               @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                               @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                               @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                               @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                               @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                               @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                               @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                               @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                               @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                               @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                               @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                               @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                               @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                               @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                               @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                               @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                               @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                               @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                               @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                               @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                               @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                               @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                               @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                               @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                               @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                               @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                               @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                               @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                               @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                               @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                               @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                               @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                               @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                               @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                               @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                               @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                               @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                               @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                               @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                               @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                               @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                               @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                               @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                               @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                               @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                               @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                               @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                               @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                               @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                               @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    return dictCodes;
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
