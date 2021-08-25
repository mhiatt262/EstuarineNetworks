function [W_cycle,Unweight_cycle, rInlets, rOutlets ] = ...
    CycledAdjmatrix( AdjMatrix , NormWidthAdjMat , NumNodes,...
    DegOutUnweight, DegInUnweight)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% Find inlets and outlets
Unweight_cycle = AdjMatrix;
W_cycle = NormWidthAdjMat;
InNodes = zeros(NumNodes,1);
OutNodes = zeros(NumNodes,1);
for ii = 1:NumNodes
    % In Nodes
    if DegInUnweight(ii,ii)==0
        if DegOutUnweight(ii,ii)>0
            InNodes(ii,1) = 1;
        end
    % Out Nodes    
    elseif  DegInUnweight(ii,ii)>0
        if  DegOutUnweight(ii,ii)==0
            OutNodes(ii,1) = 1;
        end
    else
        InNodes(ii,1) = 0;
        OutNodes(ii,1) = 0;
    end    
end

% Count the inlets and outlets
TotalOutlets = nnz(OutNodes);
TotalInlets = nnz(InNodes);

% Give indices to the outlet & inlet nodes
[rInlets,~] = find (InNodes);
[rOutlets,~] = find (OutNodes);

% Figure the fraction of flux allocated if there were no weighting
UnWeightedPart = 1/TotalInlets;

% Figure the allocation of weights for the weighted cycled matrix
W_cycle(rInlets,rOutlets) = 9000;
[r_w,c_w] = find(W_cycle==9000);
% Sum the inlets such that weighted proportions can be calculated
Raw_Sum = sum(NormWidthAdjMat,1);
Inlet_Sum = zeros(1,NumNodes);

for ii = 1:length(r_w)
    % Name inlet and outlet
    inlet = r_w(ii);
    outlet = c_w(ii);
    Inlet_Sum(1,inlet) = Raw_Sum(1,inlet);
end

% Calculate how fluxes should be partitioned among inlets
TotalInletWeight = sum(Inlet_Sum);
Inlet_Part = Inlet_Sum./TotalInletWeight;

% Assign to weighted Adjacency Matrix
for ii = 1:length(r_w)
    W_cycle(r_w(ii),c_w(ii)) = Inlet_Part(r_w(ii));
end

% Assign to adjacency unweighted matrix
Unweight_cycle(rInlets,rOutlets) = UnWeightedPart;

end

