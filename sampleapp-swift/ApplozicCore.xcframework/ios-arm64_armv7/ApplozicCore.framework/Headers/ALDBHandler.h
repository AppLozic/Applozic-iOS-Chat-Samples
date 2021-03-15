//
//  ALDBHandler.h
//  ChatApp
//
//  Created by Gaurav Nigam on 09/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DB_CONTACT.h"

@class ALContact;
static NSString *const AL_SQLITE_FILE_NAME = @"AppLozic.sqlite";

@interface ALDBHandler : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSPersistentContainer *persistentContainer;

@property (nonatomic) BOOL isStoreLoaded;

- (NSError *)saveContext;

+(ALDBHandler *) sharedInstance;

- (void)saveWithContext:(NSManagedObjectContext*)context
                       completion:(void (^)(NSError*error))completion;

-(NSArray *)executeFetchRequest:(NSFetchRequest *)fetchrequest withError:(NSError **)fetchError;

-(NSEntityDescription *)entityDescriptionWithEntityForName:(NSString *)name;

-(NSUInteger)countForFetchRequest:(NSFetchRequest *)fetchrequest;

-(NSManagedObject*)existingObjectWithID:(NSManagedObjectID *)objectID;

-(NSManagedObject *)insertNewObjectForEntityForName:(NSString *) entityName;

-(NSManagedObject *)insertNewObjectForEntityForName:(NSString *) entityName withManagedObjectContext:(NSManagedObjectContext *) context;

-(void) deleteObject:(NSManagedObject *) managedObject;

-(NSBatchUpdateResult *)executeRequestForNSBatchUpdateResult:(NSBatchUpdateRequest *)updateRequest withError: (NSError **)fetchError;

@end
