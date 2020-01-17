import numpy as np
import matplotlib.pyplot as plt



sample_rate  = 100e6
test_duration = 0.0005


t = np.linspace(0, test_duration, sample_rate*test_duration)


rf_signal = np.random.uniform(-1.0, 1.0, len(t))


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

rf_fft = np.fft.rfft(rf_signal)
rf_fft = rf_fft / np.max(rf_fft) 
rf_fft = 20*np.log10(rf_fft)
f = np.linspace(0, sample_rate, len(rf_fft)) 


plt.axis()
plt.plot(f, rf_fft)
plt.show()



