import numpy as np
import pandas as pa

class DataReader(object):

    def __init__(self, filenames, freq_file, labels = None):
        self.filenames = filenames
        self.numFiles = len(filenames)
        self.data, self.dataComplex, self.noError = self.readInFiles(filenames, updateFiles = False)
        self.freqList = pa.read_csv(freq_file).to_numpy()
        self.labels = labels
        self.train = None
        self.test = None
        self.fit = None
        self.fitval = None
        self.residuals = None

    def readInFiles(self, addFile, updateFiles = True):
        """
        Reads in files listed in addFile, adds those to the filenames

        """
        #overwrite in files

        raise "TODO"

    def getRandomSample(self, represent = True):
        """
        represent: get a represenetative sample

        """
        #overwrite

    def getData(self):
        return self.data

    def getFilenames(self):
        return self.filenames

    def getLabels(self):
        return self.labels
