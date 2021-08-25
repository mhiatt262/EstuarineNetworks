function [ TPD ] = ...
    TopologicPairwiseDependence( Subnetwork, OutletSubFlag, direction )
%Topologic Pairwise Dependence finds the topologic overlapping on a
%subnetwork-to-subnetwork scale detailed in Tejedor et al. 2015

%   TPD - Topologic Pairwise Dependence
%   Subnetwork - Binary subnetwork cell array containing adjacency matrices for each subnetwork
%   OutletSubFlag - Binary matrix detailing node-node pairings of outlet
%   subnetworks
%   direction - 1 for flood, 0 for ebb

% Created by Matt Hiatt, m.r.hiatt@uu.nl
% The metric is the design of Tejedor et al (2015a,b). Those papers should
% be cited if publishing results using this code.


%I believe that the steps to calculate this metric as detailed in Tejedor
%et al. 2015 are wrong, or at least not representative of the results they
%acheive. Basically there is absolutely no way the TPD as detailed in their
%paper can acheive a value less than 0.5, but they nevertheless have those
%values in their results. To get results that actually range between 0 and
%1, I have changed the values given for the b-values.

% 20/05/2017 - Alex Tejedor confirmed with me that the formulations in the
% papers (Tejedor et al 2015a,b) is wrong. The way I have done it is
% correct.

if direction == 1
    [rr,cc] = find(OutletSubFlag);
    TPD = zeros(length(rr),length(rr));
    b = zeros(length(rr),length(rr));
    bb = b;



    for ii = 1:length(rr)
        Ni = nnz(Subnetwork{rr(ii),cc(ii)});
        for jj = 1:length(rr)
            if ii ~= jj
                % Go to each link in subnetwork ii
                ind = find(Subnetwork{rr(ii),cc(ii)});
                for aa = 1:Ni
                    if Subnetwork{rr(jj),cc(jj)}(ind(aa))==1
                        b(ii,jj) = 1;
                        bb(ii,jj) = bb(ii,jj) + 1/b(ii,jj);
                    else
                        b(ii,jj) = 0;
                        bb(ii,jj) = bb(ii,jj) + b(ii,jj);
                    end
                end
                TPD(ii,jj) =1/Ni*bb(ii,jj);
            end
        end
        TPD(ii,ii) = 1;
    end
    
else

    [rr,cc] = find(OutletSubFlag);
    [rr,SortIndex] = sort(rr);
    cc = cc(SortIndex);
    
    TPD = zeros(length(rr),length(rr));
    b = zeros(length(rr),length(rr));
    bb = b;



    for ii = 1:length(rr)
        Ni = nnz(Subnetwork{rr(ii),cc(ii)});
        for jj = 1:length(rr)
            if ii ~= jj
                % Go to each link in subnetwork ii
                ind = find(Subnetwork{rr(ii),cc(ii)});
                for aa = 1:Ni
                    if Subnetwork{rr(jj),cc(jj)}(ind(aa))==1
                        b(ii,jj) = 1;
                        bb(ii,jj) = bb(ii,jj) + 1/b(ii,jj);
                    else
                        b(ii,jj) = 0;
                        bb(ii,jj) = bb(ii,jj) + b(ii,jj);
                    end
                end
                TPD(ii,jj) =1/Ni*bb(ii,jj);
            end
        end
        TPD(ii,ii) = 1;
    end
end

%%% EOF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%