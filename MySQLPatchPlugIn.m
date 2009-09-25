//
//  MySQLPatchPlugIn.m
//  MySQLPatch 0.1
//
//  Created by William Cotton on 9/22/09.
//  Copyright (c) 2009 redblueyellow. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "MySQLPatchPlugIn.h"

#define	kQCPlugIn_Name				@"MySQL Patch"
#define	kQCPlugIn_Description		@"Input SQL and receive a Structure of returned rows containing field names and their values.\n\n\nCreated by William Cotton (williamcotton@gmail.com)."

@implementation MySQLPatchPlugIn

@dynamic inputSQL, inputHost, inputUser, inputPassword, inputDatabase, inputUpdateSignal;
@dynamic outputRows, outputErrorMessage;

@synthesize previousSQL, returnedRows;

+ (NSDictionary*) attributes
{
	/*
	 Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	 */
	
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	if([key isEqualToString:@"inputSQL"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"SQL", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"inputHost"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Host", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"inputUser"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"User", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"inputPassword"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Password", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"inputDatabase"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Database", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"inputUpdateSignal"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Update Signal", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"outputRows"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Rows", QCPortAttributeNameKey,
				nil];
	if([key isEqualToString:@"outputErrorMessage"])
        return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Error Message", QCPortAttributeNameKey,
				nil];
    return nil;
}

+ (QCPlugInExecutionMode) executionMode
{
	/*
	 Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	 */
	
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode
{
	/*
	 Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	 */
	
	return kQCPlugInTimeModeNone;
}

- (id) init
{
	if(self = [super init]) {
		
		/*
		 Allocate any permanent resource required by the plug-in.
		 */
		
		returnedRows = [[NSMutableDictionary alloc] initWithCapacity:1];
		
	}
	
	return self;
}

- (void) finalize
{
	/*
	 Release any non garbage collected resources created in -init.
	 */
	
	[super finalize];
}

- (void) dealloc
{
	/*
	 Release any resources created in -init.
	 */
	
	[super dealloc];
}

- (QCPlugInViewController*) createViewController
{
	/*
	 Return a new QCPlugInViewController to edit the internal settings of this plug-in instance.
	 You can return a subclass of QCPlugInViewController if necessary.
	 */
	
	return [[QCPlugInViewController alloc] initWithPlugIn:self viewNibName:@"Settings"];
}

@end

@implementation MySQLPatchPlugIn (Execution)

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	/*
	 Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	 Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	 */
	
	return YES;
}

- (void) enableExecution:(id<QCPlugInContext>)context
{
	/*
	 Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	 */
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{	
	const char *host;
	host = [self.inputHost UTF8String];
	const char *user;
	user = [self.inputUser UTF8String];
	const char *password;
	password = [self.inputPassword UTF8String];
	const char *database;
	database = [self.inputDatabase UTF8String];
	const char *sqlStatement;
	sqlStatement = [self.inputSQL UTF8String];
	
	dbConnection = mysql_init(NULL);
	
	/* connect to database */
	if (!mysql_real_connect(dbConnection, host, user, password, database, 0, NULL, 0)) {
		/* output error messages */
		
		self.outputErrorMessage = [NSString stringWithFormat: @"%s", mysql_error(dbConnection)];
		self.outputRows = [[NSDictionary alloc] init];
		
		return YES;
	}
	else {
		
		/* ok, we're connected*/
		
		MYSQL_RES *res;
		MYSQL_FIELD *field;
		MYSQL_ROW row;
		
		int num_fields;
		
		/* query the database */
		if (mysql_query(dbConnection, sqlStatement)) {
			self.outputErrorMessage = [NSString stringWithFormat: @"%s", mysql_error(dbConnection)];
			self.outputRows = [[NSDictionary alloc] init];
			
			return YES;
		}
		
		res = mysql_use_result(dbConnection);
		num_fields = mysql_num_fields(res);
		int i = 0;
		
		NSMutableArray *fieldNames = [[NSMutableArray alloc] init];
		
		/* get the field names */
		while((field = mysql_fetch_field(res)))
		{
			[fieldNames addObject:[NSString stringWithFormat:@"%s",field->name]];
		}
		
		/* loop through each row, and create dictionary */
		while ((row = mysql_fetch_row(res)) != NULL) {
			NSMutableDictionary *fieldAndRow_ = [[NSMutableDictionary alloc] init];
			
			for(int j = 0; j < num_fields; j++) {
				NSString *m = [NSString stringWithFormat: @"%s", row[j]];
				[fieldAndRow_ setObject:m forKey:[fieldNames objectAtIndex:j]];
			}
			
			NSString *index = [NSString stringWithFormat: @"%d", i];
			[returnedRows setObject:fieldAndRow_ forKey:index];
			[fieldAndRow_ release];
			i++;
		}
		
		mysql_free_result(res);
		self.outputRows = returnedRows;
		[fieldNames release];
		
		return YES;
		
	}
	
}

- (void) disableExecution:(id<QCPlugInContext>)context
{
	/*
	 Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	 */
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
	
	/*
	 Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	 */
}

@end
