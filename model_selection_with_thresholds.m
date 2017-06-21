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

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{results} =} model_selection_with_thresholds (@var{sample}, @var{weights}, @var{real_times}, @var{configuration})
##
## Perform model selection on @var{sample}, where 'y' is the first column and
## 'X' spans all the others, using @var{weights}.
## @var{results} contains all the prediction errors, both the ones computed over
## the training, test, and cross validation sets, and those evaluated
## against @var{real_times}.
##
## @var{configuration} holds the settings:
## @table @samp
## @item runs
##   all the experimental configurations
## @item missing_runs
##   runs to consider missing
## @item train_fraction
##   the fraction of data to use in the training set
## @item test_fraction
##   the fraction of data to use in the test set
## @item options
##   the initial LibSVM option string
## @item C_range
##   the range to span with C during model selection
## @item epsilon_range
##   the range to span with epsilon during model selection
## @end table
##
## @var{results} holds the fields:
## @table @samp
## @item options
##   the final LibSVM option string
## @item C
##   the final C value
## @item epsilon
##   the final epsilon value
## @item available_error
##   the percentage error on the available runs
## @item missing_error
##   the percentage error on the missing runs
## @item train_error
##   the percentage error on the training set
## @item test_error
##   the percentage error on the test set
## @item cv_error
##   the percentage error on the cross validation set
## @end table
##
## @seealso{model_selection_weights}
## @end deftypefn

function results = model_selection_with_thresholds (sample, weights, real_times, configuration)

idx = randperm (rows (sample));
shuffled = sample(idx, :);
W = weights(idx);

[scaled, mu, sigma] = zscore (shuffled);
y = scaled(:, 1);
X = scaled(:, 2:end);
mu_y = mu(1);
mu_X = mu(2:end);
sigma_y = sigma(1);
sigma_X = sigma(2:end);

if (sigma_X(end) > 0)
  safe_sigma = sigma_X(end);
else
  safe_sigma = 1;
endif
scaled_cores = ((1 ./ configuration.runs) - mu_X(end)) / safe_sigma;
scaled_cores = scaled_cores(:);

[available_idx, missing_idx] = ...
  find_configurations (configuration.runs, configuration.missing_runs);

[ytr, ytst, ycv] = split_sample (y, configuration.train_fraction,
                                 configuration.test_fraction);
[Xtr, Xtst, Xcv] = split_sample (X, configuration.train_fraction,
                                 configuration.test_fraction);
[Wtr, Wtst, Wcv] = split_sample (W, configuration.train_fraction,
                                 configuration.test_fraction);

[C, eps] = model_selection_weights (Wtr, ytr, Xtr, ytst, Xtst,
                                    configuration.options,
                                    configuration.C_range,
                                    configuration.epsilon_range);
results.options = [configuration.options, " -p ", num2str(eps), " -c ", num2str(C)];
results.C = C;
results.epsilon = eps;

model = svmtrain (Wtr, ytr, Xtr, results.options);
results.model = model;
[predictions, ~, ~] = svmpredict (zeros (size (scaled_cores)), scaled_cores,
                                  model, "-q");
rescaled_predictions = rescale (predictions, mu_y, sigma_y);
results.predictions = rescaled_predictions;

perc_err = 100 * relative_error (real_times(:), rescaled_predictions);
results.available_error = mean (perc_err(available_idx));
results.missing_error = mean (perc_err(missing_idx));

[train_prediction, ~, ~] = svmpredict (ytr, Xtr, model, "-q");
tr_pred_unscaled = rescale (train_prediction, mu_y, sigma_y);
ytr_unscaled = rescale (ytr, mu_y, sigma_y);
results.train_error = 100 * mean (relative_error (ytr_unscaled, tr_pred_unscaled));

[test_prediction, ~, ~] = svmpredict (ytst, Xtst, model, "-q");
tst_pred_unscaled = rescale (test_prediction, mu_y, sigma_y);
ytst_unscaled = rescale (ytst, mu_y, sigma_y);
results.test_error = 100 * mean (relative_error (ytst_unscaled, tst_pred_unscaled));

[cv_prediction, ~, ~] = svmpredict (ycv, Xcv, model, "-q");
cv_pred_unscaled = rescale (cv_prediction, mu_y, sigma_y);
ycv_unscaled = rescale (ycv, mu_y, sigma_y);
results.cv_error = 100 * mean (relative_error (ycv_unscaled, cv_pred_unscaled));

endfunction
