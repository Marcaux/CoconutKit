//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Forward declarations
@protocol HLSTaskDelegate;

extern const NSTimeInterval HLSTaskNoTimeIntervalEstimateAvailable;

/**
 * Abstract class for tasks. Tasks offer a delegate mechanism for tracking their status. To create your own
 * tasks, simply subclass HLSTask and override the -operationClass method to return the class of the operation
 * responsible for processing the task.
 *
 * A task must not be submitted several times simultaneously (this leads to undefined behavior). A task
 * which was fully processed can be submitted again (and with another delegate if needed), but only when it
 * is not running anymore.
 */
@interface HLSTask : NSObject

/**
 * Create a task
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 * Class responsible of processing the task. Must be a subclass of HLSTaskOperation
 * Must be overridden
 */
@property (nonatomic, readonly) Class operationClass;

/**
 * Optional tag to identify a task
 * Not meant to be overridden
 */
@property (nonatomic, copy, nullable) NSString *tag;

/**
 * Dictionary which can be used freely to convey additional information
 * Not meant to be overridden
 */
@property (nonatomic, nullable) NSDictionary *userInfo;

/**
 * Return YES if the task processing is running
 * Not meant to be overridden
 */
@property (nonatomic, readonly, getter=isRunning) BOOL running;

/**
 * Return YES if the task processing is over (this can be because the operation has completed its task,
 * or after it has been cancelled)
 */
@property (nonatomic, readonly, getter=isFinished) BOOL finished;

/**
 * Return YES if the task group has been cancelled
 */
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

/**
 * Task progress value (always between 0.f and 1.f). A task might not reach 1.f if it fails
 * Not meant to be overridden
 */
@property (nonatomic, readonly) float progress;

/**
 * Return an estimate about the remaining time before the task processing completes (or HLSTaskNoTimeIntervalEstimateAvailable if no
 * estimate is available yet)
 * Important remark: Accurate measurements can only be obtained if the progress update rate of a task is not varying fast (in another
 *                   words: constant over long enough periods of time). This is for example usually the case for download or
 *                   inflating / deflating tasks.
 * Not meant to be overridden
 */
@property (nonatomic, readonly) NSTimeInterval remainingTimeIntervalEstimate;

/**
 * Return a localized string describing the estimated time before completion
 * (see remark of -remainingTimeIntervalEstimate method)
 * Not meant to be overridden
 */
@property (nonatomic, readonly, copy) NSString *remainingTimeIntervalEstimateLocalizedString;

/**
 * NSDictionary which can freely be used to convey return information
 * Not meant to be overridden
 */
@property (nonatomic, readonly, nullable) NSDictionary *returnInfo;

/**
 * When the process is complete, check this property to find out if an error was encountered
 * Not meant to be overridden
 */
@property (nonatomic, readonly, nullable) NSError *error;

@end

@protocol HLSTaskDelegate <NSObject>
@optional

/**
 * The task has started processing
 */
- (void)taskHasStartedProcessing:(HLSTask *)task;

/**
 * The task is being processed and has an updated status (you can call progress to get its completion
 * status)
 */
- (void)taskProgressUpdated:(HLSTask *)task;

/**
 * The task has been fully processed. Check the error property to find if the processing was successful or not (and
 * why)
 */
- (void)taskHasBeenProcessed:(HLSTask *)task;

/**
 * The task has been cancelled
 */
- (void)taskHasBeenCancelled:(HLSTask *)task;

@end

NS_ASSUME_NONNULL_END
