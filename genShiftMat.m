function [ M ] = genShiftMat( n )
% M - a cyclic permutation matrix of n x n
    M = zeros(n);
    M(1:end-1,2:end)=eye(n-1);
    M(end,1)=1;
end

