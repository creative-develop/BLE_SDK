//
//  PC300ViewController.m
//  PC-300Demo
//
//  Created by Creative on 2020/12/28.
//

#import "PC300ViewController.h"
#import <CRPC300Lib/CRPC300Lib.h>
#import "CRHeartLiveView.h"
#import "CRPC80BDisplayView.h"
#import "CRResult.h"

@interface PC300ViewController ()<CRBlueToothManagerDelegate, CRPC_300SDKDelegate>

/** 当前连接的设备*/
@property (nonatomic, strong) CRBleDevice *device;

/** 血氧*/
@property (weak, nonatomic) IBOutlet UILabel *spo2Label;
@property (weak, nonatomic) IBOutlet UILabel *prLabel;
@property (weak, nonatomic) IBOutlet UILabel *piLabel;
@property (weak, nonatomic) IBOutlet UIView *spo2View;
@property (nonatomic, weak) CRHeartLiveView *spo2WaveView;
/** 最新获取的血氧波形点数组 */
@property (nonatomic, strong) NSMutableArray<CRPoint *> *lastSpo2Points;
/** 画图定时器25HZ */
@property (nonatomic, weak) NSTimer *spo2Timer;

/** 心电*/
@property (weak, nonatomic) IBOutlet UILabel *ecgLabel;
@property (weak, nonatomic) IBOutlet UILabel *gainLabel;//增益值
@property (weak, nonatomic) IBOutlet UIView *ecgView;
@property (nonatomic, weak) NSTimer *ecgTimer;
/** 记录所有的6025个波形点*/
@property (nonatomic, strong) NSMutableArray<CRECGPoint *> *allEcgPoints;
/** 当前正在绘制的allEcgPoints的位置*/
@property (nonatomic, assign) NSInteger ecgIndex;
/** 心电波形图  */
@property (nonatomic, weak) CRPC80BDisplayView *ecgWaveView;

/** 血压*/
@property (weak, nonatomic) IBOutlet UILabel *systolicLabel;//收缩压
@property (weak, nonatomic) IBOutlet UILabel *diastolicLabel;//舒张压
@property (weak, nonatomic) IBOutlet UILabel *nibpLabel;//实时血压值
@property (weak, nonatomic) IBOutlet UILabel *prNibpLabel;//脉率

/** 体温*/
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

/** 血糖*/
@property (weak, nonatomic) IBOutlet UILabel *gluLabel;

/** 尿酸*/
@property (weak, nonatomic) IBOutlet UILabel *uricLabel;

/** 胆固醇*/
@property (weak, nonatomic) IBOutlet UILabel *cholLabel;

@end

@implementation PC300ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"<返回" style:(UIBarButtonItemStylePlain) target:self action:@selector(backPrevious)];
    self.navigationItem.leftBarButtonItem = item;
    [CRBlueToothManager shareInstance].delegate = self;
    [self searchDevice];
    
}

/** 返回*/
- (void)backPrevious {
    if (self.device) {
        [[CRBlueToothManager shareInstance] disconnectDevice:self.device];
        return;
    }
    [CRBlueToothManager shareInstance].delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - BLE
- (void)searchDevice {
    [[CRBlueToothManager shareInstance] startSearchDevicesForSeconds:1.5];
}

- (void)stopSearchDevice {
    [[CRBlueToothManager shareInstance] stopSearch];
}

- (void)displayDeviceList:(NSArray<CRBleDevice *> *)deviceList {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"选择设备" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    for (CRBleDevice *device in deviceList) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:device.bleName style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [[CRBlueToothManager shareInstance] connectDevice:device];
        }];
        [vc addAction:action];
    }
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDestructive) handler:nil];
    [vc addAction:action];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - BLE协议
- (void)bleManager:(CRBlueToothManager *)manager didUpdateState:(CBManagerState)state {
    if (state == CBManagerStatePoweredOn)
        NSLog(@"蓝牙已打开");
    else
        NSLog(@"蓝牙未启用");
}

- (void)bleManager:(CRBlueToothManager *)manager didSearchCompleteWithResult:(NSArray<CRBleDevice *> *)deviceList {
    NSMutableArray *fitports = [NSMutableArray array];
    for (CRBleDevice *device in deviceList) {
        if ([device.bleName containsString:pc300] ||
            [device.bleName containsString:pc200] ||
            [device.bleName containsString:PC303_CMI] ||
            [device.bleName containsString:GM_300SNT]) {
            [fitports addObject:device];
        }
    }
    /** 没有搜到设备，继续搜索*/
    if (fitports.count == 0) {
        [self searchDevice];
        return;
    }
    /** 显示搜到的设备*/
    [self displayDeviceList:fitports];
}

- (void)bleManager:(CRBlueToothManager *)manager didConnectDevice:(CRBleDevice *)device {
    NSLog(@"连接成功");
    self.device = device;
    self.navigationItem.title = device.bleName;
    [CRPC_300SDK shareInstance].delegate = self;
    [[CRPC_300SDK shareInstance] didConnectDevice:device];
}

- (void)bleManager:(CRBlueToothManager *)manager didDisconnectDevice:(CRBleDevice *)device {
    NSLog(@"连接断开");
    self.device = nil;
    [[CRPC_300SDK shareInstance] willDisconnectWithDevice:device];
    [CRPC_300SDK shareInstance].delegate = nil;
    [self backPrevious];
}

- (void)bleManager:(CRBlueToothManager *)manager didFailToConnectDevice:(CRBleDevice *)device Error:(NSError *)error {
    NSLog(@"连接失败");
}

#pragma mark - PC300命令
#pragma mark - —— 血氧 ——
#pragma mark - 血氧值
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getSpo2ParamDatasWithSpo2Value:(int)spo2 PR:(int)pr PI:(int)pi LeadOff:(BOOL)leadOff Mode:(int)mode FromDevice:(CRBleDevice *)device {
    self.spo2Label.text = [NSString stringWithFormat:@"%d", spo2];
    self.prLabel.text = [NSString stringWithFormat:@"%d", pr];
    self.piLabel.text = [NSString stringWithFormat:@"%.1f", pi * 0.1];
}

#pragma mark - 血氧波形
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getSpo2WaveDatas:(struct waveData *)waveData DataLength:(int)dataLength FromDevice:(CRBleDevice *)device {
    [self handleSpo2WaveData:waveData DataLength:dataLength];
}


#pragma mark - —— 心电 ——
#pragma mark - 开始/结束心电测量状态
/** H600设备按键回调*/
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getECGAction:(BOOL)isStart FromDevice:(CRBleDevice *)device {
    if (isStart) {
        NSLog(@"开始心电测量");
        self.ecgLabel.text = @"--";
        self.gainLabel.text = @"--";
        [[CRPC_300SDK shareInstance] setECGWaveTwelveBit:YES ForDevice:device];
    } else {
        NSLog(@"结束心电测量");
    }
    //清除上次保留的结果
    _ecgIndex = 0;
    _allEcgPoints = nil;
    [_ecgWaveView clearPath];
}

#pragma mark - 心电波形（12位）
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getECGWave:(struct waveData *)data DataLength:(int)length Leadoff:(BOOL)leadoff FromDevice:(CRBleDevice *)device {
    [self handleEcgWaveWithData:data DataLength:length Leadoff:leadoff];
}

#pragma mark - 心电测量结果
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetECGMessureResult:(int)result HeartRate:(int)heartRate ForDevice:(CRBleDevice *)device {
    self.ecgLabel.text = [NSString stringWithFormat:@"%d", heartRate];
    NSString *ecgResult = [CRResult getEcgMeasureResult:result];
    [self displayQueryResultsWithString:ecgResult];
}

#pragma mark - 心电增益
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetECGGain:(int)gain ForDevice:(CRBleDevice *)device {
    self.gainLabel.text = [NSString stringWithFormat:@"x%d", gain];
}

#pragma mark - 设置心电数据位数（是否为十二位）
BOOL isBits = NO;
- (IBAction)setEcgDataBits:(UIButton *)sender {
    isBits = YES;
    [[CRPC_300SDK shareInstance] setECGWaveTwelveBit:YES ForDevice:self.device];
}

- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetECGWaveBit:(int)bit ForDevice:(CRBleDevice *)device {
    if (isBits) {
        isBits = NO;
        NSString *string = [NSString stringWithFormat:@"当前心电位数：%d位", bit];
        [self displayQueryResultsWithString:string];
    }
}

#pragma mark - —— 血压 ——
#pragma mark - 开始/结束测量血压
UIButton *nibpBtn;
- (IBAction)bloodPressureMeasurement:(UIButton *)sender {
    nibpBtn = sender;
    if (!sender.selected) {
        /** 开始测量*/
        [[CRPC_300SDK shareInstance] startBloodPressureMeasurementForDevice:self.device];
    } else {
        /** 结束测量*/
        [[CRPC_300SDK shareInstance] stopBloodPressureMeasurementForDevice:self.device];
    }
}

- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK bloodPressureActionStart:(BOOL)start FromDevice:(CRBleDevice *)device {
    /** 测量结束不会调用，需在结论回调里手动将按钮还原*/
    nibpBtn.selected = start;
    if (start) {
        self.systolicLabel.text = @"--";
        self.diastolicLabel.text = @"--";
        self.nibpLabel.text = @"--";
        self.prNibpLabel.text = @"--";
    }
}

#pragma mark - 血压测量压力实时数据
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getNIBPRealTimeDataWithPressure:(int)pressure HeartBeat:(BOOL)heartBeat FromDevice:(CRBleDevice *)device {
    self.systolicLabel.text = [NSString stringWithFormat:@"%d", pressure];
}

#pragma mark - 血压测量结果
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getNIBPMessurementResultWithSys:(int)sys Dia:(int)dia Map:(int)map Pr:(int)pr HeartRateState:(BOOL)hrState Rank:(int)rank FromDevice:(CRBleDevice *)device {
    nibpBtn.selected = NO;
    self.systolicLabel.text = [NSString stringWithFormat:@"%d", sys];
    self.diastolicLabel.text = [NSString stringWithFormat:@"%d", dia];
    self.nibpLabel.text = [NSString stringWithFormat:@"%d", map];
    self.prNibpLabel.text = [NSString stringWithFormat:@"%d", pr];
}

#pragma mark - 血压测量错误结果
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getNIBPMessurementErrorWithErrorType:(int)errorType ErrorCode:(int)errorCode FromDevice:(CRBleDevice *)device {
    nibpBtn.selected = NO;
    NSString *string = [CRResult getNibpMeasureErrorResultWithErrorType:errorType errorCode:errorCode];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 开始血压静态压校准
- (IBAction)setStaticPressureCalibration:(UIButton *)sender {
    /** 目前仅PC-200可用*/
    [[CRPC_300SDK shareInstance] startStaticPressureCalibrationForDevice:self.device];
}

#pragma mark - —— 体温 ——
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getBodyTemparature:(float)tempValue Result:(int)result FromDevice:(CRBleDevice *)device {
    //温度高于测量范围
    int convertValue = ((int)(tempValue * 10));
    if (convertValue >= 430) {
        self.temperatureLabel.text = [NSString stringWithFormat:@"过高"];
        return;
    }
    if (convertValue <= 320) {
        self.temperatureLabel.text = [NSString stringWithFormat:@"过低"];
        return;
    }
    /** 为保证与设备一致，体温不建议四舍五入取值*/
    self.temperatureLabel.text = [NSString stringWithFormat:@"%.1f°C", convertValue * 0.1];
    NSArray *array = @[@"正常", @"偏低", @"偏高"];
    NSString *string = [NSString stringWithFormat:@"当前体温：%.1f°C，体温%@", convertValue * 0.1, array[result]];
    [self displayQueryResultsWithString:string];
}

#pragma mark - —— 血糖 ——
#pragma mark - 血糖测量结果
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getBloodGlucoseResult:(int)result GluValue:(int)gluValue UnitType:(int)unitType FromDevice:(CRBleDevice *)device {
    NSArray *array = @[@"mmol/L", @"mg/dL"];
    self.gluLabel.text = [NSString stringWithFormat:@"%.1f%@", gluValue * 0.1, array[unitType]];
}

#pragma mark - 血糖仪类型（仅部分PC-200可用）1:爱奥乐，2：百捷
- (IBAction)getGluType:(UIButton *)sender {
    [[CRPC_300SDK shareInstance] queryForGluDeviceTypeFromDevice:self.device];
}

- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getGlucoseDeviceType:(int)type FromDevice:(CRBleDevice *)device {
    NSArray *array = @[@"爱奥乐", @"百捷"];
    NSString *string = [NSString stringWithFormat:@"血糖仪类型：%@", array[type-1]];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 设置血糖仪类型 （仅部分PC-200,PC-300可用）1:爱奥乐，2：百捷
- (IBAction)setGluType:(UIButton *)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"设置血糖仪类型" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    NSArray *array = @[@"爱奥乐", @"百捷", @"取消"];
    for (int i = 0; i < 3; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:array[i] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            if (i < 2)
                [[CRPC_300SDK shareInstance] setGluDeviceType:i + 1 FromDevice:self.device];
        }];
        [vc addAction:action];
    }
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK setGlucoseDeviceTypeSuccessFromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"设置血糖仪类型成功"];
    [self displayQueryResultsWithString:string];
}

#pragma mark - —— 尿酸 ——
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getUricAcidValue:(int)uaValue UnitType:(int)unitType FromDevice:(CRBleDevice *)device {
    NSArray *array = @[@"mmol/L", @"mg/dL"];
    self.uricLabel.text = [NSString stringWithFormat:@"%.1f%@", uaValue * 0.1, array[unitType]];
}

#pragma mark - —— 胆固醇 ——
- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getCHOLValue:(int)cholValue UnitType:(int)unitType FromDevice:(CRBleDevice *)device {
    NSArray *array = @[@"mmol/L", @"mg/dL"];
    self.cholLabel.text = [NSString stringWithFormat:@"%.1f%@", cholValue * 0.1, array[unitType]];
}

#pragma mark - —— 设备信息 ——
#pragma mark - 查询产品ID
- (IBAction)getDeviceID:(UIButton *)sender {
    [[CRPC_300SDK shareInstance] queryForProductNameFromDevice:self.device];
}

- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getProductName:(NSString *)name FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"产品名称：%@", name];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 查询产品版本及电量等级
BOOL isTip = NO;
- (IBAction)getDeviceVersionAndElectricityLevel:(UIButton *)sender {
    isTip = YES;
    [[CRPC_300SDK shareInstance] queryForDeviceVerisionInfomationFromDevice:self.device];
}

- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getDeviceInfoWithSoftWareVersion:(NSString *)softWareV HardWareVersion:(NSString *)hardWareV BattaryLevel:(int)battaryLevle BattaryChargingState:(CRPC_300SDKBattaryChargingState)chargingState FromDevice:(CRBleDevice *)device {
    if (!isTip) {
        return;
    }
    isTip = NO;
    NSString *string = [NSString stringWithFormat:@"硬件版本：%@，软件版本：%@，电量格数：%d", hardWareV, softWareV, battaryLevle];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 查询客户ID
- (IBAction)getClientID:(UIButton *)sender {
    [[CRPC_300SDK shareInstance] queryForClientIDFromDevice:self.device];
}

- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK getClientID:(int)clientID FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"客户ID：%d", clientID];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 设备即将关机
- (void)aboutToShutDownDevice:(CRBleDevice *)device {
    NSLog(@"设备关机");
}

#pragma mark - —— 固件升级 ——
/*!
 *  @method
 *  @descrip 查询固件版本信息
 *  @param mode     模式.(1:准备升级固件. 2:只回应版本信息)
 *  @param device     s设备
 *
 */
- (void)queryDeviceIAPVersionWithMode:(int)mode ForDevice:(CRBleDevice *)device{}
/** 开启固件更新 */
- (void)startIAPUpdateForDevice:(CRBleDevice *)device{}
/** 开始发送数据 */
- (void)startTransmistIAPData:(NSData *)ipaData ForDevice:(CRBleDevice *)device{}
/** 完成固件更新 */
- (void)completeIAPUpdateForDevice:(CRBleDevice *)device{}
/** 停止更新 */
- (void)stopTransmistIAPDataForDevice:(CRBleDevice *)devic{}

- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetIAPState:(int)state HardWareVersion:(NSString *)hwVersion SoftWareVersion:(NSString *)swVersion ForDevice:(CRBleDevice *)device {
    
}

- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetIAPUpdateProgress:(float)progress ForDevice:(CRBleDevice *)device {
    
}

- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK GetUpdateIAPResponceForDevice:(CRBleDevice *)device {
    
}

- (void)pc_300SDK:(CRPC_300SDK *)pc_300SDK IAPUpdateCompleteWithState:(int)state ForDevice:(CRBleDevice *)device {
    
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

#pragma mark - 波形
#pragma mark - 血氧波形
- (void)handleSpo2WaveData:(struct waveData*)wave DataLength:(int)length {
    NSMutableArray *points = [NSMutableArray array];
    for (int i = 0; i < length; i++) {
        CRPoint *point = [[CRPoint alloc] init];
        point.y = 128 - wave[i].waveValue;
        [points addObject:point];
        //心跳幅度（1- point.y/ 128.0）
        //脉搏搏动标志（wave[i].pulse=YES,显示;否则隐藏）
    }
    //将接收的波形数据分成5次绘制，即每个点重绘一次
    if (!_lastSpo2Points)
        _lastSpo2Points = [NSMutableArray array];
    [_lastSpo2Points addObjectsFromArray:points];
    if (!_spo2Timer) {
        _spo2Timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 52 target:self selector:@selector(fireSpo2Timer:) userInfo:nil repeats:YES];
        [_spo2Timer fire];
        [[NSRunLoop currentRunLoop] addTimer:_spo2Timer forMode:NSRunLoopCommonModes];
    }
}

- (void)fireSpo2Timer:(NSTimer *)timer {
    if (_lastSpo2Points.count == 0) {
        [timer invalidate];
        timer = nil;
        return;
    }
    if (_lastSpo2Points.count > 0) {
        [self.spo2WaveView addPoints:[_lastSpo2Points subarrayWithRange:NSMakeRange(0 , 1)]];
        [_lastSpo2Points removeObjectAtIndex:0];
    }
}

- (CRHeartLiveView *)spo2WaveView {
    if (!_spo2WaveView) {
        CRHeartLiveView *heartL = [[CRHeartLiveView alloc] initWithFrame:self.spo2View.bounds];
        [self.spo2View addSubview:heartL];
        _spo2WaveView = heartL;
    }
    return _spo2WaveView;
}

#pragma mark - 心电波形
- (void)handleEcgWaveWithData:(struct waveData *)data DataLength:(int)length Leadoff:(BOOL)leadoff {
    if (!self.allEcgPoints)
        self.allEcgPoints = [NSMutableArray array];
    
    int gain = [self.gainLabel.text substringFromIndex:1].intValue;
    /** 点测一共发送6025个波形点，30秒=4500个点*/
    BOOL prepare = self.allEcgPoints.count < 2025;
    _ecgWaveView.needGrade = YES;
    [_ecgWaveView drawGainLineWithGain:gain];
    //设置脱落
    [_ecgWaveView setLeadOff:!leadoff];
    //设置准备状态
    [_ecgWaveView setPrepareState:prepare];
    
    for (int i = 0; i < length; i++) {
        @autoreleasepool {
            CRECGPoint *point = [[CRECGPoint alloc] init];
            point.y = (data[i].waveValue - 2048) * gain * 1.7 + 2048;
            [self.allEcgPoints addObject:point];
        }
    }
    if (!self.ecgTimer) {
        self.ecgTimer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(fireEcgTimer:) userInfo:nil repeats:YES];
        [self.ecgTimer fire];
        //滑动时timer仍执行
        [[NSRunLoop currentRunLoop] addTimer:self.ecgTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)fireEcgTimer:(NSTimer *)timer {
    if (self.allEcgPoints.count <= self.ecgIndex) {
        [timer invalidate];
        timer = nil;
        return;
    }
    BOOL prepare = self.allEcgPoints.count < 2025;
    NSInteger count = self.allEcgPoints.count >= 5 ? 5 : self.allEcgPoints.count;
    [self.ecgWaveView addPoints:[self.allEcgPoints subarrayWithRange:NSMakeRange(self.ecgIndex, count)] InModel:1 Formal:!prepare];
    self.ecgIndex += count;
}

- (CRPC80BDisplayView *)ecgWaveView {
    if (!_ecgWaveView) {
        CRPC80BDisplayView *ecgWaveView = [[CRPC80BDisplayView alloc] initWithFrame:self.ecgView.bounds];
        ecgWaveView.needGrade = NO;
        ecgWaveView.heightScale = 0.1;
        [ecgWaveView setLineColor:[UIColor redColor]];
        [ecgWaveView drawGainLineWithGain:2];
        [ecgWaveView setLeadOffColor:[UIColor lightGrayColor]];
        [self.ecgView addSubview:ecgWaveView];
        _ecgWaveView = ecgWaveView;
    }
    return _ecgWaveView;
}

@end
