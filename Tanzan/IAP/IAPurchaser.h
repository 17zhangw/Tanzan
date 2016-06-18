//
//  IAPurchaser.h
//  Tanzan
//
//  Created by williamzhang on 6/15/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol IAPurchaserDelegate
- (void)productPurchased;
- (void)productPurchaseCancelled;
- (void)productPurchaseFailed;

- (void)productReceived:(NSArray *)products;
@end

@interface IAPurchaser : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, assign) id<IAPurchaserDelegate> delegate;

- (void)requestProductInformation;
- (void)restorePurchases;
- (void)buyProduct:(SKProduct *)product;

@end
