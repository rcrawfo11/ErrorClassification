# BIS Error Classification
## Medical Electronics Group, Swarthmore College, Summer 2020

**Collaborators:** Rekha Crawford, Maggie Delano

**Project Description:** Following the steps laid out in the article Ayllón et. al 2016, this project attempted to replicate the error classification method presented, validate it, and then develop an embedded implementation.
The bulk of this was done in Python with plans to move to Cython, a superset of python that allows people to use C packages in python code. If you want help with Cython, check my help doc in the medical devices folder (currently not complete).

**File Description:**
Folders:
  CythonCode: Contains Cython implementation. NOT IMPLEMENTED

  PythonCode: Contains Python implementation. NOT COMPLETE
    matlabCode: Used for reference
    data: properly formatted data from study

lda: Implementation of least squares linear discriminant analysis algorithm.

GA: Implementation of a GeneticAlgorithm. NOT COMPLETE (needs to be modified to
better match approach in paper and needs a heuristic)

DataReader: Parent class for reading in data in varies forms

PaperData: Designed specifically to read in and analysis the data from the Allyon
Paper. Has a main that one can run to test and get back statistics

OurData: Designed to analyze our data, should have methods based of paper data,
potentially the same methods if we can make formatting similar. NOT IMPLEMENTED

Main: Is supposed to run everything ones it's all complete. NOT IMPLEMENTED

**Next Steps:**
1. Finish prepData function in PaperData. This function should take the data and
convert it to the features used in the paper.
2. Based on data setup, update GA heuristic. Also update some parts of GA (marked
in comments on GA file) to make it more aligned with the GA used in the paper
3. Test and see if we get comparable results to the paper.
4. Sort our data
5. Make a modified PaperData object called OurData, to read in and process our dataset
based on the form it's in.


**Citations:**

Ayllón D, Gil-Pita R, Seoane F(2016) Detection and Classification of Measurement Errors in Bioimpedance Spectroscopy. PLoSONE11(6): e0156522.doi:10.1371/journal.pone.0156522

Newville, Matthew, Stensitzki, Till, Allen, Daniel B., & Ingargiola, Antonino. (2014, September 21). LMFIT: Non-Linear Least-Square Minimization and Curve-Fitting for Python (Version 0.8.0). Zenodo. http://doi.org/10.5281/zenodo.11813
