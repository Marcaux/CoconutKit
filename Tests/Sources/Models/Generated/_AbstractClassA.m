// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AbstractClassA.m instead.

#import "_AbstractClassA.h"

@implementation AbstractClassAID
@end

@implementation _AbstractClassA

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"AbstractClassA" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"AbstractClassA";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"AbstractClassA" inManagedObjectContext:moc_];
}

- (AbstractClassAID*)objectID {
	return (AbstractClassAID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic codeMandatoryNotEmptyStringA;

@dynamic noValidationStringA;

@end

@implementation AbstractClassAAttributes 
+ (NSString *)codeMandatoryNotEmptyStringA {
	return @"codeMandatoryNotEmptyStringA";
}
+ (NSString *)noValidationStringA {
	return @"noValidationStringA";
}
@end

