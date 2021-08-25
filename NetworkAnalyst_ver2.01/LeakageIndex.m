function [ LeakInd ] =...
    LeakageIndex( AdjMatrix, Fc_EdgesW, Subnetwork,OutletSubFlag, Fc_NodesW )
%LEAKAGE INDEX Calculate the Leakage Index (LI) in each subnetwork
%   LeakInd - Leakge Index matrix
%   AdjMatrix - The binary, directed adjacency matrix
%   Fc_EdhesW - matrix of weighted flux in each edge
%   Subnetwork - The binary subnetwork file
%   OutletSubFlag - Outlet subnetwork flag matrix
%   Fc_NodesW - Vector weighted flux at each node

% Created by Matt Hiatt, m.r.hiatt@uu.nl
% The metric is the design of Tejedor et al (2015a,b). Those papers should
% be cited if publishing results using this code.

%% Description of metric
% The leakage index is the proportion of flux lost to other subnetworks
% relative to the total flux in the subnetwork. More specifically, it is
% the sum of the fluxes at all upsteam nodes minus the sum of the fluxes in
% each link. This difference is normalized by the sum of the fluxes at
% upstream nodes to give the Leakeage Index. A high value indicates that
% most of the flux in the subnetwork is delvered to another subnetwork
% before reaching it's outlet while a low value indicates that the bulk of
% the flux is contained within the subnetwork and is usbsequently delivered
% out of the system through the subenwtork outlet.
%% Preallocate output
LeakInd = zeros(size(AdjMatrix));

%% Calculate Leakage Index
for ii = 1:size(AdjMatrix,1)
    for jj = 1:size(AdjMatrix,2) 
        % Define fluxes
        Fv = 0; Fuv = 0;
        % Go to outlet subnetworks
        if OutletSubFlag(ii,jj)==1
            % Find the upstream nodes
            [~,Nodes] = find(Subnetwork{ii,jj});
            % Name nodes
            Nodes = unique(Nodes);
            % Sum the fluxes at the upstream nodes
            Fv = sum(Fc_NodesW(unique(Nodes)));
            % Sum the fluxes in the edges
            for aa = 1:size(AdjMatrix,1)
                for bb = 1:size(AdjMatrix,1)
                    if Subnetwork{ii,jj}(aa,bb) > 0
                        Fuv = Fuv + Fc_EdgesW(aa,bb);
                    end
                end
            end    
            % Calculate index
            LeakInd(ii,jj) = LeakInd(ii,jj) + (Fv - Fuv)./Fv;
        else
            LeakInd(ii,jj) = LeakInd(ii,jj) + (Fv - Fuv)./Fv;
        end
    end
end

%%% EOF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

