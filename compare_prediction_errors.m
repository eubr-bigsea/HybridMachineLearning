## Copyright 2017 Eugenio Gianniti
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

clear all
close all hidden
clc

base_directory = "/home/useruser/data/dag/full/Q40/250";
hybrid_csv = "/home/useruser/data/dag/hy_25_15.csv";
ml_csv = "/home/useruser/data/dag/base_25_15.csv";

configuration.runs = [20 30 40 48 60 72 80 90 100 108 120];
configuration.missing_runs = [20 30];

configuration.train_fraction = 0.6;
configuration.test_fraction = 0.2;

configuration.options = "-s 3 -t 0 -q -h 0 ";
configuration.C_range = linspace (0.1, 5, 20);
configuration.epsilon_range = linspace (0.1, 5, 20);

outer_thresholds = 25;
inner_thresholds = 15;
max_inner_iterations = 10;
seeds = 101:150;

analytical_weight = 1;
experimental_weight = 5;

%% End of configurations

[~, err, ~] = stat (hybrid_csv);
if (err == 0)
  error (sprintf ("compare_prediction_errors: '%s' exists, it cannot be overwritten",
                  hybrid_csv));
endif

[~, err, ~] = stat (ml_csv);
if (err == 0)
  error (sprintf ("compare_prediction_errors: '%s' exists, it cannot be overwritten",
                  ml_csv));
endif

analytical_data = csvread ([base_directory, "/estimated_response_times.csv"])

experimental_data = cell (size (configuration.runs));
for (ii = 1:numel (configuration.runs))
  experimental_data{ii} = ...
    read_data (sprintf ("%s/%d.csv", base_directory, configuration.runs(ii)));
endfor

clean_experimental_data = cellfun (@(A) nthargout (1, @clear_outliers, A),
                                   experimental_data, "UniformOutput", false);
clean_experimental_data = cellfun (@(A) [A(:, 1), 1 ./ A(:, end)],
                                   clean_experimental_data,
                                   "UniformOutput", false)

avg_execution_times = ...
  cellfun (@(A) mean (A(:, 1)), clean_experimental_data)

%analytical_sample = analytical_data;
%analytical_sample(:, end) = 1 ./ analytical_sample(:, end);
%analytical_sample

analytical_sample = analytical_data;
analytical_sample(:, end) = 1 ./ analytical_sample(:, end);

[available_idx, missing_idx] = find_configurations (configuration.runs,
                                                    configuration.missing_runs);

for (outer = outer_thresholds)
  for (inner = inner_thresholds)
    for (seed = seeds)
      rand ("seed", seed);
      
      knowledge_base = analytical_sample;
      weights = analytical_weight * ones (rows (analytical_sample), 1);
      

     	 ml_knowledge_base = [];
         ml_weights = [];
      
      experimental_shuffled = cell (size (clean_experimental_data));
      for (ii = 1:numel (clean_experimental_data))
        idx = randperm (rows (clean_experimental_data{ii}));
        experimental_shuffled{ii} = clean_experimental_data{ii}(idx, :);
      endfor

      overall_counter = 0;
      best_train_error = Inf;
      best_cv_error = Inf;
      too_many_inner_iterations = false;
      
      iterations = min (cellfun (@rows, experimental_shuffled))
      it = 0;
    
      while (it < iterations &&
             (best_train_error > outer || best_cv_error > outer))
        it += 1;
        
        % Update the knowledge base with new data
        current_chunk = ...
          cell2mat (arrayfun (@(jj) experimental_shuffled{jj}(it, :),
                              available_idx, "UniformOutput", false)')
        knowledge_base = [knowledge_base; current_chunk];
        weights = [weights; (experimental_weight * ones (rows (current_chunk), 1))];
        n = numel(knowledge_base)
        it
        counter = 0;
 
        do
          results = model_selection_with_thresholds (knowledge_base, weights,
                                                     avg_execution_times,
                                                     configuration);
	
%	  figure;
%	  plot(configuration.runs,results.predictions, '*r')
%	  hold all;
% 	  plot(configuration.runs, avg_execution_times, '*m')
%	  hold on;
%	  plot(configuration.runs,analytical_sample(:,1), 'c')
%	  hold on;	

          
          if (results.train_error < best_train_error)
            best_train_error = results.train_error
            best_test_error = results.test_error
            best_cv_error = results.cv_error
            best_available_error = results.available_error
            best_missing_error = results.missing_error
            best_options = results.options;
            best_model = results.model;
          endif
          
          current_train_error = results.train_error;
          current_cv_error = results.cv_error;
          
          counter += 1;
        until (counter >= max_inner_iterations ||
               (current_train_error < inner && current_cv_error < inner));
        
        if (counter == max_inner_iterations)
          too_many_inner_iterations = true;
        else
          % The idea seems to be that if you can exit from the loop before
          % exhausting your iterations then the best result is the one
          % that allowed to do so.
          best_train_error = results.train_error;
          best_test_error = results.test_error;
          best_cv_error = results.cv_error;
          best_available_error = results.available_error;
          best_missing_error = results.missing_error;
          best_options = results.options;
          best_model = results.model;
        endif
        
        overall_counter += counter;
        
        ml_knowledge_base = [ml_knowledge_base; current_chunk];
        ml_weights = [ml_weights; (experimental_weight *
                                   ones (rows (current_chunk), 1))];
        ml_results = model_selection_with_thresholds (ml_knowledge_base, ml_weights,
                                                      avg_execution_times,
                                                      configuration);
      endwhile
      
      too_many_outer_iterations = (it == iterations);
      
      row = [outer, inner, seed, it, overall_counter, ...
             too_many_inner_iterations, too_many_outer_iterations, ...
             best_train_error, best_test_error, best_cv_error, ...
             best_available_error, best_missing_error];
      csvwrite (hybrid_csv, row, "-append");
      
      ml_row = [outer, inner, seed, it, overall_counter, ...
                too_many_inner_iterations, too_many_outer_iterations, ...
                ml_results.train_error, ml_results.test_error, ...
                ml_results.cv_error, ...
                ml_results.available_error, ml_results.missing_error];
      csvwrite (ml_csv, ml_row, "-append");
    endfor
  endfor
endfor
