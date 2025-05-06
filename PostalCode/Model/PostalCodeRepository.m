//
//  PostalCodeRepository.m
//  PostalCode
//
//  Created by OCHIISHI Koichiro on 2012/10/18.
//  Copyright (c) 2012年 OCHIISHI Koichiro. All rights reserved.
//

#import "PostalCodeRepository.h"
#import "PostalCode-Swift.h"

#define FAVORITE         @"favorite"
#define DATABASE_NAME    @"data_202408.sqlite"
// AboutViewController の「郵便番号データ」の日付を変えるのを忘れないように

@implementation PostalCodeRepository {
    NSString *databasePath;
}

static PostalCodeRepository *repository;

+ (PostalCodeRepository *)sharedRepository
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        repository = [[PostalCodeRepository alloc] initWithPath:self.path];
        [repository setupDatabase];
    });
    return repository;
}

+ (NSString *)path
{
    static NSString *databasePath = nil;
    if (databasePath) {
        return databasePath;
    }
    
    NSString *path = NSTemporaryDirectory();
    databasePath = [path stringByAppendingPathComponent:DATABASE_NAME];
    
    return databasePath;
}

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        databasePath = path;
    }
    return self;
}

- (void)setupDatabase
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) {
        // データベースファイルが既に存在する場合
        return;
    } else {
        // データベースファイルが存在しない場合はコピーする
        NSString *defaultDatabasePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_NAME];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error = nil;
        BOOL success = [manager copyItemAtPath:defaultDatabasePath toPath:databasePath error:&error];
        if (success) {
            return;
        } else {
            NSLog(@"%s: %@", __func__, error);
            return;
        }
    }
}

#pragma mark - SQLite

// SQLite 利用開始
static sqlite3 *openDatabase(NSString *path)
{
    sqlite3 *database = NULL;
    int result = sqlite3_open([path fileSystemRepresentation], &database);
    if (result != SQLITE_OK) {
        NSLog(@"Open database failed. result -> %d, message -> %s", result, sqlite3_errmsg(database));
        return nil;
    }
    return database;
}

static BOOL closeDatabase(sqlite3 *database)
{
    int result = sqlite3_close(database);
    if (result != SQLITE_OK) {
        NSLog(@"Close database failed. result -> %d, message -> %s", result, sqlite3_errmsg(database));
        return NO;
    }
    return YES;
}

// SQLite の SQL 文実行用ステートメントの準備
static BOOL prepareStatement(sqlite3 *database, const char *sql, sqlite3_stmt **statement)
{
    *statement = NULL;
    int result = sqlite3_prepare_v2(database, sql, -1, statement, NULL);
    if (result != SQLITE_OK) {
        NSLog(@"Prepare statement failed. result -> %d, message -> %s", result, sqlite3_errmsg(database));
        return NO;
    }
    return YES;
}

static BOOL finalizeStatement(sqlite3 *database, sqlite3_stmt *statement)
{
	if (sqlite3_finalize(statement) != SQLITE_OK) {
        NSLog(@"Finalize Statement failed. message -> %s", sqlite3_errmsg(database));
        return NO;
    }
    return YES;
}

#pragma mark -

- (NSMutableArray *)searchWithQuery:(NSString *)query
{
    // 「都道府県、市町村、区群」を分別する
    query = [query stringByReplacingOccurrencesOfString:@"都" withString:@"都 "];
    query = [query stringByReplacingOccurrencesOfString:@"道" withString:@"道 "];
    query = [query stringByReplacingOccurrencesOfString:@"府" withString:@"府 "];
    query = [query stringByReplacingOccurrencesOfString:@"県" withString:@"県 "];
    query = [query stringByReplacingOccurrencesOfString:@"市" withString:@"市 "];
    query = [query stringByReplacingOccurrencesOfString:@"町" withString:@"町 "];
    query = [query stringByReplacingOccurrencesOfString:@"村" withString:@"村 "];
    query = [query stringByReplacingOccurrencesOfString:@"区" withString:@"区 "];
    query = [query stringByReplacingOccurrencesOfString:@"郡" withString:@"郡 "];
    
    // 半角スペースで区切られた文字列を受け取る
    NSArray *querys = [query componentsSeparatedByString:@" "];
    NSString *q = querys[0];
    
    sqlite3 *database = openDatabase(databasePath);
    if (database == nil) {
        return nil;
    }
    sqlite3_stmt *statement = nil;
    if (prepareStatement(database, "SELECT * FROM data WHERE postal_code LIKE ?001 OR state_h LIKE ?002 OR city_town_h LIKE ?003 OR street_h LIKE ?004 OR state_k LIKE ?005 OR city_town_k LIKE ?006 OR street_k LIKE ?007", &statement) == NO) {
        finalizeStatement(database, statement);
        closeDatabase(database);
        return nil;
    }

    int result;
    for (int i = 1; i < 8; i++) {
        result = sqlite3_bind_text(statement, i, [[NSString stringWithFormat:@"%%%@%%", q] UTF8String], -1, SQLITE_STATIC);
        if (result != SQLITE_OK) {
            finalizeStatement(database, statement);
            closeDatabase(database);
            return nil;
        }
    }
    
    NSMutableArray *array = [NSMutableArray new];
    while (sqlite3_step(statement) == SQLITE_ROW) {
        PostalCodeModel *model = [PostalCodeModel new];
        model.postalCode = @((char *)sqlite3_column_text(statement, 0));
        model.stateH = @((char *)sqlite3_column_text(statement, 1));
        model.cityTownH = @((char *)sqlite3_column_text(statement, 2));
        model.streetH = @((char *)sqlite3_column_text(statement, 3));
        model.stateK = @((char *)sqlite3_column_text(statement, 4));
        model.cityTownK = @((char *)sqlite3_column_text(statement, 5));
        model.streetK = @((char *)sqlite3_column_text(statement, 6));
        [array addObject:model];
    }
    
    if (finalizeStatement(database, statement) == NO) {
        closeDatabase(database);
        return nil;
    }
    
    closeDatabase(database);
    
    // 絞込み検索
    NSMutableArray *temp = array;
    for (int i = 1; i < querys.count; i++) {
        if ([querys[i] length]) {
            array = [NSMutableArray new];
            for (PostalCodeModel *model in temp) {
                q = querys[i];
                if ([self searchQuery:q from:model.postalCode] ||
                    [self searchQuery:q from:model.stateH] ||
                    [self searchQuery:q from:model.cityTownH] ||
                    [self searchQuery:q from:model.streetH] ||
                    [self searchQuery:q from:model.stateK] ||
                    [self searchQuery:q from:model.cityTownK] ||
                    [self searchQuery:q from:model.streetK])
                {
                    [array addObject:model];
                }
            }
        }
        if (array.count == 0) {
            return nil;
        }
    }
    
    if (array.count == 0) {
        return nil;
    }
    
    return [self divideByStateWithArray:array];
}

- (BOOL)searchQuery:(NSString *)query from:(NSString *)string
{
    NSRange searchResult = [string rangeOfString:query];
    if (searchResult.location != NSNotFound) {
        return YES;
    }
    return NO;
}

- (NSMutableArray *)getStateSectionIndexTitles
{
    NSArray *sectionIndexTitles = @[@"北海道", @"東北", @"関東", @"中部", @"近畿", @"中国", @"四国", @"九州"];
    return [sectionIndexTitles mutableCopy];
}

- (NSMutableArray *)getStates
{
    NSMutableArray *states = [NSMutableArray new];
    [states addObject:@[@"北海道"]];
    [states addObject:@[@"青森県", @"岩手県", @"秋田県", @"宮城県", @"山形県", @"福島県"]];
    [states addObject:@[@"茨城県", @"栃木県", @"群馬県", @"埼玉県", @"千葉県", @"東京都", @"神奈川県"]];
    [states addObject:@[@"新潟県", @"富山県", @"石川県", @"福井県", @"山梨県", @"長野県", @"岐阜県", @"静岡県", @"愛知県"]];
    [states addObject:@[@"三重県", @"滋賀県", @"京都府", @"大阪府", @"兵庫県", @"奈良県", @"和歌山県"]];
    [states addObject:@[@"鳥取県", @"島根県", @"岡山県", @"広島県", @"山口県"]];
    [states addObject:@[@"徳島県", @"香川県", @"愛媛県", @"高知県"]];
    [states addObject:@[@"福岡県", @"佐賀県", @"長崎県", @"熊本県", @"大分県", @"宮崎県", @"鹿児島県", @"沖縄県"]];
    return states;
}

- (NSMutableArray *)getCityTownsByState:(NSString *)state
{
    sqlite3 *database = openDatabase(databasePath);
    if (database == nil) {
        return nil;
    }
    
    sqlite3_stmt *statement = nil;
    if (prepareStatement(database, "SELECT * FROM data WHERE state_k LIKE ?001", &statement) == NO) {
        finalizeStatement(database, statement);
        closeDatabase(database);
        return nil;
    }
    
    int result = sqlite3_bind_text(statement, 1, [[NSString stringWithFormat:@"%%%@%%", state] UTF8String], -1, SQLITE_STATIC);
    if (result != SQLITE_OK) {
        finalizeStatement(database, statement);
        closeDatabase(database);
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray new];
    while (sqlite3_step(statement) == SQLITE_ROW) {
        PostalCodeModel *model = [PostalCodeModel new];
        model.postalCode = @((char *)sqlite3_column_text(statement, 0));
        model.stateH = @((char *)sqlite3_column_text(statement, 1));
        model.cityTownH = @((char *)sqlite3_column_text(statement, 2));
        model.streetH = @((char *)sqlite3_column_text(statement, 3));
        model.stateK = @((char *)sqlite3_column_text(statement, 4));
        model.cityTownK = @((char *)sqlite3_column_text(statement, 5));
        model.streetK = @((char *)sqlite3_column_text(statement, 6));
        [array addObject:model];
    }
    
    if (finalizeStatement(database, statement) == NO) {
        closeDatabase(database);
        return nil;
    }
    
    closeDatabase(database);
    
    NSMutableArray *cityTownArray = [NSMutableArray new];
    for (PostalCodeModel *model in array) {
        if (cityTownArray.count == 0) {
            [cityTownArray addObject:model];
        } else if (![[[cityTownArray lastObject] cityTownK] isEqualToString:model.cityTownK]) {
            [cityTownArray addObject:model];
        }
    }

    return cityTownArray;
}

- (NSMutableArray *)getStreetsByState:(NSString *)state byCityAndTown:(NSString *)cityTown
{
    sqlite3 *database = openDatabase(databasePath);
    if (database == nil) {
        return nil;
    }
    sqlite3_stmt *statement = nil;
    if (prepareStatement(database, "SELECT * FROM data WHERE state_k LIKE ?001 AND city_town_k LIKE ?002", &statement) == NO) {
        finalizeStatement(database, statement);
        closeDatabase(database);
        return nil;
    }
    
    int result = sqlite3_bind_text(statement, 1, [[NSString stringWithFormat:@"%%%@%%", state] UTF8String], -1, SQLITE_STATIC);
    if (result == SQLITE_OK) {
        result = sqlite3_bind_text(statement, 2, [[NSString stringWithFormat:@"%%%@%%", cityTown] UTF8String], -1, SQLITE_STATIC);
    }
    if (result != SQLITE_OK) {
        finalizeStatement(database, statement);
        closeDatabase(database);
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray new];
    while (sqlite3_step(statement) == SQLITE_ROW) {
        PostalCodeModel *model = [PostalCodeModel new];
        model.postalCode = @((char *)sqlite3_column_text(statement, 0));
        model.stateH = @((char *)sqlite3_column_text(statement, 1));
        model.cityTownH = @((char *)sqlite3_column_text(statement, 2));
        model.streetH = @((char *)sqlite3_column_text(statement, 3));
        model.stateK = @((char *)sqlite3_column_text(statement, 4));
        model.cityTownK = @((char *)sqlite3_column_text(statement, 5));
        model.streetK = @((char *)sqlite3_column_text(statement, 6));
        [array addObject:model];
    }
    
    if (finalizeStatement(database, statement) == NO) {
        closeDatabase(database);
        return nil;
    }
    
    closeDatabase(database);
    
    // 平仮名別に配列を整理
    NSMutableArray *streetKanas = [NSMutableArray new];    // streetKana を格納する配列
    NSMutableArray *streetKana = [NSMutableArray new];     // 平仮名ごとに住所をまとめた配列

    for (PostalCodeModel *model in array) {
        if (streetKana.count == 0) {
            [streetKana addObject:model];
        } else {
            // 直前に保存した項目の平仮名と比較
            PostalCodeModel *comparedModel = [streetKana lastObject];
            NSString *streetStr = ([comparedModel.streetH length]) ? [comparedModel.streetH substringToIndex:1] : @"";
            NSString *comparedStreetStr = ([model.streetH length]) ? [model.streetH substringToIndex:1] : @"";

            if ([streetStr isEqualToString:comparedStreetStr]) {
                [streetKana addObject:model];
            } else {
                [streetKanas addObject:streetKana];
                streetKana = [NSMutableArray new];
                [streetKana addObject:model];
            }
        }
    }
    
    // 最後の要素を格納
    [streetKanas addObject:streetKana];
    
    return streetKanas;
}

// 都道府県別に配列を整理
- (NSMutableArray *)divideByStateWithArray:(NSMutableArray *)array
{
    NSMutableArray *states = [NSMutableArray new];
    NSMutableArray *state = [NSMutableArray new];
    
    for (PostalCodeModel *model in array) {
        if (state.count == 0) {
            [state addObject:model];
        } else {
            // 直前に保存した項目の都道府県名と比較
            PostalCodeModel *comparedModel = [state lastObject];

            if ([comparedModel.stateK isEqualToString:model.stateK]) {
                [state addObject:model];
            } else {
                [states addObject:state];
                state = [NSMutableArray new];
                [state addObject:model];
            }
        }
    }
    
    [states addObject:state];
    
    return states;
}

// 市町村別に配列を整理
- (NSMutableArray *)divideByCityAndTownWithArray:(NSMutableArray *)array
{
    NSMutableArray *cityTowns = [NSMutableArray new];
    NSMutableArray *cityTown = [NSMutableArray new];
    
    for (PostalCodeModel *model in array) {
        if (cityTown.count == 0) {
            [cityTown addObject:model];
        } else {
            // 直前に保存した項目の市町村名と比較
            PostalCodeModel *comparedModel = [cityTown lastObject];

            if ([comparedModel.stateK isEqualToString:model.cityTownK]) {
                [cityTown addObject:model];
            } else {
                [cityTowns addObject:cityTown];
                cityTown = [[NSMutableArray alloc] init];
                [cityTown addObject:model];
            }
        }
    }
    
    [cityTowns addObject:cityTown];
    
    return cityTowns;
}

@end
