function [ ContribSub, ContribSubUnweight ] = ...
    ContributingSubnetworks(AdjMatrix, DegOutUnweight, NumNodes, LwOut )
%OUTLETSUBNETWORKS Creates Contributing Subnetworks (weighted and unweighted)
%   This function delineates the outlet subnetworks for a network based on:
%   AdjMatrix - the unweighted adjacency matrix
%   DegOutUnweight - The out-degree sparse matrix for AdjMatrix
%   NumNodes - The number of nodes in AdjMatrix
%   LwOut - The weighted Laplacian Matrix based on the out-degree matrix

%   created by Matt Hiatt, m.r.hiatt@uu.nl

% ContribSub is the matrix that identifies the fraction of flux contributed
% from each upstream node to the outlet in question. The column correcponds
% to the outlet node ID and the rows correspond to the node IDs of the
% contributing subnetwork.

% First determine the eigenvectors and eigenvalues of the Laplacian for the
% weighted degree out matrix
[vec,val] = eig(LwOut');

%% Preallocate outputs
ContribSub = zeros(size(AdjMatrix));
ContribSubUnweight = ContribSub;
% index = zeros(1,NumNodes);

%% Calculate flux contribution 
% Determine which eigenvectors/values this corresponds to 
for ii = 1:NumNodes
    ContribSub(ii,ii) = 0;
    vec(:,ii) = vec(:,ii)./max(vec(:,ii));
    if max(val(:,ii))==0
        index = find(vec(:,ii));
%         index = find(vec(:,ii)==1);
        if numel(index)>1
            for jj = 1:numel(index)
                if max(DegOutUnweight(:,index(jj)))==0
                    ind = index(jj);
                    ContribSub(:,ind) = vec(:,ii);
                end
            end
        else
        ContribSub(:,index) = vec(:,ii);
        end
    end
end

%% Eliminate any spurious self-loops
for ii = 1:NumNodes
    ContribSub(ii,ii) = 0;
end

%% Make sparse
ContribSub = sparse(ContribSub');
ContribSubUnweight(ContribSub>0)=1;
ContribSubUnweight = sparse(ContribSubUnweight);

%EOF
end

