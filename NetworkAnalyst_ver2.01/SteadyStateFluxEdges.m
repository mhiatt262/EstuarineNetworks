function [ Fc_Edges] = ...
    SteadyStateFluxEdges( AdjMatrix, CycledFlux, rInlets, NormFac )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

Fc_Edges = zeros(size(AdjMatrix));

for ii = 1:size(AdjMatrix,1)
    for jj= 1:1:size(AdjMatrix,2)
        Fc_Edges(ii,jj) = AdjMatrix(ii,jj).*CycledFlux(jj); 
    end
end

% Normalize the inlets such that the incoming and outgoing flux = 100
% Find total inlet flux
InletFlux =sum(sum(Fc_Edges(:,rInlets),1));
% Normalize and multiply by 100
Fc_Edges = Fc_Edges./InletFlux.*NormFac;
Fc_Edges = sparse(Fc_Edges);
end

