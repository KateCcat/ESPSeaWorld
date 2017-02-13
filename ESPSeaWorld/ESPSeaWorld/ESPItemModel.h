//
//  ESPItemModel.h
//  ESPSeaWorld
//
//  Created by Kate on 09.02.17.
//  Copyright © 2017 Kate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPAnimals.h"

@interface ESPItemModel : NSObject
@property (nonatomic) NSInteger xCoord;
@property (nonatomic) NSInteger yCoord;
@property (nonatomic) AnimalType stateItem;
@property (strong, nonatomic)ESPAnimals* animal;
@end
