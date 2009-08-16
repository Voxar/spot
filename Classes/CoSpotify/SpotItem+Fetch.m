//
//  SpotItem+Fetch.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-08-15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotItem+Fetch.h"

#import "SpotSession.h"
#import "SpotArtist.h"
#import "SpotAlbum.h"
#import "SpotTrack.h"
#import "SpotPlaylist.h"

@implementation SpotItem (Fetch)

+(SpotArtist *)artistById:(NSString *)id_;
{
  return [[SpotSession defaultSession] artistById:id_];
}

+(void)artistById:(NSString *)id_ respondTo:(id)target selector:(SEL)selector;
{
  [[SpotSession defaultSession] artistById:id_ respondTo:target selector:selector];
}

+(SpotAlbum *)albumById:(NSString *)id;
{
  return [[SpotSession defaultSession] albumById:id];
}

+(void)albumById:(NSString *)id_ respondTo:(id)target selector:(SEL)selector;
{
  [[SpotSession defaultSession] albumById:id_ respondTo:target selector:selector];
}

+(SpotTrack *)trackById:(NSString *)id;
{
  return [[SpotSession defaultSession] trackById:id];
}

//-(void)trackById:(NSString *)id_ respondTo:(id)target selector:(SEL)selector;

+(SpotPlaylist *)playlistById:(NSString *)id;
{
  return [[SpotSession defaultSession] playlistById:id];
}

+(void)playlistById:(NSString *)id_ respondTo:(id)target selector:(SEL)selector;
{
  [[SpotSession defaultSession] playlistById:id_ respondTo:target selector:selector];
}


@end
