function [ NumAltPath ] = ...
    NumAltPaths_ver02( AdjMatrix, NumNodes, Subnetwork, OutletSubFlag )

%% Number of Alternative Paths for OutletSubnetworks
% This script calculates th number of alternative paths from source to sink
% in an outlet subnetwork. The adjacency matrix must be a binary, directed
% graph.

% This script is much more efficient (memory and speed) than ver01 since
% the number of alternative paths is limited to calculation within the
% outlet subnetworks. This sacrifices completeness for speed but doesn't
% really alter the analysis.

% Created by Matt Hiatt, m.r.hiatt@uu.nl
% The metric is the design of Tejedor et al (2015a,b). Those papers should
% be cited if publishing results using this code.

[rr,cc] = find(OutletSubFlag);
vec2 = cell(NumNodes);
val2 = cell(NumNodes);
NumAltPath = zeros(size(AdjMatrix));

% Identify the outlets each subnetwork and determine the matrix MM =
% (I*-A^T)
for ii = 1:nnz(OutletSubFlag)
        % Reset variables
        I_Star = eye(size(AdjMatrix));
        % Zero out the outlet in the identity matrix
        I_Star(rr(ii),rr(ii)) = 0;
        MM = I_Star - transpose(Subnetwork{rr(ii),cc(ii)'});
        % Next need to get the eigenvectors
        [vec2{rr(ii),cc(ii)},val2{rr(ii),cc(ii)}] = eig(MM);
        clear MM
        % The outlet to the subnetwork is ii and the apex is jj. So, I need
        % to go to vec2{ii,jj} and select element (jj,ii). This element
        % needs to be normalized by the smallest value in vec2{ii,jj}(:,ii)
        % The eignevector must span the null space but matlab doesn't order
        % them in any fashion, so we need to find the one we are interested
        % and assign it an index. There should only be one considering we
        % are dealing with subnetworks with only one outlet.
        for aa = 1:size(Subnetwork,2)
            if max(val2{rr(ii),cc(ii)}(:,aa))==0
                index = aa;
            end
        end
        [~,~,v] = find(vec2{rr(ii),cc(ii)}(:,index));
        % All subnetworks
        NumAltPath(rr(ii),cc(ii)) = vec2{rr(ii),cc(ii)}(cc(ii),index)./min(v);
        % Clear self-loops
        NumAltPath(rr(ii),rr(ii)) = 0;
end

%%% EOF
end
