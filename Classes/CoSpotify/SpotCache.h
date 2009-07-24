//
//  SpotCache.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotItem.h"

//keeps a cache of SpotItems

@interface SpotCache : NSObject {
  void *mycache;
  NSMutableDictionary *memcache;
}

-(void)addItem:(SpotItem*)item;
-(SpotItem *)itemById:(NSString*)id;

-(void)purge;
-(void)didReceiveMemoryWarning:(NSNotification*)n;

-(NSUInteger)diskCacheSize;
@property (readonly) NSUInteger diskCacheSize;

@end
