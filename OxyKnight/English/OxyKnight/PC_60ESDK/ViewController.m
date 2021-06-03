//
//  ViewController.m
//  PC_60ESDK
//
//  Created by Creative on 2020/11/19.
//

#import "ViewController.h"
#import "CRBlueToothManager.h"
#import "CRAP20SDK.h"
#import "CRHeartLiveView.h"
#import "CRPodDeviceMenuView.h"

@interface ViewController ()<CRBlueToothManagerDelegate, CRAP20SDKDelegate>

/** Bound device  */
@property (nonatomic, strong) CRBleDevice *device;
/** Connected device name  */
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
/** Hardware version number  */
@property (weak, nonatomic) IBOutlet UILabel *hardWareVersionLabel;
/** Software version number */
@property (weak, nonatomic) IBOutlet UILabel *softWareVersionLabel;
/** devise serial number */
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
/** Electricity */
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;
/** SpO2%  */
@property (weak, nonatomic) IBOutlet UILabel *spo2Label;
/** Pulse bpm  */
@property (weak, nonatomic) IBOutlet UILabel *prLabel;
/** PI Label  */
@property (weak, nonatomic) IBOutlet UILabel *piLabel;
/** Enable/disable upload of blood oxygen parameters */
@property (weak, nonatomic) IBOutlet UISwitch *parameterSwitch;
/** Enable/disable upload of blood oxygen waveform */
@property (weak, nonatomic) IBOutlet UISwitch *waveformSwitch;
/** base view  */
@property (weak, nonatomic) IBOutlet UIView *bottomContentView;
/** Measurement conclusion  */
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
/** Measurement mode  */
@property (weak, nonatomic) IBOutlet UILabel *workModeLabel;
/** The latest point array */
@property (nonatomic, strong) NSArray<CRPoint *> *lastPoints;
/** Drawing timer */
@property (nonatomic, weak) NSTimer *timer;
/** Waveform graph  */
@property (nonatomic, weak) CRHeartLiveView *heartLiveView;
/** Number of draws  */
@property (nonatomic, assign) int drawCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CRBlueToothManager shareInstance].delegate = self;
    
}

//Click to search for Bluetooth
- (IBAction)searchClieked:(UIBarButtonItem *)sender {
    [[CRBlueToothManager shareInstance] startSearchDevicesForSeconds:1];
}

//Display the searched Bluetooth device list and connect manually
- (void)displayDeviceList:(NSArray *)deviceList {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Select device" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 0; i < deviceList.count; i++) {
        NSString *bleName = ((CRBleDevice *)deviceList[i]).bleName;
        UIAlertAction *action = [UIAlertAction actionWithTitle:bleName style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //Connect Bluetooth
            [[CRBlueToothManager shareInstance] connectDevice:deviceList[i]];
            [alertVC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertVC addAction:action];
    }
    //cancel
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}
//Click Disconnect Bluetooth
- (IBAction)disconnectClicked:(id)sender {
    [[CRBlueToothManager shareInstance] disconnectDevice:self.device];
}
//Enable/disable upload of blood oxygen parameters
- (IBAction)valueChangedWithParameterSwitch:(UISwitch *)sender {
    [self setSpo2ParamEnable:sender.isOn];
}
//Enable/disable upload of blood oxygen waveform
- (IBAction)valueChangedWithWaveformSwitch:(UISwitch *)sender {
    [self setSpo2WaveEnable:sender.isOn];
}
//Set device menu item
- (IBAction)setupClicked:(UIButton *)sender {
    [self queryMenuOptions];
}
//Measurement view (load UI after successful BLE connection)
- (void)loadMessureUI {
    CGSize size = self.view.bounds.size;
    CRHeartLiveView *heartL = [[CRHeartLiveView alloc] initWithFrame:CGRectMake(size.width * 0.03, 0, size.width * 0.94, size.width * 0.9 / 1.85)];
    [_bottomContentView addSubview:heartL];
    _heartLiveView = heartL;
}
//init UI
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

#pragma mark - BLE
//BLE state
- (void)bleManager:(CRBlueToothManager *)manager didUpdateState:(CBManagerState)state API_AVAILABLE(ios(10.0)) {
    if (state == CBManagerStatePoweredOn)
        NSLog(@"open");
    else
        NSLog(@"close");
}
//Filter out bleName from the obtained BLE device list
- (void)bleManager:(CRBlueToothManager *)manager didSearchCompleteWithResult:(NSArray<CRBleDevice *> *)deviceList {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (CRBleDevice *device in deviceList) {
        if ([device.bleName containsString:pc_60f] ||
            [device.bleName containsString:OxyKnight] ||
            [device.bleName containsString:OxySmart]) {
            [array addObject:device];
        }
    }
    //Display the list of searched devices
    [self displayDeviceList:array];
}
//connection succeeded
- (void)bleManager:(CRBlueToothManager *)manager didConnectDevice:(CRBleDevice *)device {
    NSLog(@"connection succeeded");
    self.device = device;
    [[CRAP20SDK shareInstance] didConnectDevice:device];
    //BLE Instruction read and write callback protocol
    [CRAP20SDK shareInstance].delegate = self;
    //Query version information, serial number, Mac address
    [self queryDeviceInfo];
    [self querySerialNumber];
    [self queryMacAddress];
    //Default setting-enable blood oxygen data upload
    [self setSpo2EnableAction];
    //Update UI
    self.deviceNameLabel.text = device.peripheral.name;
    [self loadMessureUI];
}
//Disconnect
- (void)bleManager:(CRBlueToothManager *)manager didDisconnectDevice:(CRBleDevice *)device {
    NSLog(@"Disconnect");
    [[CRAP20SDK shareInstance] willDisconnectWithDevice:device];
    //Release BLE command to read and write callback protocol
    [CRAP20SDK shareInstance].delegate = nil;
    //Clear the interface
    [self initUI];
}
//Connection failed
- (void)bleManager:(CRBlueToothManager *)manager didFailToConnectDevice:(CRBleDevice *)device Error:(NSError *)error {
    
}

#pragma mark - CRAP20SDK BLE read and write
#pragma mark - device info
//【Query device information】
- (void)queryDeviceInfo {
    [[CRAP20SDK shareInstance] queryForDeviceFourBitVersionForDevice:self.device];
}
//Receive the callback of [Query Device Information]
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetDeviceInfoForSoftWareVersion:(NSString *)softWareV HardWaveVersion:(NSString *)hardWareV ProductName:(NSString *)productName FromDevice:(CRBleDevice *)device {
    self.hardWareVersionLabel.text = hardWareV;
    self.softWareVersionLabel.text = softWareV;
}
#pragma mark - devise serial number
//【Query equipment serial number】
- (void)querySerialNumber {
    [[CRAP20SDK shareInstance] queryForSerialNumberForDevice:self.device];
}
//Receive the callback of [Query Device Serial Number]
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSerialNumber:(NSString *)serialNumber FromDevice:(CRBleDevice *)device {
    self.serialNumberLabel.text = serialNumber;
}

#pragma mark - MAC Address
- (void)queryMacAddress {
    [[CRAP20SDK shareInstance] queryForMACAddressForDevice:self.device];
}

- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetMACAddress:(NSString *)macAddress FromDevice:(CRBleDevice *)device {
    NSLog(@"Mac Address:%@", macAddress);
}

#pragma mark - Get battery
/** There are 4 levels of battery power level, the value range is 0-3 */
//【Query battery level】
- (void)queryBatteryLevel {
    //nil
}
//Receive the automatic callback of [Check battery level] (After the BLE connection is successful, the device will automatically send the battery value to the iPhone every second)
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetBartteryLevel:(int)batteryLevel FromDevice:(CRBleDevice *)device {
    self.batteryLabel.text = [NSString stringWithFormat:@"%d", batteryLevel];
}
#pragma mark - Device menu item (for PC-60E)
//【Query equipment menu item】
- (void)queryMenuOptions {
    [[CRAP20SDK shareInstance] queryForMenuOptionsForDevice:_device];
}
//Receive the callback of [Query Device Menu Item]
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK getMenuLowSpO2:(int)lowSpO2 highPR:(int)highPr lowPR:(int)lowPr spot:(int)spot beepOn:(int)beepOn rotateOn:(int)rotateOn FromDevice:(CRBleDevice *)device {
    __block CRPodDeviceMenuView *deviceMenuView = [[CRPodDeviceMenuView alloc] initWithDeviceName:device.peripheral.name Update:^(int lowSpO2, int highPr, int lowPr, int spot, int beepOn, int rotateOn) {
        [deviceMenuView removeFromSuperview];
        //【Set Device Menu Item】(Update)
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
//[Set device menu item] Success or failure callback
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK setMenuSuccess:(BOOL)failOrSuccess FromDevice:(CRBleDevice *)device {
    
}

#pragma mark - Blood oxygen waveform, parameter enable
/** Enable/disable upload of blood oxygen parameters to APP, 0x00 disable, 0x01 enable (default) */
//[Set the switch of uploading blood oxygen parameters]
- (void)setSpo2ParamEnable:(BOOL)beEnable {
    [[CRAP20SDK shareInstance] sendCommandForSpo2ParamEnable:beEnable ForDevice:self.device];
}
//Success【Set the switch of uploading blood oxygen parameters】Callback
- (void)successdToSetSpo2ParamEnableFromDevice:(CRBleDevice *)device {
    NSLog(@"Successfully set blood oxygen parameters：%d", self.parameterSwitch.isOn);
}
/** Enable/disable upload of blood oxygen waveform to APP, 0x00 disable, 0x01 enable (default) */
//[Set the switch for uploading blood oxygen waveform]
- (void)setSpo2WaveEnable:(BOOL)beEnable {
    [[CRAP20SDK shareInstance] sendCommandForSpo2WaveEnable:beEnable ForDevice:self.device];
}
//Success 【Set the Spo2 Waveform Upload Switch】Callback
- (void)successdToSetSpo2WaveEnableFromDevice:(CRBleDevice *)device {
    //[[CRAP20SDK shareInstance] setMenuOptions:90 highPR:120 lowPR:60 spot:2 beepOn:1 forDevice:self.device];
}
/**
 After the BLE connection is successful, set-enable the blood oxygen waveform and parameters to be uploaded to the APP
 */
- (void)setSpo2EnableAction {
    //Allow the device to automatically send blood oxygen waveform data to the APP
    [self setSpo2WaveEnable:YES];
    //Allow the device to automatically send blood oxygen parameters to the APP
    [self setSpo2ParamEnable:YES];
}
#pragma mark - Blood oxygen waveform
/** [Blood oxygen waveform data] automatic callback */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Wave:(struct waveData*)wave FromDevice:(CRBleDevice *)device {
    //绘制波形
    [self handleSpo2WaveData:wave];
}
#pragma mark - Blood oxygen parameters
/** [Spo2 parameter] automatic callback */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetSpo2Value:(int)spo2 PulseRate:(int)pr PI:(int)pi State:(CRAP_20Spo2State)state Mode:(CRAP_20Spo2Mode)mode BattaryLevel:(int)battaryLevel FromDevice:(CRBleDevice *)device {
    self.spo2Label.text = [NSString stringWithFormat:@"%d", spo2];
    self.prLabel.text = [NSString stringWithFormat:@"%d", pr];
    self.piLabel.text = [NSString stringWithFormat:@"%.1f", pi * 0.1];//PI*0.1
}
#pragma mark - Blood oxygen measurement status
/** 【Working status】Automatic callback */
- (void)ap_20SDK:(CRAP20SDK *)ap_20SDK GetWorkStatusDataWithMode:(CRPC_60FWorkStatusMode)mode Stage:(CRPC_60FCommanMessureStage)stage Parameter:(int)para OtherParameter:(int)otherPara FromDevice:(CRBleDevice *)device {
    //NSLog(@"Working status:%d，stage:%d, parameter:%d-%d", mode, stage, para, otherPara);
    NSMutableString *str = [NSMutableString string];
    //Measurement mode
    [str appendFormat:@"%@", mode == 1 ? @"Spot mode" : @"Continuous test mode"];
    //Measurement status
    [str appendFormat:@"\t\t%@", [self getMessureStage:stage]];
    if (stage == 2 && mode == 1)
        //It is measuring, if it is in the spot measuring mode, add the countdown para
        [str appendFormat:@" %ds", para];
    self.workModeLabel.text = str;
    //Measurement conclusion
    if (stage == 3)
        self.resultLabel.text = [NSString stringWithFormat:@"Blood oxygen measurement result: blood oxygen value: %d, pulse rate value: %d", para, otherPara];
    if (stage == 4) {
        NSString *string = [NSString stringWithFormat:@"%@", self.resultLabel.text];
        self.resultLabel.text = [string stringByAppendingFormat:@"\nPulse rate analysis result：%@", [self getMessureResult:para]];
    }
}

//Current measurement phase
- (NSString *)getMessureStage:(int)stage {
    NSArray *array = @[@"", @"preparation phase", @"measurement", @"broadcast result", @"pulse rate analysis result", @"measurement completed"];
    NSString *str = array[stage];
    return str;
}
//Get the measured pulse rate analysis result
- (NSString *)getMessureResult:(int)para {
    NSString *str = @"";
    switch (para) {
        case 0:
            str = @"No irregularity found";
            break;
        case 1:
            str = @"Suspected a little fast pulse";
            break;
        case 2:
            str = @"Suspected fast pulse";
            break;
        case 3:
            str = @"Suspected short run of fast pulse";
            break;
        case 4:
            str = @"Suspected a little slow pulse";
            break;
        case 5:
            str = @"Suspected slow pulse";
            break;
        case 6:
            str = @"Suspected occasional short pulse interval";
            break;
        case 7:
            str = @"Suspected irregular pulse interval";
            break;
        case 8:
            str = @"Suspected fast pulse with short pulse interval";
            break;
        case 9:
            str = @"Suspected slow pulse with short pulse interval";
            break;
        case 10:
            str = @"Suspected slow pulse with irregular pulse interval";
            break;
        default:
            str = @"Poor signal. Measure again";
            break;
    }
    return str;
}

#pragma mark - Drawing
//Process the waveform data and generate the number of waveform points to be drawn (5)
- (void)handleSpo2WaveData:(struct waveData*)wave {
    NSMutableArray *points = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        CRPoint *point = [[CRPoint alloc] init];
        point.y = 128 - wave[i].waveValue;
        [points addObject:point];
        //Heartbeat amplitude (1- point.y/ 128.0)
        //Pulse pulsation flag (wave[i].pulse=YES, displayed; otherwise hidden)
    }
    //Divide the received waveform data into 5 draws, that is, redraw each point once
    _lastPoints = points;
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 *1.0 / 52 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
    }
    _drawCount = 0;
    [_timer setFireDate:[NSDate distantPast]];
}
//draw
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
