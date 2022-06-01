# parf - Parallel Random Forest

These scripts were written by Robert Weyres in 2015 and adapted for public usage in 2022.

A fork of randomforest-matlab used in the scripts can be found at https://github.com/jrderuiter/randomforest-matlab.

The purpose of this function is to train a model on multiple threads and predict on multiple threads to save time.
In 2015, this training method was already proven to be 10 times faster than classical classRF_train, which itself was single-threaded.

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
