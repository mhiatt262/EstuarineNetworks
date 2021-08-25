function [ OutletSubFlag ] =...
    OutletSubFlagCreate( AdjMatrix, rOutlets, rInlets, ContribSub )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% Assign 1s for outlet subnetworks (node-node pairing for a
% outletsubnetwork has a 1 while a subnetwork that is not a source to sink
% subnetwork is given a zero)
% Create flag matrix for Outlet Subnetwork
OutletSubFlag = zeros(size(AdjMatrix));
OutletSubFlag(rOutlets,rInlets) = 1;
OutletSubFlag(ContribSub==0)=0;
OutletSubFlag = sparse(OutletSubFlag);


end

