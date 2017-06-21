function [samples]  = initKB (analytical)

analytical(:, 2) = 1 ./ analytical(:, 2);
samples = analytical;

endfunction
