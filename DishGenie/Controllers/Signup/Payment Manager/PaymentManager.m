//
//  PaymentManager.m
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 08/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

#import "PaymentManager.h"
#import "PayPalMobile.h"
#import "PayPalFuturePaymentViewController.h"
#import "CardIO.h"

@interface PaymentManager () <PayPalFuturePaymentDelegate, CardIOPaymentViewControllerDelegate>

@property (nonatomic) PayPalConfiguration *payPalConfig;

@end

@implementation PaymentManager
{
    id client;
    void(^clientCompletionBlock)(PaymentModel *);
}

+(instancetype)sharedManager
{
    static PaymentManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        // Set up payPalConfig
        _payPalConfig = [[PayPalConfiguration alloc] init];
        _payPalConfig.acceptCreditCards = YES;
        _payPalConfig.merchantName = @"Dish Genie";
        _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
        _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
        
        // Setting the languageOrLocale property is optional.
        //
        // If you do not set languageOrLocale, then the PayPalPaymentViewController will present
        // its user interface according to the device's current language setting.
        //
        // Setting languageOrLocale to a particular language (e.g., @"es" for Spanish) or
        // locale (e.g., @"es_MX" for Mexican Spanish) forces the PayPalPaymentViewController
        // to use that language/locale.
        //
        // For full details, including a list of available languages and locales, see PayPalPaymentViewController.h.
        
        _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
        
        // Setting the payPalShippingAddressOption property is optional.
        //
        // See PayPalConfiguration.h for details.
        
        _payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
        
        // use default environment, should be Production in real life
        [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentNoNetwork];
        
        NSLog(@"PayPal iOS SDK version: %@", [PayPalMobile libraryVersion]);
    }
    return self;
}

-(void)startCardProcess:(id)clientController withCompletionBlock:(void (^)(PaymentModel *))completionBlock
{
    client = clientController;
    clientCompletionBlock = completionBlock;
    
    [CardIOUtilities preload];
    
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    [clientController presentViewController:scanViewController animated:YES completion:nil];
}

-(NSString *)getClientMetadataId
{
    return [PayPalMobile clientMetadataID];
}

-(void)startPaypalProcess:(id)clientController withCompletionBlock:(void (^)(PaymentModel *))completionBlock
{
    client = clientController;
    clientCompletionBlock = completionBlock;
    
    PayPalFuturePaymentViewController *futurePaymentViewController = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:self.payPalConfig delegate:self];
    [clientController presentViewController:futurePaymentViewController animated:YES completion:nil];
}

#pragma mark - PayPalFuturePaymentDelegate methods
- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization
{
    [self sendFuturePaymentAuthorizationToServer:futurePaymentAuthorization];
    [client dismissViewControllerAnimated:YES completion:nil];
}

- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController
{
    [client dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendFuturePaymentAuthorizationToServer:(NSDictionary *)authorization
{
    NSLog(@"Paypal: %@", authorization);
    
    PaymentModel *paymentModel = [[PaymentModel alloc] initWithObject:@{@"auth":[[authorization valueForKey:@"response"] valueForKey:@"code"]}];
    
    if (clientCompletionBlock)
    {
        clientCompletionBlock(paymentModel);
    }
}

#pragma mark - CardIO delegate methods
- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController
{
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController
{
    PaymentModel *paymentModel = [[PaymentModel alloc] initWithObject:@{@"card":[info cardNumber], @"ccv":[info cvv], @"expiry":[NSString stringWithFormat:@"%@/%@", [@([info expiryMonth]) stringValue], [@([info expiryYear]) stringValue]], @"type":[CardIOCreditCardInfo displayStringForCardType:[info cardType] usingLanguageOrLocale:@"en-US"]}];
    
    if (clientCompletionBlock)
    {
        clientCompletionBlock(paymentModel);
    }
    
    // Use the card info...
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation PaymentModel

-(instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self)
    {
        if ([[[object allKeys] firstObject] isEqualToString:@"auth"])
        {
            self.isPaypal = YES;
            
            self.authToken = [object valueForKey:@"auth"];
        }
        else
        {
            self.cardNumber = [object valueForKey:@"card"];
            self.ccvCode = [object valueForKey:@"ccv"];
            self.expiryDate = [object valueForKey:@"expiry"];
            self.cardType = [object valueForKey:@"type"];
        }
    }
    return self;
}

@end
