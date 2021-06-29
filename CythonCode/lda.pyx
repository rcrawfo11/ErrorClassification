from cython.view cimport array as cvarray
import numpy as np

class ourLDA(object):

  def __init__(self, verbose=False):
    # Memoryview on a NumPy array
    #, int size, int numFeat, data, v
    # narr = np.arange(27, dtype=np.dtype("i")).reshape((3, 3, 3))
    # cdef int [:, :, :] narr_view = narr
    cdef int size, numFeat
    # cdef int self.numFeat = numFeat
    # self.data = data
