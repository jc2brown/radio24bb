import ftd3xx
import sys
if sys.platform == 'win32':
    import _ftd3xx_win32 as _ft
elif sys.platform == 'linux2':
    import _ftd3xx_linux as _ft
if sys.version_info.major == 3:
    import queue
elif sys.version_info.major == 2:
    import Queue as queue
import datetime
import time
import timeit
import binascii
import itertools
import ctypes
import threading
import logging
import os
import platform
import argparse
import random
import string




def GetOSVersion():

    if (sys.platform == 'win32'):
        verList = [("Windows 7", 6, 1), ("Windows 8", 6, 2), ("Windows 8.1", 6, 3), ("Windows 10", 10, 0)]
        ver = sys.getwindowsversion()
        elemList = [elem for index, elem in enumerate(verList) if ver.major == elem[1] and ver.minor == elem[2]]
        return elemList[0][0] if len(elemList) == 1 else os.getenv("OS")

    return os.uname()[0]


def GetOSArchitecture():

    if (sys.platform == 'win32'):
        return os.environ["PROCESSOR_ARCHITECTURE"]

    return platform.machine()


def GetComputername():

    if (sys.platform == 'win32'):
        return os.getenv('COMPUTERNAME')

    return platform.node()


def GetUsername():

    if (sys.platform == 'win32'):
        return os.getenv('USERNAME')

    import pwd
    return pwd.getpwuid(os.getuid())[0]



def DisplayDeviceList(numDevices, devList):

    for i in range(numDevices):
        print("DEVICE[%d]" % i)
        print("\tFlags = %d" % devList[i].Flags)
        print("\tType = %d" % devList[i].Type)
        print("\tID = %#010X" % devList[i].ID)
        print("\tLocId = %d" % devList[i].LocId)
        print("\tSerialNumber = %s" % devList[i].SerialNumber.decode('utf-8'))
        print("\tDescription = %s" % devList[i].Description.decode('utf-8'))


def DisplayVersions(D3XX):

    print("Library Version: %#08X" % D3XX.getLibraryVersion())  
    print("Driver Version: %#08X" % D3XX.getDriverVersion())    
    print("Firmware Version: %#08X" % D3XX.getFirmwareVersion())    




def DisplayChipConfiguration(cfg):

    print("Chip Configuration:")
    print("\tVendorID = %#06x" % cfg.VendorID)
    print("\tProductID = %#06x" % cfg.ProductID)
    
    print("\tStringDescriptors")
    STRDESC = GetInfoFromStringDescriptor(cfg.StringDescriptors)
    print("\t\tManufacturer = %s" % STRDESC['Manufacturer'])
    print("\t\tProductDescription = %s" % STRDESC['ProductDescription'])
    print("\t\tSerialNumber = %s" % STRDESC['SerialNumber'])
    
    print("\tInterruptInterval = %#04x" % cfg.bInterval)
    
    bSelfPowered = "Self-powered" if (cfg.PowerAttributes & _ft.FT_SELF_POWERED_MASK) else "Bus-powered"
    bRemoteWakeup = "Remote wakeup" if (cfg.PowerAttributes & _ft.FT_REMOTE_WAKEUP_MASK) else ""
    print("\tPowerAttributes = %#04x (%s %s)" % (cfg.PowerAttributes, bSelfPowered, bRemoteWakeup))
    
    print("\tPowerConsumption = %#04x" % cfg.PowerConsumption)
    print("\tReserved2 = %#04x" % cfg.Reserved2)

    fifoClock = ["100 MHz", "66 MHz"]   
    print("\tFIFOClock = %#04x (%s)" % (cfg.FIFOClock, fifoClock[cfg.FIFOClock]))
    
    fifoMode = ["245 Mode", "600 Mode"]
    print("\tFIFOMode = %#04x (%s)" % (cfg.FIFOMode, fifoMode[cfg.FIFOMode]))
    
    channelConfig = ["4 Channels", "2 Channels", "1 Channel", "1 OUT Pipe", "1 IN Pipe"]
    print("\tChannelConfig = %#04x (%s)" % (cfg.ChannelConfig, channelConfig[cfg.ChannelConfig]))
    


    #    
    # Optional features
    #
    print("\tOptionalFeatureSupport = %#06x" % cfg.OptionalFeatureSupport)
   
    print_optional_feature_details = True

    if print_optional_feature_details:

	    print("\t\tBatteryChargingEnabled  : %d" % 
	        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLEBATTERYCHARGING) >> 0) )

	    print("\t\tDisableCancelOnUnderrun : %d" % 
	        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_DISABLECANCELSESSIONUNDERRUN) >> 1) )
	    
	    print("\t\tNotificationEnabled     : %d %d %d %d" %
	        (((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLENOTIFICATIONMESSAGE_INCH1) >> 2),
	        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLENOTIFICATIONMESSAGE_INCH2) >> 3),
	        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLENOTIFICATIONMESSAGE_INCH3) >> 4),
	        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLENOTIFICATIONMESSAGE_INCH4) >> 5) ))
	        
	    print("\t\tUnderrunEnabled         : %d %d %d %d" %
	        (((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_DISABLEUNDERRUN_INCH1) >> 6),
	        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_DISABLEUNDERRUN_INCH2) >> 7),
	        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_DISABLEUNDERRUN_INCH3) >> 8),
	        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_DISABLEUNDERRUN_INCH4) >> 9) ))
	        
	    print("\t\tEnableFifoInSuspend     : %d" % 
	        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_SUPPORT_ENABLE_FIFO_IN_SUSPEND) >> 10) )
	    
	    print("\t\tDisableChipPowerdown    : %d" % 
	        ((cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_SUPPORT_DISABLE_CHIP_POWERDOWN) >> 11) )
    



    print("\tBatteryChargingGPIOConfig = %#02x" % cfg.BatteryChargingGPIOConfig)
    
    print("\tFlashEEPROMDetection = %#02x (read-only)" % cfg.FlashEEPROMDetection)
    print("\t\tCustom Config Validity  : %s" % 
        ("Invalid" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_CUSTOMDATA_INVALID)) else "Valid") )
    print("\t\tCustom Config Checksum  : %s" % 
        ("Invalid" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_CUSTOMDATACHKSUM_INVALID)) else "Valid") )
    print("\t\tGPIO Input              : %s" % 
        ("Used" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_GPIO_INPUT)) else "Ignore") )
    if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_GPIO_INPUT)):
        print("\t\tGPIO 0                  : %s" % 
            ("High" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_GPIO_0)) else "Low") )
        print("\t\tGPIO 1                  : %s" % 
            ("High" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_GPIO_1)) else "Low") )
    print("\t\tConfig Used             : %s" % 
        ("Custom" if (cfg.FlashEEPROMDetection & (1<<_ft.FT_CONFIGURATION_FLASH_ROM_BIT_CUSTOM)) else "Default") )
        
    print("\tMSIO_Control = %#010x" % cfg.MSIO_Control)
    print("\tGPIO_Control = %#010x" % cfg.GPIO_Control)
    print("")




def GetInfoFromStringDescriptor(stringDescriptor):

    desc = bytearray(stringDescriptor)
    
    len = int(desc[0])
    Manufacturer = ""
    for i in range(2, len, 2):
        Manufacturer += "{0:c}".format(desc[i])
    desc = desc[len:]

    len = desc[0]
    ProductDescription = ""
    for i in range(2, len, 2):
        ProductDescription += "{0:c}".format(desc[i])
    desc = desc[len:]

    len = desc[0]
    SerialNumber = ""
    for i in range(2, len, 2):
        SerialNumber += "{0:c}".format(desc[i])
    desc = desc[len:]
    
    return {'Manufacturer': Manufacturer,
        'ProductDescription': ProductDescription,
        'SerialNumber': SerialNumber}


def SelectDevice(numDevices):

    index = 0
    if numDevices == 1:
        return index

    # prompt user to select the index of the device to test
    while True:
        index = input("Select the index of the device to test (0-{0}): ".format(numDevices))
        try:
            index = int(index)
        except:
            continue        
        if (index >= numDevices):
            continue
        break

    print("Device at index %d will be used." % index)   
    print("")
    return index






def usb_main():
    # ftd3xx.raiseExceptionOnError(True)


    # check connected devices
    numDevices = ftd3xx.createDeviceInfoList()
    if (numDevices == 0):
        print("ERROR: Please check environment setup! No device is detected.")
        return False
    print("Detected %d device(s) connected." % numDevices)
    devList = ftd3xx.getDeviceInfoList()    
    DisplayDeviceList(numDevices, devList)
    devIndex = SelectDevice(numDevices)
                
    # open the first device (index 0)
    D3XX = ftd3xx.create(devIndex, _ft.FT_OPEN_BY_INDEX)
    if (D3XX is None):
        print("ERROR: Please check if another D3XX application is open!")
        return False

    # get the version numbers of driver and firmware
    DisplayVersions(D3XX)
    if (sys.platform == 'win32' and D3XX.getDriverVersion() < 0x01020006):
        print("ERROR: Old kernel driver version. Please update driver from Windows Update or FTDI website!")
        D3XX.close()
        return False

    # check if USB3 or USB2     
    devDesc = D3XX.getDeviceDescriptor()
    bUSB3 = devDesc.bcdUSB >= 0x300
    if (bUSB3 == False and transferSize==16*1024):
        transferSize=4*1024
    if (bUSB3 == False):
        print("Warning: Device is connected using USB2 cable or through USB2 host controller!")

    # validate chip configuration
    cfg = D3XX.getChipConfiguration()
    DisplayChipConfiguration(cfg)
    numChannels = [4, 2, 1, 0, 0]
    numChannels = numChannels[cfg.ChannelConfig]
    if (numChannels == 0):
        numChannels = 1
        if (cfg.ChannelConfig == _ft.FT_CONFIGURATION_CHANNEL_CONFIG_1_OUTPIPE):
            bWrite = True
            bRead = False
        elif (cfg.ChannelConfig == _ft.FT_CONFIGURATION_CHANNEL_CONFIG_1_INPIPE):
            bWrite = False
            bRead = True
    if (cfg.OptionalFeatureSupport &
        _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLENOTIFICATIONMESSAGE_INCHALL):
        print("invalid chip configuration: notification callback is set")   
        D3XX.close()
        return False




    # process loopback for all channels
    # error = ProcessStreaming(D3XX, channelsToTest, transferSize, transferIteration, bWrite, bRead, bStressTest)
    # if error:
    #     DisplayTroubleshootingGuide("STREAMER", devList, devIndex, cfg)

    D3XX.close()
    D3XX = 0    
    
    return True









if __name__ == "__main__":

    print("**************************************************************")
    print("RADIO24BB SCOPE")
    print("WORKSTATION: %s" % GetComputername())
    print("OS VERSION: %s,%s" % (GetOSVersion(), GetOSArchitecture()))
    print("OPERATOR: %s" % GetUsername())
    print("DATE: %s" % datetime.datetime.now().strftime("%Y-%m-%d"))
    print("TIME: %s" % datetime.datetime.now().strftime("%H:%M:%S"))
    print("PYTHON VERSION: %d.%d.%d" % (sys.version_info.major, sys.version_info.minor, sys.version_info.micro))
    print("**************************************************************")
    print("")
        

    parser = argparse.ArgumentParser(description="scope application")
    parser.add_argument('-c', '--channels', type=int, nargs='*', default=[0], help="channel/s to test (0-3)")
    parser.add_argument('-s', '--size', type=int, default=1024, help="data transfer size")
    parser.add_argument('-i', '--iteration', type=int, default=1, help="number of iterations to transfer size")
    parser.add_argument('-r', '--read', action="store_false", help="disable read operation")
    parser.add_argument('-w', '--write', action="store_false", help="disable write operation")
    parser.add_argument('-t', '--stress', action="store_false", help="disable stress test, do one time transfer")   
    args = parser.parse_args()
    
    usb_main()






