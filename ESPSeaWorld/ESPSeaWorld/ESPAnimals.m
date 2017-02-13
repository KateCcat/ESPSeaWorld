//
//  ESPAnimals.m
//  ESPSeaWorld
//
//  Created by Kate on 10.02.17.
//  Copyright © 2017 Kate. All rights reserved.
//

#import "ESPAnimals.h"
#import "ESPPenguin.h"
#import "ESPWhale.h"

@implementation ESPAnimals

+ (ESPAnimals *)animalWithType:(AnimalType)type {
    ESPAnimals *animal;
    if (type == animalPenguin) {
        animal = [[ESPPenguin alloc] init];
    } else if (type == animalWhale) {
        animal = [[ESPWhale alloc] init];
    } else {
        NSAssert(NO, @"Unknown type");
    }
    animal.type = type;
    return animal;
}

@end
