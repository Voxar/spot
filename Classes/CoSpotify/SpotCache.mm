//
//  SpotCache.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotCache.h"

#import "Cache.h"
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
  
  mycache = createCache(std::string("mamma3"), std::vector<uint8_t>());
  
  return self;
}

-(void)dealloc;
{
  delete (Cache*)mycache;
  [super dealloc];
}

-(void)addItem:(SpotItem*)item;
{
  if(!item || !item.id || [item.id length] == 0)return;
  
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
  
  std::vector<uint8_t> dataVector = std::vector<uint8_t>(data.length);
  std::copy((char*)data.bytes, (char*)((char*)data.bytes + data.length), dataVector.begin());
  
  NSLog(@"adding item %d bytes of %d", dataVector.size(), data.length);
  self.cache->writeObject([item.id cStringUsingEncoding:NSASCIIStringEncoding], dataVector);
  
}

-(SpotItem *)itemById:(NSString*)id_;
{
  if(!id_ || [id_ length] == 0)return nil;
  
  if(self.cache->hasObject([id_ cStringUsingEncoding:NSASCIIStringEncoding]))
  {
    std::vector<uint8_t> dataVector = std::vector<uint8_t>();
    if(!self.cache->readObject([id_ cStringUsingEncoding:NSASCIIStringEncoding], dataVector))
    {
      NSLog(@"Failed to read object from cache! id: %@", id_);
    }
    

    NSData *data = [NSData dataWithBytes:&(*dataVector.begin()) length:dataVector.size()];
    
    SpotItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSLog(@"Cache %s %@ %@", item ? "hit" : "miss", item, id_);
    return item;
  }
  
  return nil;
}


@end
