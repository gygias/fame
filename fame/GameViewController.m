//
//  GameViewController.m
//  fame
//
//  Created by david on 8/6/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    NSLog(@"%@",[[NSBundle mainBundle] bundlePath]);
//    NSString *textureNamesPath = [[NSBundle mainBundle] pathForResource:@"textures" ofType:@"txt"];
//    NSArray *textureNames = [[NSString stringWithContentsOfFile:textureNamesPath encoding:NSUTF8StringEncoding error:NULL] componentsSeparatedByString:@"\n"];
    
//    NSMutableArray *allTextures = [NSMutableArray new];
//    [textureNames enumerateObjectsUsingBlock:^(NSString *textureName, NSUInteger idx, BOOL *stop) {
//        SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
//        [allTextures addObject:texture];
//        [texture preloadWithCompletionHandler:^{
//            NSLog(@"preloaded %@",textureName);
//        }];
//    }];
//    self.allTextures = allTextures;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
