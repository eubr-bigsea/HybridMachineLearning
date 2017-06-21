## Copyright 2016 Eugenio Gianniti
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
## @deftypefn {Function File} {[@var{clean}, @var{indices}] =} clear_outliers (@var{dirty})
##
## Clear outliers from @var{dirty} by excluding rows where the value on a
## column is more than 3 standard deviations away from the mean.
## Return the @var{clean} dataset and the original @var{indices}
## kept after the procedure.
##
## @end deftypefn

function [clean, indices] = clear_outliers (dirty)

avg = mean (dirty);
dev = std (dirty);
cols = size (dirty, 2);

clean = dirty;
indices = 1:size (dirty, 1)';

for (jj = 1:cols)
  if (dev(jj) > 0)
    idx = (abs (clean(:, jj) - avg(jj)) < 3 * dev(jj));
    clean = clean(idx, :);
    indices = indices(idx);
  endif
endfor

endfunction
