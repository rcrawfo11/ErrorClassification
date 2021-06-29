import scipy as sp
import numpy as np
import random
import math, cmath
import lmfit
import pylab
from DataReader import *

class PaperData(DataReader):

   def readInFiles(self, addFile, updateFiles = True):
       """
       Reads in data from csv files, updates data array.

       Parameters:
       self- PaperData object
       addFile - list of files to add (must be in the form of a list of strings)
       updateFiles - add to final data array
       """
       # Read in data and convert to numpy array
       finalArrayStr = pa.read_csv(self.filenames[0]).to_numpy()
       noErrorStr = pa.read_csv(self.filenames[0]).to_numpy()
       numFiles = len(addFile)
       for i in range(numFiles-1):
           tempArray = pa.read_csv(self.filenames[i+1]).to_numpy()
           finalArrayStr = np.append(finalArrayStr, tempArray.copy(), axis = 1)
       #Change data from string to complex number
       shape = finalArrayStr.shape
       row = shape[0]
       col = shape[1]
       finalArrayComplex = np.zeros([row-2, col], dtype = complex)
       noErrorComplex = np.zeros([noErrorStr.shape[0]-2, noErrorStr.shape[1]], dtype = complex)
       for i in range(row-2):
           for j in range(col):
               finalArrayComplex[i, j] = complex(finalArrayStr[i,j])
               if j < noErrorStr.shape[1]:
                   noErrorComplex[i, j] = complex(noErrorStr[i,j])

       return finalArrayStr.copy(), finalArrayComplex.copy(),  noErrorComplex.copy()

   def getRandomSample(self, percentSamp = 0.60, represent = True):
       """
       Function that breaks data into a train and test set randomly

       Parameters:
       Self - PaperData object
       percentSamp - the percentage of the data to sample as a float
       represent - whether or not to get a representative sample of the data (aka
       get a sample that has the same percentage of each type of error in the dataset)
       NOT IMPLEMENTED YET

       Returns:
       training  - sample to train on as complex numpy array
       test - sample to test on as complex numpy array
       trainingLabel  - labels for samples as numpy array of arrays (the two rows
       corresponds to the divide-and-conquer approach and the all-at-once approach
       respectively)
       testLabel - labels for samples as numpy array of arrays (the two rows
       corresponds to the divide-and-conquer approach and the all-at-once approach
       respectively)

       The paper used 60 and 40 percent

       TODO:
       Implement represantative sampling, which takes in columns from specific
       sets to make the data look like the real life distrubution
       """
       shape = self.data.shape
       row = shape[0]
       col = shape[1]
       samps = random.sample(range(col), int(col*percentSamp))
       samps.sort(reverse = True)
       test = self.data.copy()
       train =  test[:, samps[:]].copy()
       test = np.delete(test, samps[:], axis = 1)
       trainLabel = np.empty([2, int(col*percentSamp)])
       testLabel = np.array([2, col - int(col*percentSamp)])
       np.random.shuffle(np.transpose(test))
       self.trainLabel = train[row-2:row, :].copy()
       self.testLabel = test[row-2:row, :].copy()
       self.train = np.delete(train, [row-2, row-1], axis = 0)
       self.test = np.delete(test, [row-2, row-1], axis = 0)

       return self.test, self.train, self.testLabel, self.trainLabel

   def prepData(self):
        """
        Converts data from raw data to the features used in the article,
        check article for more specifics on what those features are supposed to
        be. There are 31 features in total.

        Parameters:
        self- paperData object

        Returns:
        features- np array containing the 31 features for each column

        TODO:
        Finish extracting features, current it's not functional
        """

        shape = self.dataComplex.shape
        row = shape[0]
        col = shape[1]

        shape_train = self.train.shape
        col_train = shape[1]

        #"fit" is an object of type MinimizerResult from the lmfit package
        # for a list of things you can do with it check out
        # https://lmfit.github.io/lmfit-py/fitting.html
        self.fit, self.residuals = self.coleModelFit()

        Rinf = self.fit.params['Rinf'].value
        Rnot = self.fit.params['Rnot'].value
        alpha = self.fit.params['alpha'].value
        tau = self.fit.params['tau'].value

        omega_c = 1/tau

        jOmegaTau = np.multiply(self.freqList,complex('j')*tau*2*math.pi)
        denom = 1 + np.power(jOmegaTau, alpha)
        self.fitval = (Rinf + np.multiply((Rnot-Rinf), 1/denom))
        fitval = self.fitval.copy()

        R_error = np.divide(self.dataComplex.real - fitval.real, self.dataComplex.real)

        X_error = np.divide(self.dataComplex.imag - fitval.imag, self.dataComplex.imag)

        G_error = np.divide(self.dataComplex.real, (\
        np.power(self.dataComplex.real,2)+np.power(self.dataComplex.imag,2)))-\
        np.divide(fitval.real, (np.power(fitval.real,2)+np.power(fitval.imag,2)))
        G_error = np.divide(G_error, np.divide(self.dataComplex.real, (\
        np.power(self.dataComplex.real,2)+np.power(self.dataComplex.imag,2))))

        B_error = np.divide(-self.dataComplex.imag, (np.power(self.dataComplex.real,2) + np.power(self.dataComplex.imag,2)))\
        + np.divide(fitval.imag, (np.power(fitval.real,2)+np.power(fitval.imag,2)))
        B_error = np.divide(B_error, np.divide(-self.dataComplex.imag, (np.power(self.dataComplex.real,2) + np.power(self.dataComplex.imag,2))))

        z_mag_error = np.zeros(self.dataComplex.shape)
        z_phase_error = np.zeros(self.dataComplex.shape)
        for i in range(self.dataComplex.shape[0]):
            for j in range(self.dataComplex.shape[1]):
                z_mag_error[i, j] = (abs(self.dataComplex[i, j]) - abs(fitval[i]))/abs(self.dataComplex[i, j])
                z_phase_error[i, j] = (cmath.phase(self.dataComplex[i, j]) - cmath.phase(fitval[i]))/cmath.phase(self.dataComplex[i, j])

        #ωc: VLF (ω < ωc/5), LF (ωc/5 ≤ ω < ωc/2), MF (ωc/2 ≤ ω < 2ωc), HF (2ωc ≤ ω ≤ 5ωc), VHF (ω > 5ωc).
        omega_list = [omega_c/5, omega_c/2, 2*omega_c, 5*omega_c, inf]
        features = np.zeros([31, self.dataComplex.shape[1]])
        j = 0
        for i in range(5):
            start_index = j
            while self.freqList[j] < omega_list[i]:
                features[i, :] = np.add(features[i, :], R_error[j, :])
                features[i+5, :] = np.add(features[i+5, :], X_error[j, :])
                features[i+10, :] = np.add(features[i+10, :], G_error[j, :])
                features[i+15, :] = np.add(features[i+15, :], B_error[j, :])
                features[i+20, :] = np.add(features[i+20, :], z_mag_error[j, :])
                features[i+25, :] = np.add(features[i+25, :], z_phase_error[j, :])
                j += 1
            features[start_index: j, :] = np.divide(features[start_index: j, :], j - start_index)



   def objective(self, params, x, ydata):
       """
       Calculates objective function which is the error of Cole Function fit
       Data

       Parameters:
       Self - PaperData object
       params - Parameters object from lmfit
       x - frequency data in np array
       ydata - recorded data in numpy array

       Returns:
       error.view(np.float)- a numpy float array since complex arrays break
       everything

       link to how I decided this approach:
       https://lmfit.github.io/lmfit-py/faq.html?highlight=complex#how-can-i-fit
       -complex-data
       """
       Rinf = params['Rinf'].value
       Rnot = params['Rnot'].value
       alpha = params['alpha'].value
       tau = params['tau'].value

       error = np.zeros(ydata.shape, dtype = complex)
       jOmegaTau = np.multiply(x,complex('j')*tau*2*math.pi)

       denom = 1 + np.power(jOmegaTau, alpha)
       fitval = (Rinf + np.multiply((Rnot-Rinf), 1/denom))

       #For loop may be unnessary
       #error = np.subtract(ydata, (Rinf + (Rnot-Rinf)/denom))
       for i in range(ydata.shape[1]):
           error[:, i] = ydata[:, i] - fitval.reshape(255)
       return error.view(np.float64)


   def coleModelFit(self, method = 'least_sq'):
        """
        Fits data to Cole function based on objective above

        Parameters:
        self - PaperData object
        method - defaults to Levenberg-Marquadt, for other options check
        https://lmfit.github.io/lmfit-py/fitting.html

        Returns:
        Result - type is MinimizerResult from the lmfit package, for information
        on how to work with this type visit:
        https://lmfit.github.io/lmfit-py/fitting.html

        TODO: Implement iterations to make sure we get a good fit, add parameters
        for that?
        """

        params = lmfit.Parameters()
        params.add('Rinf', value = 400, min = 10, max = 1000)
        params.add('Rnot', value = 600, min = 10, max = 1000)
        params.add('tau',  value = 1/(50e3*2*math.pi), min = 1/(800e3*2*math.pi), max = 1/(20e3*2*math.pi))
        params.add('alpha', value = 0.8, min = 0.0, max = 1)

        x = self.freqList.copy()
        ydata = self.noError.copy()

        result = lmfit.minimize(self.objective, params, args=(x, ydata), method= method)

        result.params.pretty_print()
        print(result.success)
        print(lmfit.fit_report(result))
        return result, result.residual

   def plotData(self, type = 'R_X'):
       """
       Plot the actual data and the fit value in terms of magnitude and phase
       or in terms of resistance (R(ω)) and reactance (X(ω))

       Parameters:
       self - PaperData object
       type - two options possible 'Mag_phase' and 'R_X', basically pick what you
       want to plot by

       Returns:
       Nothing
       """

       xdata = self.freqList.copy()
       fitval = self.fitval.copy()
       if type == 'Mag_phase':
           y_1 = np.zeros(self.dataComplex.shape)
           y_2 = np.zeros(self.dataComplex.shape)
           y_fit = np.zeros(self.fitval.shape)
           y_fit2 = np.zeros(self.fitval.shape)

           for i in range(self.dataComplex.shape[0]):
               y_fit[i] = abs(fitval[i])
               y_fit2[i] = cmath.phase(fitval[i])
               for j in range(self.dataComplex.shape[1]):
                   y_1[i, j] = abs(self.dataComplex[i, j])
                   y_2[i, j] = cmath.phase(self.dataComplex[i, j])

       elif type == 'R_X':
           y_1 = self.dataComplex.real
           y_2 = self.dataComplex.imag
           y_fit = fitval.real
           y_fit2 = fitval.imag

           print(y_1.shape)

       for i in range(20):
           pylab.figure(i)
           pylab.scatter(y_1[:, i], -y_2[:, i])
           pylab.scatter(y_fit, -y_fit2, color = 'red')

       pylab.show()


def main():
    t1 = PaperData(["data\s001.csv","data\s002.csv", "data\s003.csv", "data\s004.csv", "data\s005.csv", "data\s006.csv", "data\s007.csv"], "data\s008.csv")
    test, train, testLabel, trainLabel = t1.getRandomSample()
    #print("Test data", test, "\nTrain data", train, "\nTest Labels", testLabel,\
    # "\nTrain Label", trainLabel)
    #print(np.array(trainLabel[1,1]))
    t1.prepData()
    t1.plotData()

if __name__ == '__main__':
    main()
