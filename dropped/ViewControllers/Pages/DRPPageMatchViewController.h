//
//  DRPPageMatchViewController.h
//  dropped
//
//  Created by Brad Zeis on 12/20/13.
//  Copyright (c) 2013 Brad Zeis. All rights reserved.
//

#import "DRPPageViewController.h"
#import "DRPMatchHeaderViewController.h"
#import "DRPBoardViewController.h"
#import "DRPMatchCurrentWordViewController.h"

@interface DRPPageMatchViewController : DRPPageViewController <DRPHeaderViewControllerDelegate, DRPBoardViewControllerDelegate, DRPCurrentWordViewControllerDelegate>

@end
