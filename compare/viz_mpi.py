from pylab import *

A = fromfile('final.dat', sep = " ")
A = array(A)

m = A[0]; n = A[1]

A = reshape(A[2:], [m, n])




x, y = meshgrid(linspace(0, 1, m), linspace(0, 1, n))
contourf(x, y, A)
colorbar()
show()
