//
//  EPAndPartCell.m
//  TVThailandV2
//
//  Created by April Smith on 11/9/2556 BE.
//  Copyright (c) 2556 luciferultram@gmail.com. All rights reserved.
//

#import "EPAndPartCell.h"
#import "Episode.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "VideoPlayerViewController.h"



@interface EPAndPartCell()

@end

@implementation EPAndPartCell{
    UIImageView *goForwardImgSlider;
}




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        {
            // code for landscape orientation
            
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                hortable = [[UITableView alloc]initWithFrame:CGRectMake(442, -442, 140, 1024) style:UITableViewStylePlain];
//                NSLog(@"---iPad Land---, width : %f, hight : %f, x : %f, y : %f", self.frame.size.width, self.frame.size.height, self.frame.origin.x, self.frame.origin.y);

            }
            else if ([[UIScreen mainScreen] bounds].size.height>500) {
                hortable = [[UITableView alloc]initWithFrame:CGRectMake(214, -214, 140, 568) style:UITableViewStylePlain];
            }
            else
            {
                hortable = [[UITableView alloc]initWithFrame:CGRectMake(170, -170, 140, 480) style:UITableViewStylePlain];
//                NSLog(@"---iPhone Land---, width : %f, hight : %f, x : %f, y : %f", self.frame.size.width, self.frame.size.height, self.frame.origin.x, self.frame.origin.y);
            }

            
            
        }else      {
            // code for Portrait orientation
            if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                hortable = [[UITableView alloc]initWithFrame:CGRectMake(315, -315, 140, 770) style:UITableViewStylePlain];
//                NSLog(@"---iPad Portrait---, width : %f, hight : %f, x : %f, y : %f", self.frame.size.width, self.frame.size.height, self.frame.origin.x, self.frame.origin.y);
            }
            else {
                 hortable = [[UITableView alloc]initWithFrame:CGRectMake(90, -90, 140, 320) style:UITableViewStylePlain];
//                NSLog(@"---iPhone Portrait---, width : %f, hight : %f, x : %f, y : %f", self.frame.size.width, self.frame.size.height, self.frame.origin.x, self.frame.origin.y);
//                 NSLog(@"---iPhone Portrait---, width : %f, hight : %f, x : %f, y : %f", [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height, self.frame.origin.x, self.frame.origin.y);
            }

            
        }

        
        hortable.delegate = self;
        hortable.dataSource = self;
        hortable.transform = CGAffineTransformMakeRotation(M_PI / 2 *3);
        [hortable setBackgroundColor:[UIColor clearColor]];
        [hortable setSeparatorColor:[UIColor clearColor]];
		[self addSubview:hortable];

        

    }
    return self;
}


- (void)configureWithEpisode:(Episode *)episode {

    self.episode = episode;

    [self configureWithSlider:episode];
    

}

- (void)configureWithSlider:(Episode *)episode {
    CGRect viewFrame = hortable.frame;
//    NSLog(@"X=%f Y=%f Width=%f Height=%f", viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
    
    goForwardImgSlider = [[UIImageView alloc] initWithFrame:CGRectMake(viewFrame.size.width-25, 50, 20, 20)];
    [goForwardImgSlider setImage:[UIImage animatedImageNamed:@"forwardImg" duration:0.8]];
    [self addSubview:goForwardImgSlider];
    

    
    if (episode.videos.count == 1) {
        goForwardImgSlider.hidden = YES;
    }
    


}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.episode.videos.count;
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell%d",indexPath.row];
    NSString *imageUrl = [self.episode videoThumbnail:indexPath.row];


	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.transform = CGAffineTransformMakeRotation(M_PI/2);


        UIImageView *partImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 155, 120)];
        [partImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder"] options:SDWebImageProgressiveDownload];
        [cell addSubview:partImageView];
        
        UILabel *partTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 155, 20)];
        partTitleLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        partTitleLabel.textColor = [UIColor whiteColor];
        [partTitleLabel setText:[NSString stringWithFormat:@"Part %d/%d", (indexPath.row+1), self.episode.videos.count ]];
        partTitleLabel.numberOfLines = 0;

        if (self.episode.videos.count != 1 ){
            [cell addSubview:partTitleLabel];
        }
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];


	}
    
    if (self.episode.videos.count*157 > self.frame.size.width ) {
        goForwardImgSlider.hidden = NO;
    }else{
        goForwardImgSlider.hidden = YES;
    }
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 157;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(playVideoPart:episode:)]) {
        [self.delegate playVideoPart:indexPath episode:self.episode];
    }


}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"Y=%f | contentHeight=%f | boundsHeight=%f",hortable.contentOffset.y,hortable.contentSize.height,hortable.bounds.size.height);
    
    if (hortable.contentOffset.y == 0) {

        [UIView animateWithDuration:0.3 animations:^{
            [goForwardImgSlider setTransform:CGAffineTransformMakeScale(1, -1)];
        }];
        
    }

    if (hortable.contentOffset.y == floorf(hortable.contentSize.height - hortable.bounds.size.height)) {

        [UIView animateWithDuration:0.3 animations:^{
            [goForwardImgSlider setTransform:CGAffineTransformMakeScale(-1, 1)];
        }];
        
    }
}




@end
