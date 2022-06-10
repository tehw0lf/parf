function [model, traintime, jointime, total_traintime] = parf_train(data, indices, varargin)
    %
    % This script was written by Robert Weyres in 2015 and adapted for public usage in 2022.
    % A fork of randomforest-matlab used in this script can be found at https://github.com/jrderuiter/randomforest-matlab.
    %
    % The purpose of this function is to train a model on multiple threads to save time.
    % In 2015, this method was already proven to be 10 times faster than classical classRF_train, which itself was single-threaded.
    %
    % The script takes the following parameters
    %
    % data - the training data
    % indices - the training indices
    % varargin - num_threads and num_trees, the number of threads and trees to train with - if not specified, num_threads is set to 25 and num_trees is set to 500
    %
    % The script is licensed under the MIT license
    %
    % MIT License
    %
    % Copyright (c) 2015; 2022 Robert Weyres
    %
    % Permission is hereby granted, free of charge, to any person obtaining a copy
    % of this software and associated documentation files (the "Software"), to deal
    % in the Software without restriction, including without limitation the rights
    % to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    % copies of the Software, and to permit persons to whom the Software is
    % furnished to do so, subject to the following conditions:
    %
    % The above copyright notice and this permission notice shall be included in all
    % copies or substantial portions of the Software.
    %
    % THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    % IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    % FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    % AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    % LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    % OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    % SOFTWARE.

    switch nargin
        case 2
            num_threads = 25
            num_trees = 500

        case 3
            num_threads = varargin{1}
            num_trees = 500

        case 4
            num_threads = varargin{1}
            num_trees = varargin{2}

        otherwise
            disp('Error: Please input data as well as indices.')
            end
    end

    num_threads = 25; % Number of threads to be used
    num_trees = 500; % Number of trees that will be trained
    splittree = num_trees / num_threads; % Calculate workload for each thread. This has to be an integer value.
    delete(gcp('nocreate'))% Delete any existing parallel pools

    if size(gcp('nocreate'), 1) == 0% Create parpool with number of threads.
        tic
        poolobj = parpool('local', num_threads);
        toc
    end

    disp('Training...');
    % Parallel Training start
    trainstart = tic;

    parfor i = 1:num_threads
        model_all{i, 1} = classRF_train(data, indices, splittree); % Train the calculated amount of trees on each thread
        fprintf('Model %d trained\n', i);
    end

    clear data														% Clear variables and parallel pool to save memory
    clear indices
    traintime = toc(trainstart);
    delete(poolobj)
    clear poolobj
    % Parallel Training end
    disp('Joining models'); % Merge the split models into a combined one that can be used for prediction
    joinstart = tic; % The needed values of each split are combined in single steps

    for i = 1:num_threads

        if ~exist('model', 'var')
            model = model_all{i, 1};
            model.ntree = num_trees;
            fprintf('%d split joined\n', i);
        else
            model.xbestsplit = [model.xbestsplit'; model_all{i, 1}.xbestsplit']';
            model.treemap = [model.treemap'; model_all{i, 1}.treemap']';
            model.nodestatus = [model.nodestatus'; model_all{i, 1}.nodestatus']';
            model.nodeclass = [model.nodeclass'; model_all{i, 1}.nodeclass']';
            model.bestvar = [model.bestvar'; model_all{i, 1}.bestvar']';
            model.ndbigtree = [model.ndbigtree'; model_all{i, 1}.ndbigtree']';
            model.errtr = [model.errtr; model_all{i, 1}.errtr];
            model.errts = [model.errts; model_all{i, 1}.errts];
            fprintf('%d splits joined\n', i);
        end

    end

    jointime = toc(joinstart);
    total_traintime = traintime + jointime;
end
