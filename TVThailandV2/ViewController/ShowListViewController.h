//
//  ShowListViewController.h
//  TVThailandV2
//
//  Created by Nattapong Tonprasert on 9/11/56 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kWhatsNew = 0,
    kGenre = 1
} ShowModeType;

@interface ShowListViewController : UIViewController

- (void)reloadWithMode:(ShowModeType) mode Id:(NSString *)Id;

@end
