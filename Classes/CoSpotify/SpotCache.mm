//
//  SpotCache.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotCache.h"

#import "Cache.h"
#import "Sqlite.h"
#import <string>

@interface SpotCache (Private)
@property (readonly, nonatomic) Cache* cache;
@end
@implementation SpotCache (Private)
-(Cache*)cache;{return (Cache*)mycache;}
@end



@implementation SpotCache

-(id)init;
{
  if( ! [super init] ) return nil;
  
  //Open the diskcache
  NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *persistentCachePath = [docsPath stringByAppendingPathComponent:@"cache"];
  NSLog(@"Opening cache: %@", persistentCachePath);
  
  try{
    mycache = createCache(std::string([persistentCachePath cStringUsingEncoding:NSASCIIStringEncoding]), std::vector<uint8_t>());
  }
  catch (Sqlite::Error &e) {
    NSLog(@"Cache is currupt! Recreating");
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:persistentCachePath error:&error];
    if(error) {
      NSLog(@"Error deleteing currupt cache: %@", error);
      mycache = nil;
    }
    //try create again
    mycache = createCache(std::string([persistentCachePath cStringUsingEncoding:NSASCIIStringEncoding]), std::vector<uint8_t>());
  }
  int maxDiscCacheSize = 1024*1024*1000; //one gig is ok?
  if(mycache)
    self.cache->setMaxSize(maxDiscCacheSize);
  
  //Create memcache
  memcache = [[NSMutableDictionary alloc] init];
  
  //Subscribe to memory warnings to autoflush the cache
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
  
  NSLog(@"cache ready");
  
  return self;
}

-(void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [memcache release];
  if(mycache) delete (Cache*)mycache;
  [super dealloc];
}

-(void)addItem:(SpotItem*)item;
{
  if(!item || !item.id || [item.id length] == 0)return;
  
  //Add to memcache
  [memcache setObject:item forKey:item.id];
  
  //Add to persistent cache
  if(mycache)
  @synchronized(self){
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
    
    std::vector<uint8_t> dataVector = std::vector<uint8_t>(data.length);
    std::copy((char*)data.bytes, (char*)((char*)data.bytes + data.length), dataVector.begin());
    
    NSLog(@"adding item %d bytes of %d", dataVector.size(), data.length);
    self.cache->writeObject([item.id cStringUsingEncoding:NSASCIIStringEncoding], dataVector);
  }  
}

-(SpotItem *)itemById:(NSString*)id_;
{
  if(!id_ || [id_ length] == 0)return nil;
  
  {
    SpotItem *item = [memcache objectForKey:id_];
    if(item) {
      NSLog(@"MemCache %s %@ %@", item ? "hit" : "miss", item, id_);
      return item;
    }
  }
  
  if(mycache)
  @synchronized(self){
    if(self.cache->hasObject([id_ cStringUsingEncoding:NSASCIIStringEncoding]))
    {
      std::vector<uint8_t> dataVector = std::vector<uint8_t>();
      if(!self.cache->readObject([id_ cStringUsingEncoding:NSASCIIStringEncoding], dataVector))
      {
        NSLog(@"Failed to read object from cache! id: %@", id_);
        self.cache->eraseObject([id_ cStringUsingEncoding:NSASCIIStringEncoding]);
        return nil;
      }
      //found data. pack it up
      NSData *data = [NSData dataWithBytes:&(*dataVector.begin()) length:dataVector.size()];
      
      SpotItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
      
      NSLog(@"Cache %s %@ %@", item ? "hit" : "miss", item, id_);
      
      //Add to memcache so it's closer at hand next time
      [memcache setObject:item forKey:item.id];
      
      return item;
    }
  }  
  return nil;
}

-(void)purge;
{
  NSLog(@"Purging memcache");
  for(SpotItem *item in [memcache allValues]){
    if([item retainCount] == 2){
      //item is in cache and allValues only so we want them gone
      NSLog(@"Removing %@", item);
      [memcache removeObjectForKey:item.id]; //Hm. Hope id doesn't change!
    } else if([item retainCount] < 2){
      NSLog(@"Hmm. cache got object with RetainCount Below two");
    }
  }
}

-(void)didReceiveMemoryWarningNotification:(NSNotification*)n;
{
  [self purge];
}

-(NSUInteger)diskCacheSize;
{
  if(!mycache) return 0;
  return self.cache->getCurrentSize();
}

@end
