import numpy as np
from scipy import signal


# sos = signal.ellip(15, 0.5, 60, (0.2, 0.4), btype='bandpass', output='sos')

sos = [[0.857, -0.857, 0, 1, -0.714, 0]]
sos = [[0.950, -0.750, 0, 1, -0.000, 0]]
sos = [[2.3750, -1.875, 0, 1, -0.5000, 0]]
sos = [[0.9, -0.75, 0, 1, -0.6000, 0]]
sos = [[1.5, -1.1, 0, 1, -0.4000, 0]]
sos = [[0.950, -0.700, 0, 1, -0.100, 0]]
sos = [[0.950, -0.600, 0, 1, -0.200, 0]]
sos = [[0.950, -0.650, 0, 1, -0.150, 0]]


w, h = signal.sosfreqz(sos, worN=1500)


import matplotlib.pyplot as plt
plt.subplot(2, 1, 1)
db = 20*np.log10(np.maximum(np.abs(h), 1e-5))
# plt.plot(w/np.pi, db)
plt.plot(np.log10(w/np.pi), db)
plt.ylim(-20, 20)
plt.grid(True)
plt.yticks([-20, -10, 0, 10, 20])
plt.ylabel('Gain [dB]')
plt.title('Frequency Response')
plt.subplot(2, 1, 2)
plt.plot(w/np.pi, np.angle(h))
plt.grid(True)
plt.yticks([-np.pi, -0.5*np.pi, 0, 0.5*np.pi, np.pi], [r'$-\pi$', r'$-\pi/2$', '0', r'$\pi/2$', r'$\pi$'])
plt.ylabel('Phase [rad]')
plt.xlabel('Normalized frequency (1.0 = Nyquist)')
plt.show()