//
//  SpotURI.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "despotify.h"

@class SpotId;
@class SpotArtist;
@class SpotAlbum;
@class SpotTrack;
@class SpotPlaylist;
@class SpotSearch;

typedef enum {
  SpotLinkTypeInvalid = LINK_TYPE_INVALID,
  SpotLinkTypeAlbum = LINK_TYPE_ALBUM,
  SpotLinkTypeArtist = LINK_TYPE_ARTIST,
  SpotLinkTypePlaylist = LINK_TYPE_PLAYLIST,
  SpotLinkTypeSearch = LINK_TYPE_SEARCH,
  SpotLinkTypeTrack = LINK_TYPE_TRACK
} SpotLinkType;

@interface SpotURI : NSObject {
  struct link *link;
  char uriBuffer[256];
}

+(SpotURI*)uriWithId:(SpotId*)id;
+(SpotURI*)uriWithURI:(char *)uri;

-(id)initWithURI:(char*)uri;

@property (readonly, nonatomic) SpotLinkType type;
@property (readonly, nonatomic) NSString *uri;
@property (readonly, nonatomic) NSString *url;
@property (readonly, nonatomic) struct link *link;

@end

