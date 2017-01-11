//
//  ViewController.m
//  YellowBook
//
//  Created by Emon on 1/12/17.
//  Copyright © 2017 Emon. All rights reserved.
//

#import "ViewController.h"
#import "Group.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define CAPITALCITY @"https://restcountries.eu/rest/v1/all"
#define CALLINGCODE @"https://restcountries.eu/rest/v1/callingcode/7"

@interface ViewController (){
    NSMutableArray *tableData;
    int selectedBtnIndex;
}
@property (weak, nonatomic) IBOutlet UIButton *capitalCityBtn;
@property (weak, nonatomic) IBOutlet UIButton *callingCodeBtn;
@property (weak, nonatomic) IBOutlet UITableView *InfoTableView;
@property (strong,nonatomic) UIAlertController* alertController;;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillAppear:(BOOL)animated{
    selectedBtnIndex = 0;


    self.alertController = [UIAlertController alertControllerWithTitle: @"Loading"
                                                               message: nil
                                                        preferredStyle: UIAlertControllerStyleAlert];

//    [self.alertController addAction:[UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler:nil]];


    UIViewController *customVC     = [[UIViewController alloc] init];
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    [customVC.view addSubview:spinner];
    [customVC.view addConstraint:[NSLayoutConstraint  constraintWithItem: spinner attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1.0f
                                  constant:0.0f]];
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1.0f
                                  constant:0.0f]];
    [self.alertController setValue:customVC forKey:@"contentViewController"];
    [self presentViewController: self.alertController
                       animated: true
                     completion: nil];


    [self fetchDataFromUrl:CAPITALCITY];

}
-(void)fetchDataFromUrl:(NSString*)urlString{

    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    // Create url connection and fire request
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                    if (error) {
                        NSLog(@"No Data");
                    }
                    else{

                        NSError *localError = nil;
                        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&localError];

                        tableData = [[NSMutableArray alloc] init];
                        for (NSDictionary *dict in parsedObject)
                        {

                            Group *group = [[Group alloc] init];

                            for (NSString *key in dict) {
                                if ([group respondsToSelector:NSSelectorFromString(key)]) {
                                    [group setValue:[dict valueForKey:key] forKey:key];
                                }
                            }
                            [tableData addObject:group];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_InfoTableView reloadData];
                            [self.alertController dismissViewControllerAnimated:YES completion:nil];
                        });
                    }
                }] resume];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self setHighlighted:YES withButton:_capitalCityBtn];
    [self setHighlighted:NO withButton:_callingCodeBtn];
}
- (IBAction)CapitalCityBtnClicked:(id)sender {
    selectedBtnIndex = 0;
    [self setHighlighted:YES withButton:_capitalCityBtn];
    [self setHighlighted:NO withButton:_callingCodeBtn];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_InfoTableView reloadData];
    });
}
- (IBAction)CallingCodeBtnClicked:(id)sender {
    selectedBtnIndex = 1;
    [self setHighlighted:NO withButton:_capitalCityBtn];
    [self setHighlighted:YES withButton:_callingCodeBtn];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_InfoTableView reloadData];
    });

}
- (void) setHighlighted:(BOOL)highlighted withButton:(UIButton*)btn {

    if (highlighted) {
        btn.backgroundColor = UIColorFromRGB(0x90D469);
    }
    else {
        btn.backgroundColor = UIColorFromRGB(0x70BD4C);
    }
    btn.selected = YES;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    tableView.backgroundColor = [UIColor clearColor];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    Group *group = [tableData objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",group.name];
    if (selectedBtnIndex == 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",group.capital];
    }
    else{
        if (group.callingCodes.count>0) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",group.callingCodes[0]];
        }
    }

    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 80;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
