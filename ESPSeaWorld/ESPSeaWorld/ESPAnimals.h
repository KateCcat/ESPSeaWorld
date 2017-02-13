//
//  ESPAnimals.h
//  ESPSeaWorld
//
//  Created by Kate on 10.02.17.
//  Copyright © 2017 Kate. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    animalNone,
    animalWhale,
    animalPenguin
} AnimalType;

@interface ESPAnimals : NSObject
@property (nonatomic) NSInteger xCoord;
@property (nonatomic) NSInteger yCoord;
@property (nonatomic) NSInteger reproduction;
@property (nonatomic) AnimalType type;
@property (nonatomic, readonly) NSInteger reproductionInterval;

+ (ESPAnimals *)animalWithType:(AnimalType)type;;

@end
