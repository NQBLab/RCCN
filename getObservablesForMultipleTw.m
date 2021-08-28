% This script gets the observables value for each experiment out of
% experiments with different waiting times (different ages of the system).
% The script saves the data for each experiment in a matlab file

Tw = [20,40,80,160,320,640,1280,3000];
exp_times = [2000, 3000, 9000];
exp_num=900;
dist_file_prefix = 'Experiments/Observables/Exp1/T'; % prefix of the results files
spins_hist_file_prefix = 'Experiments/Spins/Exp1/T';
JInfo_file_prefix = 'Experiments/Spins/Exp1/JInfoT';
win = 100; % window in which cycles should not change their magnetization in order to count as frozen

for i=1:length(Tw)
    exp_times(2)=Tw(i); % update the experiment time to the current experiment
    reference_timepoints = [exp_times(1)+exp_times(2)]; % the reference timepoints for the correlation
                                                        % in this case, just the end of the external field period
    % get observables and save
    str1 = strcat(spins_hist_file_prefix,num2str(Tw(i)),'R');
    str2 = strcat(JInfo_file_prefix,num2str(Tw(i)),'R');
    [frozen,corr_C,corr_A,mag_A,mag_B,mag_C] = getObservables(exp_num, str1, str2, exp_times, reference_timepoints,win);
    save(strcat(dist_file_prefix,num2str(Tw(i))),'frozen','corr_C','corr_A','mag_A','mag_B','mag_C');
    
    disp(i)
end

    
