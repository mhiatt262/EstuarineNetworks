function [ LSI ] = ...
    LinkSharingIndex_ver02( AdjMatrix, Subnetwork, OutletSubFlag )
%LINK_SHARING_INDEX_VER02 Calculate the Link Sharing Index (LSI)
%   LSI - Link sharing index. There is a value at each location where
%   OutletSubFlag = 1.
%   AdjMatrix - The binary, directed adjacency matrix
%   Subnetwork - The binary subnetwork file
%   OutletSubFlag - Outlet subnetwork flag matrix

% Created by Matt Hiatt, m.r.hiatt@uu.nl
% The metric is the design of Tejedor et al (2015a,b). Those papers should
% be cited if publishing results using this code.

%% Find the source and sinks of subnetworks
[rr,cc] = find(OutletSubFlag);

%% Preallocate output
b_link = zeros(size(AdjMatrix));
LSI = zeros(size(AdjMatrix));


%% Find the number of Subnetworks each link belongs to
aa = find(AdjMatrix);
for ii = 1:nnz(AdjMatrix)
    for jj = 1:nnz(OutletSubFlag)
        if Subnetwork{rr(jj),cc(jj)}(aa(ii))==1
            b_link(aa(ii)) = b_link(aa(ii)) + 1;
        end
    end
end

%% Reciprocal
b_invert = b_link.^(-1);
b_invert(isinf(b_invert)) = NaN(1,1);

%% Compute the LSI for each subnetwork
for kk = 1:nnz(OutletSubFlag)
    % Count the number of links the subnetwork kk
    Ni = nnz(Subnetwork{rr(kk),cc(kk)});
    b_sublink = sum(sum(b_invert(Subnetwork{rr(kk),cc(kk)}==1)));
    LSI(rr(kk),cc(kk)) = 1 - Ni^(-1)*b_sublink;
end

%% All uncalculated cells are coverted to NaN's
LSI(OutletSubFlag==0) = nan(1,1);

%%% EOF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

