//
//  ViewController.m
//  PC_60ESDK
//
//  Created by Creative on 2020/11/19.
//

#import "ViewController.h"
#import <CRAP20Lib/CRAP20Lib.h>
#import "CRHeartLiveView.h"
#import "CRPodDeviceMenuView.h"

@interface ViewController ()<CRBlueToothManagerDelegate, CRAP20SDKDelegate>

/** 已绑定的设备  */
@property (nonatomic, strong) CRBleDevice *device;
/** 已连接的设备名Label  */
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
/** 硬件版本号Label  */
@property (weak, nonatomic) IBOutlet UILabel *hardWareVersionLabel;
/** 软件版本号Label  */
@property (weak, nonatomic) IBOutlet UILabel *softWareVersionLabel;
/** 设备序列号Label  */
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
/** 电量Label  */
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
/** SpO2% Label  */
@property (weak, nonatomic) IBOutlet UILabel *spo2Label;
/** Pulse bpm Label  */
@property (weak, nonatomic) IBOutlet UILabel *prLabel;
/** PI Label  */
@property (weak, nonatomic) IBOutlet UILabel *piLabel;
/** 使能/禁止血氧参数上传Switch */
@property (weak, nonatomic) IBOutlet UISwitch *parameterSwitch;
/** 使能/禁止血氧波形上传Switch */
@property (weak, nonatomic) IBOutlet UISwitch *waveformSwitch;
/** 底部view  */
@property (weak, nonatomic) IBOutlet UIView *bottomContentView;
/** 测量结论Label  */
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
/** 测量模式Label  */
@property (weak, nonatomic) IBOutlet UILabel *workModeLabel;
/** 最新获取的点数组 */
@property (nonatomic, strong) NSArray<CRPoint *> *lastPoints;
/** 画图定时器 */
@property (nonatomic, weak) NSTimer *timer;
/** 波形图  */
@property (nonatomic, weak) CRHeartLiveView *heartLiveView;
/** 绘制次数  */
@property (nonatomic, assign) int drawCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CRBlueToothManager shareInstance].delegate = self;
    
}

//点击搜索蓝牙
- (IBAction)searchClieked:(UIBarButtonItem *)sender {
    [[CRBlueToothManager shareInstance] startSearchDevicesForSeconds:5];
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
    //弹出选择框
    [self presentViewController:alertVC animated:YES completion:nil];
}
//点击断开连接蓝牙
- (IBAction)disconnectClicked:(id)sender {
    [[CRBlueToothManager shareInstance] disconnectDevice:self.device];
}
//使能/禁止血氧参数上传
- (IBAction)valueChangedWithParameterSwitch:(UISwitch *)sender {
    [self setSpo2ParamEnable:sender.isOn];
}
//使能/禁止血氧波形上传
- (IBAction)valueChangedWithWaveformSwitch:(UISwitch *)sender {
    [self setSpo2WaveEnable:sender.isOn];
}
//设置设备菜单项
- (IBAction)setupClicked:(UIButton *)sender {
    [self queryMenuOptions];
}
//测量视图（BLE连接成功后加载UI）
- (void)loadMessureUI {
    CGSize size = self.view.bounds.size;
    CRHeartLiveView *heartL = [[CRHeartLiveView alloc] initWithFrame:CGRectMake(size.width * 0.03, 0, size.width * 0.94, size.width * 0.9 / 1.85)];
    [_bottomContentView addSubview:heartL];
    _heartLiveView = heartL;
}
//初始化界面
- (void)initUI {
    self.deviceNameLabel.text = @"--";
    self.hardWareVersionLabel.text = @"--";
    self.softWareVersionLabel.text = @"--";
    self.serialNumberLabel.text = @"--";
    self.batteryLabel.text = @"0";
    self.spo2Label.text = @"0";
    self.prLabel.text = @"0";
    self.piLabel.text = @"0";
    self.waveformSwitch.on = YES;
    self.parameterSwitch.on = YES;
    [self.timer invalidate];
    self.timer = nil;
    [self.heartLiveView clearPath];
    [self.heartLiveView removeFromSuperview];
    self.resultLabel.text = @"";
    self.workModeLabel.text = @"";
}

#pragma mark - BLE连接
//BLE状态
- (void)bleManager:(CRBlueToothManager *)manager didUpdateState:(CBManagerState)state API_AVAILABLE(ios(10.0)) {
    if (state == CBManagerStatePoweredOn)
        NSLog(@"蓝牙已打开");
    else
        NSLog(@"蓝牙已关闭");
}

- (void)bleManager:(CRBlueToothManager *)manager didFindDevice:(NSArray<CRBleDevice *> *)deviceList {
    
}

//从获取的BLE设备列表中筛选出PC_60E
- (void)bleManager:(CRBlueToothManager *)manager didSearchCompleteWithResult:(NSArray<CRBleDevice *> *)deviceList {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    /*
     Those devices is supported by the lib.
     #define pod @"POD"
     #define ap_10 @"AP-10"
     #define ap_20 @"AP-20"
     #define sp_20 @"SP-20"
     #define pc_60nw @"PC-60NW"
     #define pc_60nw_1 @"PC-60NW-1"

     #define pc_68b @"PC-68B"
     #define pc_66b @"PC-66B"

     #define pc_60e @"PC-60E"
     #define pc_60b @"PC-60B"


     #define pc_60f @"PC-60F"
     #define pf_10  @"PF-10"
     #define pf_20  @"PF-20"
     #define OxySmart @"OxySmart "  //定制版PC-60F
     #define BabyOximeter @"BabyOximeter"
     #define OxyKnight @"OxyKnight"//BabyOximeter改名

     #define s5w @"S5W"
     #define s6w @"S6W"
     #define s7w @"S7W"
     #define s7bw @"S7BW"
     */
    for (CRBleDevice *device in deviceList) {
        if ([device.bleName containsString:pc_60e] ||
            [device.bleName containsString:pc_60f] ||
            [device.bleName containsString:pf_10] ||
            [device.bleName containsString:OxySmart] ||
            [device.bleName containsString:pod]) {
            [array addObject:device];
        }
    }
    //显示搜索到的设备列表
    [self displayDeviceList:array];
}
//连接成功
- (void)bleManager:(CRBlueToothManager *)manager didConnectDevice:(CRBleDevice *)device {
    NSLog(@"蓝牙连接成功");
    self.device = device;
    [[CRAP20SDK shareInstance] didConnectDevice:device];
    //BLE指令读写回调协议
    [CRAP20SDK shareInstance].delegate = self;
    //查询版本信息、序列号、Mac地址
    [self queryDeviceInfo];
    [self querySerialNumber];
    [self queryMacAddress];
    //默认设置-使能血氧数据上传
    [self setSpo2EnableAction];
    //更新UI
    self.deviceNameLabel.text = device.peripheral.name;
    [self loadMessureUI];
}
//断开连接
- (void)bleManager:(CRBlueToothManager *)manager didDisconnectDevice:(CRBleDevice *)device {
    NSLog(@"蓝牙断开连接");
    [[CRAP20SDK shareInstance] willDisconnectWithDevice:device];
    //释放BLE指令读写回调协议
    [CRAP20SDK shareInstance].delegate = nil;
    //清空界面
    [self initUI];
}
//连接失败
- (void)bleManager:(CRBlueToothManager *)manager didFailToConnectDevice:(CRBleDevice *)device Error:(NSError *)error {
    
}

#pragma mark - CRAP20SDK BLE指令读写
#pragma mark - 设备信息
/** 设备信息(软件版本号，硬件版本号，产品名称) */
//【查询设备信息】
- (void)queryDeviceInfo {
    [[CRAP20SDK shareInstance] queryForDeviceFourBitVersionForDevice:self.device];
}
//接收【查询设备信息】的回调
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceInfoForSoftWareVersion:(NSString *)softWareV HardWaveVersion:(NSString *)hardWareV ProductName:(NSString *)productName FromDevice:(CRBleDevice *)device {
    self.hardWareVersionLabel.text = hardWareV;
    self.softWareVersionLabel.text = softWareV;
}
#pragma mark - 设备序列号
//【查询设备序列号】
- (void)querySerialNumber {
    [[CRAP20SDK shareInstance] queryForSerialNumberForDevice:self.device];
}
//接收【查询设备序列号】的回调
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSerialNumber:(NSString *)serialNumber FromDevice:(CRBleDevice *)device {
    self.serialNumberLabel.text = serialNumber;
}

#pragma mark - MAC地址
- (void)queryMacAddress {
    [[CRAP20SDK shareInstance] queryForMACAddressForDevice:self.device];
}

- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetMACAddress:(NSString *)macAddress FromDevice:(CRBleDevice *)device {
    NSLog(@"Mac Address:%@", macAddress);
}

#pragma mark - 获取电量
/** 电池电量等级共4个等级，取值范围为0-3 */
//【查询电量等级】
- (void)queryBatteryLevel {
    //nil
}
//接收【查询电量等级】的自动回调（BLE连接成功后设备每秒自动给iPhone发送电量值）
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetBartteryLevel:(int)batteryLevel FromDevice:(CRBleDevice *)device {
    self.batteryLabel.text = [NSString stringWithFormat:@"%d", batteryLevel];
}
#pragma mark - 设备菜单项
//【查询设备菜单项】
- (void)queryMenuOptions {
    [[CRAP20SDK shareInstance] queryForMenuOptionsForDevice:_device];
}
//接收【查询设备菜单项】的回调
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK getMenuLowSpO2:(int)lowSpO2 highPR:(int)highPr lowPR:(int)lowPr spot:(int)spot beepOn:(int)beepOn rotateOn:(int)rotateOn FromDevice:(CRBleDevice *)device {
    __block CRPodDeviceMenuView *deviceMenuView = [[CRPodDeviceMenuView alloc] initWithDeviceName:device.peripheral.name Update:^(int lowSpO2, int highPr, int lowPr, int spot, int beepOn, int rotateOn) {
        [deviceMenuView removeFromSuperview];
        //【设置设备菜单项】（更新）
        [[CRAP20SDK shareInstance] setMenuOptions:lowSpO2 highPR:highPr lowPR:lowPr spot:spot beepOn:beepOn rotateOn:rotateOn forDevice:device];
    } Cancel:^{
        [deviceMenuView removeFromSuperview];
    }];
    deviceMenuView.lowSpO2 = lowSpO2;
    deviceMenuView.highPr = highPr;
    deviceMenuView.lowPr = lowPr;
    deviceMenuView.spot = spot;
    deviceMenuView.beepOn = beepOn;
    deviceMenuView.rotateOn = rotateOn;
    [self.view addSubview:deviceMenuView];
}
//【设置设备菜单项】成功或失败回调
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK setMenuSuccess:(BOOL)failOrSuccess FromDevice:(CRBleDevice *)device {
    NSLog(@"设备菜单项设置成功");
}

#pragma mark - 血氧波形、参数使能
/** 使能/禁止血氧参数上传到APP，0x00 禁止、0x01 使能（默认） */
//【设置血氧参数上传开关】
- (void)setSpo2ParamEnable:(BOOL)beEnable {
    [[CRAP20SDK shareInstance] sendCommandForSpo2ParamEnable:beEnable ForDevice:self.device];
}
//成功【设置血氧参数上传开关】回调
- (void)successdToSetSpo2ParamEnableFromDevice:(CRBleDevice *)device {
    NSLog(@"成功设置血氧参数%d", self.parameterSwitch.isOn);
}
/** 使能/禁止血氧波形上传到APP，0x00 禁止、0x01 使能（默认） */
//【设置血氧波形上传开关】
- (void)setSpo2WaveEnable:(BOOL)beEnable {
    [[CRAP20SDK shareInstance] sendCommandForSpo2WaveEnable:beEnable ForDevice:self.device];
}
//成功【设置血氧波形上传开关】回调
- (void)successdToSetSpo2WaveEnableFromDevice:(CRBleDevice *)device {
    NSLog(@"成功设置血氧波形%d", self.waveformSwitch.isOn);
    //[[CRAP20SDK shareInstance] setMenuOptions:90 highPR:120 lowPR:60 spot:2 beepOn:1 forDevice:self.device];
}
/** BLE连接成功后设置-使能血氧波形和参数上传到APP */
- (void)setSpo2EnableAction {
    //允许设备给APP自动发送血氧波形数据
    [self setSpo2WaveEnable:YES];
    //允许设备给APP自动发送血氧参数
    [self setSpo2ParamEnable:YES];
}
#pragma mark - 血氧波形
/** 【血氧波形数据】自动回调 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Wave:(struct waveData*)wave FromDevice:(CRBleDevice *)device {
    //绘制波形
    [self handleSpo2WaveData:wave];
}
#pragma mark - 血氧参数
/** 【血氧参数】自动回调 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Value:(int)spo2 PulseRate:(int)pr PI:(int)pi State:(CRAP_20Spo2State)state Mode:(CRAP_20Spo2Mode)mode BattaryLevel:(int)battaryLevel FromDevice:(CRBleDevice *)device {
    self.spo2Label.text = [NSString stringWithFormat:@"%d", spo2];
    self.prLabel.text = [NSString stringWithFormat:@"%d", pr];
    self.piLabel.text = [NSString stringWithFormat:@"%.1f", pi * 0.1];//PI*0.1
}
#pragma mark - 血氧测量状态及结论
/** 【工作状态】自动回调 */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetWorkStatusDataWithMode:(CRPC_60FWorkStatusMode)mode Stage:(CRPC_60FCommanMessureStage)stage Parameter:(int)para OtherParameter:(int)otherPara FromDevice:(CRBleDevice *)device {
    //NSLog(@"工作状态-%d，阶段-%d, 参数-%d-%d", mode, stage, para, otherPara);
    NSMutableString *str = [NSMutableString string];
    //测量模式
    [str appendFormat:@"%@", mode == 1 ? @"点测模式" : @"连测模式"];
    //测量状态
    [str appendFormat:@"\t\t%@", [self getMessureStage:stage]];
    if (stage == 2 && mode == 1)
        //正在测量，若为点测模式mode，则增加倒计时para
        [str appendFormat:@" %d秒", para];
    self.workModeLabel.text = str;
    //测量结论
    if (stage == 3)
        self.resultLabel.text = [NSString stringWithFormat:@"血氧测量结果：血氧值：%d，脉率值：%d", para, otherPara];
    if (stage == 4) {
        NSString *string = [NSString stringWithFormat:@"%@", self.resultLabel.text];
        self.resultLabel.text = [string stringByAppendingFormat:@"\n脉率分析结果：%@", [self getMessureResult:para]];
    }
}

//当前测量阶段
- (NSString *)getMessureStage:(int)stage {
    NSArray *array = @[@"", @"准备阶段", @"正在测量", @"播报结果", @"脉率分析结果", @"测量完成"];
    NSString *str = array[stage];
    return str;
}
//获取测量的脉率分析结果
- (NSString *)getMessureResult:(int)para {
    NSString *str = @"";
    switch (para) {
        case 0:
            str = @"脉搏节律未见异常";
            break;
        case 1:
            str = @"疑似脉率稍快";
            break;
        case 2:
            str = @"疑似脉率过快";
            break;
        case 3:
            str = @"疑似阵发性脉率过快";
            break;
        case 4:
            str = @"疑似脉率稍缓";
            break;
        case 5:
            str = @"疑似脉率过缓";
            break;
        case 6:
            str = @"疑似偶发脉搏间期缩短";
            break;
        case 7:
            str = @"疑似脉搏间期不规则";
            break;
        case 8:
            str = @"疑似脉率稍快伴有偶发脉搏间期缩短";
            break;
        case 9:
            str = @"疑似脉率稍缓伴有偶发脉搏间期缩短";
            break;
        case 10:
            str = @"疑似脉率稍缓伴有脉搏间期不规则";
            break;
        default:
            str = @"信号质量差请重新测量";
            break;
    }
    return str;
}

#pragma mark - 绘图
//处理波形数据，生成将要绘制的波形点数（5个）
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
    _lastPoints = points;
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 *1.0 / 52 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
    }
    _drawCount = 0;
    [_timer setFireDate:[NSDate distantPast]];
}
//绘制
- (void)fireTimer:(NSTimer *)timer {
    if (_drawCount == 5) {
        _drawCount = 0;
        [timer setFireDate:[NSDate distantFuture]];
        return;
    }
    [_heartLiveView addPoints:[_lastPoints subarrayWithRange:NSMakeRange(_drawCount , 1)]];
    _drawCount++;
}

@end
