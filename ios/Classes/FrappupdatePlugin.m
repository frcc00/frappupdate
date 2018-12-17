#import "FrappupdatePlugin.h"
#import <frappupdate/frappupdate-Swift.h>

@implementation FrappupdatePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFrappupdatePlugin registerWithRegistrar:registrar];
}
@end
