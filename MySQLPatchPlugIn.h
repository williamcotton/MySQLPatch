//
//  MySQLPatchPlugIn.h
//  MySQLPatch 0.1
//
//  Created by William Cotton on 9/22/09.
//  Copyright (c) 2009 redblueyellow. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <stdio.h>
#import <mysql.h>

@interface MySQLPatchPlugIn : QCPlugIn
{
	NSMutableDictionary *returnedRows;
	NSString *previousSQL;
	MYSQL *dbConnection;
}

@property(assign) NSString *inputSQL;
@property(assign) NSString *inputHost;
@property(assign) NSString *inputUser;
@property(assign) NSString *inputPassword;
@property(assign) NSString *inputDatabase;
@property(assign) BOOL inputUpdateSignal;
@property(assign) NSDictionary *outputRows;
@property(assign) NSString *outputErrorMessage;

@property (nonatomic, assign) NSMutableDictionary *returnedRows;
@property(assign) NSString *previousSQL;

@end
