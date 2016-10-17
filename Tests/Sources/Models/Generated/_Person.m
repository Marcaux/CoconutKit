// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Person.m instead.

#import "_Person.h"

@implementation PersonID
@end

@implementation _Person

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Person";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Person" inManagedObjectContext:moc_];
}

- (PersonID*)objectID {
	return (PersonID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic firstName;

@dynamic lastName;

@dynamic accounts;

- (NSMutableSet<BankAccount*>*)accountsSet {
	[self willAccessValueForKey:@"accounts"];

	NSMutableSet<BankAccount*> *result = (NSMutableSet<BankAccount*>*)[self mutableSetValueForKey:@"accounts"];

	[self didAccessValueForKey:@"accounts"];
	return result;
}

@dynamic houses;

- (NSMutableSet<House*>*)housesSet {
	[self willAccessValueForKey:@"houses"];

	NSMutableSet<House*> *result = (NSMutableSet<House*>*)[self mutableSetValueForKey:@"houses"];

	[self didAccessValueForKey:@"houses"];
	return result;
}

@end

@implementation PersonAttributes 
+ (NSString *)firstName {
	return @"firstName";
}
+ (NSString *)lastName {
	return @"lastName";
}
@end

@implementation PersonRelationships 
+ (NSString *)accounts {
	return @"accounts";
}
+ (NSString *)houses {
	return @"houses";
}
@end

