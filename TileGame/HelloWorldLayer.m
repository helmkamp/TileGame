//
//  HelloWorldLayer.m
//  TileGame
//
//  Created by Andrew Helmkamp on 12/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

@implementation HelloWorldHub

-(id) init {
    if ( (self = [super init])) {
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        label = [CCLabelTTF labelWithString:@"0" dimensions:CGSizeMake(50, 20) hAlignment:UITextAlignmentRight fontName:@"Verdana-Bold" fontSize:18.0];
        label.color = ccc3(0, 0, 0);
        int margin = 10;
        label.position = ccp(winSize.width - (label.contentSize.width/2) - margin, label.contentSize.height/2 + margin);
        [self addChild:label];
    }
    return self;
}

-(void)numCollectedChanged:(int)numCollected {
    [label setString:[NSString stringWithFormat:@"%d", numCollected]];
}

@end

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize tileMap = _tileMap, background = _background, player = _player, meta = _meta, foreground = _foreground, numCollected = _numCollected, hud = _hud;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
    //add the score layer
    HelloWorldHub *hud = [HelloWorldHub node];
    [scene addChild:hud];
    layer.hud = hud;
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        self.isTouchEnabled = YES;
        
        //Add the background
		self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMap-hd.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
        //Foreground
        self.foreground = [_tileMap layerNamed:@"Foreground"];
        
        //Load the Meta layer for collision detection
        self.meta = [_tileMap layerNamed:@"Meta"];
        _meta.visible = NO;
		
		//Add the player
        CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"Objects"];
        NSAssert(objects != nil, @"'Objects' object group not found");
        NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];
        NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
        int x = [[spawnPoint valueForKey:@"x"] intValue];
        int y = [[spawnPoint valueForKey:@"y"] intValue];
        
        self.player = [CCSprite spriteWithFile:@"Player.png"];
        _player.position = ccp(x,y);
        _player.anchorPoint = ccp(0,0);
        
        
        [self addChild:_tileMap z:-1];
        [self addChild:_player];
        
        [self setViewpointCenter:_player.position];
		
		

	}
	return self;
}

-(CGPoint) tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height)-position.y) / _tileMap.tileSize.height;
    return ccp(x,y);
}

-(void)setViewpointCenter:(CGPoint) position {
    // ask director for the window size
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, size.width/2);
    int y = MAX(position.y, size.height/2);
    
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) - size.width/2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) - size.height/2);
    
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(size.width/2, size.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
}

-(void)registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

-(void)setPlayerPosition:(CGPoint)position {
    CGPoint tileCoord = [self tileCoordForPosition:position];
    int tileGid = [_meta tileGIDAt:tileCoord];
    if (tileGid) {
        NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
        if (properties) {
            NSString *collision = [properties valueForKey:@"Collidable"];
            if (collision && [collision compare:@"True"] == NSOrderedSame) {
                return;
            }
            NSString *collectable = [properties valueForKey:@"Collectable"];
            if (collectable && [collectable compare:@"True"] == NSOrderedSame) {
                [_meta removeTileAt:tileCoord];
                [_foreground removeTileAt:tileCoord];
                //add to the score
                self.numCollected++;
                [_hud numCollectedChanged:_numCollected];
            }
        }
    }
    _player.position = position;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    CGPoint playerPos = _player.position;
    CGPoint diff = ccpSub(touchLocation, playerPos);
    if (abs(diff.x) > abs(diff.y)) {
        if (diff.x > 0) {
            playerPos.x += _tileMap.tileSize.width;
        } else {
            playerPos.x -= _tileMap.tileSize.width;
        }
    } else {
        if (diff.y > 0) {
            playerPos.y += _tileMap.tileSize.height;
        } else {
            playerPos.y -= _tileMap.tileSize.height;
        }
    }
    
    if (playerPos.x <= (_tileMap.mapSize.width * _tileMap.tileSize.width) && playerPos.y <= (_tileMap.mapSize.height * _tileMap.tileSize.height) && playerPos.y >= 0 && playerPos.x >= 0) {
        [self setPlayerPosition:playerPos];
    }

    [self setViewpointCenter:_player.position];
}










// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	self.background = nil;
    self.foreground = nil;
    self.meta = nil;
    self.tileMap = nil;
    self.player = nil;
    self.hud = nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}












@end
