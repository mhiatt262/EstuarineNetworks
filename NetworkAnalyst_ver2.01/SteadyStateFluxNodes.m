function [ Fc_Nodes] = ...
    SteadyStateFluxNodes( Fc_Edges, rInlets)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

% Flux received by each node
Fc_Nodes = sum(Fc_Edges,2);

% Now need to add also the flux delivered by the inlets
for ii = 1:length(rInlets)
    Fc_Nodes(rInlets(ii)) = sum(Fc_Edges(:,rInlets(ii)),1);
end

end

