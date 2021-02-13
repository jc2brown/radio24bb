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



def CreateLogFile(logFile, logBuffer, bAppend=False):

    fileObject = open(logFile, "w" if bAppend==False else "a")
    fileObject.write(logBuffer) 
    fileObject.close()


def CreateLogDirectory():

    if sys.platform == 'linux2':
        logDirectory = os.path.dirname(__file__) + "/dataloopback_output/"
    elif sys.platform == 'win32':
        logDirectory = os.path.dirname(__file__) + "\\dataloopback_output\\"    
    if not os.path.exists(logDirectory):
        os.makedirs(logDirectory)

    return logDirectory


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
    
    print("\tOptionalFeatureSupport = %#06x" % cfg.OptionalFeatureSupport)
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


def DemoTurnOffPipeThreads():

    # Call before FT_Create when non-transfer functions will be called
    # Only needed for RevA chip (Firmware 1.0.2)
    # Not necessary starting RevB chip (Firmware 1.0.9)

    if sys.platform == 'linux2':

        conf = _ft.FT_TRANSFER_CONF();
        conf.wStructSize = ctypes.sizeof(_ft.FT_TRANSFER_CONF);
        conf.pipe[_ft.FT_PIPE_DIR_IN].fPipeNotUsed = True;
        conf.pipe[_ft.FT_PIPE_DIR_OUT].fPipeNotUsed = True;
        conf.pipe.fReserved = False;
        conf.pipe.fKeepDeviceSideBufferAfterReopen = False;
        for i in range(4):
            ftd3xx.setTransferParams(conf, i);

    return True


def DisplayTroubleshootingGuide(operation, devList, devIndex, cfg):

    fifoClock = ["100MHz", "66MHz"]
    fifoMode = ["245Mode", "600Mode"]
    ft60XType = "FT" + str(devList[devIndex].Type) + (" (32bit)" if devList[devIndex].Type == 601 else " (16bit)")
    print("NOTE: FPGA device should be using the %s sample for %s %s %s." %
        (operation, "FT" + str(devList[devIndex].Type), fifoClock[cfg.FIFOClock], fifoMode[cfg.FIFOMode]) )
    print("If test fails or hangs, below is the basic troubleshooting guide:")
    print("1) Unplug/plug device.");
    print("2) No other D3XX application is open.");
    print("3) FPGA image is for %s. And chip is configured using same mode." % fifoMode[cfg.FIFOMode])
    print("4) FPGA image is for %s. And PCB module has matching architecture." % ft60XType)
    print("5) Jumpers and switches are set correctly on FPGA and PCB module.")
    print("");


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


def CancelPipe(D3XX, pipe):

    if sys.platform == 'linux2':
        return D3XX.flushPipe(pipe)

    return D3XX.abortPipe(pipe)


def WriterThreadFunc(D3XX, pipe, buffer, size, iteration, qoutput):
    qoutput.put(True)
    return 

    result = True
    if sys.platform == 'linux2':
        pipe -= 0x02
    start = timeit.default_timer()  
    for iter in range(iteration):

        transferred = 0
        while (transferred != size):

            # write data to specified pipe  
            transferred += D3XX.writePipe(pipe, buffer, size - transferred)
            #print("Write[%#04X] iteration %d bytesTransferred %d" % 
            #    (pipe, iter, transferred))
        
            # check status of writing data
            status = D3XX.getLastError()
            if (status != 0):
                print("Write[%#04X] error status %d (%s)" %
                    (pipe, status, ftd3xx.getStrError(status)))
                CancelPipe(D3XX, pipe)
                result = False
                break

        if (result == False):
            break

    elapsed = timeit.default_timer() - start    
    print("W[%d] Transferring %d(%dx%d) bytes took %.2f sec. Rate is %d MBps." % 
        (pipe if sys.platform == 'linux2' else pipe-0x02, size*iteration, size, iteration, elapsed, size*iteration/(elapsed)/1024/1024))
    qoutput.put(result)


def ReaderThreadFunc(D3XX, pipe, size, read_queue):
    if sys.platform == 'linux2':
        pipe -= 0x82
    data = ctypes.c_buffer(size)        
    D3XX.setPipeTimeout(pipe, 1000)
    print("READING...")
    while True:
        transferred = D3XX.readPipe(pipe, data, size)
        print("#rx: %d" % transferred)
        
        if transferred > 0 and not read_queue.full():
            # read_queue.put_nowait(np.ctypeslib.as_array(data))
            # read_queue.put_nowait(np.ctypeslib.as_array(data).astype(np.uint8, order='C'))
            # v = np.frombuffer(data, dtype=np.int32)[0:]-128
            v = np.frombuffer(data, dtype=np.int8)[0::4]
            #v = v.astype(np.int32, order='C')
            # [ print(e) for e in v ]
            try:
                read_queue.put_nowait(v)
            except Exception:
                pass

            # Print text 
            # for d in data[0:transferred]:
            #     if d == 10:
            #         sys.stdout.write('\n')
            #     elif d != 0:
            #         sys.stdout.write(chr(d))

                


























# Known issues:
#


import timeit
import random
import os
import sys
import time
import ctypes
import cProfile

import pygame 
import numpy as np
import tkinter as tk
from tkinter import ttk



black = pygame.Color(0,0,0)
gray = pygame.Color(100,100,100)
yellow = pygame.Color(255,255,0)
cyan = pygame.Color(0,255,255)



class DataSource:

    IDLE = 0
    IF_TONE_8BIT = 1
    AF_TONE_16BIT = 2
    QUEUE_8BIT = 3

    def __init__(self, buffer_size):
        self.mode = DataSource.IDLE
        self.buffer_size = buffer_size
        self.sample_rate = None
        self.bit_depth = None
        self.queue = None
        self.get_buffer = None
        self.last_buffer = None


    def set_mode(self, mode, queue=None):
        if mode == DataSource.IF_TONE_8BIT:
            self.sample_rate = 100_000_000
            self.bit_depth = 8
            self.tone_freq = 10.7e6
            self.get_buffer = self.create_buffer
        if mode == DataSource.AF_TONE_16BIT:
            self.sample_rate = 38_000
            self.bit_depth = 16
            self.tone_freq = 0.1e3
            self.get_buffer = self.create_buffer
        if mode == DataSource.QUEUE_8BIT:
            self.bit_depth = 8
            self.queue = queue
            self.get_buffer = self.get_queued_buffer


    def create_buffer(self):

        buffer_duration = self.buffer_size / self.sample_rate
        t = np.linspace(0, buffer_duration, self.buffer_size, endpoint=False)

        random_phase_offset = random.random()
        maxval = 2 ** (self.bit_depth-1) - 1
        v = maxval * np.sin(2*3.14159*self.tone_freq*(t+random_phase_offset))

        if self.bit_depth == 8:
            v = v.astype(np.int8, order='C')
            return v
            return v.ctypes.data_as(ctypes.POINTER(ctypes.c_int8))

        if self.bit_depth == 16:
            v = v.astype(np.int16, order='C')
            return v
            return v.ctypes.data_as(ctypes.POINTER(ctypes.c_int16))
            

        print("DataSource.get_buffer: invalid bit_depth: %d" % (self.bit_depth))
        return None


    def get_queued_buffer(self):
        if not self.queue.empty(): 
            self.last_buffer = self.queue.get_nowait()
        return self.last_buffer

        



class ScopeChannel:

    def __init__(self, data_source, rgb):

        self.rgb = rgb
        self.trace_colour = rgb
        self.dim_trace_colour = tuple([c//2 for c in rgb])

        self.data_source = data_source

        self.xoffset = 0
        self.yoffset = 0

        self.temp_xoffset = 0
        self.temp_yoffset = 0

        self.xscale = 1.0
        self.yscale = 1.0

        self.button_states = [None, ButtonState(), ButtonState(), ButtonState()]

        self.trace_surface = None
        self.trace_points = None
        
        self.display_size = None
        self.trace_data_len = None



    def handle_event(self, event):

        if event.type == pygame.MOUSEBUTTONDOWN:
            if event.button >= 1 and event.button <= 3:
                self.button_states[event.button].dragging = True
                self.button_states[event.button].drag_start_pos = event.pos

        if event.type == pygame.MOUSEBUTTONUP:
            if event.button >= 1 and event.button <= 3:
                if self.button_states[event.button].dragging:
                    self.button_states[event.button].dragging = False
                    drag_stop = event.pos
                    rel = (drag_stop[0]-self.button_states[event.button].drag_start_pos[0], drag_stop[1]-self.button_states[event.button].drag_start_pos[1])
                    if event.button == 2:
                        self.xoffset += rel[0]
                        self.yoffset += rel[1]
                        self.temp_xoffset = 0
                        self.temp_yoffset = 0

        if event.type == pygame.MOUSEMOTION:
            buttons = [0, 0, 0]
            if hasattr(event, "buttons"):

                if isinstance(event.buttons, tuple):
                    buttons = event.buttons
                else:
                    if event.buttons & 0x100:
                        buttons[0] = 1
                    if event.buttons & 0x200:
                        buttons[1] = 1
                    if event.buttons & 0x400:
                        buttons[2] = 1


            if buttons[1] and self.button_states[2].dragging:
                button = 2
                drag_stop = event.pos
                rel = (
                    drag_stop[0]-
                    self.button_states[button].drag_start_pos[0], 
                    drag_stop[1]-
                    self.button_states[button].drag_start_pos[1])
                self.temp_xoffset = rel[0]
                self.temp_yoffset = rel[1]




    def on_trace_length_change(self):
        pass



    def on_display_size_change(self):
        pass



    # The following depends only on surface dimensions and trace buffer length, not on trace data
    def generate_time_points(self, display_size, trace_data_len):

        if display_size[0] <= 0 or display_size[1] <= 0: 
            return

        if display_size == self.display_size and trace_data_len == self.trace_data_len:
            return 

        self.display_size = display_size
        self.trace_data_len = trace_data_len

        self.t = np.linspace(0, 1, self.trace_data_len, endpoint=False)




    def generate_trace_surface(self, display_size, trace_data, trace_data_len):

        (display_width, display_height) = display_size

        if display_width <= 0 or display_height <= 0: 
            return

        self.generate_time_points(display_size, trace_data_len)

        self.x0 = self.xoffset + self.temp_xoffset + self.display_size[0]//2
        self.y0 = (display_size[1]//2 + self.yoffset + self.temp_yoffset)


        # The following depends on trace data in addition to surface dimensions and trace buffer length

        # Convert the received buffer to a numpy array
        v = trace_data
        # print(v.shape)
        # print(type(v[0]))
        non_negative = v >= 0
        # try:
        #     non_negative = v >= 0
        # except TypeError:
        #     v = np.ctypeslib.as_array(trace_data, (trace_data_len, ))
        #     non_negative = v >= 0
        
        # Find all positive zero crossing
        #non_negative = v >= 0
        negative = v < 0
        zero_crossings = np.where(np.bitwise_and(negative[1:], non_negative[:-1]))[0]

        if len(zero_crossings) == 0:
            print("NO ZERO CROSSINGS DETECTED")
            return

        # Set pos_zc_index to the index of the median crossing 
        pos_zc_index = zero_crossings[len(zero_crossings)//2]

        # interp is the linearly interpolated fraction of the sample period at which the signal crosses zero
        # This subsample correction factor is added as a horizontal offset to eliminate jitter in the displayed waverform
        # Reminder: this interpolation only works for a zero reference. Non-zero crossings require a more complex calculation
        dv = v[pos_zc_index+1] - v[pos_zc_index]
        interp = v[pos_zc_index] / dv
        #interp = 0   # disable zero cross interpolation

        # Calculate the (x, y) pixels that define the trace as displayed on screen
        x =  self.x0  + 1.5*self.display_size[0] * (self.t - (pos_zc_index - interp) / trace_data_len)
        y = v * (.8 * display_height / (2**self.data_source.bit_depth)) + self.y0
        self.trace_points = list(zip(x, y))



    def draw_traces(self, surface, frame_size):
        trace_data = self.data_source.get_buffer()
        if trace_data is None:
            return
        trace_data_len = self.data_source.buffer_size
        self.generate_trace_surface(frame_size, trace_data, trace_data_len) 
        if self.trace_points is None:
            print("YYY")
            return

        # Reference indicators

        pygame.draw.line(surface, self.dim_trace_colour, (0, self.y0), (self.display_size[0], self.y0), 1)
        pygame.draw.line(surface, self.dim_trace_colour, (self.x0, 0), (self.x0, self.display_size[1]), 1)


        pygame.draw.line(surface, self.dim_trace_colour, (self.x0-10, self.y0), (self.x0+10, self.y0), 1)
        pygame.draw.line(surface, self.dim_trace_colour, (self.x0, self.y0-10), (self.x0, self.y0+10), 1)


        pygame.draw.circle(surface, self.dim_trace_colour, (int(self.x0), int(self.y0)), 10, 1)

        # pygame.draw.lines(surface, self.trace_colour, False, self.trace_points, 2)
        pygame.draw.lines(surface, self.trace_colour, False, self.trace_points, 1)





class ButtonState:
    def __init__(self):
        self.dragging = False
        self.drag_start_pos = None



class ScopeAxis:


    def __init__(self, name):

        self.name = name


        left_margin = 120
        top_margin = 20
        right_margin = 20
        bottom_margin = 20

        self.margin = pygame.Rect((-left_margin, -top_margin), (left_margin+right_margin, top_margin+bottom_margin))

        self.grid_surface = None
        self.grid_size = None

        self.trace_surface = None
        self.trace_size = None

        self.channels = []

        self.absolute_region = None

        self.font = pygame.font.SysFont("Arial", 12, bold=True, italic=False)

        self.name_surface = self.font.render(self.name, False, (255, 255, 255))




    def add_channel(self, scope_channel):
        self.channels += [scope_channel]


    def handle_event(self, event):
        [ channel.handle_event(event) for channel in self.channels ]


    def draw(self, buffer, frame_size):
        self.draw_grid(buffer, frame_size)
        axis_bounds = pygame.Rect((-self.margin.left, -self.margin.top), (frame_size[0]-(self.margin.width), frame_size[1]-(self.margin.height)))
        trace_frame = buffer.subsurface(axis_bounds)
        [ channel.draw_traces(trace_frame, trace_frame.get_size()) for channel in self.channels ]
        buffer.blit(self.name_surface, (-self.margin.left, -self.margin.top - self.name_surface.get_size()[1]))



    # Generates a grid image which can be blitted onto the display 
    # - Creates a new pygame Surface with the same size as the active pygame display
    # - Draws a grid onto the surface 
    # - Saves the surface in self.grid_surface
    def generate_grid_surface(self, display_size):

        # display_size = self.pygame_display.get_size()
        (display_width, display_height) = display_size

        if self.grid_size == display_size:
            return

        print("Generating new grid surface, size %d x %d" % display_size) 

        self.grid_surface = pygame.Surface(display_size)
        self.grid_size = display_size



        grid_outline = pygame.Rect(
            (-self.margin.left, -self.margin.top), 
            (display_width-self.margin.width, display_height-self.margin.height)
        )


        num_x_ticks = 11
        x_ticks = np.linspace(grid_outline.left, grid_outline.right, num_x_ticks)

        for x_tick in x_ticks:
            pygame.draw.line(self.grid_surface, gray, (x_tick, grid_outline.top), (x_tick, grid_outline.bottom))


        num_y_ticks = 11
        y_ticks = np.linspace(grid_outline.top, grid_outline.bottom, num_y_ticks)

        for y_tick in y_ticks:
            pygame.draw.line(self.grid_surface, gray, (grid_outline.left, y_tick), (grid_outline.right, y_tick))


    def draw_grid(self, surface, frame_size):
        self.generate_grid_surface(frame_size)
        surface.blit(self.grid_surface, (0, 0))
        
        # TODO: maybe cache reference tick mark
        for channel in self.channels:
            x = -self.margin.left
            y = ((-self.margin.top)+(frame_size[1]-self.margin.bottom))//2 + channel.yoffset + channel.temp_yoffset
            pygame.draw.line(surface, channel.trace_colour, (x-6, y), (x-10, y), 7)
            pygame.draw.line(surface, channel.trace_colour, (x-4, y), (x-6, y), 5)
            pygame.draw.line(surface, channel.trace_colour, (x-2, y), (x-4, y), 3)
            pygame.draw.line(surface, channel.trace_colour, (x-0, y), (x-2, y), 1)








# The ScopeDisplay class contains the pygame display surface and all routines for drawing to it
# It expects to be embedded in a Tkinter UI
class ScopeDisplay:

    def __init__(self, tk_frame):
        self.tk_frame = tk_frame
        self.pygame_display = None    
        self.axes = { 
            "default" : ScopeAxis("default"),
            "secondary" : ScopeAxis("secondary") 
        }
        self.channels = []


    def add_channel(self, scope_channel, axes_names):
        [ self.axes[axis_name].add_channel(scope_channel) for axis_name in axes_names ]


    def handle_event(self, event):

        # print("ScopeDisplay.handle_event()")

        for axis in self.axes.values():
            if event.type == pygame.MOUSEBUTTONDOWN:
                if axis.absolute_region.collidepoint(event.pos):
                    print(event.pos)
                    axis.handle_event(event)

            if event.type == pygame.MOUSEBUTTONUP:
                axis.handle_event(event)

            if event.type == pygame.MOUSEMOTION:
                axis.handle_event(event)

        # [ axis.handle_event(event) for axis in self.axes.values() ]       


    def draw(self):
        frame_size = (self.tk_frame.winfo_width(), self.tk_frame.winfo_height())
        if self.pygame_display == None or self.pygame_display_size != frame_size:
            print("Creating display")
            # Probably shouldn't do this multiple times
            os.environ['SDL_WINDOWID'] = str(self.tk_frame.winfo_id())
            if sys.platform == "Windows":
                os.environ['SDL_VIDEODRIVER'] = 'windib'
            self.pygame_display = pygame.display.set_mode(frame_size)
            print(pygame.display.Info())
            self.pygame_display_size = frame_size
            pygame.init()
            pygame.display.init()
            pygame.display.update()

            self.buffer = self.pygame_display
            # self.buffer = pygame.Surface(self.pygame_display.get_size())
            self.display_size = self.pygame_display.get_size()

            self.axes["default"].absolute_region = pygame.Rect((0, 0), (self.display_size[0], self.display_size[1]//2))
            self.default_axis_subbuf = self.buffer.subsurface(self.axes["default"].absolute_region)
            self.default_axis_size = (self.display_size[0], self.display_size[1]//2)


            self.axes["secondary"].absolute_region = pygame.Rect((0, self.display_size[1]//2), (self.display_size[0], self.display_size[1]//2))
            self.secondary_axis_subbuf = self.buffer.subsurface(self.axes["secondary"].absolute_region)
            self.secondary_axis_size = (self.display_size[0], self.display_size[1]//2)


        # self.buffer.fill(black)   

        self.axes["default"].draw(self.default_axis_subbuf, self.default_axis_size)
        self.axes["secondary"].draw(self.secondary_axis_subbuf, self.secondary_axis_size)

        self.pygame_display.blit(self.buffer, (0, 0))
        pygame.display.flip()
        # pygame.display.update([self.axes["default"].absolute_region, self.axes["secondary"].absolute_region])
        # pygame.display.update(self.axes["secondary"].absolute_region)







class UI(tk.Tk):



    def tkinter_event_to_pygame_event(evt):
        print(evt)



    def post_tkinter_button_event_as_pygame_event(evt):
        UI.tkinter_event_to_pygame_event(evt)
        pygame.event.post(
            pygame.event.Event(
                pygame.MOUSEBUTTONDOWN, 
                pos=(evt.x, evt.y), 
                button=evt.num
            )
        )


    def post_tkinter_button_release_event_as_pygame_event(evt):
        UI.tkinter_event_to_pygame_event(evt)
        pygame.event.post(
            pygame.event.Event(
                pygame.MOUSEBUTTONUP, 
                pos=(evt.x, evt.y), 
                button=evt.num
            )
        )


    def post_tkinter_motion_event_as_pygame_event(evt):
        pygame.event.post(
            pygame.event.Event(
                pygame.MOUSEMOTION, 
                pos=(evt.x, evt.y), 
                rel=(0, 0), 
                button=evt.state
            )
        )



    def __init__(self, w, h):
        tk.Tk.__init__(self)
        self.geometry('%dx%d' % (w, h))

        self.button = ttk.Button(self, text="hello", command=lambda: print("BUTTON"))
        self.button.grid(row=1, column=1)

        # N.B. MUST set scope_frame row & col weights to 1 to force frame to fill available space 
        scope_frame_row = 2
        scope_frame_col = 1

        self.scope_frame = tk.Frame(self, width=300, height=300)
        self.scope_frame.grid(row=scope_frame_row, column=scope_frame_col, sticky=tk.NSEW)

        self.grid_rowconfigure(scope_frame_row, weight=1) 
        self.grid_columnconfigure(scope_frame_col, weight=1)


        self.update()


    def bind_interrupt_forwarders(self):
        # This forwarder used to be necessary but it seems that changing the order of something init-related  
        # to pygame and tkinter has caused pygame to correctly capture mouse events 
        pass
        # These must be bound only after pygame.display.init() has been called to avoid exceptions at startup when Tkinter catches mouse events before the pygame display exists
        # self.scope_frame.bind("<Button>", UI.post_tkinter_button_event_as_pygame_event)
        # self.scope_frame.bind("<ButtonRelease>", UI.post_tkinter_button_release_event_as_pygame_event)
        # self.scope_frame.bind("<Motion>", UI.post_tkinter_motion_event_as_pygame_event) # Mouse buttons are encoded in evt.state[10..8]




# def on_resize(event):
#   w, h = event.width, event.height
#   print("tk resize %d x %d" % (event.width, event.height))
    #draw(scope_ui, screen)




class App:

    static_inst = None

    def on_close():
        App.static_inst.alive = False


    def _del__(self):        
        self.D3XX.close()
        self.D3XX = 0    



    def open_usb_device(self):

        

        # check connected devices
        numDevices = ftd3xx.createDeviceInfoList()
        if numDevices == 0:
            print("ERROR: Please check environment setup! No device is detected.")
            return False
        print("Detected %d device(s) connected." % numDevices)
        devList = ftd3xx.getDeviceInfoList()    
        DisplayDeviceList(numDevices, devList)
        devIndex = SelectDevice(numDevices)
                    
        self.D3XX = ftd3xx.create(devIndex, _ft.FT_OPEN_BY_INDEX)
        if (self.D3XX is None):
            print("ERROR: Please check if another D3XX application is open!")
            return False

        # get the version numbers of driver and firmware
        DisplayVersions(self.D3XX)
        if (sys.platform == 'win32' and self.D3XX.getDriverVersion() < 0x01020006):
            print("ERROR: Old kernel driver version. Please update driver from Windows Update or FTDI website!")
            self.D3XX.close()
            return False

        # check if USB3 or USB2     
        devDesc = self.D3XX.getDeviceDescriptor()
        bUSB3 = devDesc.bcdUSB >= 0x300
        if (bUSB3 == False and transferSize==16*1024):
            transferSize=4*1024
        if (bUSB3 == False):
            print("Warning: Device is connected using USB2 cable or through USB2 host controller!")

        # validate chip configuration
        cfg = self.D3XX.getChipConfiguration()
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
        if (cfg.OptionalFeatureSupport & _ft.FT_CONFIGURATION_OPTIONAL_FEATURE_ENABLENOTIFICATIONMESSAGE_INCHALL):
            print("invalid chip configuration: notification callback is set")   
            self.D3XX.close()
            return False

        return True


        


    def start_usb_read_thread(self, channel, packet_size):
        threadReader = threading.Thread(target = ReaderThreadFunc, args = (self.D3XX, 0x82 + channel, packet_size, self.ch1_read_queue))
        threadReader.start()




    def __init__(self):

        self.ch1_read_queue = queue.Queue(3)
        
        self.usb_device_opened = self.open_usb_device()
        if not self.usb_device_opened:
            print("Failed to open USB device")
            return
        
        self.start_usb_read_thread(0, 1024)



        pygame.font.init()

        App.static_inst = self
        self.ui = UI(1200, 1000)





        # self.ch1_data_source = DataSource(2048)
        # self.ch1_data_source.set_mode(DataSource.AF_TONE_16BIT)
        self.ch1_data_source = DataSource(256)
        self.ch1_data_source.set_mode(DataSource.QUEUE_8BIT, self.ch1_read_queue)

        self.ch2_data_source = DataSource(100)
        self.ch2_data_source.set_mode(DataSource.IF_TONE_8BIT)

        self.scope_display = ScopeDisplay(self.ui.scope_frame)

        ch1 = ScopeChannel(self.ch1_data_source, yellow)
        ch2 = ScopeChannel(self.ch2_data_source, cyan)

        self.scope_display.add_channel(ch1, ["default"])
        self.scope_display.add_channel(ch2, ["secondary"])

        # ui = UI(500, 500)
        self.ui.bind_interrupt_forwarders()
        # self.ui.scope_frame.bind("<Configure>", on_resize)

        self.ui.protocol("WM_DELETE_WINDOW", App.on_close)
        self.alive = True


    def pygame_draw(self):
        self.pygame_display.fill(pygame.Color(200,200,200))





    def run(self):

        last_fps_report_time = 0
        fps_accum = 0
        fps_accum_count = 0

        clock = pygame.time.Clock()
        while self.alive:
            clock.tick()
            fps_accum += clock.get_fps()
            fps_accum_count += 1
            now = time.time()
            if now - last_fps_report_time >= 1.0:
                print("%4.01f FPS" % (fps_accum / fps_accum_count))
                last_fps_report_time = now
                fps_accum = 0
                fps_accum_count = 0

            self.scope_display.draw()
            self.ui.update_idletasks()
            self.ui.update()


            events = pygame.event.get()
            for event in events:

                if event.type == pygame.VIDEORESIZE:
                    print("RESIZE %d x %d" % event.size)

                if event.type == pygame.MOUSEBUTTONDOWN:
                    self.scope_display.handle_event(event)

                if event.type == pygame.MOUSEBUTTONUP:
                    self.scope_display.handle_event(event)

                if event.type == pygame.MOUSEMOTION:
                    self.scope_display.handle_event(event)




        self.ui.destroy()
        pygame.quit()







import multiprocessing as mp


def foo(q):
    q.put('hello')


if __name__ == "__main__":
    ctx = mp.get_context('spawn')
    q = ctx.Queue()
    p = ctx.Process(target=foo, args=(q,))
    p.start()
    print(q.get())
    p.join()







    app = App()

    app.run()
    # cProfile.run("app.run")

    del app
    #sys.exit() # Why does this throw an exception now?
    os._exit(0) # This exits cleanly (AFAIK?)
    # Why doesn't the program terminate without an exit call under Sublime?













