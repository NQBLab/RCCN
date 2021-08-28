% this is the script that starts the execution of a series of simulation
% experiments.
% the script runs the the simulation 'run_num' number of times for different 
% waiting times (tw). run_num is equivalent to the number of cells.
% in each run, J might be different (different realizations), or J is the same 
% but the initial condition is different.
% the script outputs to the dest_folder a matlab file containing all the
% information of each run for each tw, and files containing information of 
% the J matrices that were used.
% On our GPU, it takes around a minute for a single run for a single tw.

% this function assumes a GPU, if no GPU is available, small adaptations
% are needed
% - deleting the references to the gpu from this function and from the
% functions that are being called.

% reset the gpu
d = gpuDevice;
reset(d);
% initializing parameters
dest_folder = 'Experiments/Spins/Exp1';
different_initial_conditions = false; % true  - same J matrix, different initial
                                     %         conditions for each run
                                     % false - different J matrix for each run
tw = [20,40,80,160,320,640,1280,3000]; % different time durations for the external magnetic field
run_num = 900; % number of runs for each tw
% num_spins - number of spins in the network
% exp_times - array of 1X3 determining the duration of each part of the
%             simulation
% gamma     - the std of the distribution of the interaction coefficients
% H         - array of 1X3 determining the value of the external magnetic field in each
%             part of the simulation
[num_spins, exp_times, gamma, H] = initParams();

if different_initial_conditions
        % generate the J matrix which will be constant for all the runs
        % J_ij - the interaction matrix
        % JInfo - information about the interaction matrix, relevant for
        % later data processing. the information includes the size of each
        % loop, in a format explained inside the function
        [J_ij,JInfo] = initJij(num_spins, gamma);
        JInfo = gather(JInfo); % gather(A) converts gpuArray to regular array
        st = strcat(dest_folder,'/JInfo');
        save(st,'JInfo'); % save JInfo to a file, for later use
        J_ij_backup = gather(J_ij); % in every run reset(d) will delete J_ij 
                                    % from the GPU, so we backup it
end

for r = 1:run_num % r - the current run index, there are run_num runs for every tw
    for i = 1:length(tw)
        exp_times(2)=tw(i);
        
        % generate the matrix J
        if different_initial_conditions
            J_ij = gpuArray(J_ij_backup);
        else
            [J_ij,JInfo] = initJij(num_spins, gamma);
            JInfo = gather(JInfo);
            st = strcat(dest_folder,'/JInfo','T',num2str(tw(i)),'R',num2str(r)); 
            save(st,'JInfo'); % save JInfo to a file, for later use, with the indication of the current run and Tw in the name of the file
        end
        
        % run the experiment, also saves the results to a file
        dynamicExperiment(J_ij,num_spins,exp_times,H,r,strcat(dest_folder,'/T',num2str(tw(i)))); 
        
        wait(d); % wait for gpu to end what it's doing
        reset(d); % reset gpu
       
        disp(tw(i))
    end
    disp(r)
end
