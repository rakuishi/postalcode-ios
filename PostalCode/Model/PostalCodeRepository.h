//
//  PostalCodeRepository.h
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 2012/10/18.
//  Copyright (c) 2012年 OCHIISHI Koichiro. All rights reserved.

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface PostalCodeRepository : NSObject

+ (PostalCodeRepository *)sharedRepository;
+ (NSString *)path;

- (NSMutableArray *)searchWithQuery:(NSString *)query;
- (NSMutableArray *)getStateSectionIndexTitles;
- (NSMutableArray *)getStates;
- (NSMutableArray *)getCityTownsByState:(NSString *)state;
- (NSMutableArray *)getStreetsByState:(NSString *)state byCityAndTown:(NSString *)cityTown;

@end
