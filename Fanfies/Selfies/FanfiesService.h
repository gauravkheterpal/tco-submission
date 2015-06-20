//
//  FanfiesService.h
//  Fanifes
//
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FanfiesServiceDelegate <NSObject>

@required

-(void) returnedResults:(NSMutableArray*) results;

@end


@interface FanfiesService : NSObject

@property (weak) id <FanfiesServiceDelegate> delegate;

@property (strong) NSString *minimumTagId;

-(void) getImageUrls;

@end
