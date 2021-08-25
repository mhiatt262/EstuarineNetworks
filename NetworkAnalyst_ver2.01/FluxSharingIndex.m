function [ FSI ] = ...
    FluxSharingIndex( NumNodes, ContribSub, OutletSubFlag, Subnetwork )
%FLUX SHARING INDEX calculate the Flux Sharing Index (FSI)
%   FSI - Flux sharing index. There is a value at each location where
%   OutletSubFlag = 1.
%   NumNodes - Number of nodes in AdjMatrix
%   Contrib Sub - The proportion of flux from each node that is delivered
%   to the node in question
%   Subnetwork - The binary subnetwork file
%   OutletSubFlag - Outlet subnetwork flag matrix

% Created by Matt Hiatt, m.r.hiatt@uu.nl
% The metric is the design of Tejedor et al (2015a,b). Those papers should
% be cited if publishing results using this code.

%% Preallocate Output
FSI = NaN(NumNodes);

%% Calculate FSI
for ii = 1:NumNodes
    for jj = 1:NumNodes
        if OutletSubFlag(ii,jj)==1
            % The proportion of flux that arrives at the outlet node
            ContribSubProportion = ContribSub.*max(Subnetwork{ii,jj});
            % Average over the subnetwork
            FSI(ii,jj) = 1 - nnz(ContribSubProportion(ii,:))^(-1)*sum(ContribSubProportion(ii,:));
        end
    end
end

%%% EOF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

