//
//  SpotItem.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotItem.h"


@implementation SpotItem

-(SpotId *)id;
{
  return nil;
}

-(SpotURI *)uri;
{
  return [SpotURI uriWithId:self.id];
}

@end
