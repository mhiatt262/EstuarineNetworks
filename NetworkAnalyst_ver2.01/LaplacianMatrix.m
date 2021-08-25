function [ Laplacian ] = LaplacianMatrix( Degree, AdjacencyMatrix )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

Laplacian = Degree - AdjacencyMatrix;

end

