//
//  ViewController.m
//  ESPSeaWorld
//
//  Created by Kate on 08.02.17.
//  Copyright © 2017 Kate. All rights reserved.
//

#import "ViewController.h"
#import "ESPItemModel.h"
#import "ESPItemViewCell.h"
#import "ESPWhale.h"
#import "ESPPenguin.h"

#define kWhaleDeathTime 2
#define kWhaleChildTime 7
#define kPenguinChildTime 2
#define kWhalesPercentage 0.05
#define kPenguinPercentage 0.5

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *fieldCollectionView;
@property(nonatomic) NSUInteger fieldHeight;
@property(nonatomic) NSUInteger fieldWidth;
@property(strong, nonatomic) NSMutableArray<NSMutableArray<ESPItemModel*>*> * fullField;
@property (strong,nonatomic)NSMutableArray* whales;
@property (strong,nonatomic)NSMutableArray* penguins;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;

@end

@implementation ViewController
static NSString * const reuseIdentifier = @"Cell";

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _fieldHeight = 15;
    _fieldWidth = 10;
    [self setupField];
    [self startField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Initial setup

-(void) setupField {
    _fullField =[NSMutableArray array];
    _whales = [NSMutableArray array];
    _penguins =[NSMutableArray array];
    for (NSInteger y = 0; y < _fieldHeight; y++) {
        NSMutableArray* items = [NSMutableArray array];
        for (NSInteger x = 0; x < _fieldWidth; x++) {
            ESPItemModel* item = [[ESPItemModel alloc]init];
            item.stateItem = stateEmpty;
            item.xCoord = x;
            item.yCoord = y;
            [items addObject:item];
        }
        [_fullField addObject:items];
    }
}

-(void)startField{
    
    NSInteger countWhale = roundf(_fieldWidth * _fieldHeight * kWhalesPercentage);
    NSInteger countPenguin = roundf(_fieldWidth * _fieldHeight * kPenguinPercentage);
    
    while (countWhale > 0) {
        
        NSInteger rndX = arc4random() % _fieldWidth;
        NSInteger rndY = arc4random() % _fieldHeight;
        ESPItemModel* item = [[_fullField objectAtIndex:rndY] objectAtIndex:rndX];
        
        if (item.stateItem == stateEmpty) {
            
            item.stateItem = stateWhale;
            ESPWhale* whale = [[ESPWhale alloc]init];
            item.animal = whale;
            whale.xCoord = rndX;
            whale.yCoord = rndY;
            [_whales addObject:whale];
            countWhale--;
        }
    }
    while (countPenguin > 0) {
        
        NSInteger rndX = arc4random() % _fieldWidth;
        NSInteger rndY = arc4random() % _fieldHeight;
        ESPItemModel* item = [[_fullField objectAtIndex:rndY] objectAtIndex:rndX];
        
        if (item.stateItem == stateEmpty) {
            
            item.stateItem = statePenguin;
            ESPPenguin* penguin =[[ESPPenguin alloc]init];
            item.animal = penguin;
            penguin.xCoord = rndX;
            penguin.yCoord = rndY;
            [_penguins addObject:penguin];
            countPenguin--;
        }
    }
    [_fieldCollectionView reloadData];
}

#pragma mark - Actions

- (IBAction)restartAction:(id)sender {
    [self setupField];
    [self startField];
}

- (IBAction)moveAction:(id)sender {
    
    NSMutableArray* whalesForDelete = [NSMutableArray array];
    for (NSInteger i = 0; i < _whales.count ; i++) {
        ESPWhale* whale = [_whales objectAtIndex: i];
        NSArray* whalesTemp = [self nearItemsForAnimal:whale];
        if (whale.whaleDeath > kWhaleDeathTime) {
            
            [whalesForDelete addObject:whale];
            ESPItemModel* item =  [[_fullField objectAtIndex:(whale.yCoord )] objectAtIndex:(whale.xCoord )];
            item.stateItem = stateEmpty;
            item.animal = nil;
            continue;
        }
        
        if (whale.reproduction == kWhaleChildTime) {
            NSInteger countWhale = arc4random() % [whalesTemp count];
            ESPItemModel* item = [whalesTemp objectAtIndex: countWhale];
            
            if ( item.stateItem  == stateEmpty) {
                ESPWhale * whaleNew = [[ESPWhale alloc]init];
                item.stateItem = stateWhale;
                item.animal = whaleNew;
                
                whaleNew.xCoord = item.xCoord;
                whaleNew.yCoord = item.yCoord;
                [_whales addObject:whaleNew];
            }
            whale.reproduction = 0;
        }
        
        BOOL isMoved = NO;
        for (NSInteger i = 0; i<whalesTemp.count; i++) {
            ESPItemModel* item = [whalesTemp objectAtIndex: i];
            if (item.stateItem == statePenguin) {
                
                item.stateItem = stateWhale;
                [_penguins removeObject:item.animal];
                item.animal = whale;
                ESPItemModel* itemOld = [[_fullField objectAtIndex:(whale.yCoord )] objectAtIndex:(whale.xCoord )];
                itemOld.stateItem = stateEmpty;
                itemOld.animal =nil;
                whale.xCoord = item.xCoord;
                whale.yCoord = item.yCoord;
                whale.whaleDeath = 0;
                isMoved = YES;
                break;
            }
        }
        
        if ( ! isMoved) {
            NSInteger countWhale = arc4random() % [whalesTemp count];
            ESPItemModel* item = [whalesTemp objectAtIndex: countWhale];
            
            if ( item.stateItem  == stateEmpty) {
                
                item.stateItem = stateWhale;
                ESPItemModel* itemOld = [[_fullField objectAtIndex:(whale.yCoord )] objectAtIndex:(whale.xCoord )];
                itemOld.stateItem = stateEmpty;
                whale.xCoord = item.xCoord;
                whale.yCoord = item.yCoord;
                whale.whaleDeath++;
            }
        }
        whale.reproduction++;
    }
    [_whales removeObjectsInArray: whalesForDelete];
    
    for (NSInteger i = 0; i < _penguins.count ; i++) {
        ESPPenguin* penguin = [_penguins objectAtIndex: i];
        NSArray* penguinsTemp  = [self nearItemsForAnimal:penguin];
        
        if (penguin.reproduction == kPenguinChildTime) {
            NSInteger countPeng = arc4random() % [penguinsTemp count];
            ESPItemModel* item = [penguinsTemp objectAtIndex: countPeng];
            
            if ( item.stateItem  == stateEmpty) {
                ESPPenguin* pengNew = [[ESPPenguin alloc]init];
                item.stateItem = statePenguin;
                item.animal = pengNew;
                
                pengNew.xCoord = item.xCoord;
                pengNew.yCoord = item.yCoord;
                [_penguins addObject:pengNew];
            }
            penguin.reproduction = 0;
        }
        
        NSInteger countPeng = arc4random() % [penguinsTemp count];
        ESPItemModel* item = [penguinsTemp objectAtIndex: countPeng];
        if ( item.stateItem  == stateEmpty) {
            
            item.stateItem = statePenguin;
            item.animal = penguin;
            ESPItemModel* itemOld = [[_fullField objectAtIndex:(penguin.yCoord )] objectAtIndex:(penguin.xCoord )];
            itemOld.stateItem = stateEmpty;
            itemOld.animal = nil;
            penguin.xCoord = item.xCoord;
            penguin.yCoord = item.yCoord;
        }
        penguin.reproduction ++;
    }
    
    [_fieldCollectionView reloadData];
}


-(NSArray*)nearItemsForAnimal: (ESPAnimals*)animal{
    
    NSMutableArray* animalsTemp = [NSMutableArray array];
    
    if (0 <= (animal.xCoord -1)  && (animal.xCoord -1) < _fieldWidth  && 0 <= (animal.yCoord - 1) && (animal.yCoord - 1) < _fieldHeight ) {
        
        ESPItemModel* item = [[_fullField objectAtIndex:(animal.yCoord - 1)] objectAtIndex:(animal.xCoord -1)];
        [animalsTemp addObject: item];
    }
    if (0 <= (animal.xCoord) && (animal.xCoord) < _fieldWidth  && 0 <= (animal.yCoord - 1) &&  (animal.yCoord - 1)< _fieldHeight ) {
        
        ESPItemModel* item = [[_fullField objectAtIndex:(animal.yCoord - 1)] objectAtIndex:(animal.xCoord)];
        [animalsTemp addObject: item];
    }
    if (0 <= (animal.xCoord +1) && (animal.xCoord +1)< _fieldWidth  && 0 <= (animal.yCoord - 1) && (animal.yCoord - 1) <_fieldHeight ) {
        
        ESPItemModel* item = [[_fullField objectAtIndex:(animal.yCoord - 1)] objectAtIndex:(animal.xCoord +1)];
        [animalsTemp addObject: item];
    }
    if (0 <= (animal.xCoord -1) && (animal.xCoord -1)< _fieldWidth && 0 <= (animal.yCoord) && (animal.yCoord)< _fieldHeight ) {
        
        ESPItemModel* item = [[_fullField objectAtIndex:(animal.yCoord )] objectAtIndex:(animal.xCoord -1)];
        [animalsTemp addObject: item];
    }
    if (0 <= (animal.xCoord +1) && (animal.xCoord +1)< _fieldWidth  && 0 <= (animal.yCoord )&& (animal.yCoord )< _fieldHeight ) {
        
        ESPItemModel* item = [[_fullField objectAtIndex:(animal.yCoord )] objectAtIndex:(animal.xCoord +1)];
        [animalsTemp addObject: item];
    }
    if (0 <= (animal.xCoord -1) && (animal.xCoord -1) < _fieldWidth  && 0 <= (animal.yCoord + 1) && (animal.yCoord + 1) < _fieldHeight ) {
        
        ESPItemModel* item = [[_fullField objectAtIndex:(animal.yCoord + 1)] objectAtIndex:(animal.xCoord -1)];
        [animalsTemp addObject: item];
    }
    if (0 <= (animal.xCoord) && (animal.xCoord) < _fieldWidth  && 0 <= (animal.yCoord + 1) && (animal.yCoord + 1)< _fieldHeight ) {
        
        ESPItemModel* item = [[_fullField objectAtIndex:(animal.yCoord + 1)] objectAtIndex:(animal.xCoord )];
        [animalsTemp addObject: item];
    }
    if (0 <= (animal.xCoord+1)&& (animal.xCoord+1) < _fieldWidth && 0 <= (animal.yCoord + 1) && (animal.yCoord + 1) < _fieldHeight ) {
        
        ESPItemModel* item = [[_fullField objectAtIndex:(animal.yCoord + 1)] objectAtIndex:(animal.xCoord +1)];
        [animalsTemp addObject: item];
    }
    return  animalsTemp;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    _debugLabel.text = [NSString stringWithFormat:@" Whale %lu Penguin %lu",(unsigned long)_whales.count, (unsigned long)_penguins.count];
    return _fieldWidth;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _fieldHeight;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ESPItemViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    ESPItemModel* item = [[_fullField objectAtIndex: indexPath.section] objectAtIndex:indexPath.row];
    
    cell.imageView.image =nil;
    cell.backgroundColor=[UIColor whiteColor];
    
    if (item.stateItem == statePenguin) {
        
        cell.imageView.image = [UIImage imageNamed:@"tux"];
    }
    else if (item.stateItem == stateWhale){
        cell.imageView.image = [UIImage imageNamed:@"orca"];
        
    }
    else{
        
        cell.backgroundColor=[UIColor blueColor];
        
    }
    return cell;
}

#pragma mark - ICollectionViewDelegateFlowLayout 

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    float itemHeight = ceilf((self.view.frame.size.height-60)/_fieldHeight) - 2;
    float itemWigth = ceilf(self.view.frame.size.width/_fieldWidth)- 2;
    
    return CGSizeMake(itemWigth, itemHeight);
}

@end
