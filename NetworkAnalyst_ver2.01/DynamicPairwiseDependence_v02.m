function [ DPD ] =...
    DynamicPairwiseDependence_v02( Fc_EdgesW, Subnetwork, OutletSubFlag, direction )
%DYNAMIC PAIRWISE DEPENDENCE 
%   This metric is akin to the TPD. It  is the ratio of the flux shared
%   between two subnetworks Si and Sj to the flux contained within the
%   subnetwork Si.

%   Subnetwork - Binary subnetwork cell array containing adjacency matrices for each subnetwork
%   OutletSubFlag - Binary matrix detailing node-node pairings of outlet
%   subnetworks
%   direction - 1 for flood, 0 for ebb
%   Fc_EdgesW - Matrix containing weighted fluxes for each edge

% 08/06/2017 - Correction by M. Hiatt. The original function calculated the
% DPD incorrectly by calling the Subnetwork weights rather than the fluxes.
% This has been corrected.

% Created by Matt Hiatt, m.r.hiatt@uu.nl
% The metric is the design of Tejedor et al (2015a,b). Those papers should
% be cited if publishing results using this code.

if direction == 1

    [rr,cc] = find(OutletSubFlag);
    DPD = zeros(length(rr),length(rr));

    for ii = 1:length(rr)
        TotalFlux = Fc_EdgesW.*Subnetwork{rr(ii),cc(ii)};
        Fv = sum(sum(TotalFlux));
        for jj = 1:length(rr)
            if ii ~= jj
                % Now check the other subnetworks
                ind_i = find(Subnetwork{rr(ii),cc(ii)});
                ind_j = find(Subnetwork{rr(jj),cc(jj)});
                ind_intersect = intersect(ind_i,ind_j);
                if nnz(ind_intersect) > 0 
                    Fu = sum(Fc_EdgesW(ind_intersect));
                    DPD(ii,jj) = Fu./Fv;
                else
                    DPD(ii,jj) = 0;
                end
            else
                DPD(ii,jj) = 1;
            end 
        end 
    end

else
    [rr,cc] = find(OutletSubFlag);
    [rr,SortIndex] = sort(rr);
    cc = cc(SortIndex);
    DPD = zeros(length(rr),length(rr));

    for ii = 1:length(rr)
        TotalFlux = Fc_EdgesW.*Subnetwork{rr(ii),cc(ii)};
        Fv = sum(sum(TotalFlux));
        for jj = 1:length(rr)
            if ii ~= jj
                % Now check the other subnetworks
                ind_i = find(Subnetwork{rr(ii),cc(ii)});
                ind_j = find(Subnetwork{rr(jj),cc(jj)});
                ind_intersect = intersect(ind_i,ind_j);
                if nnz(ind_intersect) > 0 
                    Fu = sum(Fc_EdgesW(ind_intersect));
                    DPD(ii,jj) = Fu./Fv;
                else
                    DPD(ii,jj) = 0;
                end
            else
                DPD(ii,jj) = 1;
            end 
        end 
    end
    
end
end


