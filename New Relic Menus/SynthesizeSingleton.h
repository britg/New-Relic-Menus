//
//  SynthesizeSingleton.h
//
// Modified by Karl Stenerud starting 16/04/2010.
// - Moved the swizzle code to allocWithZone so that non-default init methods may be
//   used to initialize the singleton.
// - Added "lesser" singleton which allows other instances besides sharedInstance to be created.
// - Added guard ifndef so that this file can be used in multiple library distributions.
// - Made singleton variable name class-specific so that it can be used on multiple classes
//   within the same compilation module.
//
//  Modified by CJ Hanson on 26/02/2010.
//  This version of Matt's code uses method_setImplementaiton() to dynamically
//  replace the +sharedInstance method with one that does not use @synchronized
//
//  Based on code by Matt Gallagher from CocoaWithLove
//
//  Created by Matt Gallagher on 20/10/08.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#ifndef SYNTHESIZE_SINGLETON_FOR_CLASS

#import <objc/runtime.h>


#pragma mark -
#pragma mark Singleton

/* Synthesize Singleton For Class
 *
 * Creates a singleton interface for the specified class with the following methods:
 *
 * + (MyClass*) sharedInstance;
 * + (void) purgeSharedInstance;
 *
 * Calling sharedInstance will instantiate the class and swizzle some methods to ensure
 * that only a single instance ever exists.
 * Calling purgeSharedInstance will destroy the shared instance and return the swizzled
 * methods to their former selves.
 *
 *
 * Usage:
 *
 * MyClass.h:
 * ========================================
 *	#import "SynthesizeSingleton.h"
 *
 *	@interface MyClass: SomeSuperclass
 *	{
 *		...
 *	}
 *	SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MyClass);
 *
 *	@end
 * ========================================
 *
 *
 *	MyClass.m:
 * ========================================
 *	#import "MyClass.h"
 *
 *	@implementation MyClass
 *
 *	SYNTHESIZE_SINGLETON_FOR_CLASS(MyClass);
 *
 *	...
 *
 *	@end
 * ========================================
 *
 *
 * Note: Calling alloc manually will also initialize the singleton, so you
 * can call a more complex init routine to initialize the singleton like so:
 *
 * [[MyClass alloc] initWithParam:firstParam secondParam:secondParam];
 *
 * Just be sure to make such a call BEFORE you call "sharedInstance" in
 * your program.
 */

#define SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(__CLASSNAME__)	\
\
+ (__CLASSNAME__*) sharedInstance;	\


#define SYNTHESIZE_SINGLETON_FOR_CLASS(__CLASSNAME__)	\
\
static __CLASSNAME__* _##__CLASSNAME__##_sharedInstance = nil;\
\
+ (__CLASSNAME__*) sharedInstanceNoSynch	\
{	\
return (__CLASSNAME__*) _##__CLASSNAME__##_sharedInstance;	\
}	\
\
+ (__CLASSNAME__*) sharedInstanceSynch	\
{	\
static dispatch_once_t predicate;\
dispatch_once(&predicate, ^{\
_##__CLASSNAME__##_sharedInstance = [[self alloc] init]; \
});\
return (__CLASSNAME__*) _##__CLASSNAME__##_sharedInstance;	\
}	\
\
+ (__CLASSNAME__*) sharedInstance	\
{	\
return [self sharedInstanceSynch]; \
}	\
\
+ (id)allocWithZone:(NSZone*) zone	\
{	\
@synchronized(self)	\
{	\
if (nil == _##__CLASSNAME__##_sharedInstance)	\
{	\
_##__CLASSNAME__##_sharedInstance = [super allocWithZone:zone];	\
if(nil != _##__CLASSNAME__##_sharedInstance)	\
{	\
Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceNoSynch));	\
method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));\
}	\
}	\
}	\
return _##__CLASSNAME__##_sharedInstance;	\
}	\
\
\
- (id)copyWithZone:(NSZone *)zone	\
{	\
return self;	\
}	\




#pragma mark -
#pragma mark Lesser Singleton

/* A lesser singleton has a shared instance, but can also be instantiated on its own.
 *
 * For a lesser singleton, you still use SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(),
 * but use SYNTHESIZE_LESSER_SINGLETON_FOR_CLASS() in the implementation file.
 * You must specify which creation methods are to initialize the shared instance
 * (besides "sharedInstance") via CALL_LESSER_SINGLETON_INIT_METHOD()
 *
 * Example:
 *
 * MyClass.h:
 * ========================================
 *	#import "SynthesizeSingleton.h"
 *
 *	@interface MyClass: SomeSuperclass
 *	{
 *		int value;
 *		...
 *	}
 *	SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MyClass);
 *
 *	+ (void) initSharedInstanceWithValue:(int) value;
 *
 * - (id) initWithValue:(int) value;
 *
 *	@end
 * ========================================
 *
 *
 *	MyClass.m:
 * ========================================
 *	#import "MyClass.h"
 *
 *	@implementation MyClass
 *
 *	SYNTHESIZE_LESSER_SINGLETON_FOR_CLASS(MyClass);
 *
 *	+ (void) initSharedInstanceWithValue:(int) value
 *	{
 *		CALL_LESSER_SINGLETON_INIT_METHOD(MyClass, initWithValue:value);
 *	}
 *
 *	...
 *
 *	@end
 * ========================================
 *
 *
 * Note: CALL_LESSER_SINGLETON_INIT_METHOD() will not work if your
 * init call contains commas.  If you need commas (such as for varargs),
 * or other more complex initialization, use the PRE and POST macros:
 *
 *	+ (void) initSharedInstanceComplex
 *	{
 *		CALL_LESSER_SINGLETON_INIT_METHOD_PRE(MyClass);
 *
 *		int firstNumber = [self getFirstNumberSomehow];
 *		_sharedInstance = [[self alloc] initWithValues:firstNumber, 2, 3, 4, -1];
 *
 *		CALL_LESSER_SINGLETON_INIT_METHOD_POST(MyClass);
 *	}
 */

#define SYNTHESIZE_LESSER_SINGLETON_FOR_CLASS(__CLASSNAME__)	\
\
static volatile __CLASSNAME__* _##__CLASSNAME__##_sharedInstance = nil;	\
\
+ (__CLASSNAME__*) sharedInstanceNoSynch	\
{	\
return (__CLASSNAME__*) _##__CLASSNAME__##_sharedInstance;	\
}	\
\
+ (__CLASSNAME__*) sharedInstanceSynch	\
{	\
@synchronized(self)	\
{	\
if(nil == _##__CLASSNAME__##_sharedInstance)	\
{	\
_##__CLASSNAME__##_sharedInstance = [[self alloc] init];	\
if(_##__CLASSNAME__##_sharedInstance)	\
{	\
Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceNoSynch));	\
method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));	\
}	\
}	\
else	\
{	\
NSAssert2(1==0, @"SynthesizeSingleton: %@ ERROR: +(%@ *)sharedInstance method did not get swizzled.", self, self);	\
}	\
}	\
return (__CLASSNAME__*) _##__CLASSNAME__##_sharedInstance;	\
}	\
\
+ (__CLASSNAME__*) sharedInstance	\
{	\
return [self sharedInstanceSynch]; \
}	\
\
+ (void)purgeSharedInstance	\
{	\
@synchronized(self)	\
{	\
Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceSynch));	\
method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));	\
[_##__CLASSNAME__##_sharedInstance release];	\
_##__CLASSNAME__##_sharedInstance = nil;	\
}	\
}


#define CALL_LESSER_SINGLETON_INIT_METHOD_PRE(__CLASSNAME__) \
@synchronized(self)	\
{	\
if(nil == _##__CLASSNAME__##_sharedInstance)	\
{


#define CALL_LESSER_SINGLETON_INIT_METHOD_POST(__CLASSNAME__) \
if(_##__CLASSNAME__##_sharedInstance)	\
{	\
Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceNoSynch));	\
method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));	\
}	\
}	\
else	\
{	\
NSAssert1(1==0, @"SynthesizeSingleton: %@ ERROR: _sharedInstance has already been initialized.", self);	\
}	\
}


#define CALL_LESSER_SINGLETON_INIT_METHOD(__CLASSNAME__,__INIT_CALL__) \
CALL_LESSER_SINGLETON_INIT_METHOD_PRE(__CLASSNAME__); \
_##__CLASSNAME__##_sharedInstance = [[self alloc] __INIT_CALL__];	\
CALL_LESSER_SINGLETON_INIT_METHOD_POST(__CLASSNAME__)

#endif /* SYNTHESIZE_SINGLETON_FOR_CLASS */