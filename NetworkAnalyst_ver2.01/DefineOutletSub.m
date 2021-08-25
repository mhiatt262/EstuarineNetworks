function [ rInlets, rOutlets ] =...
    DefineOutletSub( DegInUnweight, DegOutUnweight, AdjMatrix, NumNodes )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


% Create flag matrix for Outlet Subnetwork
OutletSubFlag = zeros(size(AdjMatrix));

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

[rInlets,~] = find (InNodes);
[rOutlets,~] = find (OutNodes);


clear InNodes; clear OutNodes;

end

