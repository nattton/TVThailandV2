//
//  OTVEpAndPartTableViewCell.m
//  TVThailandV2
//
//  Created by April Smith on 3/21/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVEpisodePartTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "OTVEpisode.h"
#import "OTVPart.h"


@implementation OTVEpisodePartTableViewCell {
    UIImageView *goForwardImgSlider;
}

static NSString *CellIdentifier = @"otv_part_cell";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            hortable = [[UITableView alloc]initWithFrame:CGRectMake(442, -442, 140, width) style:UITableViewStylePlain];
        }
        else {
            CGFloat x = 90;
            CGFloat y = -90;
            if (width > 320) {
                x = 118;
                y = -118;
            }
            hortable = [[UITableView alloc] initWithFrame:CGRectMake(x, y, 140, width) style:UITableViewStylePlain];
        }
        
        hortable.delegate = self;
        hortable.dataSource = self;
        hortable.transform = CGAffineTransformMakeRotation(M_PI / 2 *3);
        [hortable setBackgroundColor:[UIColor clearColor]];
        [hortable setSeparatorColor:[UIColor clearColor]];
        hortable.showsHorizontalScrollIndicator = NO;
        hortable.showsVerticalScrollIndicator = NO;
		[self addSubview:hortable];
    }
    
    return self;
}

- (void)configureWithEpisode:(OTVEpisode *)episode {
    
    self.otvEpisode = episode;
    
    [self configureWithSlider:episode];
    
    
}

- (void)configureWithSlider:(OTVEpisode *)episode {
    CGRect viewFrame = hortable.frame;
    //    NSLog(@"X=%f Y=%f Width=%f Height=%f", viewFrame.origin.x, viewFrame.origin.y, viewFrame.size.width, viewFrame.size.height);
    
    goForwardImgSlider = [[UIImageView alloc] initWithFrame:CGRectMake(viewFrame.size.width-25, 50, 20, 20)];
    [goForwardImgSlider setImage:[UIImage animatedImageNamed:@"forwardImg" duration:0.8]];
    [self addSubview:goForwardImgSlider];
    
    if (episode.parts.count == 1) {
        goForwardImgSlider.hidden = YES;
    }
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.otvEpisode.parts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        
        UIImageView *partImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 155, 120)];
        [partImageView setTag:101];
        [cell addSubview:partImageView];
        
        CGRect initialFrame = CGRectMake(0, 88, 155, 32);
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        CGRect paddedFrame = UIEdgeInsetsInsetRect(initialFrame, contentInsets);
        UILabel *partTitleLabel = [[UILabel alloc]initWithFrame:paddedFrame];
        [partTitleLabel setTag:102];
        partTitleLabel.textColor = [UIColor whiteColor];
        partTitleLabel.font = [UIFont systemFontOfSize:12];
        partTitleLabel.numberOfLines = 2;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, partTitleLabel.frame.origin.y - 10, partTitleLabel.frame.size.width + 5, partTitleLabel.frame.size.height + 10);
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f/255.0f] CGColor], (id)[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:160/255.0f] CGColor], nil];
        [partImageView.layer insertSublayer:gradient atIndex:0];
        [cell addSubview:partTitleLabel];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
	}
    
    NSString *imageUrl = [[self.otvEpisode.parts objectAtIndex:indexPath.row] thumbnail];
    UIImageView *thumbnailImageView = (UIImageView *)[cell viewWithTag:101];
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"part_thumb_wide_s"] options:SDWebImageProgressiveDownload];
    
    UILabel *titleLable = (UILabel *)[cell viewWithTag:102];
    if (self.otvEpisode.parts.count != 1 ) {
        titleLable.text = [self.otvEpisode.parts[indexPath.row] nameTh];
        
//        titleLable.text = [NSString stringWithFormat:@"Part %d/%d", [[NSNumber numberWithInteger:indexPath.row+1] intValue], [[NSNumber numberWithInteger:self.otvEpisode.parts.count] intValue]];
        titleLable.hidden = NO;
    } else {
        titleLable.hidden = YES;
    }
    
    if (self.otvEpisode.parts.count * 157 > self.frame.size.width ) {
        goForwardImgSlider.hidden = NO;
    } else {
        goForwardImgSlider.hidden = YES;
    }
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 157;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(playVideoPart:episode:)]) {
        [self.delegate playVideoPart:indexPath episode:self.otvEpisode];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (hortable.contentOffset.y == 0) {
        
        [UIView animateWithDuration:0.3 animations:^{
            [goForwardImgSlider setTransform:CGAffineTransformMakeScale(1, -1)];
        }];
        
    }
    
    if (hortable.contentOffset.y == floorf(hortable.contentSize.height - hortable.bounds.size.height)) {
        
        [UIView animateWithDuration:0.3 animations:^{
            [goForwardImgSlider setTransform:CGAffineTransformMakeScale(-1, 1)];
        }];
        
    }else if ( floorf(hortable.contentSize.height - hortable.bounds.size.height) > hortable.contentOffset.y + 150 ) {
        [UIView animateWithDuration:0.3 animations:^{
            [goForwardImgSlider setTransform:CGAffineTransformMakeScale(1, -1)];
        }];
    }
}


@end
