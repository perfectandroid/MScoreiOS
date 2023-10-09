//
//  ViewController.m
//  encry
//
//  Created by Perfect on 20/10/18.
//  Copyright © 2018 PSS. All rights reserved.
//

#import "Encryption.h"
#import <CommonCrypto/CommonCrypto.h>

@interface Encryption ()

@end



@implementation NSString (URLEncoding)
- (nullable NSString *)stringByAddingPercentEncodingForRFC3986 {
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    return [self
            stringByAddingPercentEncodingWithAllowedCharacters:
            allowed];
}
@end



@implementation Encryption

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (long long)random8Numbers
{
    return [self randomNumber:10000000 to:100000000];
}
- (long long)randomNumber:(long long)from to:(long long)to
{
    return (long long)(from + arc4random() % (to - from + 1));
}
+ (NSString*)genRandomNum
{
    int maxNum = 36;
    int i;
    int count = 0;
    char str[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString* pwd = [[NSMutableString alloc] init];
    while (count < 8) {
        i = arc4random() % maxNum;
        if (i >= 0 && i < maxNum) {
            [pwd appendFormat:@"%@", [NSString stringWithFormat:@"%c",str[i]]];
            count++;
        }
    }
    return pwd;
}
- (NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key
{
    const Byte iv[] = {65, 103, 101,110,116, 115, 99, 114};
    NSData *textData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          [textData bytes], dataLength,
                                          buffer, 1024,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        NSString *ciphertext1 =[ data base64EncodedStringWithOptions:0] ;
//        [Base64 encode:data];
        NSString *escapedString = [ciphertext1 stringByAddingPercentEncodingForRFC3986];
        NSLog(@"escapedString: %@", escapedString);
        _myString = escapedString;
        return escapedString;
//        qs7wmgEv3pUUz3cdm9SqqA%3D%3D%0A
    }
    return @"";

}


- (NSString *)convertDataToHexStr:(NSData *)data
{
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


