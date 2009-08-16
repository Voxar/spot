//
//  SpotItem+Fetch.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-08-15.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SpotItem.h"

@class SpotArtist;
@class SpotAlbum;
@class SpotTrack;
@class SpotPlaylist;

@interface SpotItem (Fetch) 


+(SpotArtist *)artistById:(NSString *)id_;
+(void)artistById:(NSString *)id_ respondTo:(id)target selector:(SEL)selector;

+(SpotAlbum *)albumById:(NSString *)id;
+(void)albumById:(NSString *)id_ respondTo:(id)target selector:(SEL)selector;

+(SpotTrack *)trackById:(NSString *)id;
//+(void)trackById:(NSString *)id_ respondTo:(id)target selector:(SEL)selector;

+(SpotPlaylist *)playlistById:(NSString *)id;
+(void)playlistById:(NSString *)id_ respondTo:(id)target selector:(SEL)selector;


@end
