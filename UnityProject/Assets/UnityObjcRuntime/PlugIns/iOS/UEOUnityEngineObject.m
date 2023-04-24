#import "UEOBridge.h"
#import "UEOUnityEngineObject.h"

@interface UnityEngineObject()
{
    int _instanceID;
}
@end

@implementation UnityEngineObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", [super description], [self safeCSharpStringForKey:@"ToString"]];
}

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
    Class cls = UnityEngineObject.class;
    NSString *typeFullName = TO_NSSTRING(UnityEngineObjectTypeFullName_CSharpFunc(instanceID));
    if ( [typeFullName isEqualToString:@"UnityEngine.GameObject"] )
    {
        cls = NSClassFromString(@"UnityEngineGameObject");
    }
    else if ( [typeFullName isEqualToString:@"UnityEngine.Transform"] )
    {
        cls = NSClassFromString(@"UnityEngineTransform");
    }
    else if ( [typeFullName isEqualToString:@"Apple.Accessibility.UnityAccessibilityNode"] )
    {
        cls = NSClassFromString(@"UnityAccessibilityNodeComponent");
    }
    else
    {
        cls = NSClassFromString(@"UnityEngineComponent");
    }
    UnityEngineObject *result = [cls new];
    result->_instanceID = instanceID;
    return result;
}

- (int)instanceID
{
    return _instanceID;
}


- (NSString *)typeFullName
{
    return TO_NSSTRING(UnityEngineObjectTypeFullName_CSharpFunc(_instanceID));
}

- (BOOL)safeCSharpBoolForKey:(NSString *)key
{
    return UnityEngineObjectSafeCSharpBoolForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key));
}

- (int)safeCSharpIntForKey:(NSString *)key
{
    return UnityEngineObjectSafeCSharpIntForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key));
}

- (NSString *)safeCSharpStringForKey:(NSString *)key
{
    return TO_NSSTRING(UnityEngineObjectSafeCSharpStringForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key)));
}

- (UnityEngineObject *)safeCSharpObjectForKey:(NSString *)key
{
    return [UnityEngineObject objectWithID:UnityEngineObjectSafeCSharpObjectForKey_CSharpFunc(self.instanceID, FROM_NSSTRING(key))];
}

+ (NSArray<UnityEngineObject *> *)findObjectsOfType:(NSString *)component
{
    NSString *arrayString = TO_NSSTRING(UnityEngineObjectFindObjectsOfType_CSharpFunc(FROM_NSSTRING(component)));
    return [[arrayString _ueoToNumberArray] _ueoMapedObjects:^id(NSNumber *obj) {
        return [UnityEngineObject objectWithID:obj.intValue];
    }];
}

@end
