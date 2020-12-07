
@protocol MKDeviceSettingHeaderDelegate <NSObject>

/**
 模式选择
 
 @param item 0:abp,1:otaa
 */
- (void)modemItemSelected:(NSInteger)item;

@end

@protocol MKDeviceSettingRegionDelegate <NSObject>

- (void)deviceRegionChanged:(NSInteger)region;

@end

@protocol MKDeviceSettingDeviceTypeDelegate <NSObject>

- (void)deviceTypeChanged:(NSInteger)deviceType;

@end

@protocol MKDeviceSettingReportIntervalDelegate <NSObject>

- (void)deviceReportIntervalChanged:(NSInteger)interval;

@end

@protocol MKDeviceSettingCDOptionsDelegate <NSObject>

- (void)deviceCDOptionsChanged:(NSInteger)row valueL:(NSInteger)valueL valueH:(NSInteger)valueH;

@end

@protocol MKDeviceSettingPowerDelegate <NSObject>

- (void)devicePowerValueChanged:(NSInteger)power;

@end

@protocol MKDeviceSettingResetDelegate <NSObject>

- (void)resetButtonAction;

@end


@protocol MKDeviceSettingMessageTypeDelegate <NSObject>

- (void)messageTypeChanged:(NSInteger)messageType;

@end


@protocol MKDeviceSettingTextCellDelegate <NSObject>

- (void)MKDeviceTextCellValueChanged:(NSInteger)index value:(NSString *)value;

@end
