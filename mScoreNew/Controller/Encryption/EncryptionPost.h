//
//  ViewController.h
//  encry
//
//  Created by Perfect on 20/10/18.
//  Copyright © 2018 PSS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EncryptionPost : UIViewController

@property (nonatomic, strong) NSString *myString;
- (NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key;
@end

