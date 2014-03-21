//
//  IAmCoder.h
//  Ekoobot 3D
//
//  Created by Andrés Abril on 26/07/12.
//
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>


@interface IAmCoder : NSObject

+(NSString*)encodeURL:(NSString*)url;
+(NSString*)decodeURL:(NSString*)url;
+(NSString*)hash256:(NSString*)parameters;
+(NSString*)dateString;
+(NSData*)base64EncodeString:(NSString *)strData;
+(NSString*)base64String:(NSString*)str;
+ (NSString*) sha256:(NSString *)clear;
@end
