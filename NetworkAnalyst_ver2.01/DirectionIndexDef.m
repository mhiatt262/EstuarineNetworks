function [ StartNodes, EndNodes ] = DirectionIndexDef( data )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

StartNodes = zeros(size(data,1),1);
EndNodes = zeros(size(data,1),1);
DirectionIndex = data(:,end);

for ii = 1:size(data,1)
    if DirectionIndex(ii)==0
        ActualStart = data(ii,end-1);
        ActualEnd = data(ii,end-2);
        StartNodes(ii) = ActualStart;
        EndNodes(ii) = ActualEnd;
    else
        ActualStart = data(ii,end-2);
        ActualEnd = data(ii,end-1);
    end
    
    StartNodes(ii) = ActualStart;
    EndNodes(ii) = ActualEnd;    
end

end

