//
//  main.cpp
//  TesterApp
//
//  Created by Eric Liang on 4/24/21.
//

#import <Foundation/Foundation.h>
//#import "UnityFramework.h"
#import <UnityFramework/UnityFramework.h>

void loadaxbundle(void)
{
    NSBundle* bundle = [NSBundle bundleWithPath:[NSBundle.mainBundle.builtInPlugInsPath stringByAppendingPathComponent:@"AccessibilityBundle.axbundle"]];
    [bundle load];
}

id UnityFrameworkLoad()
{
    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString: @"/Frameworks/UnityFramework.framework"];

    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) [bundle load];

    id ufw = [bundle.principalClass getInstance];
    if (![ufw appController])
    {
        // unity is not initialized
        [ufw setExecuteHeader: &_mh_execute_header];
    }
    loadaxbundle();
    return ufw;
}



int main(int argc, char* argv[])
{
    @autoreleasepool
    {
        id ufw = UnityFrameworkLoad();
        [ufw runUIApplicationMainWithArgc: argc argv: argv];
        return 0;
    }
}
