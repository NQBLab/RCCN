function [frozen,corr_C,corr_A,mag_A,mag_B,mag_C] = getObservables(exp_num, str1,str2, exp_times,reference_timepoints,win)
% the function reads the data from exp_num runs of the simulation from one
% experiment, and returns the observables over time for each of
% the runs as a matrix:(exp_num x total-time-of-exp)
% the observables are: the magnetization, in 3 different normalizations of 
% each cycle, the correlation, in two different normalizations, and the 
% frozen cycles' partial amount.
% the normalization options for the cycles' magnetization are denoted A,B,C:
% A) by the square root of it's length
% B) by it's length
% C) by 1 - no normalization
% for the correlation, the function receives the different time points in
% which the correltaion will be measured from, and returns the correlation 
% as a 3-d matrix: (exp_num x total-time x amount-of-reference-points).
% for the frozen, the function recieves the time window in which cycles
% should not change their magnetization in order to count as frozen.
    mag_A = zeros(exp_num, sum(exp_times));
    mag_B = zeros(exp_num, sum(exp_times));
    mag_C = zeros(exp_num, sum(exp_times));    
    corr_C = zeros(exp_num, sum(exp_times),length(reference_timepoints));
    corr_A = zeros(exp_num, sum(exp_times),length(reference_timepoints));
    frozen = zeros(exp_num, sum(exp_times));
   
    done_init_to_gpu = false; % if old gpu - put true, since no init required
                              % if new gpu - put false, since it is
                              % required to catch the error as a fix to
                              % matlab's bug
    for curr_exp=1:exp_num
        % spins_hist stores the data of the state of each site in every
        % time of the experiment, in binary (true=+1, false=-1)
        % JInfo stores the information of which site belongs to which cycle
        load(strcat(str1,num2str(curr_exp)),'spins_hist');
        load(strcat(str2,num2str(curr_exp)),'JInfo');
        % convert to real values of sites
        spins_hist = gpuArray(spins_hist)*2-1;
        % representatives is the list of the first site in each cycle
        representatives = unique(JInfo(1,:));
        % length(representatives) is the amount of cycles
        num_cycles = length(representatives);
        % in the first step of the analysis, we want to produce the
        % magnetization of each cycle (cycles_hist), with the proper 
        % normalization, over time. The spins_hist matrix is 
        % (#spins x total-time).thus, we will use matrices of 
        % (#cycles x #spins), that multiplying them by the spins_hist 
        % matrix result in matrices of (#cycles x total-time). Those 
        % matrices will have in each row, indicating each cycle, zero for 
        % every site that doesn't belong to the cycle, and 
        % 1/normalization-function(cycle's-length) in each site that does 
        % belong to the cycle. This will result in summing over all the 
        % sites of each cycle, and normalizing according to the cycle's length.
        spins2cycles_C = zeros(num_cycles,2^14,'gpuArray');
        spins2cycles_B = zeros(num_cycles,2^14,'gpuArray');
        spins2cycles_A = zeros(num_cycles,2^14,'gpuArray');
        for i=1:num_cycles-1
            % JInfo(2,i) is the length of the cycles that i belongs to
            spins2cycles_A(i,representatives(i):representatives(i)-1+JInfo(2,representatives(i))) = ones(1,JInfo(2,representatives(i)))/sqrt(JInfo(2,representatives(i)));
            spins2cycles_B(i,representatives(i):representatives(i)-1+JInfo(2,representatives(i))) = ones(1,JInfo(2,representatives(i)))/JInfo(2,representatives(i));
            spins2cycles_C(i,representatives(i):representatives(i)-1+JInfo(2,representatives(i))) = ones(1,JInfo(2,representatives(i)))/1;
        end
        spins2cycles_A(end,representatives(end):end) = ones(1,2^14+1-representatives(end))/sqrt(JInfo(2,representatives(end)));
        spins2cycles_B(end,representatives(end):end) = ones(1,2^14+1-representatives(end))/JInfo(2,representatives(end));
        spins2cycles_C(end,representatives(end):end) = ones(1,2^14+1-representatives(end))/1;
        
        % deal with matlab's bug if needed
        if done_init_to_gpu==false
            try
                cycles_hist_A = gather(spins2cycles_A*spins_hist);
            catch ME
            end
            done_init_to_gpu=true;
        end
        
        cycles_hist_A = gather(spins2cycles_A*spins_hist);
        cycles_hist_B = gather(spins2cycles_B*spins_hist);
        cycles_hist_C = gather(spins2cycles_C*spins_hist);
        
        % the maximum possible value of the sum over all the cycles'
        % magnetizations, with the different normalizations
        maximum_sum_C = sum(JInfo(2,representatives).^(1-0)); % this is equal to num_spins
        maximum_sum_A = sum(JInfo(2,representatives).^(1-1/2));
        maximum_sum_B = sum(JInfo(2,representatives).^(1-1)); % this is equal to num_cycles
        % the total magnetization is the mean of the cycles' magnetization,
        % such that the maximum is 1
        mag_A(curr_exp,:) = sum(cycles_hist_A,1)/maximum_sum_A;
        mag_B(curr_exp,:) = sum(cycles_hist_B,1)/maximum_sum_B;
        mag_C(curr_exp,:) = sum(cycles_hist_C,1)/maximum_sum_C;
        
        % get the reference values for the correlation
        mag_at_reference_points_A = cycles_hist_A(:,reference_timepoints); 
        mag_at_reference_points_C = cycles_hist_C(:,reference_timepoints);
        % calc the correlation and normalize by the value at the reference point        
        corr_A(curr_exp,:,:) = (cycles_hist_A.'*mag_at_reference_points_A)./diag(mag_at_reference_points_A.'*mag_at_reference_points_A).';
        corr_C(curr_exp,:,:) = (cycles_hist_C.'*mag_at_reference_points_C)./diag(mag_at_reference_points_C.'*mag_at_reference_points_C).';
        
        % changes(i,t) = true if the magnetization of the i'th cycle has
        % changed from t-1 to t
        cycles_hist_C_shifted = circshift(cycles_hist_C,1,2);
        changes = cycles_hist_C_shifted~=cycles_hist_C;
        % f(i,t) = 0 if no changes happened to the i'th cycle in the past
        % win time steps i.e. the cycle is 'frozen', and f(i,t)>0 otherwise
        f = gather(movmean(changes,[win 0],2));
        % frozen is the partial amount of frozen cycles
        frozen(curr_exp,:) = sum(f==0)/num_cycles;
        
        disp(curr_exp)
    end
end