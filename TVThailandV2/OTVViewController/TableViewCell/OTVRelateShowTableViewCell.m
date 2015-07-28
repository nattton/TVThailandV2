//
//  OTVRelateShowTableViewCell.m
//  TVThailandV2
//
//  Created by April Smith on 6/17/2557 BE.
//  Copyright (c) 2557 luciferultram@gmail.com. All rights reserved.
//

#import "OTVRelateShowTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "OTVEpisodePartViewController.h"
#import "Show.h"

@implementation OTVRelateShowTableViewCell {
    NSArray *_shows;
}

#pragma mark - Static Variable

static NSString *CellIdentifier = @"part_cell";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            hortable = [[UITableView alloc]initWithFrame:CGRectMake(315, -315, 140, width) style:UITableViewStylePlain];
        } else {
            hortable = [[UITableView alloc]initWithFrame:CGRectMake(90, -90, 140, width) style:UITableViewStylePlain];
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

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureWithShows:(NSArray *)shows {
    
    _shows = shows;
    
    
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [_shows count];
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *imageUrl = [[_shows objectAtIndex:indexPath.row] thumbnailUrl];
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.transform = CGAffineTransformMakeRotation(M_PI/2);
        
        
        UIImageView *partImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 85)];
        [partImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"part_thumb_wide_s"] options:SDWebImageProgressiveDownload];
        [cell addSubview:partImageView];
        
        UILabel *partTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 65, 120, 20)];
        partTitleLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        partTitleLabel.textColor = [UIColor whiteColor];
        //        [partTitleLabel setText:[NSString stringWithFormat:@"Part %d/%d", (indexPath.row+1), self.episode.videos.count ]];
        [partTitleLabel setText:[[_shows objectAtIndex:indexPath.row] title]];
        partTitleLabel.numberOfLines = 1;
        [cell addSubview:partTitleLabel];
        

        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
        
	}
    

    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 122;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(openOTVShow:show:)]) {
        [self.delegate openOTVShow:indexPath show:_shows[indexPath.row]];
    }
    
    
}




@end
