//
//  ALAttachmentService.m
//  Applozic
//
//  Created by Sunil on 25/09/18.
//  Copyright © 2018 applozic Inc. All rights reserved.
//

#import "ALAttachmentService.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALMessageClientService.h"
#import "ApplozicClient.h"
#import "ALMessageService.h"

@implementation ALAttachmentService


+(ALAttachmentService *)sharedInstance
{
    static ALAttachmentService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ALAttachmentService alloc] init];
    });
    return sharedInstance;
}


-(void)sendMessageWithAttachment:(ALMessage*) attachmentMessage withDelegate:(id<ApplozicUpdatesDelegate>) delegate withAttachmentDelegate:(id<ApplozicAttachmentDelegate>)attachmentProgressDelegate{
    
    if(!attachmentMessage || !attachmentMessage.imageFilePath){
        return;
    }
    self.delegate = delegate;
    self.attachmentProgressDelegate = attachmentProgressDelegate;
    
    CFStringRef pathExtension = (__bridge_retained CFStringRef)[attachmentMessage.imageFilePath pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    CFRelease(pathExtension);
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    
    attachmentMessage.fileMeta.contentType = mimeType;
    if( attachmentMessage.contentType == ALMESSAGE_CONTENT_VCARD){
        attachmentMessage.fileMeta.contentType = @"text/x-vcard";
    }
    NSData *imageSize = [NSData dataWithContentsOfFile:attachmentMessage.imageFilePath];
    attachmentMessage.fileMeta.size = [NSString stringWithFormat:@"%lu",(unsigned long)imageSize.length];
    
    //DB Addition

    ALMessageDBService *alMessageDbService = [[ALMessageDBService alloc]init];

    DB_Message *dbMessage =   [alMessageDbService addAttachmentMessage:attachmentMessage];

    NSDictionary * userInfo = [attachmentMessage dictionary];
    
    ALMessageClientService * clientService  = [[ALMessageClientService alloc]init];
    [clientService sendPhotoForUserInfo:userInfo withCompletion:^(NSString *responseUrl, NSError *error) {
        
        if (error)
        {
            
            [self.attachmentProgressDelegate onUploadFailed:[[ALMessageService sharedInstance] handleMessageFailedStatus:attachmentMessage]];
            return;
        }
        
        [ALMessageService proessUploadImageForMessage:attachmentMessage databaseObj:dbMessage.fileMetaInfo uploadURL:responseUrl  withdelegate:self];
    }];
    
}

-(void) downloadMessageAttachment:(ALMessage*)alMessage withDelegate:(id<ApplozicAttachmentDelegate>)attachmentProgressDelegate{
    
    self.attachmentProgressDelegate = attachmentProgressDelegate;
    
    [ALMessageService processImageDownloadforMessage:alMessage withDelegate:self withCompletionHandler:^(NSError *error) {
        if(error){
            [attachmentProgressDelegate onDownloadFailed:alMessage];
        }
    }];
}

-(void)connectionDidFinishLoading:(ALConnection *)connection{
    
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
    ALMessageDBService * dbService = [[ALMessageDBService alloc] init];
    
    
    if ([connection.connectionType isEqualToString:@"Image Posting"])
    {
        DB_Message * dbMessage = (DB_Message*)[dbService getMessageByKey:@"key" value:connection.keystring];
        ALMessage * message = [dbService createMessageEntity:dbMessage];
        if(!message)
        {
            DB_Message * dbMessage = (DB_Message*)[dbService getMessageByKey:@"key" value:connection.keystring];
            message = [dbService createMessageEntity:dbMessage];
        }
        NSError * theJsonError = nil;
        NSDictionary *theJson = [NSJSONSerialization JSONObjectWithData:connection.mData options:NSJSONReadingMutableLeaves error:&theJsonError];
        
        if(ALApplozicSettings.isS3StorageServiceEnabled){
            [message.fileMeta populate:theJson];
        }else{
            NSDictionary *fileInfo = [theJson objectForKey:@"fileMeta"];
            [message.fileMeta populate:fileInfo];
        }
        ALMessage * almessage =  [ALMessageService processFileUploadSucess:message];
        [[ALMessageService sharedInstance] sendMessages:almessage withCompletion:^(NSString *message, NSError *error) {
            
            if(error)
            {
                ALSLog(ALLoggerSeverityError, @"ERROR IN POSTING Data:: %@", error);
                if(self.attachmentProgressDelegate){
                    [self.attachmentProgressDelegate onUploadFailed:[[ALMessageService sharedInstance] handleMessageFailedStatus:almessage]];
                }
                return;
            }else{
                if(self.attachmentProgressDelegate){
                    [self.attachmentProgressDelegate onUploadCompleted:almessage];
                }
                if(self.delegate){
                    [self.delegate onMessageSent:almessage];
                }
            }
        }];
        
    }
    else if ([connection.connectionType isEqualToString:@"Thumbnail Downloading"])
    {
        ALMessage *almessage =  [dbService writeFileAndUpdateMessageInDb:connection withFileFlag:NO];

        if(self.attachmentProgressDelegate){
            [self.attachmentProgressDelegate onDownloadCompleted:almessage];
        }
    }else{
        
       ALMessage *almessage =  [dbService writeFileAndUpdateMessageInDb:connection withFileFlag:YES];

        if(self.attachmentProgressDelegate){
            [self.attachmentProgressDelegate onDownloadCompleted:almessage];
        }
        
    }
    
}

-(void)connection:(ALConnection *)connection didReceiveData:(NSData *)data{
    
    [connection.mData appendData:data];
    
    if ([connection.connectionType isEqualToString:@"Image Posting"])
    {
        ALSLog(ALLoggerSeverityInfo, @"File posting done");
        return;
    }
    if(self.attachmentProgressDelegate){
        ALMessage *message = [[ALMessageService sharedInstance]getMessageByKey:connection.keystring];
        [self.attachmentProgressDelegate onUpdateBytesDownloaded:connection.mData.length withMessage:message];
    }
    
}

-(void)connection:(ALConnection *)connection didSendBodyData:(NSInteger)bytesWritten
totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    //upload percentage
    if(self.attachmentProgressDelegate){
        ALMessage *message = [[ALMessageService sharedInstance]getMessageByKey:connection.keystring];
        [self.attachmentProgressDelegate onUpdateBytesUploaded:totalBytesWritten withMessage:message];
    }
}

//Error
-(void)connection:(ALConnection *)connection didFailWithError:(NSError *)error
{
    if(self.attachmentProgressDelegate){
        ALMessage *message = [[ALMessageService sharedInstance]getMessageByKey:connection.keystring];
        message = [[ALMessageService sharedInstance] handleMessageFailedStatus:message];
        if(message.imageFilePath){
            [self.attachmentProgressDelegate onUploadFailed:message];
        }else{
            [self.attachmentProgressDelegate onDownloadFailed:message];
        }
    }
    ALSLog(ALLoggerSeverityError, @"didFailWithError ::: %@",error);
    [[[ALConnectionQueueHandler sharedConnectionQueueHandler] getCurrentConnectionQueue] removeObject:connection];
}


@end
