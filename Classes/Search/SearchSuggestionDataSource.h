//
//  SearchSuggestionDataSource.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-08-16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SpotSearch.h"

@interface SearchSuggestionDataSource : NSObject <UITableViewDataSource> {
  SpotSearch *searchResults;
  NSArray *suggestions;
  NSString *didYouMean;
}

@property (nonatomic, retain) SpotSearch *searchResults;
@property (nonatomic, retain) NSArray *suggestions;

@end
