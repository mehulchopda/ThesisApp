#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface GestureView : UIView{
    NSMutableDictionary *currentTouches;
    NSMutableArray *completeStrokes;
    //NSTimer * timer;
    int currentTime;
    NSDate *startDate;
   
   
}
//@property (strong, nonatomic) NSTimer *timer; // Store the timer that fires after a certain time
@property (strong, nonatomic) NSDate *startDate;
- (void)clearAll;
-(void)sendNotification;
-(void)stopTimer;
@end