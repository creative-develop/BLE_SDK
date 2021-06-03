//
//  CRH600ViewController.m
//  H600Demo
//
//  Created by Creative on 2021/1/8.
//

#import "CRH600ViewController.h"
#import "CRBlueToothManager.h"
#import "CRH600SDK.h"
#import "CRPC80BDisplayView.h"
#import "CRECGResultModel.h"
#import "CRResult.h"

@interface CRH600ViewController ()<CRBlueToothManagerDelegate, CRH600SDKDelegate>

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

@implementation CRH600ViewController

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
        if ([device.bleName containsString:h600]) {
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
    [CRH600SDK shareInstance].delegate = self;
    [[CRH600SDK shareInstance] didConnectDevice:device];
}

- (void)bleManager:(CRBlueToothManager *)manager didDisconnectDevice:(CRBleDevice *)device {
    NSLog(@"连接断开");
    self.device = nil;
    [[CRH600SDK shareInstance] willDisconnectWithDevice:device];
    [CRH600SDK shareInstance].delegate = nil;
    [self backPrevious];
}

- (void)bleManager:(CRBlueToothManager *)manager didFailToConnectDevice:(CRBleDevice *)device Error:(NSError *)error {
    NSLog(@"连接失败");
}

#pragma mark - H600命令
#pragma mark - 查询设备版本号
- (IBAction)getDeviceVersion {
    [[CRH600SDK shareInstance] queryTwoBitDeviceVersionForDevice:self.device];
}
/** 获取到设备版本号 */
- (void)h600SDK:(CRH600SDK *)h600SDK GetDeviceHardWareVersion:(NSString *)hardWareV SoftWareVersion:(NSString *)softWareV FromDevice:(CRBleDevice *)device {
    NSString *string = [NSString stringWithFormat:@"硬件版本：%@，软件版本：%@", hardWareV, softWareV];
    NSLog(@"%@", string);
}

#pragma mark - 查询设备电量[0,4)
- (void)h600SDK:(CRH600SDK *)h600SDK GetBattayLevel:(int)battaryLevel ForDevice:(CRBleDevice *)device {
    NSString *imgName = [NSString stringWithFormat:@"battery_%d", battaryLevel];
    self.battayImageView.image = [UIImage imageNamed:imgName];
}

#pragma mark - 心电开始/停止测量
- (void)h600SDK:(CRH600SDK *)h600SDK GetECGAction:(BOOL)isStart ForDevice:(CRBleDevice *)device {
    /** H600设备上物理按键监听*/
}

#pragma mark - 实时心率
- (void)h600SDK:(CRH600SDK *)h600SDK GetRealTimeHeartRate:(int)heartRate ForDevice:(CRBleDevice *)device {
    self.ecgLabel.text = [NSString stringWithFormat:@"%d", heartRate];
}

#pragma mark - 心电波形
/*!
 *  @method
 *  @descrip 获取到心电跟踪波形数据
 *  @param data     波形值数组
 *  @param length     波形值数组长度
 *  @param gain     增益值（0 表示 ½）
 *  @param stage     当前为哪种测量阶段
 *  @param leadOff     导联脱落情况
 *  @param device     设备
 */
- (void)h600SDK:(CRH600SDK *)pc80bSDK GetTrackingWaveData:(struct waveData *)data Length:(int)length Gain:(int)gain MessureStage:(CRH600SDKMessureStage)stage LeadOff:(BOOL)leadOff ForDevice:(CRBleDevice *)device {
    [self handleEcgWaveWithData:data DataLength:length Gain:gain Leadoff:leadOff MessureStage:stage];
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
- (void)h600bSDK:(CRH600SDK *)h600bSDK GetMessureResult:(int)result HeartRate:(int)heartRate Date:(NSString *)date ForDevice:(CRBleDevice *)device {
    NSString *ecgResult = [CRResult getEcgMeasureResult:result];
    NSString *string = [NSString stringWithFormat:@"测量时间：%@， 心率：%d，分析结果：%@", date, heartRate, ecgResult];
    [self displayQueryResultsWithString:string];
}

#pragma mark - 绘制心电波形
- (void)handleEcgWaveWithData:(struct waveData *)data DataLength:(int)length Gain:(int)gain Leadoff:(BOOL)leadoff MessureStage:(CRH600SDKMessureStage)stage {
    if (!self.allEcgPoints)
        self.allEcgPoints = [NSMutableArray array];
    //增益
    float realGain = gain > 0 ? gain : 0.5;
    self.gainLabel.text = [NSString stringWithFormat:@"x%.1f", realGain];
    /** 点测一共发送6025个波形点，30秒=4500个点*/
    BOOL prepare = stage < 2 ? YES : NO;
    [self.ecgWaveView drawGainLineWithGain:gain];
    //设置脱落
    [self.ecgWaveView setLeadOff:!leadoff];
    //设置准备状态
    [self.ecgWaveView setPrepareState:prepare];
    
    for (int i = 0; i < length; i++) {
        @autoreleasepool {
            CRECGPoint *point = [[CRECGPoint alloc] init];
            point.y = (data[i].waveValue - 2048) * realGain * 1.7 + 2048;
            [self.allEcgPoints addObject:point];
        }
    }
    if (!self.ecgTimer) {
        self.ecgTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 35 target:self selector:@selector(fireEcgTimer:) userInfo:@{@"prepare" : [NSNumber numberWithBool:prepare]} repeats:YES];
        [self.ecgTimer fire];
    }
}

- (void)fireEcgTimer:(NSTimer *)timer {
    if (self.allEcgPoints.count <= self.ecgIndex) {
        [timer invalidate];
        timer = nil;
        return;
    }
    int prepare = ((NSNumber *)[timer.userInfo valueForKey:@"prepare"]).boolValue;
    NSInteger count = self.allEcgPoints.count >= 5 ? 5 : self.allEcgPoints.count;
    [self.ecgWaveView addPoints:[self.allEcgPoints subarrayWithRange:NSMakeRange(self.ecgIndex, count)] InModel:1 Formal:!prepare];
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

@end
