function [ RD_Norm ] = ...
    ResistanceDistance_ver02( NumNodes, Subnetwork, OutletSubFlag, Binary_Dist )
%RESISTANCE_DISTANCE_VER02 Resistance distance in outlet subnetworks
%   NumNodes - Number of nodes in AdjMatrix
%   Subnetwork - Binary Outlet Subnetwork 
%   OutletSubFlag - Outlet subnetwork flag matrix
%   Binary_Dist - Topological distance calculated with the Brain
%   Connectivity Toolbox

% Created by Matt Hiatt, m.r.hiatt@uu.nl
% The metric is the design of Tejedor et al (2015a,b). Those papers should
% be cited if publishing results using this code.

%% Find the outlet subnetworks
[rr,cc] = find(OutletSubFlag);

%% Preallocate output
SymSubnetwork = cell(NumNodes);
RD = zeros(NumNodes);
RD_Norm = zeros(NumNodes);

%% Calculae Resistance Distance
for ii = 1:nnz(OutletSubFlag)
    % Only calculate on outlet subnetworks
        if OutletSubFlag(rr(ii),cc(ii))==1
            % Make subnetwork symmetrical
            SymSubnetwork{rr(ii),cc(ii)} = Subnetwork{rr(ii),cc(ii)}...
                + transpose(Subnetwork{rr(ii),cc(ii)});
            % Find Out Degree
            [degOut,~] = degreeOutIn_dir(SymSubnetwork{rr(ii),cc(ii)});
            % Convert from sparse to full matrix
            degOut = full(degOut);
            % Find symmetrical Laplacian Out
            LSymOut = degOut - SymSubnetwork{rr(ii),cc(ii)};
            % Calculate Morse-Penrose pseudo-inverse
            MorsePen = pinv(LSymOut);
            % Calculate Resistance Distance
            RD(rr(ii),cc(ii)) = MorsePen(cc(ii),cc(ii))+MorsePen(rr(ii),rr(ii))-...
                    MorsePen(rr(ii),cc(ii)) - MorsePen(cc(ii),rr(ii));
            % Normalize by topological distance    
            RD_Norm(rr(ii),cc(ii)) = RD(rr(ii),cc(ii))./Binary_Dist(rr(ii),cc(ii));
        end
end

%%% EOF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

