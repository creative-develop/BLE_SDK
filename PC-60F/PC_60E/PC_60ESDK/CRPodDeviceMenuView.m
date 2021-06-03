//
//  CRPodDeviceMenuView.m
//  health
//
//  Created by Creative on 2020/11/17.
//  Copyright © 2020 creative. All rights reserved.
//

#import "CRPodDeviceMenuView.h"

/** PC-60E设备菜单项选项*/
typedef NS_ENUM(int, CRPC_60EDeviceMenuOption)
{
    CRPC_60EDeviceMenuOptionEmpty   = 0,
    CRPC_60EDeviceMenuOptionLowSpO2 = 1,
    CRPC_60EDeviceMenuOptionHightPr = 2,
    CRPC_60EDeviceMenuOptionLowPr   = 3,
    CRPC_60EDeviceMenuOptionSpot    = 4,
    CRPC_60EDeviceMenuOptionBeepOn  = 5,
    CRPC_60EDeviceMenuOptionRotateOn= 6
};

@interface CRPodDeviceMenuView ()<UIPickerViewDelegate, UIPickerViewDataSource>

/** 点击更新后执行的block */
@property (nonatomic, copy) void(^update)(int lowSpO2, int highPr, int lowPr, int spot, int beepOn, int rotateOn);
/** 点击取消后执行的block */
@property (nonatomic, copy) void(^cancel)(void);
/** 信息图  */
@property (nonatomic, weak) UIView *infoView;
/** 设备名称层 */
@property (nonatomic, weak) CATextLayer *portNameLayer;
/** Spo2L label layer*/
@property (nonatomic, weak) CATextLayer *lowSpO2Layer;
/** PrH */
@property (nonatomic, weak) CATextLayer *highPrLayer;
/** PrL */
@property (nonatomic, weak) CATextLayer *lowPrLayer;
/** ContinuousOrSpot */
@property (nonatomic, weak) CATextLayer *spotLayer;
/** Deep */
@property (nonatomic, weak) CATextLayer *beepOnLayer;
/** Rotate */
@property (nonatomic, weak) CATextLayer *rotateOnLayer;
/** 取消按钮  */
@property (nonatomic, weak) UIButton *cancelBtn;
/** 更新按钮  */
@property (nonatomic, weak) UIButton *updateBtn;
/** 选择数值pickerView*/
@property (nonatomic, strong) UIPickerView *pickerView;
/** pickerView取值范围*/
@property (nonatomic, strong) NSArray *rangeArray;
/** 选项*/
@property (nonatomic, assign) int option;

@end

@implementation CRPodDeviceMenuView

- (instancetype)initWithDeviceName:(NSString *)deviceName Update:(void(^)(int lowSpO2, int highPr, int lowPr, int spot, int beepOn, int rotateOn))update Cancel:(void(^)(void))cancel
{
    if (self = [super init])
    {
        self.update = update;
        self.cancel = cancel;
        self.userInteractionEnabled = YES;
        [self initSubviewsWithPort:deviceName];
    }
    return self;
}

- (void)initSubviewsWithPort:(NSString *)deviceName
{
    float infoHeight = 270;
    float margin = 5;
    float tipsHeight = 35;
    float btnHeight = 35;
    float lineHeight = (infoHeight - 9 *margin - tipsHeight - btnHeight) * 1.0 / 7;
    //遮罩
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    //信息图
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, infoHeight, infoHeight)];
    infoView.center = self.center;
    infoView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:1];
    infoView.layer.cornerRadius = 10;
    infoView.layer.masksToBounds = YES;
    _infoView = infoView;
    [self addSubview:infoView];
    
    CGSize size = infoView.bounds.size;
    //提示层
    CATextLayer *tipsL = [CATextLayer layer];
    tipsL.contentsScale = [UIScreen mainScreen].scale;
    //字体大小
    tipsL.fontSize = 25.f;
    //对齐方式
    tipsL.alignmentMode = kCAAlignmentCenter;
    //背景颜色
    tipsL.backgroundColor = [UIColor colorWithRed:38/255.0 green:149/255.0 blue:162/255.0 alpha:1.0].CGColor;
    //字体颜色
    tipsL.foregroundColor = [UIColor whiteColor].CGColor;
    tipsL.frame = CGRectMake(0, 0, size.width, tipsHeight);
    tipsL.string = NSLocalizedString(@"设备菜单项",@"设备菜单项");
    [infoView.layer addSublayer:tipsL];
    //当前连接设备：
   CATextLayer *descriptText1 = [self createTextLayerWithFrame:CGRectMake(margin, CGRectGetMaxY(tipsL.frame) + margin, 0.4 * size.width, lineHeight) Text: NSLocalizedString(@"当前连接设备:", @"当前连接设备:") FontSize:15];
    //设备名称
    _portNameLayer = [self createTextLayerWithFrame:CGRectMake(CGRectGetMaxX(descriptText1.frame) + margin, descriptText1.frame.origin.y, size.width - CGRectGetMaxX(descriptText1.frame), lineHeight) Text:deviceName FontSize:13];
//    _portNameLayer.alignmentMode = kCAAlignmentLeft;
    //lowSpO2 title
    CATextLayer *descriptText2 = [self createTextLayerWithFrame:CGRectMake(margin, CGRectGetMaxY(descriptText1.frame) + margin, 0.4 * size.width, lineHeight) Text:NSLocalizedString(@"lowSpO2", @"lowSpO2") FontSize:15];
    //lowSpO2 value
    _lowSpO2Layer = [self createTextLayerWithFrame:CGRectMake(CGRectGetMaxX(descriptText2.frame) + margin, descriptText2.frame.origin.y, 0.4 * size.width, lineHeight) Text:@"" FontSize:15];
    //highPr
    CATextLayer *descriptText3 = [self createTextLayerWithFrame:CGRectMake(margin, CGRectGetMaxY(descriptText2.frame) + margin, 0.4 * size.width, lineHeight) Text:NSLocalizedString(@"highPr", @"highPr") FontSize:15];
    _highPrLayer = [self createTextLayerWithFrame:CGRectMake(CGRectGetMaxX(descriptText3.frame) + margin, descriptText3.frame.origin.y, 0.4 * size.width, lineHeight) Text:@"" FontSize:15];
    //lowPr
    CATextLayer *descriptText4 = [self createTextLayerWithFrame:CGRectMake(margin, CGRectGetMaxY(descriptText3.frame) + margin, 0.4 * size.width, lineHeight) Text:NSLocalizedString(@"lowPr", @"lowPr") FontSize:15];
    _lowPrLayer = [self createTextLayerWithFrame:CGRectMake(CGRectGetMaxX(descriptText4.frame) + margin, descriptText4.frame.origin.y, 0.4 * size.width, lineHeight) Text:@"" FontSize:15];
    //spot
    CATextLayer *descriptText5 = [self createTextLayerWithFrame:CGRectMake(margin, CGRectGetMaxY(descriptText4.frame) + margin, 0.4 * size.width, lineHeight) Text:NSLocalizedString(@"spot", @"spot") FontSize:15];
    _spotLayer = [self createTextLayerWithFrame:CGRectMake(CGRectGetMaxX(descriptText5.frame) + margin, descriptText5.frame.origin.y, 0.4 * size.width, lineHeight) Text:@"" FontSize:15];
    //beepOn
    CATextLayer *descriptText6 = [self createTextLayerWithFrame:CGRectMake(margin, CGRectGetMaxY(descriptText5.frame) + margin, 0.4 * size.width, lineHeight) Text:NSLocalizedString(@"beepOn", @"beepOn") FontSize:15];
    _beepOnLayer = [self createTextLayerWithFrame:CGRectMake(CGRectGetMaxX(descriptText6.frame) + margin, descriptText6.frame.origin.y, 0.4 * size.width, lineHeight) Text:@"" FontSize:15];
    //rotateOn
    CATextLayer *descriptText7 = [self createTextLayerWithFrame:CGRectMake(margin, CGRectGetMaxY(descriptText6.frame) + margin, 0.4 * size.width, lineHeight) Text:NSLocalizedString(@"rotateOn", @"rotateOn") FontSize:15];
    _rotateOnLayer = [self createTextLayerWithFrame:CGRectMake(CGRectGetMaxX(descriptText7.frame) + margin, descriptText7.frame.origin.y, 0.4 * size.width, lineHeight) Text:@"" FontSize:15];
    
    //取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(10, 8 * margin + 7 * lineHeight + tipsHeight, 120, btnHeight);
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitle:NSLocalizedString(@"取消", @"取消") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:[UIColor colorWithRed:38/255.0 green:149/255.0 blue:162/255.0 alpha:.8] forState:UIControlStateNormal];
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.layer.masksToBounds = YES;
    _cancelBtn = cancelBtn;
    [infoView addSubview:cancelBtn];
    
    //更新按钮
    UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    updateBtn.frame = CGRectMake(CGRectGetMaxX(cancelBtn.frame) + 10, cancelBtn.frame.origin.y, 120, btnHeight);
    [updateBtn addTarget:self action:@selector(updateClicked:) forControlEvents:UIControlEventTouchUpInside];
    updateBtn.backgroundColor = [UIColor colorWithRed:38/255.0 green:149/255.0 blue:162/255.0 alpha:.8];
    [updateBtn setTitle:NSLocalizedString(@"更新", @"更新") forState:UIControlStateNormal];
    [updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    updateBtn.layer.cornerRadius = 5;
    updateBtn.layer.masksToBounds = YES;
    _updateBtn = updateBtn;
    [infoView addSubview:updateBtn];
}

- (CATextLayer *)createTextLayerWithFrame:(CGRect)frame Text:(NSString *)text FontSize:(float)fontSize
{
    CATextLayer *textL = [CATextLayer layer];
    textL.contentsScale = [UIScreen mainScreen].scale;
    textL.fontSize = fontSize;
    textL.foregroundColor = [UIColor whiteColor].CGColor;
    textL.backgroundColor = [UIColor darkGrayColor].CGColor;
    textL.frame = frame;
    textL.string = text;
    [_infoView.layer addSublayer:textL];
    return textL;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.infoView];
    self.rangeArray = nil;
    self.option = CRPC_60EDeviceMenuOptionEmpty;
    //选中（更改）设备菜单某一项的值
    if ([self.lowSpO2Layer hitTest:point])
        self.option = CRPC_60EDeviceMenuOptionLowSpO2;
    else if ([self.highPrLayer hitTest:point])
        self.option = CRPC_60EDeviceMenuOptionHightPr;
    else if ([self.lowPrLayer hitTest:point])
        self.option = CRPC_60EDeviceMenuOptionLowPr;
    else if ([self.spotLayer hitTest:point])
        self.option = CRPC_60EDeviceMenuOptionSpot;
    else if ([self.beepOnLayer hitTest:point])
        self.option = CRPC_60EDeviceMenuOptionBeepOn;
    else if ([self.rotateOnLayer hitTest:point])
        self.option = CRPC_60EDeviceMenuOptionRotateOn;
    //load picker
    if (self.option >= 1 && self.option <= 6) {
        self.rangeArray = [self getRangeArrayWithOption:self.option];
        self.pickerView.hidden = NO;
        [self.pickerView reloadComponent:0];
        [self initSelectRowWithPickerView:self.pickerView];
    } else {
        self.pickerView.hidden = YES;
    }
}

- (NSArray *)getRangeArrayWithOption:(int)option
{
    int low = 0;
    int hight = 0;
    if (option == CRPC_60EDeviceMenuOptionLowSpO2) {
        low = 80;
        hight = 99;
    } else if (option == CRPC_60EDeviceMenuOptionHightPr) {
        low = 100;
        hight = 240;
    } else if (option == CRPC_60EDeviceMenuOptionLowPr) {
        low = 30;
        hight = 60;
    } else {
        low = 1;
        hight = 2;
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = low; i <= hight; i++) {
        [arr addObject:[NSNumber numberWithInt:i]];
    }
    return [arr copy];
}

- (void)setLowSpO2:(int)lowSpO2
{
    _lowSpO2 = lowSpO2;
    _lowSpO2Layer.string = [NSString stringWithFormat:@"%d", lowSpO2];
}

- (void)setHighPr:(int)highPr
{
    _highPr = highPr;
    _highPrLayer.string = [NSString stringWithFormat:@"%d", highPr];
}

- (void)setLowPr:(int)lowPr
{
    _lowPr = lowPr;
    _lowPrLayer.string = [NSString stringWithFormat:@"%d", lowPr];
}

- (void)setSpot:(int)spot
{
    _spot = spot;
    _spotLayer.string = [NSString stringWithFormat:@"%@", spot == 1 ? @"点测模式" : @"连测模式"];
}

- (void)setBeepOn:(int)beepOn
{
    _beepOn = beepOn;
    _beepOnLayer.string = [NSString stringWithFormat:@"%@", beepOn == 1 ? @"开" : @"关"];
}

- (void)setRotateOn:(int)rotateOn
{
    _rotateOn = rotateOn;
    _rotateOnLayer.string = [NSString stringWithFormat:@"%@", rotateOn == 1 ? @"开" : @"关"];
}

- (void)cancelClicked:(UIButton *)sender
{
    if (_cancel)
    {
        _cancel();
        _cancel = nil;
    }
}

- (void)updateClicked:(UIButton *)sender
{
    if (_update)
    {
        _update(self.lowSpO2, self.highPr, self.lowPr, self.spot, self.beepOn, self.rotateOn);
        _update = nil;
    }
}

#pragma mark UIPickerView
- (UIPickerView *)pickerView {
    if (!_pickerView) {
        UIPickerView *view = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 200, self.bounds.size.width, 200)];
        view.delegate = self;
        view.dataSource = self;
        view.backgroundColor = [UIColor whiteColor];
        [self addSubview:view];
        _pickerView = view;
    }
    return _pickerView;;
}

// 返回多少列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
// 返回多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.rangeArray.count;
}
// 返回每行的标题
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [NSString stringWithFormat:@"%@", self.rangeArray[row]];
    if (self.option == CRPC_60EDeviceMenuOptionSpot)
        title = title.intValue == 1 ? @"点测模式" : @"连测模式";
    else if (self.option == CRPC_60EDeviceMenuOptionBeepOn)
        title = title.intValue == 1 ? @"开" : @"关";
    else if (self.option == CRPC_60EDeviceMenuOptionRotateOn)
        title = title.intValue == 1 ? @"开" : @"关";
    return title;
}
// 选中行显示在label上
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *title = [NSString stringWithFormat:@"%@", self.rangeArray[row]];
    if (self.option == CRPC_60EDeviceMenuOptionLowSpO2)
        self.lowSpO2 = title.intValue;
    else if (self.option == CRPC_60EDeviceMenuOptionHightPr)
        self.highPr = title.intValue;
    else if (self.option == CRPC_60EDeviceMenuOptionLowPr)
        self.lowPr = title.intValue;
    else if (self.option == CRPC_60EDeviceMenuOptionSpot)
        self.spot = title.intValue;
    else if (self.option == CRPC_60EDeviceMenuOptionBeepOn)
        self.beepOn = title.intValue;
    else if (self.option == CRPC_60EDeviceMenuOptionRotateOn)
        self.rotateOn = title.intValue;
}

//设置初始选中行为当前值
- (void)initSelectRowWithPickerView:(UIPickerView *)pickerView
{
    if (self.option == CRPC_60EDeviceMenuOptionLowSpO2)
        [pickerView selectRow:self.lowSpO2 - 80 inComponent:0 animated:YES];
    else if (self.option == CRPC_60EDeviceMenuOptionHightPr)
        [pickerView selectRow:self.highPr - 100 inComponent:0 animated:YES];
    else if (self.option == CRPC_60EDeviceMenuOptionLowPr)
        [pickerView selectRow:self.lowPr - 30 inComponent:0 animated:YES];
    else if (self.option == CRPC_60EDeviceMenuOptionSpot)
        [pickerView selectRow:self.spot - 1 inComponent:0 animated:YES];
    else if (self.option == CRPC_60EDeviceMenuOptionBeepOn)
        [pickerView selectRow:self.beepOn - 1 inComponent:0 animated:YES];
    else if (self.option == CRPC_60EDeviceMenuOptionRotateOn)
        [pickerView selectRow:self.rotateOn - 1 inComponent:0 animated:YES];
}

@end
