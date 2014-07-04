//
//  MDDSHelper.m
//  macDS
//
//  Created by Jonas Schnelli on 30.06.14.
//  Copyright (c) 2014 include7. All rights reserved.
//

#import "MDDSHelper.h"

@interface MDDSHelper ()

@end
@implementation MDDSHelper

+ (NSImage *)iconForDevice:(NSDictionary *)deviceDictonary
{
    NSArray *groups = [(NSDictionary *)deviceDictonary objectForKey:@"groups"];
    
    NSString *iconName = @"device_unknown";
    groups = [groups sortedArrayUsingSelector:@selector(compare:)];
    if(groups.count == 2)
    {
        iconName = [NSString stringWithFormat:@"group_%@_%@", [groups objectAtIndex:0], [groups objectAtIndex:1]];
    }
    else
    {
        iconName = [NSString stringWithFormat:@"group_%@", [groups objectAtIndex:0]];
    }
    
    return [NSImage imageNamed:iconName];
}

+ (BOOL)deviceHasLight:(NSDictionary *)deviceDictonary
{
    return [self device:deviceDictonary hasGroup:1];
}

+ (BOOL)deviceHasShadow:(NSDictionary *)deviceDictonary
{
    return [self device:deviceDictonary hasGroup:2];
}

+ (BOOL)device:(NSDictionary *)deviceDictonary hasGroup:(NSInteger)group
{
    NSArray *groups = [deviceDictonary objectForKey:@"groups"];
    if([groups indexOfObjectIdenticalTo:[NSNumber numberWithLong:group]] != NSNotFound)
    {
        return YES;
    }
    
    return NO;
}

+ (NSString *)customSceneNameForScene:(int)scene fromJSON:(NSArray *)json
{
    for(NSDictionary *customSceneName in json)
    {
        if([[customSceneName objectForKey:@"scene"] intValue] == scene)
        {
            return [customSceneName objectForKey:@"name"];
        }
    }
    return @"";
}

+ (BOOL)hasGroup:(int)groupNr inZone:(NSDictionary *)zoneDict
{
    for(NSDictionary *groupDict in [zoneDict objectForKey:@"groups"])
    {
        if([[groupDict objectForKey:@"color"] intValue] == groupNr)
        {
            if([[groupDict objectForKey:@"devices"] count] > 0)
            {
                return YES;
            }
        }
    }
    return NO;
}

@end
