//
//  ESPItemModel.h
//  ESPSeaWorld
//
//  Created by Kate on 09.02.17.
//  Copyright © 2017 Kate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPAnimals.h"
typedef enum {
    stateEmpty,
    stateWhale,
    statePenguin
} StateItem;

@interface ESPItemModel : NSObject
@property (nonatomic) NSInteger xCoord;
@property (nonatomic) NSInteger yCoord;
@property (nonatomic) StateItem stateItem;
@property (strong, nonatomic)ESPAnimals* animal;
@end
