//
//  HelloWorldLayer.h
//  TileGame
//
//  Created by Andrew Helmkamp on 12/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@interface HelloWorldHub : CCLayer {
    CCLabelTTF *label;
}

-(void)numCollectedChanged:(int)numCollected;

@end


// HelloWorldLayer
@interface HelloWorldLayer : CCLayer 
{
    CCTMXLayer *_background;
    CCTMXLayer *_meta;
    CCTMXLayer *_foreground;
    CCTMXTiledMap *_tileMap;
    CCSprite *_player;
    
    int _numCollected;
    HelloWorldHub *_hud;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) CCTMXLayer *foreground;
@property (nonatomic, retain) CCTMXLayer *meta;
@property (nonatomic, retain) CCSprite *player;

@property (nonatomic, assign) int numCollected;
@property (nonatomic, retain) HelloWorldHub *hud;

@end
