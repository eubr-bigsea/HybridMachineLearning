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

configurations = [20 30 40 48 60 72 80 90 100 108 120];
%configurations = [20]
%base_path = "/home/useruser/data/40";
base_path = "/home/useruser/data/dag/full/Q40/250"

%% Example to retrieve task_idx:
%    head -n 2 10.csv| tail -n 1 | tr , '\n' | grep -n nTask | cut -d : -f 1 | xargs echo
%task_idx = [5 10 15 22];
task_idx = [4 11 18 25 32 39 46 53 60 67];

operational_data = cell (size (configurations));
for (idx = 1:numel (configurations))
  filename = sprintf ([base_path, "/%d.csv"], configurations(idx));
  operational_data{idx} = read_data (filename);
endfor

clean_data = cellfun (@(A) nthargout (1, @clear_outliers, A), operational_data,
                      "UniformOutput", false);

tasks = cellfun (@(A) A(:, task_idx), clean_data, "UniformOutput", false);
times = cellfun (@(A) A(:, task_idx + 2), clean_data, "UniformOutput", false);
containers = cellfun (@(A) A(:, end), clean_data, "UniformOutput", false);

predictions = zeros (size (containers));
for (idx = 1:numel (predictions))
  predictions(idx) = compute_waves_prediction (containers{idx},
                                               tasks{idx},
                                               times{idx});
endfor

plot (configurations, predictions, '-');

results = [predictions(:), configurations(:)];
filename = [base_path, "/estimated_response_times.csv"];
csvwrite (filename, results);
