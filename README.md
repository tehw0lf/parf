# parf - Parallel Random Forest

These scripts were written by Robert Weyres in 2015 and adapted for public usage in 2022.

A fork of randomforest-matlab used in the scripts can be found at https://github.com/jrderuiter/randomforest-matlab.

The purpose of this function is to train a model on multiple threads and predict on multiple threads to save time.
In 2015, this training method was already proven to be 10 times faster than classical classRF_train, which itself was single-threaded.

For training, the data set will be kept as it is, but the decision trees will be split across multiple threads - this is possible because every tree does a random decision by itself and is independent of the other trees.

For prediction, the data set will be split across multiple threads to let the model predict on subsets that will be joined together after all predictions are done.

Originally, these scripts were written to facilitate classification of different imaging data sets obtained using FTIR Spectrometry.
The data sets consisted of double-precision values of spectra in different ranges of wavelengths, resulting in an [n-dimensional array](https://www.mathworks.com/help/matlab/math/multidimensional-arrays.html) with one dimension representing spectra of one wavelength.
The goal was to classify tissue parts by their individual spectra.

In theory, the scripts should work with any input to classRF_train and classRF_predict - if not, please feel free to open an issue or pull request!

## Original usage

The input for the model is an n-dimensional array (:,:,n) of double-precision values between 0 and 1 that contain the data points of m classes in n wavelengths that will be trained. The classes are concatenated, thus an index is needed to determine which data belongs to which class.

Usually, a single class with data points on multiple wavelengths has a data structure of (:,:,n), whereas n is the number of wave numbers.

Example with arbitrary values for two classes with data points of a single wavelength (two-dimensional, :,:,1):

```matlab
[
   0.2305 0.2015 0.2015 0.1015 0.2015
   0.2015 0.2015 0.2015 0.1015 0.1015
   0.2015 0.2305 0.2015 0.1015 0.2015
   0.2015 0.2015 0.2015 0.2015 0.2015
   0.2035 0.2015 0.2215 0.2015 0.2015
   0.2015 0.2015 0.2015 0.2015 0.2015
   0.2015 0.2015 0.2015 0.2015 0.2015
   0.7015 0.7015 0.7015 0.7015 0.7015
   0.7015 0.7015 0.7015 0.7015 0.7015
   0.7015 0.7015 0.7015 0.7015 0.7015
   0.7015 0.7015 0.7015 0.7015 0.7015
   0.7015 0.7015 0.7015 0.7015 0.7015
   0.7015 0.7015 0.7015 0.7015 0.7015
   0.7015 0.7015 0.7015 0.7015 0.7015
]
```

The index is a two-dimensional array of labels, beginning at 1 and increasing with every class, shaped like the training data array:

```matlab
[ 1 1 1 1 1
  1 1 1 1 1
  1 1 1 1 1
  1 1 1 1 1
  1 1 1 1 1
  1 1 1 1 1
  1 1 1 1 1
  2 2 2 2 2
  2 2 2 2 2
  2 2 2 2 2
  2 2 2 2 2
  2 2 2 2 2
  2 2 2 2 2
  2 2 2 2 2
]
```

After training the model, it can be used to predict the tissue type in other data sets, which are n-dimensional arrays that contain data points measured by FTIR Spectrometry.

## Training

parf_train takes the following parameters:

- data - the training data
- indices - the training indices
- varargin - num_threads and num_trees, the number of threads and trees to train with - if not specified, num_threads is set to 25 and num_trees is set to 500

## Prediction

parf_predict takes the following parameters:

- data - the data set to run the prediction on
- model - the trained model
- diarypath - the path to the diary used to reconstruct the order after prediction
- varargin - num_threads, the number of threads to predict with - if not specified, num_threads is set to 25

## License and contributing

The scripts are licensed under the MIT license.

Contributions are welcome in the form of issues and/or pull requests.
