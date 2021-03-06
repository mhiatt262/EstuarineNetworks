clc 
clear
close all
tic;

%% ESTUARY NETWORK ANALYST
% This script reads in information generated by the Python script called
% Autom_NetworkGeneration and converts the data into an adjacency matrix
% which is subsequently analyzed

% Functions (aside from native matlab and BCT functions) are written by
% Matt Hiatt, m.r.hiatt@uu.nl


%% Add the Brain Connectivity Toolbox for analysis
% The Brain Connectivity Toolbox is required to run a number of functions
% in this program (https://sites.google.com/site/bctnet/). Edit the addpath
% command accordingly to point towards a local download
addpath('D:\MattData\BCT\2016_01_16_BCT');


%% Load the data
% 1 for flood, 0 for ebb
direction = 0;
symbol = 's';
system = 'Bannow';

% The variable 'name' is a required variable as it sets the output filename
% for saving variables and figures. It can be commented out, but some
% functions will need to be altered accordingly.

if direction==1
    name = [system '_Flood'];
else
    name = [system '_Ebb'];
end

% The function Load Data Matrix is specific to the dataset, so it will only
% work (in it's current form) with the Python script Autom_NetworkGeneration
data = LoadDataMatrix('D:\MattData\Estuary_Images\LandSat8_OLI\Ireland\Extracted_Channels\Final_export.txt');
% Delete coordinates automatically generated by ArcMap
data(:,1:2) = [];


%% Rectify the direction of the links
% If the direction of the links is known in advance, this is probably
% unecessary.
[ StartNodes, EndNodes ] = DirectionIndexDef( data );


%% Create Adjacency Matrices
% The adjacency matrix shows the connectivity of the network
% The size of the adjacency matrix is equal to the number of nodes in the
% network

disp('Creating the adjacency matrices...')

% Define some of the variables
NumNodes = max(max(data(:,end-2:end-1)));
MedianWidths = data(:,end-3);
% maxWidth = max(MedianWidths);
Lengths = data(:,1);

% Remove Raw data
LineID = data(:,2);
clear data

% Calculate
[ AdjMatrix, NormWidthAdjMat, NormWidthLengthAdjMat ]...
    = CreateAdjmatrix( MedianWidths, Lengths, StartNodes, EndNodes, NumNodes );

% Make a symmetrical matrix
[ SymMatrix ] = SymmetryMatrix( AdjMatrix );

clear MedianWidths; clear maxWidth; clear Lengths;
%% Spectral Radius
SpectralRadius = max(abs(eig(SymMatrix)));
NumLinks = nnz(AdjMatrix);

%% Define by Length Also
% NormWidthAdjMat = NormWidthLengthAdjMat;

%% Determine whether this will be landward or seaward flow
if direction == 1
    AdjMatrix = transpose(AdjMatrix);
    NormWidthAdjMat = transpose(NormWidthAdjMat);
end


%% Define binary topologic distance
Binary_Dist = distance_bin(AdjMatrix);
% Make sparse
Binary_Dist = sparse(Binary_Dist);

%% Calculate clustering
Transitivity = transitivity_wd(AdjMatrix);
Clustering_Coeff = clustering_coef_wd(AdjMatrix);
[R,~] = randmio_dir(NormWidthAdjMat,100);
Transitivity1 = transitivity_wd(R);
Clustering_Coeff1 = clustering_coef_wd(R);

%% Calculate the in- and out-degree matrices

disp('Creating Degree Matrices and Laplcaians...')

% Unewighted
[DegOutUnweight, DegInUnweight] = degreeOutIn_dir(sparse(AdjMatrix));

% Weighted
[DegOutWeight, DegInWeight] = degreeOutIn_dir(sparse(NormWidthAdjMat));



%% Outlet subnetwork flag
disp('Find Outlet Subnetworks...')
[ rInlets, rOutlets ] = ...
    DefineOutletSub( DegInUnweight, DegOutUnweight, AdjMatrix, NumNodes );

%% Connectivity for flux recycling at steady state calculation
% This must be determined on a case by case basis
% The number of inlet and outlet nodes must be determined so that the flow
% can be split equally among them

disp('Determining Network Fluxes...')

[W_cycle,Unweight_cycle, rInlets, rOutlets ] = ...
    CycledAdjmatrix( AdjMatrix , NormWidthAdjMat , NumNodes,...
    DegOutUnweight, DegInUnweight);

%% Create Cycled (un)Weighted degree matrices
% Unweighted
[DegOutCycle, DegInCycle] = degreeOutIn_dir(Unweight_cycle);
% Weighted
[DegOutCycleW, DegInCycleW] = degreeOutIn_dir(W_cycle);

%% Define in- and out-Laplacians
% Unweighted
Lout = LaplacianMatrix( DegOutUnweight, AdjMatrix );
Lin = LaplacianMatrix( DegInUnweight, AdjMatrix );
% Weighted
LwOut = LaplacianMatrix( DegOutWeight, NormWidthAdjMat );
LwIn = LaplacianMatrix( DegInWeight, NormWidthAdjMat );
% Cycled
LcOut = LaplacianMatrix( DegOutCycle, Unweight_cycle );
LcIn = LaplacianMatrix( DegInCycle, Unweight_cycle );
% Cycled & Weighted
LcOutW = LaplacianMatrix( DegOutCycleW, W_cycle );
LcInW = LaplacianMatrix( DegInCycleW, W_cycle );

%% Compute Steady State Flux
% Unweighted
F_Cycled = SteadyStateFlux( LcOut );
% Weighted
F_CycledW = SteadyStateFlux( LcOutW );

% Set total flux entering the domain (default = 100)
NormFac = 100;
% Calculate for the edges
% Unewighted
[ Fc_Edges ] = ...
    SteadyStateFluxEdges( AdjMatrix, F_Cycled, rInlets, NormFac );
% Weighted
[ Fc_EdgesW ] = ...
    SteadyStateFluxEdges( NormWidthAdjMat, F_CycledW, rInlets, NormFac );

% Calculate for the nodes
% Unweighted
[ Fc_Nodes ] = ...
    SteadyStateFluxNodes( Fc_Edges, rInlets);
% Weighted
[ Fc_NodesW ] = ...
    SteadyStateFluxNodes( Fc_EdgesW, rInlets);

if direction==1
    Fc_Edges = full(Fc_EdgesW'); 
else
    Fc_Edges = full(Fc_EdgesW); 
end

[~,~,Fc_Edges_Output] = find(Fc_EdgesW);
%% Output weighted fluxes to the arcmap file
% The issue here is that the geo file has these trivial loops that aren't
% recognized in spectral graph theory so they aren't showing up in the
% matlab adjacency matrix. We need to ID these node-node pairings and split
% the flux among them for export back to arcmap. The following function
% does just that. If you do not care about GIS output, you can comment out
% this function. It is not needed for the remaining functions.
[ NodesPairings ] =...
    Fluxes2GISformat( StartNodes, EndNodes, Fc_EdgesW, direction, name, LineID );

%% Outlet Subnetworks
% Finds contributing subneworks for the outlet nodes
disp('Finding flux contibutions...')

% ContribSub is the matrix that identifies the fraction of flux contributed
% from each upstream node to the outlet in question. The column correcponds
% to the outlet node ID and the rows correspond to the node IDs of the
% contributing subnetwork.

[ ContribSub, ContribSubUnweight ] = ...
    ContributingSubnetworks(AdjMatrix, DegOutUnweight, NumNodes, LwOut );

% Create flag matrix for Outlet Subnetwork
[ OutletSubFlag ] = OutletSubFlagCreate( AdjMatrix, rOutlets, rInlets, ContribSub );

%% Create Digraph in the bioinformatics toolbox
% The bioinformatics tooldbox operates on an adjacency matrix defined as
% the transpose of the adjacency matrix defined for the rest of the
% analysis

% Create weighted and unweighted full subnetwork matrices
disp('Creating Outlet Subnetworks...')
tic;
[ Subnetwork, SubnetworkWeight ] = ...
    SubnetCreate_Sparse_v02( AdjMatrix, NormWidthAdjMat, NumNodes, OutletSubFlag );
toc;

%% Topologic Complexity
%% Number of Alternative paths
% Find for every subnetwork node pairing
disp('Calculating Number of Alternative Paths...')
tic;
[ NumAltPathOutlets ] = ...
    NumAltPaths_ver02( AdjMatrix, NumNodes, Subnetwork, OutletSubFlag );
toc;
NumAlt_Export = NumAltPathOutlets(:);
NumAlt_Export(NumAlt_Export==0)=[];


%% Resistance Distance
% Subnetwork i defined as the contributing network beginging at some node v
% (subnetwork apex) and ending at node u (subnetwork outlet). These
% subnetworks were already calculated using the bioinformatics tools
disp('Calculating Resistance Distance...')
tic;
[ RD_Norm ] = ...
    ResistanceDistance_ver02( NumNodes, Subnetwork, OutletSubFlag, Binary_Dist );
toc;
RD_Norm_Export = RD_Norm(:);
RD_Norm_Export(RD_Norm_Export==0)=[];


%% Link Sharing Index
% All of the contributing subnetworks have been identified in an earlier
% step. The papers of Tejedor et al. 2015 identify the LSI for only the
% outlet subnetworks

disp('Calculating Link Sharing Index...')
tic;
[ LSI ] = ...
    LinkSharingIndex_ver02( AdjMatrix, Subnetwork, OutletSubFlag );
toc;
LSI_export = LSI(:);
LSI_export(isnan(LSI_export)) = [];

%% Dynamic Complexity of networks
%% Leakage Index
% Subnetwork leakage for all subnetworks (the calculation does not depend
% on specifying whether or not they are outlet subnetworks since it is
% normalized. So this calculation is universal in that it gets not only the
% outlet subnetworks correct, but also the internal subnetworks.
[ LeakInd ] = ...
    LeakageIndex( AdjMatrix, Fc_EdgesW, Subnetwork, OutletSubFlag, Fc_NodesW );

LeakIndExport = LeakInd(~isnan(LeakInd(:)));

%% Flux Sharing Index
% This is only counted for the source to sink nodes
[ FSI ] = ...
    FluxSharingIndex( NumNodes, ContribSub, OutletSubFlag, Subnetwork );

FSI_export = FSI(~isnan(FSI(:)));


%% Topological pairwise dependence
[ TPD ] = TopologicPairwiseDependence( Subnetwork, OutletSubFlag, direction );
figure;
imagesc(TPD, [0 1]);
set(gca,'Ydir','normal')
colormap(jet)
title('Topologic Pairwise Dependence')
colorbar

% Save figure as eps
hh = gcf;
filename = ['D:\MattData\Estuary_Images\Results\TPD\TPD_' name '.eps'];
% saveas(hh,filename, 'epsc');

%% Dynamic pairwise dependence (DPD)
[ DPD ] = DynamicPairwiseDependence_v02( Fc_EdgesW, Subnetwork,...
    OutletSubFlag, direction );
figure;
imagesc(DPD, [0 1]);
set(gca,'Ydir','normal')
colormap(jet)
title('Dynamic Pairwise Dependence')
colorbar

hh = gcf;
filename = ['D:\MattData\Estuary_Images\Results\DPD\DPD_' name '.eps'];
% saveas(hh,filename, 'epsc');

figure;
imagesc(DPD./TPD);
set(gca,'Ydir','normal')
colormap(jet)
title('DPD/TPD')
colorbar

hh = gcf;
filename = ['D:\MattData\Estuary_Images\Results\DPD\DPDTPD_' name '.eps'];
% saveas(hh,filename, 'epsc');

figure;
boxplot(DPD(:));
ylabel('DPD')

hh = gcf;
filename = ['D:\MattData\Estuary_Images\Results\DPD\DPDBOX_' name '.eps'];
% saveas(hh,filename);

% Save the TPD and DPD 
% save(['D:\MattData\Estuary_Images\Results\TPD\TPD' name '.txt'],'TPD','-ASCII')
% save(['D:\MattData\Estuary_Images\Results\DPD\DPD' name '.txt'],'DPD','-ASCII')

%% Navigate to save folder
cd('D:\MattData\Estuary_Images\Results')
 %% Plot the directed network with unweighted steady state fluxes
% figure
% GG = digraph(Fc_EdgesW');
% h = plot(GG,'EdgeLabel',GG.Edges.Weight);

%% Plot the distributions for...
% The Leakage Index (LI)
figure;
boxplot(LeakInd(~isnan(LeakInd)));
ylim([0 1]);
ylabel('Leakage Index (-)')
set(gcf);
% saveas(gcf,['LeakInd',name,'.eps'],'epsc');

% The Resistance Distance 
figure;
boxplot(RD_Norm_Export(~isnan(RD_Norm_Export)));
ylim([0 1]);
ylabel('Resistance Distance (-)')
set(gcf);
% saveas(gcf,['RD',name,'.eps'],'epsc');

% The Link Sharing Index (LSI)
figure;
boxplot(LSI(~isnan(LSI)));
ylim([0 1]);
ylabel('Link Sharing Index (-)')
set(gcf);
% saveas(gcf,['LSI',name,'.eps'],'epsc');

% Num of Alternative Paths

figure;
boxplot(NumAlt_Export(~isnan(NumAlt_Export)));
% ylim([0 35]);
ylabel('Number of Alternative Paths')
set(gcf);
% saveas(gcf,['NumAlt',name,'.eps'],'epsc');

% RD vs NAP
figure;
semilogx(NumAlt_Export(~isnan(NumAlt_Export)),RD_Norm_Export(~isnan(RD_Norm_Export)),symbol);
ylabel('Resistance Distance (-)');
xlabel('Number of alternative paths');
ylim([0 1])
% xlim([0 10^4])
set(gcf);
% saveas(gcf,['RD_NumAlt',name,'.eps'],'epsc');

% Flux sharing index

figure;
boxplot(FSI(~isnan(FSI)));
ylim([0 1]);
ylabel('Flux Sharing Index (-)')
set(gcf);
% saveas(gcf,['FSI',name,'.eps'],'epsc');

% LI vs FSI

figure;
plot(LeakInd(~isnan(LeakInd(:))),FSI_export,symbol) ;
xlim([0 1])
ylim([0 1])
ylabel('Flux Sharing Index (-)')
xlabel('Leakage Index (-)')
set(gcf);
% saveas(gcf,['xLeak_FSI',name,'.eps'],'epsc');

toc

%% Export the data outputs

Export(:,1) = FSI_export;
Export(:,2) = LSI_export;
Export(:,3) = LeakIndExport;
Export(:,4) = NumAlt_Export;
Export(:,5) = RD_Norm_Export;


% save([name '.txt'],'Export','-ASCII')
%==============================End of File================================%