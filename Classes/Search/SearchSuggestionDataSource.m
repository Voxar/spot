//
//  SearchSuggestionDataSource.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-08-16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchSuggestionDataSource.h"


@implementation SearchSuggestionDataSource
@synthesize searchResults, suggestions;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if( ! [SpotSession defaultSession].loggedIn) return 0;
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
  return 0;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return suggestions.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
	if(searchResults) 
    return @"Suggestions";
  else
    return @"Latest Searches";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  NSString *reuseIdentifier = @"tableViewCell";
  UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(!cell)
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
  
  cell.textLabel.text = [suggestions objectAtIndex:indexPath.row];

  return cell;
}

-(NSArray *)takeItemNamesFromItems:(NSArray*)array;
{
  int max = 3;
  NSMutableArray *a = [NSMutableArray array];
  for(SpotItem* item in array){
    if(![[item name] isEqual:searchResults.query]){ //suggestion not same as query   
      [a addObject:[item name]];
      if(--max==0)
        break;
    }
  }
  return a;
}

-(void)setSearchResults:(SpotSearch *)newResults;
{
  [newResults retain];
  [searchResults release];
  searchResults = newResults;

  if(searchResults){
    NSMutableArray *s = [NSMutableArray array];
    if(searchResults.suggestion)
      [s addObject:searchResults.suggestion];

    [s addObjectsFromArray:[self takeItemNamesFromItems:searchResults.artists]];
    [s addObjectsFromArray:[self takeItemNamesFromItems:searchResults.albums]];
    [s addObjectsFromArray:[self takeItemNamesFromItems:searchResults.tracks]];
    self.suggestions = s;
  } else {
    //fill with latest searches
    self.suggestions = [[NSUserDefaults standardUserDefaults] objectForKey:@"latestSearches"];
    NSLog(@"suggestions: %@", suggestions);
  }
}


@end
