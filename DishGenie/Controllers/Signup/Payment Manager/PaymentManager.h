//
//  PaymentManager.h
//  DishGenie
//
//  Created by Syed Muhammad Fakhir on 08/04/2015.
//  Copyright (c) 2015 DishGenie. All rights reserved.
//

/* This manager supports paypal future payments and debit/credit card payments */

#import <Foundation/Foundation.h>

@interface PaymentModel : NSObject

@property (nonatomic) BOOL isPaypal;

//Debit/Credit card model
@property (nonatomic) NSString *cardNumber;
@property (nonatomic) NSString *ccvCode;
@property (nonatomic) NSString *expiryDate;
@property (nonatomic) NSString *cardType;

//Paypal model
@property (nonatomic) NSString *authToken;

-(instancetype)initWithObject:(id)object;

@end

@interface PaymentManager : NSObject

+(instancetype)sharedManager;

-(void)startPaypalProcess:(id)client withCompletionBlock:(void(^)(PaymentModel *paymentModel))completionBlock;
-(void)startCardProcess:(id)client withCompletionBlock:(void(^)(PaymentModel *paymentModel))completionBlock;
-(NSString *)getClientMetadataId;

@end
