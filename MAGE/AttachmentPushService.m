//
//  AttachmentPushService.m
//  mage-ios-sdk
//
//

#import "AttachmentPushService.h"
#import "Attachment.h"
#import "Observation.h"
#import "UserUtility.h"
#import "NSDate+Iso8601.h"
#import "StoredPassword.h"

NSString * const kAttachmentPushFrequencyKey = @"attachmentPushFrequency";
NSString * const kAttachmentBackgroundSessionIdentifier = @"mil.nga.mage.background.attachment";

@interface AttachmentPushService () <NSFetchedResultsControllerDelegate>
@property (nonatomic) NSTimeInterval interval;
@property (nonatomic, strong) NSTimer* attachmentPushTimer;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *pushTasks;
@property (nonatomic, strong) NSMutableDictionary *pushData;
@end

@implementation AttachmentPushService

+ (instancetype) singleton {
    static AttachmentPushService *pushService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pushService = [[self alloc] init];
    });
    return pushService;
}

- (id) init {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kAttachmentBackgroundSessionIdentifier];
    
    if (self = [super initWithSessionConfiguration:configuration]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        _interval = [[defaults valueForKey:kAttachmentPushFrequencyKey] doubleValue];
        _pushTasks = [NSMutableArray array];
        _pushData = [NSMutableDictionary dictionary];
        
        [self configureProgress];
        [self configureTaskReceivedData];
        [self configureTaskCompletion];
        [self configureBackgroundCompletion];
    }
    
    return self;
}

- (void) start {
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [StoredPassword retrieveStoredToken]] forHTTPHeaderField:@"Authorization"];
    
    self.fetchedResultsController = [Attachment MR_fetchAllSortedBy:@"lastModified"
                                                          ascending:NO
                                                      withPredicate:[NSPredicate predicateWithFormat:@"observationRemoteId != nil && dirty == YES"]
                                                            groupBy:nil
                                                           delegate:self
                                                          inContext:[NSManagedObjectContext MR_defaultContext]];
    
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.pushTasks = [NSMutableArray arrayWithArray:[uploadTasks valueForKeyPath:@"taskIdentifier"]];
            
            [self pushAttachments:self.fetchedResultsController.fetchedObjects];
            [self scheduleTimer];
        });
    }];
}

- (void) stop {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_attachmentPushTimer isValid]) {
            [_attachmentPushTimer invalidate];
            _attachmentPushTimer = nil;
        }
    });
    
    self.fetchedResultsController = nil;
}


- (void) scheduleTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.attachmentPushTimer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(onTimerFire) userInfo:nil repeats:YES];
    });
}

- (void) onTimerFire {
    if (![[UserUtility singleton] isTokenExpired]) {
        NSLog(@"ATTACHMENT - push timer fired, checking if any attachments need to be pushed");
        [Attachment MR_performFetch:self.fetchedResultsController];
        [self pushAttachments:self.fetchedResultsController.fetchedObjects];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id) anObject atIndexPath:(NSIndexPath *) indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *) newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"ATTACHMENT - attachment inserted, push em");
            [self pushAttachments:@[anObject]];
            break;
        default:
            break;
    }
}

- (void) pushAttachments:(NSArray *) attachments {
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [StoredPassword retrieveStoredToken]] forHTTPHeaderField:@"Authorization"];

    for (Attachment *attachment in attachments) {
        if ([self.pushTasks containsObject:attachment.taskIdentifier]) {
            // already pushing this attachment
            continue;
        }
        
        NSData *attachmentData = [NSData dataWithContentsOfFile:attachment.localPath];
        if (attachmentData == nil) {
            NSLog(@"Attachment data nil for observation: %@ at path: %@", attachment.observation.remoteId, attachment.localPath);
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                Attachment *localAttachment = [attachment MR_inContext:localContext];
                [localAttachment MR_deleteEntity];
            }];
            
            continue;
        }
        
        NSString *url = [NSString stringWithFormat:@"%@/%@", attachment.observation.url, @"attachments"];
        NSLog(@"pushing attachment %@", url);

        NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:attachment.localPath] name:@"attachment" fileName:attachment.name mimeType:attachment.contentType error:nil];
        } error:nil];
        
        NSURL *attachmentUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:attachment.name]];
        NSLog(@"ATTACHMENT - Creating tmp multi part file for attachment upload %@", attachmentUrl);
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            // update the attachment
            Attachment *localAttachment = [attachment MR_inContext:localContext];
            localAttachment.uploading = YES;
            localAttachment.uploadProgress = [NSNumber numberWithInt:0];
            attachment.observation.attachmentsLastUpdated = [NSDate date];
        } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
            // send the file
            [self.requestSerializer requestWithMultipartFormRequest:request writingStreamContentsToFile:attachmentUrl completionHandler:^(NSError * _Nullable error) {
                NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithRequest:request fromFile:attachmentUrl];
                
                NSNumber *taskIdentifier = [NSNumber numberWithLong:uploadTask.taskIdentifier];
                [self.pushTasks addObject:taskIdentifier];
                attachment.taskIdentifier = taskIdentifier;
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
                    NSLog(@"ATTACHMENT - Context did save %d with error %@", contextDidSave, error);
                    [uploadTask resume];
                }];
            }];
        }];
    }
}

- (void) configureProgress {
    [self setTaskDidSendBodyDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        double progress = (double) totalBytesSent / (double) totalBytesExpectedToSend;
        NSUInteger percent = (NSUInteger) (100.0 * progress);
        NSLog(@"ATTACHMENT - Upload %@ progress: %lu%%", task, (unsigned long)percent);
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * _Nonnull localContext) {
            // update the attachment
            Attachment *attachment = [Attachment MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"taskIdentifier == %@", [NSNumber numberWithLong:task.taskIdentifier]]
                                                                 inContext:localContext];
            attachment.uploadProgress = [NSNumber numberWithUnsignedInteger:percent];
            attachment.observation.attachmentsLastUpdated = [NSDate date];
        } completion:^(BOOL contextDidSave, NSError * _Nullable error) {
            NSLog(@"ATTACHMENT - Upload progress Context did save %d with error %@", contextDidSave, error);
        }];
    }];
}

- (void) attachmentUploadReceivedData:(NSData *) data forTask:(NSURLSessionDataTask *) task {
    NSLog(@"ATTACHMENT - upload received data for task %@", task);
    
    NSNumber *taskIdentifier = [NSNumber numberWithLong:task.taskIdentifier];
    NSMutableData *existingData = [self.pushData objectForKey:taskIdentifier];
    if (existingData) {
        [existingData appendData:data];
    } else {
        [self.pushData setObject:[data mutableCopy] forKey:taskIdentifier];
    }
}

- (void) attachmentUploadCompleteWithTask:(NSURLSessionTask *) task withError:(NSError *) error {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    Attachment *attachment = [Attachment MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"taskIdentifier == %@", [NSNumber numberWithLong:task.taskIdentifier]]
                                                         inContext:context];

    if (!attachment) {
        NSLog(@"ATTACHMENT - error completing attachment upload, could not retrieve attachment for task id %lu", (unsigned long)task.taskIdentifier);
        return;
    }
    attachment.uploading = NO;
    attachment.observation.attachmentsLastUpdated = [NSDate date];
    
    NSMutableDictionary *localError = [NSMutableDictionary dictionary];

    if (error) {
        
        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        if ([error localizedDescription]) {
            [localError setObject:[error localizedDescription] forKey:kAttachmentErrorDescription];
        }
        
        if (response) {
            [localError setObject:[NSNumber numberWithInteger:response.statusCode] forKey:kAttachmentErrorStatusCode];
            [localError setObject:[[NSString alloc] initWithData:(NSData *) error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding] forKey:kAttachmentErrorMessage];
        }
        
        attachment.error = localError;
        
        attachment.uploadStatus = [NSString stringWithFormat:@"Error uploading attachment %@", error];
        [context MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
            NSLog(@"ATTACHMENT - error uploading attachment %@", error);
        }];
        return;
    }
    
    if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        
        [localError setObject:[NSNumber numberWithInteger:httpResponse.statusCode] forKey:kAttachmentErrorStatusCode];

        if (httpResponse.statusCode >= 400 && httpResponse.statusCode < 600) {
            
            [localError setObject:[NSString stringWithFormat:@"Error uploading attachment %ld", (long)httpResponse.statusCode] forKey:kAttachmentErrorMessage];
            
            attachment.error = localError;
            
            attachment.uploadStatus = [NSString stringWithFormat:@"Error uploading attachment %ld", (long)httpResponse.statusCode];
            [context MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
                NSLog(@"Error uploading attachment. Status: %ld", (long)httpResponse.statusCode);
            }];
            return;
        }
    }
    
    NSData *data = [self.pushData objectForKey:[NSNumber numberWithLong:task.taskIdentifier]];
    if (!data) {
        [localError setObject:[error localizedDescription] forKey:kAttachmentErrorDescription];
        [localError setObject:@"Error uploading attachment, did not receive response from the server" forKey:kAttachmentErrorMessage];
        
        attachment.error = localError;
        
        attachment.uploadStatus = @"Error uploading attachment, did not receive response from the server";
        [context MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
            NSLog(@"ATTACHMENT - error uploading attachment, did not receive response from the server");
        }];
        return;
    }
    
    NSString *tmpFileLocation = [NSTemporaryDirectory() stringByAppendingPathComponent:attachment.name];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    attachment.uploadProgress = [NSNumber numberWithInt:100];
    attachment.uploadStatus = [NSString stringWithFormat:@"Successfully pushed on %@", [formatter stringFromDate:[NSDate date]]];
    attachment.dirty = [NSNumber numberWithBool:NO];
    attachment.remoteId = [response valueForKey:@"id"];
    attachment.name = [response valueForKey:@"name"];
    attachment.url = [response valueForKey:@"url"];
    attachment.taskIdentifier = nil;
    NSString *dateString = [response valueForKey:@"lastModified"];
    if (dateString != nil) {
        NSDate *date = [NSDate dateFromIso8601String:dateString];
        [attachment setLastModified:date];
    }
    
    if (attachment.url) {
        __weak __typeof__(self) weakSelf = self;

        [context MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
            [weakSelf.pushTasks removeObject:[NSNumber numberWithLong:task.taskIdentifier]];

            NSURL *attachmentUrl = [NSURL fileURLWithPath:tmpFileLocation];
            NSError *removeError;
            NSLog(@"ATTACHMENT - Deleting tmp multi part file for attachment upload %@", attachmentUrl);
            if (![[NSFileManager defaultManager] removeItemAtURL:attachmentUrl error:&removeError]) {
                NSLog(@"ATTACHMENT - Error removing temporary attachment upload file %@", removeError);
            }
        }];
    } else {
        // try again
        [self.pushTasks removeObject:[NSNumber numberWithLong:task.taskIdentifier]];
    }
}

- (void) configureTaskReceivedData {
    __weak __typeof__(self) weakSelf = self;
    [self setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        NSLog(@"ATTACHMENT - MageBackgroundSessionManager setDataTaskDidReceiveDataBlock");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf attachmentUploadReceivedData:data forTask:dataTask];
        });
    }];
}

- (void) configureTaskCompletion {
    __weak __typeof__(self) weakSelf = self;
    [self setTaskDidCompleteBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSError * _Nullable error) {
        NSLog(@"ATTACHMENT - MageBackgroundSessionManager calling setTaskDidCompleteBlock with error %@", error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf attachmentUploadCompleteWithTask:task withError:error];
        });
    }];
}

- (void) configureBackgroundCompletion {
    __weak __typeof__(self) weakSelf = self;
    [self setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession * _Nonnull session) {
        if (weakSelf.backgroundSessionCompletionHandler) {
            NSLog(@"ATTACHMENT - MageBackgroundSessionManager calling backgroundSessionCompletionHandler");
            void (^completionHandler)(void) = weakSelf.backgroundSessionCompletionHandler;
            weakSelf.backgroundSessionCompletionHandler = nil;
            completionHandler();
        }
    }];
}

@end

