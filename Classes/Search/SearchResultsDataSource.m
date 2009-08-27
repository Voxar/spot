//
//  SearchResultsDataSource.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-08-16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchResultsDataSource.h"

#import "SpotPlaylist.h"
#import "SpotSearch.h"
#import "SpotCell.h"
#import "SpotArtist.h"
#import "SpotAlbum.h"
#import "SpotTrack.h"

@implementation SearchResultsDataSource
@synthesize searchResults, showType;

#pragma mark 
#pragma mark Table view callbacks
enum {
  SuggestionSection,
	ArtistsSection,
	AlbumsSection,
  TracksSection
};

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if( ! [SpotSession defaultSession].loggedIn || !searchResults) return 1;
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
  return 0;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	if( ! [SpotSession defaultSession].loggedIn || !searchResults) return 0;
	
	switch (showType) {
		case ShowArtists: return searchResults.artists.count;
		case ShowAlbums:  return searchResults.albums.count;
		case ShowTracks:  return searchResults.tracks.count;
	}
	return 0;	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
  if(searchResults)
    return @"Search results";
  else
    return @"Searching...";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  static NSString *SpotCellIdentifier = @"AlbumCell";
  UITableViewCell *the_cell = nil;
  
  BOOL loadImage = [[NSUserDefaults standardUserDefaults] boolForKey:@"coversInSearch"];
  
	int idx = [indexPath indexAtPosition:1]; idx = idx;
	switch(showType) {
		case ShowArtists: {
      SpotCell *cell = (SpotCell *)[tableView dequeueReusableCellWithIdentifier:SpotCellIdentifier];
      if (cell == nil) 
        cell = [[[SpotCell alloc] initWithFrame:CGRectZero reuseIdentifier:SpotCellIdentifier] autorelease];
      
			SpotArtist *artist = [searchResults.artists objectAtIndex:idx];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      
      
      [cell setTitle:artist.name
            subTitle:artist.genres
         bottomTitle:artist.yearsActive
          popularity:artist.popularity 
               image:loadImage
             imageId:loadImage ? artist.portraitId : nil];
      
      the_cell = cell;
		} break;
		case ShowAlbums: {
      SpotCell *cell = (SpotCell *)[tableView dequeueReusableCellWithIdentifier:SpotCellIdentifier];
      if(!cell)
        cell = [[[SpotCell alloc] initWithFrame:CGRectZero reuseIdentifier:SpotCellIdentifier] autorelease];
      
			SpotAlbum *album = [searchResults.albums objectAtIndex:idx];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      
      [cell setTitle:album.name
            subTitle:album.artistName
         bottomTitle:album.year ? [NSString stringWithFormat:@"%d", album.year] : nil
          popularity:album.popularity 
               image:loadImage 
             imageId:loadImage ? album.coverId : nil];
      
      if(!album.allowed){
        cell.bottomTitle.text = @"Unavailable in your country";
      }
      
      the_cell = cell;
		} break;
    case ShowTracks: {
      SpotCell *cell = (SpotCell *)[tableView dequeueReusableCellWithIdentifier:SpotCellIdentifier];
      if(!cell)
        cell = [[[SpotCell alloc] initWithFrame:CGRectZero reuseIdentifier:SpotCellIdentifier] autorelease];
      
			SpotTrack *track = [searchResults.tracks objectAtIndex:idx];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			//cell.text = [NSString stringWithFormat:@"%@", track.title];
      [cell setTitle:track.title 
            subTitle:track.artist.name 
         bottomTitle:track.albumName 
          popularity:track.popularity 
               image:NO 
             imageId:nil];
      
      the_cell = cell;
		} break;
      
	}
  
  return the_cell;
}


@end
