#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@class BBSectionInfo, BBThumbnailSizeConstraints;

@protocol BBDataProvider <NSObject>
-(NSString *)sectionIdentifier;
-(NSArray *)sortDescriptors;
-(NSArray *)bulletinsFilteredBy:(unsigned)by count:(unsigned)count lastCleared:(id)cleared;
@optional
-(NSString *)sectionDisplayName;
-(void)dataProviderDidLoad;
-(CGFloat)attachmentAspectRatioForRecordID:(NSString *)recordID;
-(NSData *)attachmentPNGDataForRecordID:(NSString *)recordID sizeConstraints:(BBThumbnailSizeConstraints *)sizeConstraints;
-(BBSectionInfo *)defaultSectionInfo;
-(id)sectionParameters;
-(id)clearedInfoForBulletins:(NSArray *)bulletins;
-(id)clearedInfoForBulletins:(NSArray *)bulletins lastClearedInfo:(id)info;
@end

@interface BBAction : NSObject <NSCopying, NSCoding> {
@private
	id _internalBlock;
	BOOL _hasCallblock;
	BOOL _canBypassPinLock;
	NSURL* _launchURL;
	NSString* _launchBundleID;
	int replyType;
}
@property(assign, nonatomic) int replyType;
@property(assign, nonatomic) BOOL hasCallblock;
@property(copy, nonatomic) id internalBlock;
@property(assign, nonatomic) BOOL canBypassPinLock;
@property(copy, nonatomic) NSString* launchBundleID;
@property(retain, nonatomic) NSURL* launchURL;
+(id)actionWithTextReplyCallblock:(id)textReplyCallblock;
+(id)actionWithLaunchBundleID:(id)launchBundleID callblock:(id)callblock;
+(id)actionWithLaunchURL:(id)launchURL callblock:(id)callblock;
+(id)actionWithCallblock:(id)callblock;
-(id)description;
-(void)encodeWithCoder:(id)coder;
-(id)initWithCoder:(id)coder;
-(id)copyWithZone:(NSZone*)zone;
-(id)partialDescription;
-(void)deliverResponse:(id)response;
-(id)bundleID;
-(id)url;
-(BOOL)isAppLaunchAction;
-(BOOL)isURLLaunchAction;
-(BOOL)wantsTextReply;
-(BOOL)hasLaunchInfo;
-(void)dealloc;
-(id)_initWithInternalCallblock:(id)internalCallblock replyType:(int)type;
-(id)initWithTextReplyCallblock:(id)textReplyCallblock;
-(id)initWithCallblock:(id)callblock;
@end

@class BBContent, BBSound, BBAttachments, BBAssertion, BBObserver;

@interface BBBulletin : NSObject <NSCopying, NSCoding> {
@private
	NSString* _sectionID;
	NSString* _publisherRecordID;
	NSString* _publisherBulletinID;
	int _addressBookRecordID;
	int _sectionSubtype;
	BBContent* _content;
	BBContent* _modalAlertContent;
	NSDate* _date;
	NSDate* _endDate;
	NSDate* _recencyDate;
	int _dateFormatStyle;
	BOOL _dateIsAllDay;
	NSTimeZone* _timeZone;
	int _accessoryStyle;
	BOOL _clearable;
	BBSound* _sound;
	BBAttachments* _attachments;
	NSString* _unlockActionLabelOverride;
	NSMutableDictionary* _actions;
	NSArray* _buttons;
	BOOL _expiresOnPublisherDeath;
	NSDictionary* _context;
	NSDate* _expirationDate;
	NSString* _bulletinID;
	NSDate* _lastInterruptDate;
	BBAssertion* _lifeAssertion;
	BBObserver* _observer;
	unsigned realertCount_deprecated;
	NSSet* alertSuppressionAppIDs_deprecated;
}
@property(copy, nonatomic) NSSet* alertSuppressionAppIDs_deprecated;
@property(assign, nonatomic) unsigned realertCount_deprecated;
@property(retain, nonatomic) BBObserver* observer;
@property(retain, nonatomic) BBAssertion* lifeAssertion;
@property(copy, nonatomic) BBAction* expireAction;
@property(retain, nonatomic) NSDate* expirationDate;
@property(retain, nonatomic) NSMutableDictionary* actions;
@property(copy, nonatomic) NSString* unlockActionLabelOverride;
@property(retain, nonatomic) BBAttachments* attachments;
@property(retain, nonatomic) BBContent* content;
@property(retain, nonatomic) NSDate* lastInterruptDate;
@property(retain, nonatomic) NSDictionary* context;
@property(assign, nonatomic) BOOL expiresOnPublisherDeath;
@property(copy, nonatomic) NSArray* buttons;
@property(copy, nonatomic) BBAction* replyAction;
@property(copy, nonatomic) BBAction* acknowledgeAction;
@property(copy, nonatomic) BBAction* defaultAction;
@property(readonly, assign, nonatomic) int primaryAttachmentType;
@property(retain, nonatomic) BBSound* sound;
@property(assign, nonatomic) BOOL clearable;
@property(assign, nonatomic) int accessoryStyle;
@property(retain, nonatomic) NSTimeZone* timeZone;
@property(assign, nonatomic) BOOL dateIsAllDay;
@property(assign, nonatomic) int dateFormatStyle;
@property(retain, nonatomic) NSDate* recencyDate;
@property(retain, nonatomic) NSDate* endDate;
@property(retain, nonatomic) NSDate* date;
@property(retain, nonatomic) BBContent* modalAlertContent;
@property(copy, nonatomic) NSString* message;
@property(copy, nonatomic) NSString* subtitle;
@property(copy, nonatomic) NSString* title;
@property(assign, nonatomic) int sectionSubtype;
@property(assign, nonatomic) int addressBookRecordID;
@property(copy, nonatomic) NSString* publisherBulletinID;
@property(copy, nonatomic) NSString* recordID;
@property(copy, nonatomic) NSString* sectionID;
@property(copy, nonatomic) NSString* section;
@property(copy, nonatomic) NSString* bulletinID;
+(id)bulletinWithBulletin:(BBBulletin *)bulletin;
-(id)description;
-(void)encodeWithCoder:(id)coder;
-(id)initWithCoder:(id)coder;
-(id)copyWithZone:(NSZone*)zone;
-(void)_fillOutCopy:(id)copy withZone:(NSZone*)zone;
-(void)deliverResponse:(id)response;
-(id)responseSendBlock;
-(id)responseForExpireAction;
-(id)responseForButtonActionAtIndex:(unsigned)index;
-(id)responseForAcknowledgeAction;
-(id)responseForReplyAction;
-(id)responseForDefaultAction;
-(id)_responseForActionKey:(id)actionKey;
-(id)_actionKeyForButtonIndex:(unsigned)buttonIndex;
-(id)attachmentsCreatingIfNecessary:(BOOL)necessary;
-(unsigned)numberOfAdditionalAttachmentsOfType:(int)type;
-(unsigned)numberOfAdditionalAttachments;
-(id)init;
-(void)dealloc;
@end

@interface BBBulletinRequest : BBBulletin {
}
@property(assign, nonatomic) BOOL tentative;
@property(assign, nonatomic) BOOL showsUnreadIndicator;
@property(assign, nonatomic) unsigned realertCount;
@property(copy, nonatomic) NSString* section;
@property(assign, nonatomic) BOOL expiresOnPublisherDeath;
@property(copy, nonatomic) BBAction* expireAction;
@property(retain, nonatomic) NSDate* expirationDate;
@property(copy, nonatomic) NSArray* buttons;
@property(copy, nonatomic) BBAction* replyAction;
@property(copy, nonatomic) BBAction* acknowledgeAction;
@property(copy, nonatomic) BBAction* defaultAction;
@property(assign, nonatomic) int primaryAttachmentType;
@property(retain, nonatomic) BBSound* sound;
@property(assign, nonatomic) BOOL clearable;
@property(assign, nonatomic) int accessoryStyle;
@property(retain, nonatomic) NSTimeZone* timeZone;
@property(assign, nonatomic) BOOL dateIsAllDay;
@property(assign, nonatomic) int dateFormatStyle;
@property(retain, nonatomic) NSDate* recencyDate;
@property(retain, nonatomic) NSDate* endDate;
@property(retain, nonatomic) NSDate* date;
@property(retain, nonatomic) BBContent* modalAlertContent;
@property(copy, nonatomic) NSString* message;
@property(copy, nonatomic) NSString* subtitle;
@property(copy, nonatomic) NSString* title;
@property(assign, nonatomic) int sectionSubtype;
@property(assign, nonatomic) int addressBookRecordID;
@property(copy, nonatomic) NSString* publisherBulletinID;
@property(copy, nonatomic) NSString* recordID;
@property(copy, nonatomic) NSString* sectionID;
-(void)generateBulletinID;
-(void)addAlertSuppressionAppID:(id)anId;
-(void)setUnlockActionLabel:(id)label;
-(void)withdraw;
-(void)publish;
-(void)publish:(BOOL)publish;
-(void)addButton:(id)button;
-(void)addAttachmentOfType:(int)type;
-(void)setContextValue:(id)value forKey:(id)key;
@end

@interface BBSectionInfo : NSObject <NSCopying, NSCoding> {
	NSString* _sectionID;
	unsigned _sectionType;
	BOOL _showsInNotificationCenter;
	unsigned _pushSettings;
	unsigned _alertType;
	unsigned _notificationCenterLimit;
	BOOL _showsInLockScreen;
	NSString* _pathToWeeAppPluginBundle;
}
@property(assign, nonatomic) unsigned bulletinCount;
@property(assign, nonatomic) BOOL enabled;
@property(copy, nonatomic) NSString* pathToWeeAppPluginBundle;
@property(assign, nonatomic) unsigned alertType;
@property(assign, nonatomic) unsigned pushSettings;
@property(assign, nonatomic) unsigned notificationCenterLimit;
@property(assign, nonatomic) BOOL showsInLockScreen;
@property(assign, nonatomic) BOOL showsInNotificationCenter;
@property(assign, nonatomic) unsigned sectionType;
@property(copy, nonatomic) NSString* sectionID;
+(id)defaultSectionInfoForType:(unsigned)type;
-(void)encodeWithCoder:(id)coder;
-(id)initWithCoder:(id)coder;
-(id)copyWithZone:(NSZone*)zone;
-(id)description;
-(id)_pushSettingsDescription;
-(void)dealloc;
@end

@protocol BBPushDataProviderFactory;

@interface BBServer : NSObject /*<XPCProxyTarget>*/ {
@private
	NSMutableSet* _observers;
	NSMutableSet* _listObservers;
	NSMutableSet* _modalAlertObservers;
	NSMutableSet* _bannerObservers;
	NSMutableSet* _lockscreenObservers;
	NSMutableSet* _soundObservers;
	NSMutableSet* _settingsObservers;
	NSMutableSet* _settingsGateways;
	NSMutableArray* _sortedSectionIDs;
	unsigned _sectionOrderRule;
	NSMutableDictionary* _sectionInfoByID;
	NSMutableDictionary* _sectionParametersByID;
	NSMutableDictionary* _sectionSortDescriptorsByID;
	NSMutableDictionary* _bulletinsByID;
	NSMutableDictionary* _bulletinIDsBySectionID;
	NSMutableDictionary* _transactionsByObserver;
	NSMutableDictionary* _listBulletinIDsBySectionID;
	NSMutableArray* _interruptingBulletinIDs;
	NSMutableArray* _expiringBulletinIDs;
	dispatch_source_t _timer;
	NSDate* _nextScheduledFireDate;
	NSMutableDictionary* _dataProvidersBySection;
	NSMutableSet* _pushDataProviders;
	NSMutableDictionary* _clearedSections;
	id<BBPushDataProviderFactory> _pushDataProviderFactory;
	int _demo_lockscreen_token;
@protected
	NSMutableDictionary* _bulletinRequestsByID;
}
+(void)initialize;
-(void)demo_lockscreen:(unsigned long long)lockscreen;
-(id)_defaultSectionInfoForDataProvider:(id)dataProvider;
-(void)_writeSectionInfo;
-(void)_writeSectionOrder;
-(void)_loadSavedSectionInfo;
-(void)_readSavedSectionOrder:(id*)order andRule:(unsigned*)rule;
-(id)_sectionInfoPath;
-(id)_sectionOrderPath;
-(void)_writeClearedSections;
-(void)_loadClearedSections;
-(id)_clearedSectionsPath;
-(void)_ensureDataDirectoryExists;
-(id)_dataDirectoryPath;
-(void)_loadAllWeeAppSections;
-(id)_copyDefaultEnabledWeeAppIDs;
-(void)_removePushDataProvider:(id)provider;
-(void)_updatePushSettingsForPushDataProvider:(id)pushDataProvider;
-(void)_noteUserEnabledPushDeliveryForDataProvider:(id)dataProvider;
-(void)_addPushDataProvider:(id)provider sortNowAndNotifyObservers:(BOOL)observers;
-(void)_addDataProvider:(id)provider sortSectionsNow:(BOOL)now;
-(void)_loadDataProviderPluginBundle:(id)bundle;
-(void)_loadAllDataProviderPluginBundles;
-(void)_setClearedInfo:(id)info forSectionID:(id)sectionID;
-(id)_clearedInfoForSectionID:(id)sectionID;
-(unsigned)_countForSectionID:(id)sectionID;
-(unsigned)_filtersForSectionID:(id)sectionID;
-(void)_publishBulletinRequest:(id)request forDataProvider:(id)dataProvider forDestinations:(int)destinations;
-(void)_updateSectionParametersForDataProvider:(id)dataProvider;
-(void)_updateBulletinsForDataProvider:(id)dataProvider;
-(void)_updateBulletinsForDataProviderIfSectionIsEnabled:(id)dataProviderIfSectionIsEnabled;
-(BOOL)_verifyBulletinRequest:(id)request forDataProvider:(id)dataProvider;
-(void)_publishBulletinsForAllDataProviders;
-(void)_loadDataProvidersAndSettings;
-(void)settingsGateway:(id)gateway setSectionInfo:(id)info forSectionID:(id)sectionID;
-(void)settingsGateway:(id)gateway setOrderedSectionIDs:(id)ids;
-(void)settingsGateway:(id)gateway setSectionOrderRule:(unsigned)rule;
-(void)settingsGateway:(id)gateway getSectionInfoWithHandler:(id)handler;
-(void)observer:(id)observer getRecentUnacknowledgedBulletinsForFeeds:(unsigned)feeds withHandler:(id)handler;
-(void)observer:(id)observer requestListBulletinsForSectionID:(id)sectionID;
-(id)_updatesForObserver:(id)observer bulletinIDs:(id)ids;
-(void)observer:(id)observer getSectionInfoWithHandler:(id)handler;
-(void)observer:(id)observer clearSection:(id)section;
-(void)observer:(id)observer finishedWithBulletinID:(id)bulletinID transactionID:(unsigned)anId;
-(void)observer:(id)observer handleResponse:(id)response;
-(void)observer:(id)observer setObserverFeed:(unsigned)feed;
-(void)getAttachmentAspectRatioForBulletinID:(NSString *)bulletinID withHandler:(id)handler;
-(void)getAttachmentPNGDataForBulletinID:(NSString *)bulletinID sizeConstraints:(id)constraints withHandler:(id)handler;
-(void)getSectionParametersForSectionID:(NSString *)sectionID withHandler:(id)handler;
-(void)getSortDescriptorsForSectionID:(NSString *)sectionID withHandler:(id)handler;
-(void)getSectionOrderRuleWithHandler:(id)handler;
-(id)_interruptingBulletinIDsForFeeds:(unsigned)feeds;
-(void)_expireInterruptions;
-(void)_addInterruptingBulletin:(id)bulletin;
-(void)_scheduleExpirationForBulletin:(id)bulletin;
-(void)_expireBulletins;
-(unsigned)_indexForNewDate:(id)newDate inBulletinIDArray:(id)bulletinIDArray sortedAscendingByDateForKey:(id)key;
-(id)_bulletinIDsInSortedArray:(id)sortedArray withDateForKey:(id)key beforeCutoff:(id)cutoff;
-(void)_expireBulletinsAndInterruptionsAndRescheduleTimerIfNecessary;
-(id)_nextExpireInterruptionsDate;
-(id)_nextExpireBulletinsDate;
-(void)_scheduleTimerForDate:(id)date;
-(void)_clearTimer;
-(void)_handleSignificantTimeChange;
-(void)_handleSystemWake;
-(void)_handleSystemSleep;
-(void)_setSectionInfo:(id)info forSectionID:(id)sectionID;
-(void)_clearBulletinIDIfPossible:(id)possible rescheduleExpirationTimer:(BOOL)timer;
-(id)_sectionInfoArray:(BOOL)array;
-(void)_sortSectionIDsUsingGuideArray:(id)array;
-(void)_sortSectionIDsUsingDefaultOrder;
-(id)_allBulletinsForSectionID:(id)sectionID;
-(id)_listBulletinsForSectionID:(id)sectionID;
-(id)_bulletinsForIDs:(id)ids;
-(unsigned)_incrementedTransactionIDForObserver:(id)observer bulletinID:(id)anId;
-(id)_currentTransactionForObserver:(id)observer bulletinID:(id)anId;
-(unsigned)_feedsForBulletin:(id)bulletin destinations:(int)destinations;
-(void)_removeSection:(id)section;
-(void)_clearSection:(id)section;
-(void)_removeBulletin:(id)bulletin;
-(void)_removeBulletin:(id)bulletin rescheduleTimerIfAffected:(BOOL)affected;
-(void)_modifyBulletin:(id)bulletin;
-(void)_addBulletin:(id)bulletin;
-(void)_sendRemoveBulletin:(id)bulletin toFeeds:(unsigned)feeds;
-(void)_sendModifyBulletin:(id)bulletin toFeeds:(unsigned)feeds;
-(void)_sendAddBulletin:(id)bulletin toFeeds:(unsigned)feeds;
-(id)_observersForFeeds:(unsigned)feeds;
-(void)_sendUpdateSectionOrderRule;
-(void)_sendUpdateSectionOrder;
-(void)_sendUpdateSectionInfo:(id)info;
-(void)_removeSettingsGateway:(id)gateway;
//-(void)_addSettingsGatewayWithConnection:(xpc_connection_s*)connection;
-(void)_removeObserver:(id)observer;
//-(void)_addObserverWithConnection:(xpc_connection_s*)connection;
-(id)sortDescriptorsForSectionID:(id)sectionID;
-(unsigned)listBulletinCapForSectionID:(id)sectionID;
-(id)allBulletinIDsForSectionID:(id)sectionID;
-(id)listBulletinIDsForSectionID:(id)sectionID;
-(void)removeBulletinID:(id)anId fromListSection:(id)listSection;
-(void)withdrawBulletinID:(id)anId;
-(void)publishBulletin:(id)bulletin destinations:(int)destinations;
-(id)proxy:(id)proxy detailedSignatureForSelector:(SEL)selector;
-(void)dealloc;
-(id)init;
@end

@interface BBThumbnailSizeConstraints : NSObject <NSCoding> {
@private
	int _constraintType;
	CGFloat _fixedWidth;
	CGFloat _fixedHeight;
	CGFloat _fixedDimension;
	CGFloat _minAspectRatio;
	CGFloat _maxAspectRatio;
	CGFloat _thumbnailScale;
}
@property (assign, nonatomic) CGFloat thumbnailScale;
@property (assign, nonatomic) CGFloat maxAspectRatio;
@property (assign, nonatomic) CGFloat minAspectRatio;
@property (assign, nonatomic) CGFloat fixedDimension;
@property (assign, nonatomic) CGFloat fixedHeight;
@property (assign, nonatomic) CGFloat fixedWidth;
@property (assign, nonatomic) int constraintType;
- (BOOL)areReasonable;
- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;
@end

extern void BBDataProviderAddBulletin(id <BBDataProvider> dataProvider, BBBulletin *bulletin);
extern void BBDataProviderInvalidateBulletins(id <BBDataProvider> dataProvider, NSArray *bulletins);
extern void BBDataProviderWithdrawBulletinsWithRecordID(id <BBDataProvider> dataProvider, NSString *recordID);

@interface UIImage (UIApplicationIconPrivate)
+ (UIImage *)_iconForResourceProxy:(id)resourceProxy format:(int)format;
+ (UIImage *)_iconForResourceProxy:(id)resourceProxy variant:(int)variant variantsScale:(CGFloat)scale;
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier roleIdentifier:(NSString *)roleIdentifier format:(int)format scale:(CGFloat)scale;
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier roleIdentifier:(NSString *)roleIdentifier format:(int)format;
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format scale:(float)scale;
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format;
+ (int)_iconVariantForUIApplicationIconFormat:(int)uiapplicationIconFormat scale:(CGFloat *)scale;
- (UIImage *)_applicationIconImageForFormat:(int)format precomposed:(BOOL)precomposed scale:(CGFloat)scale;
- (UIImage *)_applicationIconImageForFormat:(int)format precomposed:(BOOL)precomposed;
@end

