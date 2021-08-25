function [ Subnetwork, SubnetworkWeight ] = ...
    SubnetCreate_Sparse_v02( AdjMatrix, NormWidthAdjMat, NumNodes, OutletSubFlag )
%SubnetCreate_Sparse_v02 Create outlet subnetworks
%   AdjMatrix - The binary directed adjacency matrix
%   NormWidthAdjMatrix - The wieghted directed adjacency matrix
%   NumNodes - The number of nodes in AdjMatrix and NormWidthAdjMat
%   OutletSubFlag - a binary matrix indicating the node-node pairings for
%   outlet subnetworks

% This step is the most compuationally expensive portion of the code due to
% the identification of paths in the graphtraverse function.
% This version is more optimized than version one because it only
% calculates the Subnetwork matrix for outlet subnetworks, which
% drasticallly improves memory and speeds performance at the expense of
% less detailed information. This allows for the analysis of networks > 200
% with relative ease, whereas the system tends to lock up if calculating
% for the entire spectrum of subnetworks.

%% Preallocate outputs
DG = sparse(AdjMatrix');
Subnetwork = cell(NumNodes); 
SubnetworkWeight = cell(NumNodes);

%% Find outlet and inlet nodes
[rr,cc] = find(OutletSubFlag);

%% Identify the network by traversing the graph between inlets and outlets
for ii = 1:nnz(OutletSubFlag)
    for jj = 1:nnz(OutletSubFlag)
        StartNode = graphtraverse(DG,cc(ii));
        EndNode = graphtraverse(DG',rr(jj));
        h = intersect(StartNode,EndNode);
        DG_Sub = zeros(size(AdjMatrix));
        DG_Sub_Weighted  = zeros(size(AdjMatrix));
        for aa = 1:length(h)
            for bb = 1:length(h)
                if DG(h(aa),h(bb))==1
                    DG_Sub(h(aa),h(bb))=1;
                    DG_Sub_Weighted(h(aa),h(bb)) = NormWidthAdjMat(h(bb),h(aa));
                end
            end
        end
        % Take the transpose to get it to the format that spectral graph
        % theory uses
        Subnetwork{rr(jj),cc(ii)} = sparse(DG_Sub');
        SubnetworkWeight{rr(jj),cc(ii)} = sparse(DG_Sub_Weighted');
        
    end
end

%   EOF
end

