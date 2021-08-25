function [degreeOut, degreeIn] = degreeOutIn_dir(AdjMatrix)
%degreeOut_dir finds the out-degree matrix
%   This finds the out-degree and in-dgree matrices for each link (or node) in a network
%   or subnetwork. All that is required is the birnary adjacency matrix
%   that can be directed or undirected.
degreeOut = zeros(size(AdjMatrix));
degreeIn = zeros(size(AdjMatrix));

for ii = 1:size(AdjMatrix,1)
    %% Create degree matrices
    degreeIn(ii,ii) = sum(AdjMatrix(ii,:),2);
    degreeOut(ii,ii) = sum(AdjMatrix(:,ii),1);
    
end

degreeOut = sparse(degreeOut);
degreeIn = sparse(degreeIn);

