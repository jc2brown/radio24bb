
import numpy as np
import matplotlib.pyplot as plt



sample_rate  = 100e6
test_duration = 0.0005


t = np.linspace(0, test_duration, sample_rate*test_duration)

iq_freq = 1.7e6

i_mod_freq = 37e3
q_mod_freq = 5.9e3


i_carrier = np.sin(2*3.14159*iq_freq*t)
q_carrier = np.cos(2*3.14159*iq_freq*t)


i_mod = np.sin(2*3.14159*i_mod_freq*t)
q_mod = np.cos(2*3.14159*q_mod_freq*t)

i_sig = np.multiply( i_carrier, i_mod )
q_sig = np.multiply( q_carrier, q_mod )




rf_signal = i_sig - 1j * q_sig #  np.random.uniform(-1.0, 1.0, len(t))




plt.axis()
plt.plot(t, rf_signal.real, t, rf_signal.imag)
plt.show()




fir_taps = [
	0, 0, 0, 0, 0,
	0, 0, -0.15, -0.2, -0.3,
	0.3, 0.2, 0.15, 0, 0,
	0, 0, 0, 0, 0,
	0
]

fir_depth = 21
fir_chain = np.zeros(fir_depth)
def fir(value):
	global fir_chain
	fir_chain = np.concatenate(([value], fir_chain[0:fir_depth-1]))
	return np.sum( np.multiply( fir_chain, fir_taps ) )


def iir(value):
	return 0


rf_signal = [ fir(s) for s in rf_signal ]

abs_peak = np.max(np.abs(rf_signal))

if (abs_peak == 0):
	print("signal is 0")
	exit()

# Normalize
# rf_signal = rf_signal / abs_peak

rf_fft = np.fft.fft(rf_signal)



rf_fft = rf_fft / np.max(rf_fft) 



rf_fft_mag = 20*np.log10(rf_fft)


rf_fft_phase = 180*rf_fft/3.14159
# f = np.linspace(0, sample_rate, len(rf_fft)) 
f = np.linspace(-sample_rate/2, sample_rate/2, len(rf_fft)) 





plt.axis()
# plt.plot(f, rf_fft.real, f, rf_fft.imag)
plt.plot(f, rf_fft_mag, f, rf_fft_phase)
plt.show()


