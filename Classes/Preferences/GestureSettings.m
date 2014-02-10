// GestureSettings.h
// MobileTerminal

#import "GestureSettings.h"
#import "Settings.h"

NSString* kGestureSingleDoubleTap = @"双击";
NSString* kGestureDoubleDoubleTap = @"两指双击";
NSString* kGestureSwipeUp = @"向上轻扫";
NSString* kGestureSwipeDown = @"向下轻扫";
NSString* kGestureSwipeLeft = @"向左轻扫";
NSString* kGestureSwipeRight = @"向右轻扫";
NSString* kGestureSwipeLeftUp = @"向左上方轻扫";
NSString* kGestureSwipeLeftDown = @"向左下方轻扫";
NSString* kGestureSwipeRightUp = @"向右上方轻扫";
NSString* kGestureSwipeRightDown = @"向右下方轻扫";

@interface NoneGestureAction : NSObject<GestureAction> {
}
- (NSString*)label;
- (void)performAction;
@end

@implementation NoneGestureAction

static NoneGestureAction* noneInstance;

+ (NoneGestureAction*)getInstance
{
  if (noneInstance == nil) {
    noneInstance = [[NoneGestureAction alloc] init];
  }
  return noneInstance;
}

- (NSString*)label
{
  return NSLocalizedString(@"undifined",nil);
}

- (void)performAction
{
  // Do nothing  
}

@end


@implementation SelectorGestureAction

- (id)initWithTarget:(id)aTarget action:(SEL)anAction label:(NSString*)aLabel;
{
  self = [super init];
  if (self != nil) {
    label = aLabel;
    target = aTarget;
    action = anAction;
  }
  return self;
}

- (NSString*)label
{
  return label;
}

- (void)performAction
{
  [target performSelector:action];
}

@end

@implementation GestureItem

@synthesize name;
@synthesize actionLabel;

- (id)initWithName:(NSString*)aName
{
  self = [super init];
  if (self != nil) {
    name = aName;
    actionLabel = [[NoneGestureAction getInstance] label];
  }
  return self;
}

@end


@implementation GestureSettings


- (void)addGestureItem:(NSString*)itemName withCoder:(NSCoder *)decoder
{
  GestureItem* item = [[GestureItem alloc] initWithName:itemName];
  if ([decoder containsValueForKey:itemName]) {
    item.actionLabel = [decoder decodeObjectForKey:[item name]];
  }
  [gestureItems addObject:item];
  [item release];
}



- (id) init
{
  return [self initWithCoder:nil];
}

- (id)initWithCoder:(NSCoder *)decoder
{
  self = [super init];
  if (self != nil) {
    gestureItems = [[NSMutableArray alloc] init];
    [self addGestureItem:kGestureSingleDoubleTap withCoder:decoder];
    [self addGestureItem:kGestureDoubleDoubleTap withCoder:decoder];
    [self addGestureItem:kGestureSwipeUp withCoder:decoder];
    [self addGestureItem:kGestureSwipeDown withCoder:decoder];
    [self addGestureItem:kGestureSwipeLeft withCoder:decoder];
    [self addGestureItem:kGestureSwipeRight withCoder:decoder];
    [self addGestureItem:kGestureSwipeLeftUp withCoder:decoder];
    [self addGestureItem:kGestureSwipeLeftDown withCoder:decoder];
    [self addGestureItem:kGestureSwipeRightUp withCoder:decoder];
    [self addGestureItem:kGestureSwipeRightDown withCoder:decoder];
    
    gestureActions = [[NSMutableArray alloc] init];
    
    NoneGestureAction* noneAction = [[NoneGestureAction alloc] init];
    [gestureActions addObject:noneAction];
    [noneAction release];
  }
  return self;
}

- (void) dealloc
{
  [gestureItems release];
  [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
  for (int i = 0; i < [self gestureItemCount]; ++i) {
    GestureItem* item = [self gestureItemAtIndex: i];
    [encoder encodeObject:[item actionLabel] forKey:[item name]];
  }
}

- (int)gestureItemCount
{
  return [gestureItems count];
}

- (GestureItem*)gestureItemAtIndex:(int)index
{
  return [gestureItems objectAtIndex:index];
}

- (GestureItem*)gestureItemForName:(NSString*)name;
{
  // Simply do a linear walk of these items.  Given there are only a limited
  // number of gestures this shouldn't be too inefficient.
  for (int i = 0; i < [self gestureItemCount]; ++i) {
    GestureItem* item = [self gestureItemAtIndex: i];
    if ([[item name] isEqualToString:name]) {
      return item;
    }
  }
  return NULL;
}

- (int)gestureActionCount
{
  return [gestureActions count];
}

- (id<GestureAction>)gestureActionAtIndex:(int)index
{
  return [gestureActions objectAtIndex:index];
}

- (void)addGestureAction:(id<GestureAction>)action
{
  [gestureActions addObject:action];
}

- (id<GestureAction>)gestureActionForLabel:(NSString*)label
{
  // Simply do a linear walk of these items.  Given there are only a limited
  // number of gestures this shouldn't be too inefficient.
  for (int i = 0; i < [self gestureActionCount]; ++i) {
    id<GestureAction> action = [self gestureActionAtIndex: i];
    if ([[action label] isEqualToString:label]) {
      return action;
    }
  }
  return [NoneGestureAction getInstance];
}

- (id<GestureAction>)gestureActionForItemName:(NSString*)name
{
  GestureItem* item = [self gestureItemForName:name];
  return [self gestureActionForLabel:[item actionLabel]];
}

@end
