function [result,result2d] = parf_predict(data,model,diarypath,varargin)
%
% This script was written by Robert Weyres in 2015 and adapted for public usage in 2022.
% A fork of randomforest-matlab used in this script can be found at https://github.com/jrderuiter/randomforest-matlab.
%
% The purpose of this function is to run prediction on multiple threads to save time.
% 
% The script takes the following input parameters
%
% data - the data set to run the prediction on
% model - the trained model
% diarypath - the path to the diary used to reconstruct the order after prediction
% varargin - num_threads, the number of threads to predict with - if not specified, num_threads is set to 25
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
    case 3
        num_threads = 25

    case 4
        num_threads = varargin{1}

    otherwise
        disp('Error: Please input data, model and diarypath.')
        end    
end

num_threads=25;						% Number of threads to be used
delete(gcp('nocreate'))				% Delete any existing parallel pools
if size(gcp('nocreate'),1) == 0		% Create parpool with number of threads.
tic
poolobj=parpool('local',num_threads);
toc
end

disp('Predicting...');
% Parallel Prediction start
    disp('Splitting Input for Parallel Prediction...');
    result=[];
    for i = 1:num_threads-1												% Measure size of the source matrix and calculate sizes for splits.
        if ~exist('l','var')
            l{i,1}=floor(size(data,1)/num_threads-1);
        else
            l{i,1}=l{i-1,1}+floor(size(data,1)/num_threads-1);
        end
    end
    l{end+1,1}=size(data,1)-l{end,1};
    
    for i = 1:num_threads												% Split the source matrix into to the previously calculated sizes.
        if ~exist('data_split','var')
            data_split{i,1}=data(1:l{i},:);
        elseif l{i}-l{i-1} <= 0
            data_split{i,1}=data(1+l{i-1}:end,:);
        else
            data_split{i,1}=data(1+l{i-1}:l{i},:);
        end
    end
    clear l
    if size(gcp('nocreate'),1) == 0									    % Open parallel pool to perform the prediction on the chosen number of threads.
        tic
        poolobj=parpool('local',num_threads);
        toc
    end
    disp('Predicting...');
    diary diarypath									                    % Enable diary to log the order in which the threads are finished. Needed for reconstruction of the result.
    % Parallel Prediction start
    parpredstart=tic;
    parfor i = 1:num_threads
        l2{i,1} = classRF_predict(cell2mat(data_split(i,1)),model,i);	% Perform parallel prediction on the previously created splits.
        fprintf('%d\n',i);
    end
    parpredicttime=toc(parpredstart);
    % Parallel Prediction end
    diary off														    % Disable diary and import the created file into a matrix.
    fid=fopen(diarypath,'r');
    formatSpec='%d';
    ord=fscanf(fid,formatSpec);
    fclose(fid);
    delete(diarypath);
    for i = 1:num_threads											    % Align the calculated predictions with the information from diary.
        l2{i,2}=ord(i,1);
        l2{ord(i,1),3}=l2{i,1};
    end
    for i = 1:num_threads											    % Sort the prediction results.
        l3{i,2}=ord(i,1);
        l3{i,1}=l2{ord(i,1),3};
    end
    clear ord
    clear l2
    % Resultat ohne Parpool korrekt zusammenfügen					    % Join the results into a single matrix.
    for i = 1:num_threads
        result=[result;l3{i,1}];
    end
    clear l3
    disp('Finalising...');
    result2d = reshape(result2d,size(source,1),size(source,2));
    disp('Done.');
    clear data_split
end