//
//  TodayViewController.m
//  iOSWidget
//
//  Created by Jonas Schnelli on 20.10.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "MDIOSWidgetManager.h"
#import "MDIOSFavoritesManager.h"
#import "MDIOSWidgetView.h"
#import "Constantes.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc]
                                        initWithSuiteName:@"group.com.include7.DSMenu"];
    
    if(self.hasDSSManagerAvailable == NO)
    {
        [self initDSSManager];
    }
    
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kDSMENU_APP_GROUP_IDENTIFIER];
    NSURL *containerURLFile = [containerURL URLByAppendingPathComponent:kDSMENU_SECURITY_NAME_FOR_USERDEFAULTS];
    NSDictionary *userDefaults = [NSDictionary dictionaryWithContentsOfURL:containerURLFile];
    for(NSString *aKey in userDefaults.allKeys)
    {
        [[MDDSSManager defaultManager].currentUserDefaults setObject:[userDefaults objectForKey:aKey] forKey:aKey];
    }
    
    containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kDSMENU_APP_GROUP_IDENTIFIER];
    containerURLFile = [containerURL URLByAppendingPathComponent:@"widgetactions"];
    NSData *data = [NSData dataWithContentsOfURL:containerURLFile];
    NSMutableDictionary *widgetActions = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    
    containerURLFile = [containerURL URLByAppendingPathComponent:@"favorites"];
    data = [NSData dataWithContentsOfURL:containerURLFile];
    NSArray *favorites = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    
    NSDictionary *json = [MDDSSManager defaultManager].lastLoadesStructure;
    
    CGPoint currentPosition = CGPointMake(0, 5);
    CGSize widgetViewSize = CGSizeMake(100, 44);
    CGSize widgetSpace = CGSizeMake(5, 5);
    NSArray *favs = [MDIOSWidgetManager defaultManager].allFavoritesUUIDs;
    for(MDIOSWidgetAction *action in [widgetActions objectForKey:@"favs"])
    {
        
        if(currentPosition.x+widgetViewSize.width+widgetSpace.width > self.view.bounds.size.width)
        {
            currentPosition.x = 0;
            currentPosition.y += widgetViewSize.height+widgetSpace.height;
        }
        
        MDIOSFavorite *favorite = nil;
        
        for(MDIOSFavorite *aFavorite in favorites)
        {
            if([aFavorite.UUID isEqualToString:action.favoriteUUID])
            {
                favorite = aFavorite;
            }
        }
        
        MDIOSWidgetView *wview = [[MDIOSWidgetView alloc] initWithFrame:CGRectMake(currentPosition.x,currentPosition.y,widgetViewSize.width,widgetViewSize.height) andFavorite:favorite];
        
        [wview addTarget:self action:@selector(widgetActionTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:wview];
        currentPosition.x += widgetViewSize.width+widgetSpace.width;
    }
    
    self.noFavoritesLabel.hidden = YES;
    if(!favs || favs.count == 0)
    {
        self.noFavoritesLabel.hidden = NO;
    }
    
    self.preferredContentSize = CGSizeMake(0, currentPosition.y+widgetViewSize.height+widgetSpace.height);
    completionHandler(NCUpdateResultNewData);
}

- (void)widgetActionTapped:(id)sender
{
    MDIOSWidgetView *wview = (MDIOSWidgetView *)sender;
    
    [wview.loadingIndicator startAnimating];
    if(wview.favorite.favoriteType == MDIOSFavoriteTypeZonePreset)
    {
        [[MDDSSManager defaultManager] callScene:wview.favorite.scene zoneId:wview.favorite.zone groupID:wview.favorite.group callback:^(NSDictionary *json, NSError *error)
         {
                [wview.loadingIndicator stopAnimating];
         }];
    }
}

- (void)initDSSManager
{
    NSUserDefaults *mySharedDefaults = [[NSUserDefaults alloc]
                                        initWithSuiteName:@"group.com.include7.DSMenu"];
    
    
    NSLog(@"NSUserDefaults dump: %@", [mySharedDefaults dictionaryRepresentation]);
    
    [MDDSSManager defaultManager].currentUserDefaults = mySharedDefaults;
    [[MDDSSManager defaultManager] loadDefaults];
    
    [MDDSSManager defaultManager].appName = @"DSMenuiOS";
    [MDDSSManager defaultManager].appUUID = @"e4634770-11a3-412f-9946-91911c2a4d25";
    
    
    self.hasDSSManagerAvailable = YES;
    
    
    NSLog(@"%@", [MDDSSManager defaultManager].host);
    [[MDDSSManager defaultManager] getVersion:^(NSDictionary *json, NSError *error)
    {
        NSLog(@"%@", json);
    }];
}

@end