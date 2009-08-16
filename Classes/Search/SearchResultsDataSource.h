//
//  SearchResultsDataSource.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-08-16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SpotPlaylist.h"
#import "SpotSearch.h"

typedef enum{
  ShowArtists,
  ShowAlbums,
  ShowTracks
}SearchShowType;

@interface SearchResultsDataSource : NSObject <UITableViewDataSource> {
  SpotSearch *searchResults;
  SearchShowType showType;
}

@property (nonatomic) SearchShowType showType;
@property (nonatomic, retain) SpotSearch *searchResults;


@end
