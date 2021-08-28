% this function assumes a GPU, if no GPU is available - erase the
% 'gpuArray' option in line 19 and 67

function [J_ij ,JInfo] = initJij(num_spins, gamma)
% J_ij (num_spins x num_spins, gpuArray single):
%         the interaction matrix.
%         initialized on the gpu for performence.
%         single also in favor of performence.
%         depends on gamma for the connection strength between cycles.
%         assumes 1/L^2 distribution of cycles length, between 3 and 1000.
%         for a full definition see "Interaction Matrix" at the main documentation.
% JInfo (2 x num_spins, gpuArray single):
%         JInfo(1,i) - for the i'th spin, the index of the beginning of the 
%         cycle it belongs to. 
%         JInfo(2,i) - for the i'th spin, the length of the cycle it
%         belongs to
    
    % the matrix is generally sparse, initialize with zeros
    J_ij = zeros(num_spins,num_spins,'single','gpuArray');
    
    % generate cycle lengths
    blocks_locations = []; % list of the indexes where each cycle starts
    blocks_sizes = []; % list of the sizes of each cycle
    cummulative_len = 0; % sum of all the cycle lenghts generated so far
    while cummulative_len ~= num_spins
        % L = floor(3/rand()) generates a random number from a powerlaw dist.
        % proportional to 1/L^2. this could be checked by taking:
        % x = floor(3./rand(1,1000));
        % pdf = histcounts(x,1:100000)/1000;
        % loglog(pdf);
        block_size = floor(1/(rand()^(1/0.5)));
        % maximum length is 1000, so if length is exceeded - draw again.
        while block_size>2500
            block_size = floor(1/(rand()^(1/0.5)));
        end
        
        startt = cummulative_len + 1; % the current block starts right after the last one
        finn = min(startt+block_size-1, num_spins); % if the current ending point exceeds the number of spins, cut it
        block_size = finn-startt+1; % this is important if the size was cut in the previous command
        
        blocks_locations = [blocks_locations startt];
        blocks_sizes = [blocks_sizes block_size];
        cummulative_len = finn;
    end
    
    
    % choose the coupled spins between cycles
    coupling_idx = []; % the spins that talks with other cycles.
                       % one spin of each cycle is randomly chosen to be in this list
    for b = 1:numel(blocks_sizes) % for each cycle
        if blocks_sizes(b)>1 % the last cycle might be 1 or 2 spins in length, and if so we dismiss it
            % draw a random spin index from the block's spins
            coupling_idx = [coupling_idx, blocks_locations(b)-1+randperm(blocks_sizes(b),1)];
        end
    end
    
    
    % J_ij(C,R) are the interaction coefficients that are not zero between
    % blocks
    [C,R] = meshgrid(coupling_idx,coupling_idx);
    C = reshape(C,[1 numel(C)]);
    R = reshape(R,[1 numel(R)]);
    % initialize J_ij(C,R) to be from ~N(0,gamma/sqrt(#Blocks))
    J_ij(sub2ind(size(J_ij),C,R)) = reshape(randn(numel(coupling_idx),numel(coupling_idx),'single')* (gamma/sqrt(numel(blocks_sizes))),[1 numel(C)]);

    % set JInfo, and set the permutation block martices in J_ij
    JInfo = zeros(2,num_spins,'single','gpuArray');
    for b = 1:numel(blocks_sizes)
        block_size = blocks_sizes(b);
        startt = blocks_locations(b);
        finn = startt+block_size-1;
        JInfo(:,startt:finn) = repmat([startt,block_size].',1,block_size); % for each spin, the informtion in JInfo is the same: block's starting location and block size
        J_ij(startt:finn, startt:finn) = genShiftMat(block_size);
    end
end

