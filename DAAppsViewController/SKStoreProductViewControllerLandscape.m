#import "SKStoreProductViewControllerLandscape.h"

@interface SKStoreProductViewControllerLandscape ()

@end

@implementation SKStoreProductViewControllerLandscape

- (BOOL)shouldAutorotate {
  UIInterfaceOrientationMask applicationSupportedOrientations = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:[[UIApplication sharedApplication] keyWindow]];
  UIInterfaceOrientationMask viewControllerSupportedOrientations = [self supportedInterfaceOrientations];
  return viewControllerSupportedOrientations & applicationSupportedOrientations;
}


@end
