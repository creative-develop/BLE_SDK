//
//  PC60NWViewController.m
//  PC-60NWDemo
//
//  Created by Creative on 2021/1/11.
//

#import "PC60NWViewController.h"
#import "CRHeartLiveView.h"
#import "CRBlueToothManager.h"
#import "CRAP20SDK.h"

@interface PC60NWViewController ()<CRBlueToothManagerDelegate, CRAP20SDKDelegate>
/** 设备  */
@property (nonatomic, weak) CRBleDevice *device;
/** 绘制次数  */
@property (nonatomic, assign) int drawCount;
/** 波形图  */
@property (nonatomic, weak) CRHeartLiveView *heartLiveView;
/** 画图定时器 */
@property (nonatomic, weak) NSTimer *timer;
/** 弹出框控制器  */
@property (nonatomic, weak) UIAlertController *alertController;
/** 最新获取的点数组 */
@property (nonatomic, strong) NSArray<CRPoint *> *lastPoints;
/** 主动获取电量  */
@property (nonatomic, assign) BOOL isActivelyObtainPower;

//******显示UI数值******
@property (weak, nonatomic) IBOutlet UIView *CoverView;
@property (weak, nonatomic) IBOutlet UILabel *Spo2Lable;
@property (weak, nonatomic) IBOutlet UILabel *PRLabel;
@property (weak, nonatomic) IBOutlet UILabel *PILabel;
@property (weak, nonatomic) IBOutlet UILabel *bartteryLabel;

@end

@implementation PC60NWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNavi];
    [CRBlueToothManager shareInstance].delegate = self;
    [self searchDevice];
}

#pragma mark - 导航栏
- (void)loadNavi {
    self.navigationItem.title = @"";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"< 返回" style:UIBarButtonItemStylePlain target:self action:@selector(backVC)];
    self.navigationItem.leftBarButtonItem = backItem;
}
/** 退出*/
- (void)backVC {
    [self stopSearchDevice];
    if (self.device) {
        [[CRBlueToothManager shareInstance] disconnectDevice:self.device];
        return;
    }
    [CRBlueToothManager shareInstance].delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

//显示搜索到的蓝牙设备列表，并手动连接
- (void)displayDeviceList:(NSArray *)deviceList {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择设备" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 0; i < deviceList.count; i++) {
        NSString *bleName = ((CRBleDevice *)deviceList[i]).bleName;
        UIAlertAction *action = [UIAlertAction actionWithTitle:bleName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //连接蓝牙
            [[CRBlueToothManager shareInstance] connectDevice:deviceList[i]];
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:action];
    }
    //取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - BLE连接
/** 搜索设备*/
- (void)searchDevice {
    [[CRBlueToothManager shareInstance] startSearchDevicesForSeconds:1.5];
}
/** 停止搜索设备*/
- (void)stopSearchDevice {
    [[CRBlueToothManager shareInstance] stopSearch];
}
/** 手机蓝牙状态*/
- (void)bleManager:(CRBlueToothManager *)manager didUpdateState:(CBManagerState)state {
    if (state == CBManagerStatePoweredOn) {
        NSLog(@"蓝牙已打开");
    } else {
        NSLog(@"蓝牙不可用");
    }
}
/** 搜索到的设备*/
- (void)bleManager:(CRBlueToothManager *)manager didSearchCompleteWithResult:(NSArray<CRBleDevice *> *)deviceList {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (CRBleDevice *device in deviceList) {
        if ([device.bleName containsString:pc_60nw]) {
            [array addObject:device];
        }
    }
    if (array.count == 0) {
        [self searchDevice];
        return;
    }
    //显示搜索到的设备列表
    [self displayDeviceList:array];
}
/** 连接成功*/
- (void)bleManager:(CRBlueToothManager *)manager didConnectDevice:(CRBleDevice *)device {
    NSLog(@"连接成功");
    self.device = device;
    self.navigationItem.title = device.bleName;
    /** AP-20蓝牙通讯协议配置*/
    [CRAP20SDK shareInstance].delegate = self;
    [[CRAP20SDK shareInstance] didConnectDevice:device];
    //允许设备发送血氧参数、波形数据到APP
    [self sendEnableAction];
}
/** 断开连接*/
- (void)bleManager:(CRBlueToothManager *)manager didDisconnectDevice:(CRBleDevice *)device {
    NSLog(@"断开连接");
    self.device = nil;
    self.navigationItem.title = @"";
    /** AP-20蓝牙通讯协议释放*/
    [[CRAP20SDK shareInstance] willDisconnectWithDevice:device];
    [CRAP20SDK shareInstance].delegate = nil;
    [self backVC];
}
/** 连接失败*/
- (void)bleManager:(CRBlueToothManager *)manager didFailToConnectDevice:(CRBleDevice *)device Error:(NSError *)error {
    NSLog(@"连接失败%@", error.localizedDescription);
}

#pragma mark - PC-60NW
#pragma mark 发送使能命令
- (void)sendEnableAction{
    //允许设备发送血氧参数、波形数据到APP
    [[CRAP20SDK shareInstance] sendCommandForSpo2WaveEnable:YES ForDevice:_device];
    [[CRAP20SDK shareInstance] sendCommandForSpo2ParamEnable:YES ForDevice:_device];
}
/** 成功设置血氧参数使能 */
- (void)successdToSetSpo2ParamEnableFromDevice:(CRBleDevice *)device{
    NSLog(@"成功设置血氧参数使能");
}
/** 成功设置血氧波形使能 */
- (void)successdToSetSpo2WaveEnableFromDevice:(CRBleDevice *)device{
    NSLog(@"成功设置血氧波形使能");
}

#pragma mark - --------------- 设备信息
/** 手动断开连接并返回*/
- (IBAction)disconnectClick:(id)sender {
    [self backVC];
}

#pragma mark 获取设备版本
- (IBAction)showDeviceInfo:(id)sender {
    [[CRAP20SDK shareInstance] queryForDeviceTwoBitVersionForDevice:_device];
    [[CRAP20SDK shareInstance] queryForDeviceFourBitVersionForDevice:_device];
}

/** 获取设备版本*/
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceInfoForSoftWareVersion:(NSString *)softWareV HardWaveVersion:(NSString *)hardWareV ProductName:(NSString *)productName FromDevice:(CRBleDevice *)device {
    [self displayQueryResultsWithString:[NSString stringWithFormat:@"软件版本:%@,硬件版本:%@ 名称:%@",softWareV,hardWareV,productName]];
}

#pragma mark - --------------- 血氧测量
#pragma mark 获取血氧值
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Value:(int)spo2 PulseRate:(int)pr PI:(int)pi State:(CRAP_20Spo2State)state Mode:(CRAP_20Spo2Mode)mode BattaryLevel:(int)battaryLevel FromDevice:(CRBleDevice *)device
{
    self.Spo2Lable.text = [NSString stringWithFormat:@"%d", spo2];
    self.PRLabel.text = [NSString stringWithFormat:@"%d", pr];
    self.PILabel.text = [NSString stringWithFormat:@"%.1f", pi * 0.1];
    self.bartteryLabel.text = [NSString stringWithFormat:@"%d", battaryLevel];
}

#pragma mark 获取血氧波形
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Wave:(struct waveData *)wave FromDevice:(CRBleDevice *)device
{
    NSMutableArray *points = [NSMutableArray array];
    for (int i = 0; i < 5; i++)
    {
        CRPoint *point = [[CRPoint alloc] init];
        point.y = 128 - wave[i].waveValue;
        [points addObject:point];
    }
    _lastPoints = points;
    if (!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 *1.0 / 52 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
    }
    _drawCount = 0;
    [_timer setFireDate:[NSDate distantPast]];
}

#pragma mark 绘图
- (void)fireTimer:(NSTimer *)timer
{
    if (_drawCount == 5)
    {
        _drawCount = 0;
        [timer setFireDate:[NSDate distantFuture]];
        return;
    }
    [self.heartLiveView addPoints:[_lastPoints subarrayWithRange:NSMakeRange(_drawCount , 1)]];
    _drawCount++;
}

- (CRHeartLiveView *)heartLiveView {
    if (!_heartLiveView) {
        CRHeartLiveView *heartL = [[CRHeartLiveView alloc] initWithFrame:self.CoverView.bounds];
        [self.CoverView addSubview:heartL];
        _heartLiveView = heartL;
    }
    return _heartLiveView;
}

#pragma mark - --------------- 其他业务处理
- (void)dealloc
{
    [self invalidateTimers];
    NSLog(@"controller release");
}

#pragma mark 定时器关闭
- (void)invalidateTimers
{
    [_timer invalidate];
}
- (BOOL)prefersHomeIndicatorAutoHidden
{
    return YES;
}
#pragma mark 获取时间
- (NSString *)getTime
{
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitYear fromDate:date];
    NSString *strYear = [NSString stringWithFormat:@"%d", (int)[components year]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *timestamp1 = [formatter stringFromDate:date];
    NSString *noHaveYear = [timestamp1 substringFromIndex:4];
    NSString *timestamp = [strYear stringByAppendingString:noHaveYear];
    return timestamp;
}

- (void)displayQueryResultsWithString:(NSString *)message{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:confirm];
    [self presentViewController:alertC animated:YES completion:nil];
}

@end
