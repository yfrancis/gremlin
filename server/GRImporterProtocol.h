typedef void (^GRImportOperationBlock)(void);
typedef void (^GRImportCompletionBlock)(NSDictionary* info);

@protocol GRImporter <NSObject>

+ (GRImportOperationBlock)newImportBlockWithInfo:(NSDictionary*)info 
                                    successBlock:(GRImportCompletionBlock)succ
                                    failureBlock:(GRImportCompletionBlock)fail;

@end
