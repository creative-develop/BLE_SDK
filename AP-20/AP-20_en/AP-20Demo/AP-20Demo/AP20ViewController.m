//
//  AP20ViewController.m
//  AP-20Demo
//
//  Created by Creative on 2020/12/24.
//

#import "AP20ViewController.h"
#import <CRAP20Lib/CRAP20Lib.h>
#import "CRHeartLiveView.h"
#import "CRWavesView.h"

@interface AP20ViewController ()<CRBlueToothManagerDelegate, CRAP20SDKDelegate>

/** Currently connected device.*/
@property (nonatomic, strong) CRBleDevice *device;

/** Blood oxygen waveform parameters.*/
@property (weak, nonatomic) IBOutlet UILabel *spo2Label;
@property (weak, nonatomic) IBOutlet UILabel *prLabel;
@property (weak, nonatomic) IBOutlet UILabel *piLabel;
@property (weak, nonatomic) IBOutlet UIView *waveView;
/** The newly acquired blood oxygen waveform point array. */
@property (nonatomic, strong) NSMutableArray<CRPoint *> *lastPoints;
/** Drawing waveform timer: 50HZ */
@property (nonatomic, weak) NSTimer *timer;
/** Waveform View */
@property (nonatomic, weak) CRHeartLiveView *heartLiveView;

/** The nasal flow parameter-breathing rate.*/
@property (weak, nonatomic) IBOutlet UILabel *rrLabel;
@property (weak, nonatomic) IBOutlet CRWavesView *nasalFlowWaveView;
/** The newly acquired respiratory waveform point array. */
@property (nonatomic, strong) NSMutableArray<CRPoint *> *lastFlowPoints;
/** The newly acquired snoring waveform point arra */
@property (nonatomic, strong) NSMutableArray<CRPoint *> *lastSnorePoints;

/** Three-axis acceleration */
@property (weak, nonatomic) IBOutlet CRWavesView *threeAxesWaveView;
/** Drawing Three-axis timer: 10HZ */
@property (nonatomic, weak) NSTimer *threeAxesTimer;
/** The newly acquired X-axis waveform point array. */
@property (nonatomic, strong) NSMutableArray<CRPoint *> *lastAccXPoints;
/** The newly acquired Y-axis waveform point array. */
@property (nonatomic, strong) NSMutableArray<CRPoint *> *lastAccYPoints;
/** The newly acquired Z-axis waveform point array. */
@property (nonatomic, strong) NSMutableArray<CRPoint *> *lastAccZPoints;

@end

@implementation AP20ViewController

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
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPhone) {//防止在IPAD挂断
        alertVC.popoverPresentationController.sourceView = self.view;
        alertVC.popoverPresentationController.sourceRect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0);
    }
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
        if ([device.bleName containsString:ap_20] ||
            [device.bleName containsString:pc_60f] ||
            [device.bleName containsString:pc_68b] ||
            [device.bleName containsString:OxySmart]) {
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
    //允许设备发送血氧参数、波形数据
    [[CRAP20SDK shareInstance] sendCommandForSpo2ParamEnable:YES ForDevice:device];
    [[CRAP20SDK shareInstance] sendCommandForSpo2WaveEnable:YES ForDevice:device];
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

#pragma mark - AP-20
#pragma mark - 血氧参数
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Value:(int)spo2 PulseRate:(int)pr PI:(int)pi State:(CRAP_20Spo2State)state Mode:(CRAP_20Spo2Mode)mode BattaryLevel:(int)battaryLevel FromDevice:(CRBleDevice *)device {
    self.spo2Label.text = [NSString stringWithFormat:@"%d", spo2];
    self.prLabel.text = [NSString stringWithFormat:@"%d", pr];
    self.piLabel.text = [NSString stringWithFormat:@"%.1f", pi * 0.1];
}

#pragma mark - 血氧工作模式
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetWorkStatusDataWithMode:(CRPC_60FWorkStatusMode)mode Stage:(CRPC_60FCommanMessureStage)stage Parameter:(int)para OtherParameter:(int)otherPara FromDevice:(CRBleDevice *)device {
    if (mode == CRPC_60FWorkStatusModeCommon) {
        //NSLog(@"点测模式");
    } else if (mode == CRPC_60FWorkStatusModeContinious) {
        //NSLog(@"连测模式");
    }
}

#pragma mark - 血氧波形
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Wave:(struct waveData *)wave FromDevice:(CRBleDevice *)device {
    [self handleSpo2WaveData:wave];
}

#pragma mark - 使能血氧参数发送
- (IBAction)valueChangedWithSpO2ParamSwitch:(UISwitch *)sender {
    //是否允许设备发送血氧参数数据
    [[CRAP20SDK shareInstance] sendCommandForSpo2ParamEnable:sender.isOn ForDevice:self.device];
}

- (void)successdToSetSpo2ParamEnableFromDevice:(CRBleDevice *)device {
    NSLog(@"使能血氧参数命令发送成功");
}

#pragma mark - 使能血氧波形发送
- (IBAction)valueChangedWithSpO2WaveformSwitch:(UISwitch *)sender {
    //是否允许设备发送血氧波形数据
    [[CRAP20SDK shareInstance] sendCommandForSpo2WaveEnable:sender.isOn ForDevice:self.device];
}

- (void)successdToSetSpo2WaveEnableFromDevice:(CRBleDevice *)device {
    NSLog(@"使能血氧波形命令发送成功");
}

#pragma mark - 查询设备版本
- (IBAction)getDeviceVersion:(UIButton *)sender {
    [[CRAP20SDK shareInstance] queryForDeviceFourBitVersionForDevice:self.device];
}
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceInfoForSoftWareVersion:(NSString *)softWareV HardWaveVersion:(NSString *)hardWareV ProductName:(NSString *)productName FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"产品名：%@\n硬件版本：%@\n软件版本%@", productName, hardWareV, softWareV];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 查询设备序列号
- (IBAction)getDeviceSerialNumber:(UIButton *)sender {
    [[CRAP20SDK shareInstance] queryForSerialNumberForDevice:self.device];
}
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSerialNumber:(NSString *)serialNumber FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"设备序列号：%@", serialNumber];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 查询设备电量（0-3共4格电）
BOOL isTip = NO;
- (IBAction)getDeviceBattery:(UIButton *)sender {
    isTip = YES;
    [[CRAP20SDK shareInstance] queryForBatteryLevelForDevice:self.device];
}
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetBartteryLevel:(int)batteryLevel FromDevice:(CRBleDevice *)device {
    if (!isTip)
        return;
    isTip = NO;
    NSString *string = [NSString stringWithFormat:@"设备电量格数：%d", batteryLevel];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 查询设备时间
- (IBAction)getDeviceTime:(UIButton *)sender {
    [[CRAP20SDK shareInstance] queryForDeviceTimeForDevice:self.device];
}
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceTime:(NSString *)deviceTime FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"设备时间：%@", deviceTime];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 设置设备时间
- (IBAction)setDeviceTime:(UIButton *)sender {
    [[CRAP20SDK shareInstance] setDeviceTime:[self getCurrentDate] ForDevice:self.device];
}
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK DeviceTimeSettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"设置设备时间%@", success ? @"成功" : @"失败"];
    [self displayQueryResultsWithString:string];
}
/** 获取当前时间*/
- (NSString *)getCurrentDate {
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    return dateStr;
}

#pragma mark - 查询血氧警报参数设置信息
- (IBAction)getSpO2AlarmParamSettingInfo:(UIButton *)sender {
    //血氧警报参数设置信息有5项，当前以【报警功能的关闭/开启状态】为例
    [[CRAP20SDK shareInstance] queryForSpo2AlertParamInfomation:CRAP_20Spo2AlertConfigTypeAlertState ForDevice:self.device];
}
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2AlertInfoWithType:(CRAP_20Spo2AlertConfigType)type Value:(int)value FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"当前报警功能为【%@】状态", value ? @"开启" : @"关闭"];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 设置血氧警报参数
- (IBAction)setSpO2AlarmParam:(UIButton *)sender {
    //血氧警报参数设置信息有5项，当前以【报警功能的关闭/开启状态】为例，设置为开启状态
    [[CRAP20SDK shareInstance] setSpo2AlertParamInfomation:CRAP_20Spo2AlertConfigTypeAlertState Value:0 ForDevice:self.device];
}
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK Spo2AlertParamInfoType:(CRAP_20Spo2AlertConfigType)type SettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"将血氧报警功能设置为【关闭】状态，设置%@", success ? @"成功" : @"失败"];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 查询用户ID
- (IBAction)getUserID:(UIButton *)sender {
    [[CRAP20SDK shareInstance] queryForUserIDForDevice:self.device];
}
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetUserID:(NSString *)userID FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"用户ID：%@", userID];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 设置用户ID
- (IBAction)setUserID:(UIButton *)sender {
    [[CRAP20SDK shareInstance] setUserID:@"iPhone" ForDevice:self.device];
}
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK UserIDSettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"用户ID设置为【iPhone】，设置%@", success ? @"成功" : @"失败"];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 查询背光等级（0-5共6级）
- (IBAction)getBacklightLevel:(UIButton *)sender {
    [[CRAP20SDK shareInstance] queryForBackgroundLightLevelForDevice:self.device];
}
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceBackLightLevel:(int)lightLevel FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"设备背光等级：%d", lightLevel];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 设置背光等级
- (IBAction)setBacklightLevel:(UIButton *)sender {
    [[CRAP20SDK shareInstance] setBackgroundLightLevel:3 ForDevice:self.device];
}
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK DeviceBackLightLevelSettedSuccess:(BOOL)success FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"设备背光等级设置为3，设置%@", success ? @"成功" : @"失败"];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 使能鼻息流参数包上传
- (IBAction)valueChangedWithNasalFlowParamSwitch:(UISwitch *)sender {
    [[CRAP20SDK shareInstance] sendCommandForNasalFlowParamEnable:sender.isOn ForDevice:self.device];
}
- (void)successdToSetNasalFlowParamEnableFromDevice:(CRBleDevice *)device {
    NSLog(@"使能鼻息流参数命令发送成功");
}
#pragma mark - 鼻息流参数包
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetNasalFlowRespirationRate:(int)rate FromDevice:(CRBleDevice *)device {
    self.rrLabel.text = [NSString stringWithFormat:@"%d", rate];
}

#pragma mark - 使能鼻息流波形包上传
- (IBAction)valueChangedWithNasalFlowWaveSwitch:(UISwitch *)sender {
    [[CRAP20SDK shareInstance] sendCommandForNasalFlowWaveEnable:sender.isOn ForDevice:self.device];
}
- (void)successdToSetNasalFlowWaveEnableFromDevice:(CRBleDevice *)device {
    NSLog(@"使能鼻息流波形命令发送成功");
}
#pragma mark - 鼻息流波形包
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetNasalFlowWave:(struct nasalFlowWaveData)nasalFlowWave FromDevice:(CRBleDevice *)device {
    [self handleNasalFlowWaveData:nasalFlowWave];
}

#pragma mark - 使能三轴加速度波形包上传
- (IBAction)valueChangedWithThreeAxesWaveSwitch:(UISwitch *)sender {
    [[CRAP20SDK shareInstance] sendCommandForThree_AxesWaveEnable:sender.isOn ForDevice:self.device];
}
- (void)successdToSetThree_AxesWaveEnableFromDevice:(CRBleDevice *)device {
    NSLog(@"使能轴加速度波形命令发送成功");
}
#pragma mark - 三轴加速度波形包
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetThree_AxesWaveData:(struct three_AxesWaveData)waveData FromDevice:(CRBleDevice *)device {
    [self handleThreeAxesWaveData:waveData];
}

#pragma mark - 设置设备从HID配置模式切换到磁盘模式
- (IBAction)setDeviceFromHIDModeToDiskMode:(UIButton *)sender {
    NSLog(@"无");
}

#pragma mark - 删除存储记录
- (IBAction)deleteStorageRecords:(UIButton *)sender {
    NSLog(@"无");
}

#pragma mark - 查询设备定时开机测量
- (IBAction)getDeviceTimingBootMeasure:(UIButton *)sender {
    NSLog(@"无");
}

#pragma mark - 设置设备定时开机测量
- (IBAction)setDeviceTimingBootMeasure:(UIButton *)sender {
    NSLog(@"无");
}

#pragma mark - 查询设备电池可续航时间
- (IBAction)getDeviceBatteryLife:(UIButton *)sender {
    NSLog(@"无");
}

#pragma mark - 查询PPG波形储存格式
- (IBAction)getPPGWaveStorageFormat:(UIButton *)sender {
    NSLog(@"无");
}

#pragma mark - 设置PPG波形存储格式
- (IBAction)setPPGWaveStorageFormat:(UIButton *)sender {
    NSLog(@"无");
}

#pragma mark - 通用
/** 提示框*/
- (void)displayQueryResultsWithString:(NSString *)message{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:confirm];
    [self presentViewController:alertC animated:YES completion:nil];
}

#pragma mark - 绘制波形
#pragma mark - 血氧波形
- (void)handleSpo2WaveData:(struct waveData*)wave {
    NSMutableArray *points = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        CRPoint *point = [[CRPoint alloc] init];
        point.y = 128 - wave[i].waveValue;
        [points addObject:point];
        //心跳幅度（1- point.y/ 128.0）
        //脉搏搏动标志（wave[i].pulse=YES,显示;否则隐藏）
    }
    //将接收的波形数据分成5次绘制，即每个点重绘一次
    if (!_lastPoints)
        _lastPoints = [NSMutableArray array];
    [_lastPoints addObjectsFromArray:points];
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 *1.0 / 52 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
        [_timer fire];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}
- (void)fireTimer:(NSTimer *)timer {
    if (_lastPoints.count == 0 && _lastFlowPoints.count == 0) {
        [timer invalidate];
        timer = nil;
        return;
    }
    //血氧
    if (_lastPoints.count > 0) {
        [self.heartLiveView addPoints:[_lastPoints subarrayWithRange:NSMakeRange(0 , 1)]];
        [_lastPoints removeObjectAtIndex:0];
    }
    //鼻息流
    if (_lastFlowPoints.count > 0) {
        [self.nasalFlowWaveView addPoints1:[_lastFlowPoints  subarrayWithRange:NSMakeRange(0 , 1)] points2:[_lastSnorePoints  subarrayWithRange:NSMakeRange(0 , 1)] points3:nil];
        [_lastFlowPoints removeObjectAtIndex:0];
        [_lastSnorePoints removeObjectAtIndex:0];
    }
}
- (CRHeartLiveView *)heartLiveView {
    if (!_heartLiveView) {
        CGSize size = self.view.bounds.size;
        CRHeartLiveView *heartL = [[CRHeartLiveView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.width * 0.9 / 1.85)];
        [self.waveView addSubview:heartL];
        _heartLiveView = heartL;
    }
    return _heartLiveView;
}

#pragma mark - 鼻息流波形
- (void)handleNasalFlowWaveData:(struct nasalFlowWaveData)wave {
    //呼吸波形
    if (!_lastFlowPoints)
        _lastFlowPoints = [NSMutableArray array];
    CRPoint *point = [[CRPoint alloc] init];
    point.y = 4096 - wave.nasalFlowValue;
    [_lastFlowPoints addObject:point];
    //鼾声波形
    if (!_lastSnorePoints)
        _lastSnorePoints = [NSMutableArray array];
    CRPoint *point1 = [[CRPoint alloc] init];
    point1.y = 4096 - wave.snoreValue;
    [_lastSnorePoints addObject:point1];
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 *1.0 / 52 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
        [_timer fire];
        //滑动时timer仍执行
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - 三轴加速度波形
- (void)handleThreeAxesWaveData:(struct three_AxesWaveData)wave {
    if (!_lastAccXPoints)
        _lastAccXPoints = [NSMutableArray array];
    CRPoint *point1 = [[CRPoint alloc] init];
    point1.y = 4096 - wave.acc_X;
    [_lastAccXPoints addObject:point1];
    if (!_lastAccYPoints)
        _lastAccYPoints = [NSMutableArray array];
    CRPoint *point2 = [[CRPoint alloc] init];
    point2.y = 4096 - wave.acc_Y;
    [_lastAccYPoints addObject:point2];
    if (!_lastAccZPoints)
        _lastAccZPoints = [NSMutableArray array];
    CRPoint *point3 = [[CRPoint alloc] init];
    point3.y = 4096 - wave.acc_Z;
    [_lastAccZPoints addObject:point3];
    if (!_threeAxesTimer) {
        _threeAxesTimer = [NSTimer scheduledTimerWithTimeInterval:1 *1.0 / 10 target:self selector:@selector(fireThreeAxesTimer:) userInfo:nil repeats:YES];
        [_threeAxesTimer fire];
        [[NSRunLoop currentRunLoop] addTimer:_threeAxesTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)fireThreeAxesTimer:(NSTimer *)timer {
    if (_lastPoints.count == 0) {
        [timer invalidate];
        timer = nil;
        return;
    }
    NSArray<CRPoint *> *accXPoints = [_lastAccXPoints copy];
    NSArray<CRPoint *> *accYPoints = [_lastAccYPoints copy];
    NSArray<CRPoint *> *accZPoints = [_lastAccZPoints copy];
    [self.threeAxesWaveView addPoints1:accXPoints points2:accYPoints points3:accZPoints];
    [_lastAccXPoints removeObjectsInArray:accXPoints];
    [_lastAccYPoints removeObjectsInArray:accYPoints];
    [_lastAccZPoints removeObjectsInArray:accZPoints];
}

@end
