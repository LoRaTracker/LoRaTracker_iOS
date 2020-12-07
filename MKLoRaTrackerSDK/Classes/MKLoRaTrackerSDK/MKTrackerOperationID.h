
typedef NS_ENUM(NSInteger, mk_taskOperationID) {
    mk_defaultTaskOperationID,
    
#pragma mark - Read
    mk_taskReadBatteryPowerOperation,       //电池电量
    mk_taskReadManufacturerOperation,       //读取厂商信息
    mk_taskReadDeviceModelOperation,        //读取产品型号
    mk_taskReadHardwareOperation,           //读取硬件类型
    mk_taskReadSoftwareOperation,           //读取软件版本
    mk_taskReadFirmwareOperation,           //读取固件版本
    
    mk_taskReadProximityUUIDOperation,      //Proximity UUID
    mk_taskReadMajorOperation,              //major
    mk_taskReadMinorOperation,              //minor
    mk_taskReadMeasuredPowerOperation,      //RSSI@1m
    mk_taskReadTxPowerOperation,            //tx power
    mk_taskReadBroadcastIntervalOperation,  //广播间隔
    mk_taskReadDeviceNameOperation,         //读取设备广播名称
    mk_taskReadValidBLEDataFilterIntervalOperation,        //读取扫描有效数据筛选间隔
    mk_taskReadScanWindowDataOperation,     //读取扫描窗口时间
    mk_taskReadConnectableStatusOperation,  //读取设备的可连接状态
    mk_taskReadMacFilterStatusOperation,    //读取过滤Mac地址规则
    mk_taskReadFilterRssiValueOperation,    //读取过滤设备的RSSI
    mk_taskReadAdvNameFilterStatusOperation,   //读取过滤设备的名称
    mk_taskReadMajorFilterStateOperation,   //读取过滤设备的Major范围
    mk_taskReadMinorFilterStateOperation,   //读取过滤设备的Minor范围
    mk_taskReadAlarmTriggerRssiOperation,   //读取报警RSSI值
    mk_taskReadLoRaReportingIntervalOperation,  //读取扫描数据定时上报时间
    mk_taskReadAlarmNotificationOperation,      //读取报警提醒功能
    mk_taskReadLoraWANModemOperation,           //读取lora入网类型
    mk_taskReadDevEUIOperation,                 //读取DevEUI
    mk_taskReadAPPEUIOperation,                 //读取AppEUI
    mk_taskReadAPPKeyOperation,                 //读取AppKey
    mk_taskReadDevAddrOperation,                //读取DevAddr
    mk_taskReadAPPSKeyOperation,                //读取AppSKey
    mk_taskReadNwkSKeyOperation,                //读取NwkSKey
    mk_taskReadRegionOperation,                 //读取Region
    mk_taskReadLoRaMessageTypeOperation,        //读取上行消息类型
    mk_taskReadCHDataOperation,                 //读取CH数据
    mk_taskReadDRDataOperation,                 //读取DR数据
    mk_taskReadADRDataOperation,                //读取ADR数据
    mk_taskReadLoRaNetworkStatusOperation,      //读取lorawan网络状态
    mk_taskReadMacAddressOperation,             //读取MAC地址
    mk_taskReadFilterRawDatasOperation,         //读取Raw广播过滤规则
    mk_taskReadPWMDataOperation,                //读取PWM占空比
    mk_taskReadDurationOfVibrationOperation,    //读取马达震动时长
    mk_taskReadVibrationCycleOperation,         //读取马达周期时长
    
#pragma mark - Config
    mk_taskConfigProximityUUIDOperation,    //设置UUID
    mk_taskConfigMajorOperation,            //设置Major
    mk_taskConfigMinorOperation,            //设置Minor
    mk_taskConfigMeasuredPowerOperation,    //设置RSSI@1m
    mk_taskConfigTxPowerOperation,          //设置Tx Power
    mk_taskConfigAdvIntervalOperation,      //设置广播间隔
    mk_taskConfigDeviceNameOperation,       //设置广播名称
    mk_taskConfigPasswordOperation,               //密码
    mk_taskConfigFactoryDataResetOperation,       //恢复出厂设置
    mk_taskConfigValidBLEDataFilterIntervalOperation,       //设置扫描有效数据筛选间隔
    mk_taskConfigScannWindowOperation,          //设置扫描开关与扫描窗口
    mk_taskConfigConnectableStatusOperation,    //设置设备蓝牙连接状态
    mk_taskConfigMacFilterStatusOperation,      //设置过滤MAC
    mk_taskConfigFilterRssiValueOperation,      //设置过滤RSSI
    mk_taskConfigAdvNameFilterStatusOperation,  //设置过滤设备名称
    mk_taskConfigMajorFilterStateOperation,     //设置过滤Major范围
    mk_taskConfigMinorFilterStateOperation,     //设置过滤Minor范围
    mk_taskConfigAlarmTriggerRssiOperation,     //设置报警RSSI值
    mk_configLoRaReportingIntervalOperation,    //设置扫描数据定时上报时间
    mk_taskConfigAlarmNotificationOperation,    //设置报警提醒功能
    mk_configLoraWANModemOperation,             //设置Lora入网类型
    mk_configDevEUIOperation,                   //设置DevEUI
    mk_configAppEUIOperation,                   //设置AppEUI
    mk_configAppKeyOperation,                   //设置AppKey
    mk_configDevAddrOperation,                  //设置DevAddr
    mk_configAppSKeyOperation,                  //设置AppSKey
    mk_configNwkSKeyOperation,                  //设置NwkSKey
    mk_configRegionOperation,                   //设置Region
    mk_configMessageTypeOperation,              //设置上行消息类型
    mk_configCHDataOperation,                   //设置CH范围
    mk_configDRDataOperation,                   //设置DR范围
    mk_configADRDataOperation,                  //设置ADR状态
    mk_taskConfigDateOperation,             //设置时间
    mk_configLoRaWANConnectNetWorkOperation,    //设置入网请求
    mk_taskConfigPowerOffOperation,             //设备关机
    mk_taskConfigRawFilterOperation,
    mk_taskConfigPWMDataOperation,              //配置PWM占空比
    mk_taskConfigDurationOfVibrationOperation,  //配置马达震动时长
    mk_taskConfigVibrationCycleOperation,       //配置马达周期时长
};
