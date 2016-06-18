//
//  IAPurchaser.m
//  Tanzan
//
//  Created by williamzhang on 6/15/16.
//  Copyright © 2016 William-Trademarks. All rights reserved.
//

#import "IAPurchaser.h"

@interface IAPurchaser ()

@property (nonatomic, strong) NSArray * productIDs;
@property (nonatomic, strong) NSArray * products;

@end

@implementation IAPurchaser

- (id)init {
    if ((self = [super init])) {
        self.productIDs = [NSArray arrayWithObject:@"Diecaster.ProV"];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)requestProductInformation {
    if ([SKPaymentQueue canMakePayments]) {
        NSSet * identifiers = [NSSet setWithArray:self.productIDs];
        SKProductsRequest * req = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
        req.delegate = self;
        [req start];
    } else NSLog(@"Unable to make payments...");
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if ([response.products count] != 0) {
        self.products = [response products];
        [self.delegate productReceived:self.products];
    } else NSLog(@"There are no products...");
    
    if ([response.invalidProductIdentifiers count] != 0) {
        NSLog(@"Invalid Identifiers: %@",response.invalidProductIdentifiers);
    }
}

- (void)buyProduct:(SKProduct *)product {
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction * trans in transactions) {
        switch (trans.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:trans];
                break;
            case SKPaymentTransactionStateFailed:
                break;
            case SKPaymentTransactionStateRestored:
                [self completeTransaction:trans];
                break;
            case SKPaymentTransactionStateDeferred:
            case SKPaymentTransactionStatePurchasing:
                break;
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[transaction payment] productIdentifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self.delegate productPurchased];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    BOOL isCancel = [[transaction error] code] == SKErrorPaymentCancelled;
    NSLog(@"Transaction Error: %@",[[transaction error] localizedDescription]);
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if (isCancel) [self.delegate productPurchaseCancelled];
    else [self.delegate productPurchaseFailed];
}

- (void)restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
