import string
from pylab import *

# File to write to
f = open('output.txt')
T = f.read()
f.close()

# Grid dimensions:
m = 1024
n = 1024

T = fromstring(T, sep=', ')
T = reshape(T, [m, n])

x, y = meshgrid(linspace(0, 1, m), linspace(0, 1, n))
contourf(x, y, T)
colorbar()
show()