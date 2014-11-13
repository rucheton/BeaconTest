//
//  UIDetailViewController.m
//  IDLoc
//
//  Created by Clement RUCHETON on 17/01/2014.
//  Copyright (c) 2014 Clement RUCHETON. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;


@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)close:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"close" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.closeButton.layer setCornerRadius:15.0f];
    self.closeButton.alpha = .8;
    
    [self.imageView setImage:self.image];
    [self.titleView setText:self.title];
    [self.textview setText:self.description];
    
    CGSize imageSize = adaptedHomotheticSizeForImage(self.image);
    
    [self.widthConstraint setConstant:imageSize.width];
    [self.heightConstraint setConstant:imageSize.height];
    
    [self.textHeightConstraint setConstant:[self.textview sizeThatFits:CGSizeMake(screenSize().width, CGFLOAT_MAX)].height];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.row)
    {
        case 0:
            return self.image.size.height / self.image.size.width * [[UIScreen mainScreen] bounds].size.width;
        case 1:
            return 100;
        case 2:
        {
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
            // NSString class method: boundingRectWithSize:options:attributes:context is
            // available only on ios7.0 sdk.
            CGRect rect = [self.description boundingRectWithSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:attributes
                                                      context:nil];
            return rect.size.height;

        }
        default:
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    if(indexPath.row == 0)
    {
        UIImageView *image = [[UIImageView alloc] initWithImage:self.image];
        [image setContentMode:UIViewContentModeScaleAspectFill];
        [image setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath])];
        
        [cell addSubview:image];
        
        NSLog(@"ok");
    }
    else if(indexPath.row == 1)
    {
        [cell.textLabel setText:self.title];
        NSLog(@"%@",self.title);
    }
    else
    {
        UITextView *textview = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath])];
        [textview setText:self.description];
        [textview setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        
        NSLog(@"%@",NSStringFromCGRect(textview.frame));
        
        [cell addSubview:textview];
    }
    
    return cell;
}

@end
