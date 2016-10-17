// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ConcreteClassD.m instead.

#import "_ConcreteClassD.h"

@implementation ConcreteClassDID
@end

@implementation _ConcreteClassD

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ConcreteClassD" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ConcreteClassD";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ConcreteClassD" inManagedObjectContext:moc_];
}

- (ConcreteClassDID*)objectID {
	return (ConcreteClassDID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"noValidationNumberDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"noValidationNumberD"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic noValidationNumberD;

- (int16_t)noValidationNumberDValue {
	NSNumber *result = [self noValidationNumberD];
	return [result shortValue];
}

- (void)setNoValidationNumberDValue:(int16_t)value_ {
	[self setNoValidationNumberD:@(value_)];
}

- (int16_t)primitiveNoValidationNumberDValue {
	NSNumber *result = [self primitiveNoValidationNumberD];
	return [result shortValue];
}

- (void)setPrimitiveNoValidationNumberDValue:(int16_t)value_ {
	[self setPrimitiveNoValidationNumberD:@(value_)];
}

@dynamic noValidationStringD;

@dynamic concreteSubclassB;

- (NSMutableSet<ConcreteSubclassB*>*)concreteSubclassBSet {
	[self willAccessValueForKey:@"concreteSubclassB"];

	NSMutableSet<ConcreteSubclassB*> *result = (NSMutableSet<ConcreteSubclassB*>*)[self mutableSetValueForKey:@"concreteSubclassB"];

	[self didAccessValueForKey:@"concreteSubclassB"];
	return result;
}

@end

@implementation ConcreteClassDAttributes 
+ (NSString *)noValidationNumberD {
	return @"noValidationNumberD";
}
+ (NSString *)noValidationStringD {
	return @"noValidationStringD";
}
@end

@implementation ConcreteClassDRelationships 
+ (NSString *)concreteSubclassB {
	return @"concreteSubclassB";
}
@end

