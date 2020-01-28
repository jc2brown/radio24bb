import numpy as np
import matplotlib.pyplot as plt


sample_rate  = 100e6
test_duration = 0.0005

t = np.linspace(0, test_duration, sample_rate*test_duration)

modulating_signal = np.sin(t*2*3.14159*100e3)
carrier_signal = np.sin(t*2*3.14159*10.7e6)

rf_signal = np.multiply(carrier_signal, modulating_signal)

# rf_fft = np.concatenate( (np.fft.rfft(rf_signal),  np.zeros(len(rf_signal)//2)) )
rf_fft = np.fft.rfft(rf_signal)
rf_fft = rf_fft / np.max(rf_fft)
rf_fft = 20*np.log10(rf_fft)
f = np.linspace(0, sample_rate/2, len(rf_fft)) 

plt.axis()
plt.plot(f, rf_fft)
plt.show()
