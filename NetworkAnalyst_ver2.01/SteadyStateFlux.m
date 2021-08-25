function [ Flux_Cycled ] = SteadyStateFlux( LaplacianOut )
%SteadyStateFlux computes the steady state flux for the input graph
%   Detailed explanation goes here

F_Cycled = abs(null(LaplacianOut));

Flux_Cycled = F_Cycled./max(F_Cycled);


end

