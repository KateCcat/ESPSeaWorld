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
#define kWhalesPercentage 0.05
#define kPenguinPercentage 0.5

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *fieldCollectionView;
@property(nonatomic) NSUInteger fieldHeight;
@property(nonatomic) NSUInteger fieldWidth;
@property(strong, nonatomic) NSMutableArray<NSMutableArray<ESPItemModel*>*> * fullField;
@property (strong,nonatomic)NSMutableArray*animals;

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
    _animals = [NSMutableArray array];
    for (NSInteger y = 0; y < _fieldHeight; y++) {
        NSMutableArray* items = [NSMutableArray array];
        for (NSInteger x = 0; x < _fieldWidth; x++) {
            ESPItemModel* item = [[ESPItemModel alloc]init];
            item.stateItem = animalNone;
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
    
    [self locateAnlimalsWithCount:countWhale andType:animalWhale];
    [self locateAnlimalsWithCount:countPenguin andType:animalPenguin];
    
    [_fieldCollectionView reloadData];
}

-(void)locateAnlimalsWithCount:(NSInteger)count andType:(AnimalType)type{
    
    while (count> 0) {
        
        NSInteger rndX = arc4random() % _fieldWidth;
        NSInteger rndY = arc4random() % _fieldHeight;
        ESPItemModel* item = [[_fullField objectAtIndex:rndY] objectAtIndex:rndX];
        
        if (item.stateItem == animalNone) {
            
            item.stateItem = type;
            ESPAnimals* animal = [ESPAnimals animalWithType:type];
            
            item.animal = animal;
            animal.xCoord = rndX;
            animal.yCoord = rndY;
            [_animals addObject:animal];
            count--;
        }
    }
}

#pragma mark - Actions

- (IBAction)restartAction:(id)sender {
    [self setupField];
    [self startField];
}

- (IBAction)moveAction:(id)sender {
    
    NSMutableArray* animalsForDelete = [NSMutableArray array];
    for (NSInteger i = 0; i < _animals.count ; i++) {
        ESPAnimals* animal = [_animals objectAtIndex: i];
        NSArray* animalsTemp = [self nearItemsForAnimal:animal];
        if ([animalsForDelete containsObject:animal]) {
            continue;
        }
        if ([animal isKindOfClass:[ESPWhale class]]) {
            ESPWhale *whale =  (ESPWhale*)animal;
            
            if (whale.whaleDeath > kWhaleDeathTime) {
                
                [animalsForDelete addObject:whale];
                ESPItemModel* item =  [[_fullField objectAtIndex:(whale.yCoord )] objectAtIndex:(whale.xCoord )];
                item.stateItem = animalNone;
                item.animal = nil;
                continue;
            }
            
            [self reproduceAnimal:animal inItems:animalsTemp];
            
            BOOL isMoved = NO;
            for (NSInteger i = 0; i<animalsTemp.count; i++) {
                ESPItemModel* item = [animalsTemp objectAtIndex: i];
                if (item.stateItem == animalPenguin) {
                    
                    item.stateItem = animalWhale;
                    [animalsForDelete addObject:item.animal];
                    item.animal = whale;
                    ESPItemModel* itemOld = [[_fullField objectAtIndex:(whale.yCoord )] objectAtIndex:(whale.xCoord )];
                    itemOld.stateItem = animalNone;
                    itemOld.animal =nil;
                    whale.xCoord = item.xCoord;
                    whale.yCoord = item.yCoord;
                    whale.whaleDeath = 0;
                    isMoved = YES;
                    break;
                }
            }
            
            if ( ! isMoved) {
                
                [self moveAnimal:animal inItems:animalsTemp];
                whale.whaleDeath ++;
            }
        }
        
        else if ([animal isKindOfClass:[ESPPenguin class]])
        {
            [self reproduceAnimal:animal inItems:animalsTemp];
            [self moveAnimal:animal inItems:animalsTemp];
        }
        animal.reproduction ++;
    }
    [_animals removeObjectsInArray: animalsForDelete];
    [_fieldCollectionView reloadData];
}

-(void) reproduceAnimal:(ESPAnimals*)animal inItems:(NSArray*)animalsTemp
{
    if (animal.reproduction == [animal reproductionInterval]) {
        NSInteger countPeng = arc4random() % [animalsTemp count];
        ESPItemModel* item = [animalsTemp objectAtIndex: countPeng];
        
        if ( item.stateItem  == animalNone) {
            ESPAnimals* animalNew = [ESPAnimals animalWithType:animal.type];
            item.stateItem = animalPenguin;
            item.animal = animalNew;
            
            animalNew.xCoord = item.xCoord;
            animalNew.yCoord = item.yCoord;
            [_animals addObject:animalNew];
        }
        animal.reproduction = 0;
    }
}

-(void) moveAnimal:(ESPAnimals*)animal inItems:(NSArray*)animalsTemp
{
    NSInteger countPeng = arc4random() % [animalsTemp count];
    ESPItemModel* item = [animalsTemp objectAtIndex: countPeng];
    if ( item.stateItem  == animalNone) {
        
        item.stateItem = animal.type;
        item.animal = animal;
        ESPItemModel* itemOld = [[_fullField objectAtIndex:(animal.yCoord )] objectAtIndex:(animal.xCoord )];
        itemOld.stateItem = animalNone;
        itemOld.animal = nil;
        animal.xCoord = item.xCoord;
        animal.yCoord = item.yCoord;
    }
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
    
    if (item.stateItem == animalPenguin) {
        
        cell.imageView.image = [UIImage imageNamed:@"tux"];
    }
    else if (item.stateItem == animalWhale){
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
