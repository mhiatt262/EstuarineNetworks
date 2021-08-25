function [ NodesPairings ] =...
    Fluxes2GISformat( StartNodes, EndNodes, Fc_EdgesW, direction, name, LineID )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

[in_nodes,out_nodes,fluxes] = find(Fc_EdgesW);

disp('Creating ArcMap Outputs for Steady Flux...')

% Geo network identifier
if direction == 1
    NodesPairings = cellstr(strcat(num2str(StartNodes),num2str(EndNodes)));
    for ii = 1:size(NodesPairings,1)
        NodesPairings{ii,1}(ismember(NodesPairings{ii,1},' ,.:;!')) = [];
    end
        
else
    NodesPairings = cellstr(strcat(num2str(EndNodes),num2str(StartNodes)));
    for ii = 1:size(NodesPairings,1)
        NodesPairings{ii,1}(ismember(NodesPairings{ii,1},' ,.:;!')) = [];
    end
end

% Matlab network (without trivial loops)
NetworkInfo =  cellstr(strcat(num2str(in_nodes),num2str(out_nodes)));
for ii = 1:size(NetworkInfo,1)
	NetworkInfo{ii,1}(ismember(NetworkInfo{ii,1},' ,.:;!')) = [];
end
% Convert these things back to matrices with numbers
NetworkInfo1=str2double(NetworkInfo);
clear NetworkInfo
% NodesPairings1=zeros(size(NodesPairings,1),size(NodesPairings,2));
NodesPairings=str2double(NodesPairings);

NetworkInfo = [NetworkInfo1 fluxes];
clear in_nodes; clear out_nodes; clear fluxes;


if strcmp(name, 'Dvina_Ebb')==1
    NetworkInfo(8,1)= 99999;
    NetworkInfo1(8,1) = 99999;
    NodesPairings(29,1) = 99999;
end


% Find duplicates

[~,ind] = unique(NodesPairings,'rows');
duplicate_ind = setdiff(1:size(NodesPairings,1), ind)';
duplicate_nodes = NodesPairings(duplicate_ind,1);
rr = ismember(NodesPairings(:,1),duplicate_nodes);

for ii = 1:length(NodesPairings(:,1))
    pp = find(NetworkInfo1(:,1)==NodesPairings(ii));
    if rr(ii,1)==1
        NodesPairings(ii,2) = NetworkInfo(pp,2)./2;
    else
        NodesPairings(ii,2) = NetworkInfo(pp,2);
    end
end

% NodesPairings(:,2) is now the fluxes along the links that are represented
% in the ArcMapFile. I can just copy and paste them directly or export them
% and join the table. I can do this with the line ID. So that is added to
% NodesPairings as NodesPairings(:,3)
NodesPairings(:,3) = LineID;

% cd D:\MattData\Estuary_Images\Results\SteadyStateFluxes
% dlmwrite([name '.csv'],NodesPairings)

clear StartNodes; clear EndNodes; clear LineID; clear duplicate_nodes;
clear ind; clear duplicate_ind; clear NetworkInfo; clear Network_Info1;
clear in_nodes; clear out_nodes; clear fluxes; clear ii; clear rr;
clear pp;

end

