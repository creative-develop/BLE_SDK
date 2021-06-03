//
//  CRPC80BViewController.m
//  PC-80BDemo
//
//  Created by Creative on 2021/1/6.
//

#import "CRPC80BViewController.h"
#import "CRBlueToothManager.h"
#import "CRPC80BSDK.h"
#import "CRPC80BDisplayView.h"
#import "CRECGResultModel.h"
#import "CRResult.h"

@interface CRPC80BViewController ()<CRBlueToothManagerDelegate, CRPC80BSDKDelegate>

/** 当前连接的设备*/
@property (nonatomic, strong) CRBleDevice *device;
/** 电量*/
@property (weak, nonatomic) IBOutlet UIImageView *battayImageView;

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

@end

@implementation CRPC80BViewController

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
        if ([device.bleName containsString:pc80b]) {
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
    [CRPC80BSDK shareInstance].delegate = self;
    [[CRPC80BSDK shareInstance] didConnectDevice:device];
}

- (void)bleManager:(CRBlueToothManager *)manager didDisconnectDevice:(CRBleDevice *)device {
    NSLog(@"连接断开");
    self.device = nil;
    [[CRPC80BSDK shareInstance] willDisconnectWithDevice:device];
    [CRPC80BSDK shareInstance].delegate = nil;
    [self backPrevious];
}

- (void)bleManager:(CRBlueToothManager *)manager didFailToConnectDevice:(CRBleDevice *)device Error:(NSError *)error {
    NSLog(@"连接失败");
}

#pragma mark - PC80B命令
#pragma mark - 同步时间
- (void)getTimeSynRequestFromDevice:(CRBleDevice *)device {
    //设备开机后会给APP发送一次同步时间请求，收到后必须同步时间
    [[CRPC80BSDK shareInstance] setTime:[self getCurrentTime] ForDevice:self.device];
}

#pragma mark - 查询设备版本号
- (IBAction)getDeviceVersion {
    [[CRPC80BSDK shareInstance] queryFourBitDeviceVersionForDevice:self.device];
    [[CRPC80BSDK shareInstance] queryTwoBitDeviceVersionForDevice:self.device];
}

- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetDeviceHardWareVersion:(NSString *)hardWareV SoftWareVersion:(NSString *)softWareV FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"硬件版本：%@，软件版本：%@", hardWareV, softWareV];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 电量[0,4)
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetBattayLevel:(int)battaryLevel ForDevice:(CRBleDevice *)device {
    NSString *imgName = [NSString stringWithFormat:@"battery_%d", battaryLevel];
    self.battayImageView.image = [UIImage imageNamed:imgName];
}

#pragma mark - 心电波形数据
/*!
 *  @method
 *  @descrip 获取到心电跟踪波形数据（30秒快速测量；连续测量-准备测量阶段）
 *  @param data     波形值数组
 *  @param length     波形值数组长度
 *  @param gain     增益值（0 表示 ½）
 *  @param mode     当前波形为哪种测量模式
 *  @param stage     测量阶段：0准备阶段；1倒计时阶段；2正式测量；3开始分析；4报告结果
 *  @param leadOff     导联脱落情况
 *  @param device     设备
 */
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetTrackingWaveData:(int *)data Length:(int)length Gain:(int)gain MessureMode:(CRPC80BSDKMessureMode)mode MessureStage:(CRPC80BSDKMessureStage)stage LeadOff:(BOOL)leadOff ForDevice:(CRBleDevice *)device {
    float realGain = gain;
    if (realGain == 0) {
        realGain = 0.5;
    }
    self.gainLabel.text = [NSString stringWithFormat:@"x%.1f", realGain];
    [self handleEcgWaveWithData:data DataLength:length Leadoff:leadOff MessureMode:1 MessureStage:stage];
}

#pragma mark - 心电波形数据（连续测量-正式测量阶段）
/*!
 *  @method
 *  @descrip 获取到心电实时波形数据（连续测量-正式测量阶段）
 *  @param data     波形值数组
 *  @param length     波形值数组长度 (等于0时代表最后一个包，表示实时波形结束)
 *  @param leadOff     导联脱落情况
 *  @param heartRate     实时心率
 *  @param device     设备
 */
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetRealTimeWaveData:(int *)data Length:(int)length HeartRate:(int)heartRate LeadOff:(BOOL)leadOff ForDevice:(CRBleDevice *)device {
    self.ecgLabel.text = [NSString stringWithFormat:@"%d", heartRate];
    [self handleEcgWaveWithData:data DataLength:length Leadoff:leadOff MessureMode:2 MessureStage:2];
}

#pragma mark - 心电测量结果
/*!
 *  @method
 *  @descrip 获取到心电测量结果
 *  @param result     心电结果
 *  @param heartRate     心率
 *  @param date     测量日期(开始时间)
 *  @param device     设备
 */
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetMessureResult:(int)result HeartRate:(int)heartRate Date:(NSString *)date ForDevice:(CRBleDevice *)device {
    self.ecgLabel.text = [NSString stringWithFormat:@"%d", heartRate];
    NSString *ecgResult = [CRResult getEcgMeasureResult:result];
    NSString *string = [NSString stringWithFormat:@"测量时间：%@， 心率：%d，分析结果：%@", date, heartRate, ecgResult];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 连续测量的滤波模式
/** 滤波模式：进入（连续测量-正式测量阶段）前收到一次*/
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetSmoothMode:(int)smoothMode ForDevice:(CRBleDevice *)device {
    NSLog(@"滤波模式：%d", smoothMode);
}

#pragma mark - 接收到文件传输请求
- (void)getFileTransmissionRequestForDevice:(CRBleDevice *)device {
    //30秒快速测量单个测量文件传输到APP
    NSLog(@"接收到文件传输请求");
}

#pragma mark - 获取传输文件的数据
NSMutableData *fileData;
- (void)pc80bSDK:(CRPC80BSDK *)pc80bSDK GetTransmissionFileData:(Byte *)data DataLength:(int)length Completed:(BOOL)isCompleted ForDevice:(CRBleDevice *)device {
    if (isCompleted) {
        fileData = nil;
        return;
    }
    if (!fileData)
        fileData = [NSMutableData data];
    [fileData appendBytes:data length:length];
    float progress = fileData.length * 1.0 / ECGModelDataLength;
    NSLog(@"%.1f", progress);
}

#pragma mark - 绘制心电波形
- (void)handleEcgWaveWithData:(int *)data DataLength:(int)length Leadoff:(BOOL)leadoff MessureMode:(CRPC80BSDKMessureMode)mode MessureStage:(CRPC80BSDKMessureStage)stage {
    if (!self.allEcgPoints)
        self.allEcgPoints = [NSMutableArray array];
    
    int gain = [self.gainLabel.text substringFromIndex:1].intValue;
    float realGain = gain > 0 ? gain : 0.5;
    /** 点测一共发送6025个波形点，30秒=4500个点*/
    BOOL prepare = stage < 2 ? YES : NO;
    self.ecgWaveView.needGrade = YES;
    [self.ecgWaveView drawGainLineWithGain:gain];
    //设置脱落
    [self.ecgWaveView setLeadOff:!leadoff];
    //设置准备状态
    [self.ecgWaveView setPrepareState:prepare];
    
    for (int i = 0; i < length; i++) {
        @autoreleasepool {
            CRECGPoint *point = [[CRECGPoint alloc] init];
            point.y = (data[i] - 2048) * realGain * 1.7 + 2048;
            [self.allEcgPoints addObject:point];
        }
    }
    if (!self.ecgTimer) {
        self.ecgTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 35 target:self selector:@selector(fireEcgTimer:) userInfo:@{@"mode" : [NSNumber numberWithInt:mode], @"prepare" : [NSNumber numberWithBool:prepare]} repeats:YES];
        [self.ecgTimer fire];
    }
}

- (void)fireEcgTimer:(NSTimer *)timer {
    if (self.allEcgPoints.count <= self.ecgIndex) {
        [timer invalidate];
        timer = nil;
        return;
    }
    int mode = ((NSNumber *)[timer.userInfo valueForKey:@"mode"]).intValue;
    BOOL prepare = self.allEcgPoints.count < 2025;
    NSInteger count = self.allEcgPoints.count >= 5 ? 5 : self.allEcgPoints.count;
    [self.ecgWaveView addPoints:[self.allEcgPoints subarrayWithRange:NSMakeRange(self.ecgIndex, count)] InModel:mode Formal:!prepare];
    self.ecgIndex += count;
}

- (CRPC80BDisplayView *)ecgWaveView {
    if (!_ecgWaveView) {
        CRPC80BDisplayView *ecgWaveView = [[CRPC80BDisplayView alloc] initWithFrame:self.ecgView.bounds];
        ecgWaveView.needGrade = YES;
        ecgWaveView.heightScale = 0.1;
        [ecgWaveView setLineColor:[UIColor redColor]];
        [ecgWaveView drawGainLineWithGain:2];
        [ecgWaveView setLeadOffColor:[UIColor lightGrayColor]];
        [self.ecgView addSubview:ecgWaveView];
        _ecgWaveView = ecgWaveView;
    }
    return _ecgWaveView;
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

/** 当前时间*/
- (NSString *)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    return currentTime;
}

@end
