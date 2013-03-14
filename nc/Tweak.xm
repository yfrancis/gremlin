#import <BulletinBoard/BulletinBoard.h>
#import <Gremlin/Gremlin.h>
#import <Gremlin/GRManifestListener.h>
#import <Gremlin/GRTask.h>

@interface  BBGremlinProvider : NSObject <BBDataProvider, GRManifestListenerDelegate>
{
	NSMutableArray* _bulletins;
}

@property (nonatomic, retain) NSMutableArray* bulletins;

@end

static BBGremlinProvider* _sharedProvider;

@implementation BBGremlinProvider
@synthesize bulletins = _bulletins;

+ (BBGremlinProvider*)sharedProvider {
	return [[_sharedProvider retain] autorelease];
}

- (id)init {
	if((self = [super init])) {
		_sharedProvider = self;
	}

	return self;
}

- (void)dealloc {
	[GRManifestListener stopListening];
	_sharedProvider = nil;
	[super dealloc];
}

- (NSString*)sectionIdentifier {
	return @"co.cocoanuts.gremlin";
}

- (NSArray *)sortDescriptors {
	return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
}

- (NSArray *)bulletinsFilteredBy:(unsigned)by count:(unsigned)count lastCleared:(id)cleared {
	return nil;
}

- (NSString *)sectionDisplayName {
	return @"Gremlin";
}

- (id)defaultSectionInfo {
	id sectionInfo = [%c(BBSectionInfo) defaultSectionInfoForType:0];
	[sectionInfo setNotificationCenterLimit:10];
	[sectionInfo setSectionID:[self sectionIdentifier]];
	return sectionInfo;
}

- (void)dataProviderDidLoad {
	NSLog(@"dataProviderDidLoad:");

	[GRManifestListener stopListening];
	[GRManifestListener startListening:self];
}

- (void)manifestTasksUpdated:(NSArray*)tasks
{
	NSLog(@"manifestTasksUpdated: %@", tasks);
	for(GRTask* task in tasks)
	{
		id bulletin = [[BBBulletinRequest alloc] init];
		// these are mandatory
		[bulletin setSectionID:[@"co.cocoanuts.gremlin/" stringByAppendingString:task.uuid]];
		[bulletin setRecordID:[@"co.cocoanuts.gremlin/" stringByAppendingString:task.uuid]];
		[bulletin setPublisherBulletinID:[@"co.cocoanuts.gremlin/" stringByAppendingString:task.uuid]];

		[bulletin setTitle:@"Import Complete"];
		[bulletin setMessage:[NSString stringWithFormat:@"%@ successfully imported into %@.", [task.metadata objectForKey:@"title"], task.destination]];
		[bulletin setDate:[NSDate date]];

		void (*ff)(id, id);
		*(void**)(&ff) = dlsym(RTLD_DEFAULT, "BBDataProviderAddBulletin");
		(*ff)(self, bulletin);
	
		[bulletin release];
	}
}

- (void)manifestServerReset
{
	NSLog(@"manifestServerReset");
}

@end

MSInitialize
{
	dlopen("/Library/Frameworks/Gremlin.framework/Gremlin", 2);
}
