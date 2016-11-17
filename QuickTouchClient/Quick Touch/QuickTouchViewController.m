//
//  QuickTouchViewController.m
//  QuickTouchClient
//
//  Created by TsuiYuenHong on 2016/11/14.
//  Copyright © 2016年 TsuiYuenHong. All rights reserved.
//

#import "QuickTouchViewController.h"
#import "QTProcessor.h"

#define QTCellID @"QTCellID"

@interface QuickTouchViewController () <GCDAsyncUdpSocketDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *appQTTableView;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSilder;
@property (weak, nonatomic) IBOutlet UISlider *volumeSilder;
@property (weak, nonatomic) IBOutlet UIButton *screenShotBuuton;
@property (weak, nonatomic) IBOutlet UIButton *sleepButton;

@property (nonatomic, strong) NSMutableDictionary *appQTDataSource;

@end

@implementation QuickTouchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // config tableview
    _appQTTableView.delegate = self;
    _appQTTableView.dataSource = self;
    [_appQTTableView registerClass:[UITableViewCell self] forCellReuseIdentifier:QTCellID];

    _appNameLabel.text = @"Finder";
    
    [self configAppCommands];
    [self configSystemCommands];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:QTQuickTouchVCReloadData object:nil] subscribeNext:^(NSNotification *notication) {
        _appNameLabel.text = notication.object;
        [_appQTTableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_appQTDataSource[_appNameLabel.text] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:QTCellID];
    QTTypeModel *qtTypeModel = _appQTDataSource[_appNameLabel.text][indexPath.row];
    cell.textLabel.text = qtTypeModel.qtDesc;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    QTTypeModel *qtTypeModel = _appQTDataSource[_appNameLabel.text][indexPath.row];
    [[QTProcessor sharedInstance] sendQTTypeModel:qtTypeModel];
}

#pragma mark - Config Commands
- (void)configAppCommands{
    _appQTDataSource = [NSMutableDictionary dictionary];
    // 1. Finder
    // 1.1 新建 Finder 窗口
    NSDictionary *finderDict0 = @{
                                  @"desc":@"新建 Finder 窗口",
                                  @"command":@{
                                          @"commandType":toNSNumber(QTCommandClickMenuItem),
                                          @"menuItem":@"新建 Finder 窗口",
                                          @"menu":@"文件",
                                          @"menuBar":@1,
                                          @"app":@"Finder",
                                          }
                                  };
    
    QTClickMenuItemModel *openNewFinderContentModel = [QTClickMenuItemModel new];
    //    openNewFinderModel.desc = @"新建 Finder 窗口";
    openNewFinderContentModel.menuItem = @"新建 Finder 窗口";
    openNewFinderContentModel.menu = @"文件";
    openNewFinderContentModel.menuBar = 1;
    openNewFinderContentModel.appName = @"Finder";
    
    QTTypeModel *openNewFinderModel = [QTTypeModel new];
    openNewFinderModel.qtDesc = @"新建 Finder 窗口";
    openNewFinderModel.qtType = QTClickMenuItem;
    openNewFinderModel.qtContent = openNewFinderContentModel;

    [_appQTDataSource setObject:@[openNewFinderModel] forKey:@"Finder"];
    
//    
//    // 1.2 AirDrop
//    NSDictionary *finderDict1 = @{
//                                  @"desc":@"AirDrop",
//                                  @"command":@{
//                                          @"commandType":toNSNumber(QTCommandClickMenuItem),
//                                          @"menuItem":@"AirDrop",
//                                          @"menu":@"前往",
//                                          @"menuBar":@1,
//                                          @"app":@"Finder",
//                                          }
//                                  };
//    NSArray *finderArray = @[finderDict0,finderDict1];
//    [_appQTDataSource setObject:finderArray forKey:@"Finder"];
//    //2. Xcode
//    //2.1 注释
//    NSDictionary *xcodeDict0 = @{
//                                     @"desc":@"注释",
//                                 @"command":@{
//                                         @"commandType" : toNSNumber(QTCommandTwo),
//                                         @"functionKeys" : @[@"Command"],
//                                         @"commandKeys" : @"/"
//                                         }
//                                 };
//    NSDictionary *xcodeDict1 = @{
//                                 @"desc":@"格式化代码",
//                                 @"command":@{
//                                         @"commandType" : toNSNumber(QTCommandClickSubMenuItem),
//                                         @"subMenuItem":@"Re-Indent",
//                                         @"menuItem":@"Structure",
//                                         @"menu":@"Editor",
//                                         @"menuBar":@1,
//                                         @"app":@"Xcode",
//                                         }
//                                 };
//    NSArray *xcodeArray = @[openNewFinderModel,xcodeDict1];
//    [_appQTDataSource setObject:xcodeArray forKey:@"Xcode"];
}

- (void)configSystemCommands{
    // 发送截图指令
    [[_screenShotBuuton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSDictionary *commandDict = @{
                                      @"functionKeys":@[@"Command",@"Shift"],
                                      @"normalKey":@"4",
                                      @"commandType":toNSNumber(QTCommandMultiKeys),
                                      };
        [[CommandSender sharedInstance] sendCommandDict:commandDict];
    }];
    
    // 发送睡眠指令
//    [[_sleepButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
//        NSDictionary *commandDict = @{
//                                      @"commandType":toNSNumber(QTCommandSystemSetting),
//                                      @"systemSettingType":toNSNumber(QTSystemSettingSleep)
//                                      };
//        [[CommandSender sharedInstance] sendCommandDict:commandDict];
//    }];
//    
//    // 亮度控制
//    [[[[_brightnessSilder rac_signalForControlEvents:UIControlEventValueChanged]
//        throttle:0.1]
//        map:^id(UISlider *slider) {
//            NSString *value = [NSString stringWithFormat:@"%.1f",slider.value];
//            return @(value.floatValue);}]
//        subscribeNext:^(NSNumber *number) {
//            NSDictionary *commandDict = @{
//                                          @"commandType":toNSNumber(QTCommandSystemSetting),
//                                          @"systemSettingType":toNSNumber(QTSystemSettingBrightness),
//                                          @"brightness":number
//                                          };
//            [[CommandSender sharedInstance] sendCommandDict:commandDict];
//    }];
//    
//    // 音量控制
//    [[[[_volumeSilder rac_signalForControlEvents:UIControlEventValueChanged]
//        map:^id(UISlider *slider) {
//            return @((int)(100*slider.value));}]
//        distinctUntilChanged]
//        subscribeNext:^(NSNumber *number) {
//            NSDictionary *commandDict = @{
//                                          @"commandType":toNSNumber(QTCommandSystemSetting),
//                                          @"systemSettingType":toNSNumber(QTSystemSettingVolume),
//                                          @"volume":number
//                                          };
//            [[CommandSender sharedInstance] sendCommandDict:commandDict];
//
//    }];
}

@end
