

import numpy as np
import scipy.signal 
import matplotlib.pyplot as plt

test_freq = 10.7e6
test_duration = 10e-6
dac_sample_rate = 100e6  
global_sample_rate = 1e9  # Sets the simulation timestep


dac_timebase = np.linspace(0, test_duration, dac_sample_rate*test_duration)
dac_out = 127 * np.sin(dac_timebase * 2*3.14159*test_freq)

dac_out_sig_fcn = scipy.interpolate.interp1d(dac_timebase, dac_out, kind="previous")


global_timebase = np.linspace(0, test_duration, global_sample_rate*test_duration)
dac_out_signal = [ dac_out_sig_fcn(t) for t in global_timebase ]

# plt.axis()
# plt.stem(dac_timebase, dac_out, use_line_collection=True)
# plt.plot(global_timebase, dac_out_signal)
# plt.show()






# (b, a) = scipy.signal.ellip(9, 0.1, 80, [1.0e3, 1.5e3], btype="bandpass", analog=True, output="ba")
# (b, a) = scipy.signal.ellip(5, 0.1, 40, 22.0e6/global_sample_rate, btype="lowpass", analog=False, output="ba")
(b, a) = scipy.signal.ellip(5, 0.1, 40, [8.0e6/global_sample_rate, 14.0e6/global_sample_rate], btype="bandpass", analog=False, output="ba")

# w, h = scipy.signal.freqs(b, a, worN=np.logspace(0, 5, 10000))

w, h = scipy.signal.freqz(b, a, 1000)#, worN=np.logspace(0, 5, 10000))

plt.semilogx(w, 20 * np.log10(abs(h)))
plt.xlabel('Frequency')
plt.ylabel('Amplitude response [dB]')
plt.grid()
plt.show()



filtered_dac_signal = scipy.signal.lfilter(b, a, dac_out_signal)

# plt.axis()
# plt.plot(global_timebase, filtered_dac_signal)
# plt.show()




rf_fft = np.fft.rfft(filtered_dac_signal)
# rf_fft = rf_fft / np.max(rf_fft) 
rf_fft = 20*np.log10(rf_fft)
f = np.linspace(0, global_sample_rate/2, len(rf_fft)) 


plt.axis()
plt.plot(f, rf_fft)
plt.show()




