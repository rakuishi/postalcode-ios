//
//  PostalCodeRepository.h
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 2012/10/18.
//  Copyright (c) 2012年 OCHIISHI Koichiro. All rights reserved.

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface PostalCodeModel : NSObject <NSSecureCoding>

@property (nonatomic, strong) NSString *postalCode; // 郵便番号
@property (nonatomic, strong) NSString *stateH;     // 都道府県（平仮名）
@property (nonatomic, strong) NSString *cityTownH;  // 市町村（平仮名）
@property (nonatomic, strong) NSString *streetH;    // 区群（平仮名）
@property (nonatomic, strong) NSString *stateK;     // 都道府県（漢字）
@property (nonatomic, strong) NSString *cityTownK;  // 市町村（漢字）
@property (nonatomic, strong) NSString *streetK;    // 区群（漢字）

@end

@interface PostalCodeRepository : NSObject

+ (PostalCodeRepository *)sharedRepository;
+ (NSString *)path;

- (NSMutableArray *)searchWithQuery:(NSString *)query;
- (NSMutableArray *)getStateSectionIndexTitles;
- (NSMutableArray *)getStates;
- (NSMutableArray *)getCityTownsByState:(NSString *)state;
- (NSMutableArray *)getStreetsByState:(NSString *)state byCityAndTown:(NSString *)cityTown;

@end

@interface FavoriteRepository : NSObject

+ (NSMutableArray *)getFavorites;
+ (void)addFavoritePostalCodeModel:(PostalCodeModel *)model;
+ (void)deleteFavoritePostalCodeModel:(NSInteger)index;
+ (void)deleteAllFavorite;
+ (BOOL)isExistPostalCodeModel:(PostalCodeModel *)model;

@end
