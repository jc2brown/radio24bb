import numpy as np
import matplotlib.pyplot as plt


sample_rate  = 100e6
test_duration = 0.0005

t = np.linspace(0, test_duration, sample_rate*test_duration)

rf_signal = np.random.uniform(-1.0, 1.0, len(t))
rf_fft = np.fft.rfft(rf_signal)
rf_fft = rf_fft / np.max(rf_fft)
rf_fft = 20*np.log10(rf_fft)
f = np.linspace(0, sample_rate, len(rf_fft)) 

plt.axis()
plt.plot(f, rf_fft)
plt.show()
