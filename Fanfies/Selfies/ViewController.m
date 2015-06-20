//
//  ViewController.m
//  Fanfies
//
//

#import "ViewController.h"
#import "FanfiesService.h"
#import "SelfieCollectionViewCell.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FanfiesServiceDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *selfiesCollectionView;
@property (nonatomic, strong) FanfiesService* service;
@property (strong, nonatomic) NSMutableArray* selfiesDataSource;
@property (strong, nonatomic) UIActivityIndicatorView *activity;
@property (assign) BOOL isGettingUrls;

@end

@implementation ViewController

@synthesize selfiesCollectionView, service, selfiesDataSource,activity,isGettingUrls;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    service = [FanfiesService new];
    
    service.delegate = self;
    
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    activity.center = self.view.center;
    activity.hidesWhenStopped = YES;
    
     [self.view addSubview:activity];
    
    [activity startAnimating];
    
    [service getImageUrls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) lazyLoadImageForSelfieCell:(SelfieCollectionViewCell*) cell {
    
}

#pragma CollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [selfiesDataSource count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row / (float)selfiesDataSource.count >= 0.75f && !isGettingUrls)
    {
        [service getImageUrls];
        isGettingUrls = YES;
    }

    
    SelfieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selfiesCell" forIndexPath:indexPath];
    
    NSDictionary *cellData = [self.selfiesDataSource objectAtIndex:indexPath.row];
    
   cell.selfieImageView.alpha = 0;
    
    
    dispatch_queue_t queue = dispatch_queue_create("com.tc.fanfies.imageDownloadQueue", NULL);
    dispatch_async(queue, ^{
        
        NSURL *imageURL=[NSURL URLWithString:[cellData objectForKey:@"url"]];
        NSData *image=[NSData dataWithContentsOfURL:imageURL];
        dispatch_sync(dispatch_get_main_queue(), ^{
            //Check that cell hasn't been re-used for another indexpath.
            if ([collectionView indexPathForCell:cell] == indexPath) {
                cell.selfieImageView.image = [UIImage imageWithData:image];
                cell.selfieImageView.alpha = 1;
            }
        });
    });
    
    return cell;

    
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 3 == 0)
    {
        return CGSizeMake(280, 280);
    }
    else
    {
        return CGSizeMake(140, 140);
    }
}





#pragma SelfiesServiceDelegate

-(void)returnedResults:(NSMutableArray *)results {
    
    if (!selfiesDataSource) {
    
    selfiesDataSource = results;
        
          [selfiesCollectionView reloadData];
        
           }
    
    else {
    
    NSUInteger beginIndexPaths = [selfiesDataSource count];
    
    NSMutableArray *indexPathsArray = [NSMutableArray new];
    
    
    for (int i = 0; i < [results count]; i++) {
        
        [indexPathsArray addObject:[NSIndexPath indexPathForItem:(beginIndexPaths + i) inSection:0]];
        
    }
    
    [selfiesDataSource addObjectsFromArray:results];

    [UIView animateWithDuration:0 animations:^{
        [selfiesCollectionView performBatchUpdates:^{
            [selfiesCollectionView insertItemsAtIndexPaths:indexPathsArray];
        } completion:nil];
    }];
        
    }
    
    isGettingUrls = NO;
    
    [activity stopAnimating];
}

@end
