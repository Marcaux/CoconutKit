//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "CursorDemoViewController.h"

#import "CursorCustomPointerView.h"
#import "CursorFolderView.h"
#import "CursorSelectedFolderView.h"

static NSArray *s_weekDays = nil;
static NSArray *s_completeRange = nil;
static NSArray *s_timeScales = nil;
static NSArray *s_folders = nil;

@interface CursorDemoViewController ()

@property (nonatomic, weak) IBOutlet HLSCursor *weekDaysCursor;
@property (nonatomic, weak) IBOutlet UILabel *weekDayIndexLabel;
@property (nonatomic, weak) IBOutlet HLSCursor *randomRangeCursor;
@property (nonatomic, weak) IBOutlet UILabel *randomRangeIndexLabel;
@property (nonatomic, weak) IBOutlet UISlider *widthFactorSlider;
@property (nonatomic, weak) IBOutlet UISlider *heightFactorSlider;
@property (nonatomic, weak) IBOutlet HLSCursor *timeScalesCursor;
@property (nonatomic, weak) IBOutlet HLSCursor *foldersCursor;
@property (nonatomic, weak) IBOutlet HLSCursor *mixedFoldersCursor;

@end

@implementation CursorDemoViewController

#pragma mark Class methods

+ (void)initialize
{
    s_weekDays = [[[NSDateFormatter alloc] init] orderedWeekdaySymbols];
    s_completeRange = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10",
                        @"11", @"12", @"13", @"14", @"15", @"16"];
    s_folders = @[@"A-F", @"G-L", @"M-R", @"S-Z"];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.weekDaysCursor.dataSource = self;
    self.weekDaysCursor.delegate = self;
    [self.weekDaysCursor setSelectedIndex:3 animated:NO];
    
    self.randomRangeCursor.pointerView = [CursorCustomPointerView view];
    self.randomRangeCursor.dataSource = self;
    self.randomRangeCursor.delegate = self;
    [self.randomRangeCursor setSelectedIndex:4 animated:NO];
    
    self.timeScalesCursor.dataSource = self;
    self.timeScalesCursor.delegate = self;
    // Not perfectly centered with the font used. Tweak a little bit to get a perfect result
    self.timeScalesCursor.pointerViewTopLeftOffset = CGSizeMake(-11.f, -12.f);
    
    self.foldersCursor.dataSource = self;
    self.foldersCursor.delegate = self;
    self.foldersCursor.pointerViewTopLeftOffset = CGSizeMake(-10.f, -10.f);
    self.foldersCursor.pointerViewBottomRightOffset = CGSizeMake(10.f, 10.f);
    
    self.mixedFoldersCursor.dataSource = self;
    self.mixedFoldersCursor.delegate = self;
    
    self.weekDaysCursor.animationDuration = 0.05;
}

#pragma mark HLSCursorDataSource protocol implementation

- (UIView *)cursor:(HLSCursor *)cursor viewAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (cursor == self.foldersCursor || (cursor == self.mixedFoldersCursor && index % 2 == 0)) {
        if (selected) {
            CursorSelectedFolderView *view = [CursorSelectedFolderView view];
            view.nameLabel.text = s_folders[index];
            return view;
        }
        else {
            CursorFolderView *view = [CursorFolderView view];
            view.nameLabel.text = s_folders[index];
            return view;        
        }
    }
    else {
        // Not defined using a view
        return nil;
    }
}

- (NSUInteger)numberOfElementsForCursor:(HLSCursor *)cursor
{
    if (cursor == self.weekDaysCursor) {
        return s_weekDays.count;
    }
    else if (cursor == self.randomRangeCursor) {
        // Omit up to 10 objects at the end of the array
        return arc4random_uniform(10) + s_completeRange.count - 10 + 1;
    }
    else if (cursor == self.timeScalesCursor) {
        return s_timeScales.count;
    }
    else if (cursor == self.foldersCursor || cursor == self.mixedFoldersCursor) {
        return s_folders.count;
    }
    else {
        HLSLoggerError(@"Unknown cursor");
        return 0;
    }
}

- (NSString *)cursor:(HLSCursor *)cursor titleAtIndex:(NSUInteger)index
{
    if (cursor == self.weekDaysCursor) {
        return s_weekDays[index];
    }
    else if (cursor == self.randomRangeCursor) {
        return s_completeRange[index];
    }
    else if (cursor == self.timeScalesCursor) {
        return s_timeScales[index];
    }
    else if (cursor == self.mixedFoldersCursor && index % 2 != 0) {
        return s_folders[index];
    }
    else {
        return @"";
    }
}

- (UIFont *)cursor:(HLSCursor *)cursor fontAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (cursor == self.timeScalesCursor) {
        return [UIFont fontWithName:@"ProximaNova-Regular" size:20.f];
    }
    else {
        // Default
        return nil;
    }
}

- (UIColor *)cursor:(HLSCursor *)cursor textColorAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (cursor == self.randomRangeCursor) {
        return [UIColor blueColor];
    }
    else if (cursor == self.mixedFoldersCursor) {
        return [UIColor blackColor];
    }
    else {
        // Default
        return nil;
    }
}

- (UIColor *)cursor:(HLSCursor *)cursor shadowColorAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (cursor == self.randomRangeCursor) {
        return [UIColor whiteColor];
    }
    else {
        // Default (no shadow)
        return nil;
    }
}

- (CGSize)cursor:(HLSCursor *)cursor shadowOffsetAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (cursor == self.randomRangeCursor) {
        return CGSizeMake(0, 1);
    }
    else {
        return HLSCursorShadowOffsetDefault;
    }
}

#pragma mark HLSCursorDelegate protocol implementation

- (void)cursor:(HLSCursor *)cursor didMoveFromIndex:(NSUInteger)index
{
    HLSLoggerInfo(@"Cursor %p did move from index %lu", cursor, (unsigned long)index);
    
    if (cursor == self.weekDaysCursor) {
        self.weekDayIndexLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Index", nil), @(index)];
        self.weekDayIndexLabel.textColor = [UIColor redColor];
    }
    else if (cursor == self.randomRangeCursor) {
        self.randomRangeIndexLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Index", nil), @(index)];
        self.randomRangeIndexLabel.textColor = [UIColor redColor];
    }    
}

- (void)cursor:(HLSCursor *)cursor didMoveToIndex:(NSUInteger)index
{
    HLSLoggerInfo(@"Cursor %p did move to index %lu", cursor, (unsigned long)index);
    
    if (cursor == self.weekDaysCursor) {
        self.weekDayIndexLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Index", nil), @(index)];
        self.weekDayIndexLabel.textColor = [UIColor blackColor];
    }
    else if (cursor == self.randomRangeCursor) {
        self.randomRangeIndexLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Index", nil), @(index)];
        self.randomRangeIndexLabel.textColor = [UIColor blackColor];
        
        CursorCustomPointerView *pointerView = (CursorCustomPointerView *)cursor.pointerView;
        pointerView.valueLabel.text = s_completeRange[index];
    }
}

- (void)cursorDidStartDragging:(HLSCursor *)cursor nearIndex:(NSUInteger)index
{
    HLSLoggerInfo(@"Cursor %p did start dragging near index %@", cursor, @(index));
}

- (void)cursor:(HLSCursor *)cursor didDragNearIndex:(NSUInteger)index
{
    HLSLoggerInfo(@"Cursor %p did drag near index %@", cursor, @(index));
    
    if (cursor == self.randomRangeCursor) {
        CursorCustomPointerView *pointerView = (CursorCustomPointerView *)cursor.pointerView;
        pointerView.valueLabel.text = s_completeRange[index];
    }
}

- (void)cursorDidStopDragging:(HLSCursor *)cursor nearIndex:(NSUInteger)index
{
    HLSLoggerInfo(@"Cursor %p did stop dragging near index %@", cursor, @(index));
}

#pragma mark Event callbacks

- (IBAction)moveWeekDaysPointerToNextDay:(id)sender
{
    [self.weekDaysCursor setSelectedIndex:self.weekDaysCursor.selectedIndex + 1 animated:YES];
}

- (IBAction)reloadRandomRangeCursor:(id)sender
{
    [self.randomRangeCursor reloadData];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Cursor", nil);
    
    s_timeScales = @[NSLocalizedString(@"Year", nil).uppercaseString,
                     NSLocalizedString(@"Month", nil).uppercaseString,
                     NSLocalizedString(@"Week", nil).uppercaseString,
                     NSLocalizedString(@"Day", nil).uppercaseString];
    
    [self.weekDaysCursor reloadData];
    [self.timeScalesCursor reloadData];
}

@end
