//
//  ALUtilityClass.h
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ALMessage.h"

@interface ALUtilityClass : NSObject

+ (NSString *) formatTimestamp:(NSTimeInterval) timeInterval toFormat:(NSString *) forMatStr;

+ (NSString *)generateJsonStringFromDictionary:(NSDictionary *)dictionary;

+ (BOOL)isToday:(NSDate *)todayDate;

+ (NSString*) fileMIMEType:(NSString*) filePath;

+(CGSize)getSizeForText:(NSString *)text maxWidth:(CGFloat)width font:(NSString *)fontName fontSize:(float)fontSize;

+(NSString*)getLocationUrl:(ALMessage*)almessage;

+(NSString*)getLocationUrl:(ALMessage*)almessage size: (CGRect) withSize;

+(void)thirdDisplayNotificationTS:(NSString *)toastMessage andForContactId:(NSString *)contactId withGroupId:(NSNumber*) groupID completionHandler:(void (^)(BOOL))handler;

+(NSString *)getFileNameWithCurrentTimeStamp;

@property (nonatomic, strong) NSString *msgdate;
@property (nonatomic, strong) NSString *msgtime;

-(void)getExactDate:(NSNumber *)dateValue;
+(BOOL)isThisDebugBuild;

+(NSString *)getDevieUUID;
+(BOOL)checkDeviceKeyString:(NSString *)string;
+(NSString *)stringFromTimeInterval:(NSTimeInterval)interval;
+(NSString *)getFileExtensionWithFileName:(NSString *)fileName;
+(NSURL *)getDocumentDirectory;
+(NSURL *)getAppsGroupDirectory;
+(NSURL *)getAppsGroupDirectoryWithFilePath:(NSString *) path;
+(NSURL *)getApplicationDirectoryWithFilePath:(NSString*) path;
+(NSData *)compressImage:(NSData *) data;
+(NSURL *)moveFileToDocumentsWithFileURL:(NSURL *)url;

@end
