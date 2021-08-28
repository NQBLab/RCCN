% this function assumes a GPU, if no GPU is available - erase the
% 'gpuArray' option in line 13 and 15

function [spins, spins_hist, spins_hist_idx] = initSpins(num_spins, exp_len)
% spins - the s vector, current value of each spin
% spins_hist - the history of the spins, the value of the spins vector
% for every iteration. this is the interesting result of the
% simulation. To minimize the size, the data is stored in a binary
% form, having true indicating a value of 1 and false a value of -1.
% spins_hist_idx - the current time, starts at 1
% num_spins is the number of spins, exp_len is the total time of the
% experiment.

    % random initial state
    spins = sign(0.5 - rand(num_spins,1,'single','gpuArray'));
    % empty spins history
    spins_hist = false(num_spins,exp_len,'gpuArray');
    % fill initial state in the history
    spins_hist(:,1) = spins>0;
    % set initial time to 1
    spins_hist_idx = 1;
end