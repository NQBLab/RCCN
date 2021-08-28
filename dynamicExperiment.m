function [] = dynamicExperiment(J_ij,num_spins, exp_times,H, current_run,prefix_str)    
% the function initializes the spin vector s, and advances the time, in each
% iteration computing the next value of s and saves the entire history of
% the dynamics.


    % spins - the s vector, current value of each spin
    % spins_hist - the history of the spins, the value of the spins vector
    % for every iteration. this is the interesting result of the
    % simulation. To minimize the size, the data is stored in a binary
    % form, having true indicating a value of 1 and false a value of -1.
    % spins_hist_idx - the current time, starts at 1
    [spins, spins_hist, spins_hist_idx] = initSpins(num_spins, sum(exp_times));
    % running over each part of the experiment
    for exp_part = 1:3
        for iter = 1:exp_times(exp_part)
            spins_hist(:,spins_hist_idx) = spins>0; % spins_hist save the data in binary
            spins_hist_idx = spins_hist_idx + 1; % advance the time counter
            
            % this is what defines the dynamics: 
            % loc_field is what each spin 'feel' locally, and in every iteration it
            % chooses to orient in the direction of this field.
            loc_field = J_ij * spins + H(exp_part) + 0*(rand(num_spins,1,'single','gpuArray')-0.5); % a small amount of noise can be added
            spins = sign(loc_field);
            
        end
    end
    
    % save
   st = strcat(prefix_str,'R',num2str(current_run));
   save(st,'spins_hist');
end

