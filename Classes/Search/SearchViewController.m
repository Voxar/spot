//
//  SearchViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SearchViewController.h"
#import "SpotNavigationController.h"
#import "SpotSession.h"
#import "SpotArtist.h"
#import "SpotTrack.h"
#import "SpotSearch.h"

#import "AlbumBrowseViewController.h"
#import "ArtistBrowseViewController.h"
#import "PlayViewController.h"

#import "SpotCell.h"

@interface SearchViewController ()
@property (nonatomic, assign) UITableViewCell *selectedCellThatIsLoading;
@property (nonatomic, retain) NSTimer *quickSearchTimer;
@end

@implementation SearchViewController
@synthesize quickSearchTimer;

#pragma mark 
#pragma mark Memory and init

- (id)init;
{
    if ( ! [super initWithNibName:@"SearchView" bundle:nil]) return nil;
	
	self.title = @"Search";
	self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0] autorelease];
  //a spinner to show as accessoryView on selected cells while data for next view is loading
	loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  
  return self;
}


-(id)initWithSearch:(SpotSearch*)search;
{
//  if( ! [super initWithNibName:@"SearchView" bundle:nil])
  if( ! [self init] )
		return nil;
  
  self.searchResults = search;
  
	return self;
}

- (void)dealloc {
  [loadingSpinner release];
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  //UISegmentedControl *header = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Artists", @"Albums", @"Tracks", nil]];
  resultsTableView.rowHeight = 70;
  //resultsTableView.tableHeaderView = header;
  searchBar.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSearch"];
  
  resultsDataSource = [[SearchResultsDataSource alloc] init];
  resultsTableView.dataSource = resultsDataSource;
  
  suggestionDataSource = [[SearchSuggestionDataSource alloc] init];
  whileSearchingView.dataSource = suggestionDataSource;
}

-(void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
}
    

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark 
#pragma mark Transitions
-(void)viewWillAppear:(BOOL)animated;
{
	[self.navigationController setNavigationBarHidden:YES animated:NO];
  
  if([searchBar.text length] == 0)
    [searchBar becomeFirstResponder];
  else if(!searchResults)
    
    [self searchForString:searchBar.text];
}


#pragma mark TableView delegate
-(void)viewWillDisappear:(BOOL)animated;
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  //Don't allow new selection if data is loading
  if(self.selectedCellThatIsLoading) return nil;
  
  return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  //Don't allow deselect if data is loading
  if(self.selectedCellThatIsLoading) return nil;
  
  return indexPath;
}

-(void)doShowItem:(SpotItem*)item;
{
  [self.navigationController showItem:item];
  self.selectedCellThatIsLoading = nil;
}

- (void)tableView:(UITableView *)tableView_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(tableView_ == resultsTableView){
    [searchBar resignFirstResponder];
    int idx = [indexPath indexAtPosition:1];
    UITableViewCell *cell = [tableView_ cellForRowAtIndexPath:indexPath];
    switch(resultsDataSource.showType) {
      case ShowArtists: {
        SpotArtist *artist = [searchResults.artists objectAtIndex:idx];
        //Get the fullprofile artist
  //      artist = [[SpotSession defaultSession] artistById:artist.id];
        
        self.selectedCellThatIsLoading = cell;
        [[SpotSession defaultSession] artistById:artist.id respondTo:self selector:@selector(doShowItem:)];
        
        //[self.navigationController showArtist:artist];
      } break;
      case ShowAlbums: {
        SpotAlbum *album = [searchResults.albums objectAtIndex:idx];
        //get the fullprofile album
        //album = [[SpotSession defaultSession] albumById:album.id];
        self.selectedCellThatIsLoading = cell;

        [[SpotSession defaultSession] albumById:album.id respondTo:self selector:@selector(doShowItem:)];
  //			[self.navigationController showAlbum:album];
        break;
      }
      case ShowTracks: {
        SpotTrack *track = [searchResults.tracks objectAtIndex:idx];
        SpotPlaylist *playlist = [[[SpotPlaylist alloc] initWithName:searchResults.query author:@"search" tracks:searchResults.tracks] autorelease];
        [[SpotSession defaultSession].player playPlaylist:playlist firstTrack:track];
        [self.navigationController showPlayer];
      } break;
    }
  } else if(tableView_ == whileSearchingView){
    NSString *suggestion = [suggestionDataSource.suggestions objectAtIndex:indexPath.row];
    searchBar.text = suggestion;
    [self searchBarSearchButtonClicked:searchBar];
  }
}

#pragma mark 
#pragma mark Search bar callbacks
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;
{
	return [SpotSession defaultSession].loggedIn == YES;
}

-(void)receiveAsyncSearch:(SpotSearch *)search;
{
  NSLog(@"received searchresults");
  suggestionDataSource.searchResults = search;
  isSearching = NO;
  [whileSearchingView reloadData];
}

-(void)doSearchFor:(NSString*)searchString maxResults:(NSUInteger)maxResults;
{
  if(isSearching) {
    NSLog(@"I'm busy searching allreay");
    return;
  }
  isSearching = YES;
  [[SpotSession defaultSession] searchFor:searchString maxResults:maxResults respondTo:self selector:@selector(receiveAsyncSearch:)];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_;
{
  [self.view addSubview:whileSearchingView];
  if(searchBar_.text.length > 0){
    NSLog(@"Doing initial search");
    [self doSearchFor:searchBar_.text maxResults:5];
  }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  [quickSearchTimer invalidate];
  self.quickSearchTimer = nil;
  
  [whileSearchingView removeFromSuperview];
}



-(void)doQuickSearch:(NSTimer*)theTimer;
{
  //TODO: ProgressIndicator!
  
  NSLog(@"Doing quickSearch");
  suggestionDataSource.searchResults = nil;
  suggestionDataSource.suggestions = nil;
  [whileSearchingView reloadData];
  
  self.quickSearchTimer = nil;
  NSString *searchText = [theTimer.userInfo objectForKey:@"text"];
  [self doSearchFor:searchText maxResults:5];
}

- (void)searchBar:(UISearchBar *)searchBar_ textDidChange:(NSString *)searchText;
{
	// Do short search maybe
  [quickSearchTimer invalidate];
  self.quickSearchTimer = nil;

  if([searchText length] > 0){
    self.quickSearchTimer = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(doQuickSearch:) userInfo:[NSDictionary dictionaryWithObject:searchText forKey:@"text"] repeats:NO];
  } else {
    suggestionDataSource.searchResults = nil;
    //Show latest searches
    [whileSearchingView reloadData];
  }
}

-(void)fullSearchResponse:(SpotSearch*)results;
{
  NSString *searchString = results.query;
  self.searchResults = [SpotSearch searchFor:searchString maxResults:50];
  //save last search if it generated any results
  if(searchResults && searchResults.totalAlbums || searchResults.totalTracks || searchResults.totalArtists){
    [[NSUserDefaults standardUserDefaults] setObject:searchString forKey:@"lastSearch"];
    NSMutableArray *latest = [[[NSUserDefaults standardUserDefaults] objectForKey:@"latestSearches"] mutableCopy];
    if(![latest containsObject:searchString]){
      if(!latest) latest = [NSMutableArray array];
      
      [latest insertObject:searchString atIndex:0];
      while(latest.count > 10){
        [latest removeLastObject];
      }
      [[NSUserDefaults standardUserDefaults] setObject:latest forKey:@"latestSearches"];
      NSLog(@"saved latest:%@", latest);
    }
  }  
}

-(void)searchForString:(NSString*)string;
{
  // Do extensive search
	self.searchResults = nil;
  //NSLog(@"searching");
  [[SpotSession defaultSession] searchFor:string maxResults:50 respondTo:self selector:@selector(fullSearchResponse:)];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_;  
{
  [quickSearchTimer invalidate];
  self.quickSearchTimer = nil;
  
  [searchBar resignFirstResponder];
  [self searchForString:[searchBar_ text]];
  [whileSearchingView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_;  
{
  [quickSearchTimer invalidate];
  self.quickSearchTimer = nil;
  
  if(searchResults)
    searchBar.text = searchResults.query;
  
  [searchBar resignFirstResponder];
}


-(void)headerChanged:(id)sender;
{
  [searchBar resignFirstResponder];
  UISegmentedControl *e = sender;
  resultsDataSource.showType = (SearchShowType)e.selectedSegmentIndex;
  [resultsTableView reloadData];
}

#pragma mark 
#pragma mark Accessors
@synthesize selectedCellThatIsLoading;
-(void)setSelectedCellThatIsLoading:(UITableViewCell*)cell;
{
  if(selectedCellThatIsLoading){
    selectedCellThatIsLoading.accessoryView = nil;
    [loadingSpinner stopAnimating];
  }
  selectedCellThatIsLoading = cell;
  if(selectedCellThatIsLoading){
    selectedCellThatIsLoading.accessoryView = loadingSpinner;
    [loadingSpinner startAnimating];
  }
}

@synthesize searchResults;
-(void)setSearchResults:(SpotSearch*)searchResults_;
{
	[searchResults_ retain];
  [searchResults release];
  searchResults = searchResults_;
  
  resultsDataSource.searchResults = searchResults;
  
	[resultsTableView reloadData];
}
@end
