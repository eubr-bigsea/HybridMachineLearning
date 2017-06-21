% This piece of code averages the error for each combination of (itrThr, stopThr) to 
% find optimum conbination of them 

clear all
close all hidden
clc
warning("off")

query = "R3";
ssize = "250";

conf = [20 30 40 48 60 72 80 90 100 108 120];
configuration_to_predict = 11;
base_dir = "../source_data/";

avgPath = ["../plots/", query, "/", ssize, "/linear/missing_", num2str(conf(configuration_to_predict)), "/HyOptimumFinding/avg_hy.csv"];

for itrThr = 23 : 40
  avg(1) = itrThr;
  for stopThr = 15 : 30
    avg(2) = stopThr;
    outPath = ["../plots/", query, "/", ssize, "/linear/missing_", num2str(conf(configuration_to_predict)), "/HyOptimumFinding/out_", num2str(itrThr), "_", num2str(stopThr), ".csv"];
    outData = read_data([outPath]);
    avgOutData = mean(outData);
    
    avg(3) = avgOutData(4);
    avg(4) = avgOutData(5);
    avg(5) = avgOutData(6);

    dlmwrite(avgPath, avg, "-append");
  endfor
endfor




