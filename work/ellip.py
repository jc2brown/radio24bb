import numpy as np
import scipy.signal 
import matplotlib.pyplot as plt





# (z, p, k) = scipy.signal.ellip(6, 0.5, 50, 0.2, btype="low", analog=False, output="zpk")
# print("z:", z)
# print("p:", p)
# print("k:", k)


# sos = scipy.signal.zpk2sos(z, p, k, pairing="nearest")

# print(sos)

# sample_rate = 10000
# sig_in_len = 100000
# t = np.linspace(0, 1, sig_in_len)
# sig_in = np.random.uniform(-1.0, 1.0, sig_in_len)
# sig_out = scipy.signal.sosfilt(sos, sig_in)



# (b, a) = scipy.signal.ellip(9, 0.1, 80, [1.0e3, 1.5e3], btype="bandpass", analog=True, output="ba")
(b, a) = scipy.signal.butter(9, [1.0e3, 1.5e3], btype="bandpass", analog=True, output="ba")

w, h = scipy.signal.freqs(b, a, worN=np.logspace(0, 5, 10000))



plt.semilogx(w, 20 * np.log10(abs(h)))
plt.xlabel('Frequency')
plt.ylabel('Amplitude response [dB]')
plt.grid()
plt.show()






# rf_fft = np.fft.rfft(sig_out)
# rf_fft = rf_fft / np.max(rf_fft) 
# rf_fft = 20*np.log10(rf_fft)
# f = np.linspace(0, sample_rate, len(rf_fft)) 

# plt.axis()
# plt.plot(np.linspace(0, sample_rate/2, len(rf_fft)), rf_fft)
# plt.show()

