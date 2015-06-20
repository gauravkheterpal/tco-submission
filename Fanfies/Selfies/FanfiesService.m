//
//  FanfiesService.m
//  Fanfies
//


#import "FanfiesService.h"
// Change for lat, long and reverse geocoding
NSString *const KInstagramURL = @"https://api.instagram.com/v1/tags/gowarriors/media/recent?client_id=6d1c2ae6b8f04a7a88f3b063666e10d2";

@implementation FanfiesService


-(void) getLocationfromLatLong {
    
    NSString *url;
    // Integrate LMGeocoder here and pass lat, long to get location id
    // Pass the location id to then build instagram photo feed
    
   
    }

-(void) getImageUrls {
    
    NSString *url;
    
    if (self.minimumTagId) {
        url = [NSString stringWithFormat:@"%@&min_tag_id=%@", KInstagramURL, self.minimumTagId];
    }
    else {
        
        url = KInstagramURL;
    }
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                if (!error) {
                    
                    typeof(self) strongSelf = weakSelf;
                
                NSError *jsonParseError = nil;
                
                NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonParseError];
                
                if (!jsonParseError) {
                    
                    if ([responseDict objectForKey:@"pagination"]) {
                        NSDictionary *pagDict = [responseDict objectForKey:@"pagination"];
                        
                        if ([pagDict  objectForKey: @"min_tag_id"]) {
                            strongSelf.minimumTagId = [pagDict objectForKey:@"min_tag_id"];
                        }
                        
                        NSArray *imageDictArray;
                        
                        if ([responseDict objectForKey:@"data"]) {
                            imageDictArray = [responseDict objectForKey:@"data"];
                            
                            NSMutableArray *imageReturnArray = [[NSMutableArray alloc] init];
                            
                            for (NSDictionary *imageDict in imageDictArray) {
                                if ([imageDict objectForKey:@"images"]) {
                                    NSDictionary *images = [imageDict objectForKey:@"images"];
                                    if ([images objectForKey:@"standard_resolution"]) {
                                        [imageReturnArray addObject:[images objectForKey:@"standard_resolution"]];
                                    }
                                }
                            }  dispatch_sync(dispatch_get_main_queue(), ^{
                                
                                 typeof(self) strongSelf = weakSelf;
                            
                                if ([strongSelf.delegate respondsToSelector:@selector(returnedResults:)]) {
                                
                                [strongSelf.delegate returnedResults:imageReturnArray];
                                    
                            }
                                    });
                            
                        }
                    }

                    
                    
                }
                    
                }
               
            }] resume];

    
}


@end
