#import "UnityEngineBridge.h"
#import "UnityEngineObject.h"

@interface UnityEngineObject()
{
    int _instanceID;
}
@end

@implementation UnityEngineObject

- (BOOL)isEqual:(id)object
{
    if ( ![object isKindOfClass:UnityEngineObject.class] )
    {
        return NO;
    }
    return [(UnityEngineObject *)object instanceID] == self.instanceID;
}

+ (instancetype)objectWithID:(int)instanceID
{
    if ( instanceID == -1 )
    {
        return nil;
    }
    UnityEngineObject *result = [[self class] new];
    result->_instanceID = instanceID;
    return result;
}

- (int)instanceID
{
    return _instanceID;
}

@end
