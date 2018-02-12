classdef B2<B
    %B2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static,Access = ?Element_Elastic)
        function [B] = computeB(nunkn,nelem,nnode,cartd)
            B = zeros(3,nnode*nunkn,nelem);
            for i = 1:nnode
                j = nunkn*(i-1)+1;
                B(1,j,:)  = cartd(1,i,:);
                B(2,j+1,:)= cartd(2,i,:);
                B(3,j,:)  = cartd(2,i,:);
                B(3,j+1,:)= cartd(1,i,:);
            end
        end
    end
    
end

