function [ SymMatrix ] = SymmetryMatrix( AdjMatrix )
%SYMMETRYMATRIX - MAKE A MATRIX SYMMETRICAL

SymMatrix = AdjMatrix + AdjMatrix';

end

%%% EOF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
