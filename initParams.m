function [num_spins, exp_times, gamma, H] = initParams()
% num_spins - number of spins in the network
% exp_times - array of 1X3 determining the duration of each part of the
%             simulation
% gamma     - the std of the distribution of the interaction coefficients
% H         - array of 1X3 determining the value of the external magnetic field in each
%             part of the simulation

    num_spins = 2^14;
    exp_times = [2000, 3000, 9000]; % 2000 iterations is reasonable for a system in this gamma to relax in the beginning, and 9000 should be more than enough to relax in the end
    gamma = 1.5; % close to the transition
    H = [0, 0.8, 0];
end
