//
//  SearchViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "despotify.h"
#import "SpotPlaylist.h"
#import "SpotSearch.h"

#import "SearchResultsDataSource.h"
#import "SearchSuggestionDataSource.h"



@interface SearchViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate>
{
	IBOutlet UITableView *resultsTableView;
	IBOutlet UISearchBar *searchBar;
  IBOutlet UITableView *whileSearchingView;
  
  NSTimer *quickSearchTimer;
	
	SpotSearch *searchResults;
  
  SearchResultsDataSource *resultsDataSource;
  SearchSuggestionDataSource *suggestionDataSource;
  
  
  UITableViewCell *selectedCellThatIsLoading; //yes horrible name, but it's only assigned from selection until next view is loaded. (note _assign_ not retained)
  UIActivityIndicatorView *loadingSpinner;
  BOOL isSearching;
}
-(id)initWithSearch:(SpotSearch*)search;

-(void)searchForString:(NSString*)string;

-(IBAction)headerChanged:(id)sender;

@property (nonatomic, assign) SpotSearch *searchResults;

@end
