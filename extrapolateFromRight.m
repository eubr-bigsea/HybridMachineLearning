% This piece of code computes extrapolation capability of Hybrid and pure ML from left side
% starting from 20 as the sole missing point and go right-ward until it suppose to miss all
% the points in the rang of (20..72).

% the mean relative error, the number of iterations, and the actual number of loops are 
% plotted for each of the two approach

% sim_results and avg_time_query_vector can also be plotted easily because the required code exists.

clear all
close all hidden
clc
warning("off")

query = "Q40";
ssize = "250";

conf = [20 30 40 48 60 72 80 90 100 108 120];
configuration_to_predict = 11;
base_dir = "../source_data";


query_operational_data = cell(1, 1);
size(query_operational_data);
for i = 1 : length(conf)
  query_analytical_data = ["/home/osboxes/bootstrap/source_data/full/Q40/250/estimated_response_times.csv"];
  query_operational_data{i} = ["/home/osboxes/bootstrap/source_data/full/Q40/250/" num2str(conf(i)) ".csv"];
endfor




%query_analytical_data = ["full/" query "/" ssize "/estimatedResTimes.csv"];
%query_operational_data_20 = ["oper/" query "/" ssize "/dataOper_20.csv"];
%query_operational_data_40 = ["oper/" query "/" ssize "/dataOper_40.csv"];
%query_operational_data_48 = ["oper/" query "/" ssize "/dataOper_48.csv"];
%query_operational_data_60 = ["oper/" query "/" ssize "/dataOper_60.csv"];
%query_operational_data_72 = ["oper/" query "/" ssize "/dataOper_72.csv"];
%query_operational_data_80 = ["oper/" query "/" ssize "/dataOper_80.csv"];
%query_operational_data_90 = ["oper/" query "/" ssize "/dataOper_90.csv"];
%query_operational_data_100 = ["oper/" query "/" ssize "/dataOper_100.csv"];
%query_operational_data_108 = ["oper/" query "/" ssize "/dataOper_108.csv"];
%query_operational_data_120 = ["oper/" query "/" ssize "/dataOper_120.csv"];

%analytical_data = read_data([base_dir query_analytical_data]);
analytical_data = csvread(query_analytical_data);
sim_results = analytical_data(:, 1);
sim_results = sim_results(:)';

for i = 1 : length(conf)
  oper_data = read_data(query_operational_data{i});
  operational_data{i} = [oper_data(:,2), oper_data(:, end)];
end 


%operational_data_20 = read_data([base_dir query_operational_data_20]);
%operational_data_40 = read_data([base_dir query_operational_data_40]);
%operational_data_48 = read_data([base_dir query_operational_data_48]);
%operational_data_60 = read_data([base_dir query_operational_data_60]);
%operational_data_72 = read_data([base_dir query_operational_data_72]);
%operational_data_80 = read_data([base_dir query_operational_data_80]);
%operational_data_90 = read_data([base_dir query_operational_data_90]);
%operational_data_100 = read_data([base_dir query_operational_data_100]);
%operational_data_108 = read_data([base_dir query_operational_data_108]);
%operational_data_120 = read_data([base_dir query_operational_data_120]);

for i = 1 : length(conf)
  operational_data_cleaned{i} = clear_outliers(operational_data{i}) ;
  %avg_time_query_vector(i) = mean(operational_data_cleaned{i} (1));
  %printf("%d\n", avg_time_query_vector(i));
end 



%[operational_data_20_cleaned, ~] = clear_outliers (operational_data_20);
%[operational_data_40_cleaned, ~] = clear_outliers (operational_data_40);
%[operational_data_48_cleaned, ~] = clear_outliers (operational_data_48);
%[operational_data_60_cleaned, ~] = clear_outliers (operational_data_60);
%[operational_data_72_cleaned, ~] = clear_outliers (operational_data_72);
%[operational_data_80_cleaned, ~] = clear_outliers (operational_data_80);
%[operational_data_90_cleaned, ~] = clear_outliers (operational_data_90);
%[operational_data_100_cleaned, ~] = clear_outliers (operational_data_100);
%[operational_data_108_cleaned, ~] = clear_outliers (operational_data_108);
%[operational_data_120_cleaned, ~] = clear_outliers (operational_data_120);

avg_time_query_vector = zeros (numel (conf), 1);
% EHSAN: recomputing avg_time_query_vector at runtime to be sure of the old values : 
for i = 1 : length(conf)
  avg_time_query_vector(i) = mean(operational_data_cleaned{i})(1);
end

%avg_time_query_vector = [(mean(operational_data_20_cleaned))(1) (mean(operational_data_40_cleaned))(1) (mean(operational_data_48_cleaned))(1) (mean(operational_data_60_cleaned))(1) (mean(operational_data_72_cleaned))(1) (mean(operational_data_80_cleaned))(1) (mean(operational_data_90_cleaned))(1) (mean(operational_data_100_cleaned))(1) (mean(operational_data_108_cleaned))(1) (mean(operational_data_120_cleaned))(1)];

b_firstPath = ["../plots/", query, "/", ssize, "/linear/missing_", num2str(conf(configuration_to_predict)), "/BaseExtrapolate/"];
ml_firstPath = ["../plots/", query, "/", ssize, "/linear/missing_", num2str(conf(configuration_to_predict)), "/IMLExtrapolate/"];
firstPath = ["../plots/", query, "/", ssize, "/linear/missing_", num2str(conf(configuration_to_predict)), "/HyExtrapolate/"];

  itrThr = 34;
  stopThr = 23;
  avg(1) = itrThr;
  avg(2) = stopThr;
  
  ml_itrThr = 25;
  ml_stopThr = 15;
  avg(6) = ml_itrThr;
  avg(7) = ml_stopThr;

  diff = 0;
  for i = 0 : 4
      ml_midPath = [ml_firstPath num2str(conf(11-i))];
      midPath = [firstPath num2str(conf(11-i))];
      b_midPath = [b_firstPath num2str(conf(11-i))];
      
      b_outPath = [b_midPath, "/base_", num2str(itrThr), "_", num2str(stopThr), ".csv"];
      ml_outPath = [ml_midPath, "/iml_", num2str(ml_itrThr), "_", num2str(ml_stopThr), ".csv"];
      outPath = [midPath, "/hy_", num2str(itrThr), "_", num2str(stopThr), ".csv"];
      
      ml_outData = read_data([ml_outPath]);
      outData = read_data([outPath]);
      b_outData = read_data([b_outPath]);
    
      
      ml_avgOutData = mean(ml_outData);
      avgOutData = mean(outData);
      b_avgOutData = mean(b_outData);
      
      avg(8) = ml_avgOutData(12);
      avg(3) = avgOutData(12);
      avg(11) = b_avgOutData(12);
      
      avg(9) = ml_avgOutData(4);
      avg(10) = ml_avgOutData(5);
      avg(4) = avgOutData(4);
      avg(5) = avgOutData(5);
      avg(12) = b_avgOutData(4);
      avg(13) = b_avgOutData(5);

      ml_err(i+1) = avg(3);
      hy_err(i+1) = avg(8);
      b_err(i+1) = avg(11);
      
      ml_itr(i+1) = avg(9);
      hy_itr(i+1) = avg(4);
      b_itr(i+1) = avg(12);
      
      ml_act(i+1) = avg(10);
      hy_act(i+1) = avg(5);
      b_act(i+1) = avg(10);
      diff += 100*abs(sim_results(11-i) - avg_time_query_vector(11-i))/avg_time_query_vector(11-i) ;
      
      output = [midPath, "/extrapolate_right_", num2str(conf(11-i)), ".csv"];
      dlmwrite(output, avg);
      
      
      
      cost = costFuncRight(i+1, conf, avg_time_query_vector);
      hy_cost(i+1) = ceil(hy_itr(i+1))*cost;
      ml_cost(i+1) = (ceil(ml_itr(i+1))*cost);     
      b_cost(i+1) = ceil(b_itr(i+1))*cost;
      
    endfor
    
    hold on;
    x = [120 108 100 90 80];

%    h1 = plotyy(x, ml, x, fliplr(sim_results(6:10)));
%    h2 = plotyy(x, hy, x, fliplr(avg_time_query_vector(6:10)));
    set(gca, 'XTick', x);
    [ax1,h11,h12] = plotyy(x, ml_err, x, ml_itr);
    set(ax1, 'XTick', x);
    
    [ax2,h21,h22] = plotyy(x, hy_err, x, hy_itr);
    set(ax2, 'XTick', x);
    %[ax3,h31,h32] = plotyy(x, ml_err, x, ml_act);
    %[ax4,h41,h42] = plotyy(x, hy_err, x, hy_act);
    
     [ax3,h31,h32] = plotyy(x, b_err, x, hy_itr);
    set(ax3, 'XTick', x);

    %set(h32,'color','red');
    %set(h42,'color','red');
    
    set(h11,"linestyle","--");
    set(h21,"linestyle","--");
    set(h31,"linestyle","--");
    
    set(h12,"linestyle","-.");
    set(h22,"linestyle","-.");
    set(h32,"linestyle","-.");
    

    xlabel("Missing Configurations (Number of Cores)");
    ylabel(ax1(1), "MAPE on Missing Points");
    ylabel(ax1(2), "Number of Iterations");
    %title("Formula-based AM; Right Extrapolation; (hyItrThr, hyStopThr, mlItrThr, mlStopThr) = (34, 23, 30, 19)");
    txt = ["avg rel. error of formula with regard to expected values: ", num2str(diff/5) ];
    %text(90, 39, txt);
    text(81, 31, "IML error");
    text(81, 12, "Hybrid error");
     text(81.9, 15.1, "BML error");

    text(81, 8, "IML #iterations");

    text(81, 20, "Hybrid #iterations");



    opt = ["-djpg"];
    filepath  = [firstPath "/extrapolate_right_base.jpg"];
    print(filepath, opt);
    
     opt = ["-depsc"];
    filepath  = [firstPath "/q40_extrapolate_right_new.eps"];
    print(filepath, opt);
    
     hold off;
    plot(x, hy_cost, '-r', x, ml_cost, '-.b');
    set(gca, 'XTick', x);
    xlabel("Missing Configurations (Number of Cores)");
    ylabel("Cost");
    legend("Hybrid & BML", "IML");
    opt = ["-djpg"];
    filepath  = [firstPath "/cost_right.jpg"];
    print(filepath, opt);
    opt = ["-depsc"];
    filepath  = [firstPath "/cost_right.eps"];
    print(filepath, opt);
    
    
    hold off;
    cost_ratio=ml_cost./hy_cost
    
    %ml_itr_sim_based = [5.0300    6.3100    9.4400   11.0000    6.7800];
    %hy_itr_sim_based = [7.6049   10.1300   13.3400   14.9800   14.4100];

    %cost_ratio_sim_based= ml_itr_sim_based ./ hy_itr_sim_based;
    plot(x, cost_ratio, '-b');
    
    
    xlabel("Missing Configurations (Number of Cores)");
    ylabel("Cost ratio (IML vs. HML & BML)"); %complete and save
    %legend("approximated formula",'Location', 'SouthEast' );
    opt = ["-djpg"];
    filepath  = [firstPath "/q40_cost_right_new.jpg"];
    print(filepath, opt);
    opt = ["-depsc"];
    filepath  = [firstPath "/q40_cost_right_new.eps"];
    print(filepath, opt);
