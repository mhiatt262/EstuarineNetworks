function [ AdjMatrix, NormWidthAdjMat, NormWidthLengthAdjMat ]...
    = CreateAdjmatrix( MedianWidths, Lengths, StartNodes, EndNodes, NumNodes )
%CREATEADJMATRIX creates the various adjacency matrices
%   Creates binary and weighted adjacency matrices

% Preallocate
AdjMatrix = zeros(NumNodes);
NormWidthAdjMat = zeros(NumNodes);
NormWidthLengthAdjMat = zeros(NumNodes);

% Define the max median width for normalization
maxWidth = max(MedianWidths);
% Define adjacency matrices
for ii = 1:length(StartNodes)
    StartID = StartNodes(ii);
    EndID = EndNodes(ii);
    %% Create Unweighted Adjacency Matrix
    AdjMatrix(EndID,StartID) = 1;
    %% Create Weighted Adjacency matrix
    NormWidthAdjMat(EndID,StartID) = MedianWidths(ii)./maxWidth;
    %% Create Weighted Adjacency matrix
    NormWidthLengthAdjMat(EndID,StartID) = MedianWidths(ii)./Lengths(ii);
end


%% Can make sparse if memory issues arise
% AdjMatrix = sparse(AdjMatrix);
% NormWidthAdjMat = sparse(NormWidthAdjMat);
% NormWidthLengthAdjMat = sparse(NormWidthLengthAdjMat);
% EOF
end

