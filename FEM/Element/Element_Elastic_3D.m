classdef Element_Elastic_3D<Element_Elastic
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = Element_Elastic_3D(geometry,material,dof)
            obj = obj@Element_Elastic(geometry,material,dof);
        end
        
        function variables = computeVars(obj,uL)
            variables = obj.computeDispStressStrain(uL);
            variables = obj.permuteStressStrain(variables);
        end
        
        function [B] = computeB(obj,igaus)
            B = zeros(6,obj.nnode*obj.dof.nunkn,obj.nelem);
            for inode=1:obj.nnode
                j = obj.dof.nunkn*(inode-1)+1;
                % associated to normal strains
                B(1,j,:) = obj.geometry.cartd(1,inode,:,igaus);
                B(2,j+1,:) = obj.geometry.cartd(2,inode,:);
                B(3,j+2,:) = obj.geometry.cartd(3,inode,:);
                % associated to shear strain, gamma12
                B(4,j,:) = obj.geometry.cartd(2,inode,:);
                B(4,j+1,:) = obj.geometry.cartd(1,inode,:);
                % associated to shear strain, gamma13
                B(5,j,:) = obj.geometry.cartd(3,inode,:);
                B(5,j+2,:) = obj.geometry.cartd(1,inode,:);
                % associated to shear strain, gamma23
                B(6,j+1,:) = obj.geometry.cartd(3,inode,:);
                B(6,j+2,:) = obj.geometry.cartd(2,inode,:);
            end
        end
        
        
    end
    
end



