classdef Preprocess<handle
    % Only reads
    
    %% !! SUSCEPTIBLE OF BEING RENAMED !!
    
    properties
    end
    
    methods(Static)
        function data = readFromGiD(filename)
            
            addpath(fullfile('.','Input'))
            run(filename)
            data = struct;
            data.xpoints=coord;
            if length(data.xpoints(1,:))==3
                data.xpoints(:,4)=0;
            end
            if any(connec(:,length(connec(1,:))))==0
                data.connectivities=connec(:,1:(length(connec(1,:))-1));
            else
                data.connectivities=connec;
            end
            data.geometry = strjoin(Data_prb(1));
            data.problem_dim = strjoin(Data_prb(3));
            data.problem_type = strjoin(Data_prb(5));
            data.scale = strjoin(Data_prb(6));
        end
        
        function [fixnodes,forces,full_dirichlet_data,Master_slave] = getBC_mechanics(filename)
            run(filename)
            fixnodes{1,1} = dirichlet_data;
            forces = pointload_complete;
            
            full_dirichlet_data=External_border_nodes;
            if ~isempty(full_dirichlet_data)
                full_dirichlet_data(:,2)=ones(length(full_dirichlet_data(:,1)),1);
                full_dirichlet_data(:,3)=zeros(length(full_dirichlet_data(:,1)),1);
            end
            
            if ~exist('Master_slave','var')
               Master_slave = []; 
            end
            
        end
        
        function [fixnodes,forces,full_dirichlet_data,Master_slave] = getBC_fluids(filename,interpolation_variable,geometry_variable,interpolation_geometry,nelem)
            run(filename)
            
            full_dirichlet_data=External_border_nodes;
            if ~isempty(full_dirichlet_data)
                full_dirichlet_data(:,2)=ones(length(full_dirichlet_data(:,1)),1);
                full_dirichlet_data(:,3)=zeros(length(full_dirichlet_data(:,1)),1);
            end
            
            if ~exist('Master_slave','var')
               Master_slave = []; 
            end
            
            
            
            if (~isempty(velocity))  
                ind=1;
                for inode = 1: length(interpolation_variable(1).xpoints(:,1))
                    if interpolation_variable(1).xpoints(inode,1) ==0  || interpolation_variable(1).xpoints(inode,1) == 1 ...
                            || interpolation_variable(1).xpoints(inode,2) == 0 || interpolation_variable(1).xpoints(inode,2) == 1
                        fixnodes(ind,:)=[inode 1 0];
                        fixnodes(ind+1,:)=[inode 2 0];
                        ind = ind+2;
                        
                    end
                end
%                 for inode = 1: length(interpolation_variable(1).xpoints(:,1))
%                     if  interpolation_variable(1).xpoints(inode,2) == 1 ...
%                            
%                         fixnodes(ind,:)=[inode 1 1];
%                         fixnodes(ind+1,:)=[inode 2 0];
%                         ind = ind+2;
%                     elseif     interpolation_variable(1).xpoints(inode,2) == 0 ||  interpolation_variable(1).xpoints(inode,1)== 0 ...
%                         || interpolation_variable(1).xpoints(inode,1) == 1
%                         fixnodes(ind,:)=[inode 1 0];
%                         fixnodes(ind+1,:)=[inode 2 0];
%                         ind = ind+2;
%                         
%                     end
%                 end

%                 for inode = 1: length(interpolation_variable(1).xpoints(:,1))
%                     if  interpolation_variable(1).xpoints(inode,2) == 1 || interpolation_variable(1).xpoints(inode,2) == 0
%                            
%                         fixnodes(ind,:)=[inode 1 0];
%                         fixnodes(ind+1,:)=[inode 2 0];
%                         ind = ind+2;
% %                     elseif     interpolation_variable(1).xpoints(inode,2) == 0 ||  interpolation_variable(1).xpoints(inode,1)== 0 ...
% %                     || interpolation_variable(1).xpoints(inode,1) == 1
% %                         fixnodes(ind,:)=[inode 1 0];
% %                         fixnodes(ind+1,:)=[inode 2 0];
% %                         ind = ind+2;
%                         
%                     end
%                 end
                fixnodes_u=fixnodes;
%                 for i = 1:length(obj.fixnodes_u(:,1))
%                     obj.iD_u(i) = obj.fixnodes_u(i,1)*nunkn_u - nunkn_u + obj.fixnodes_u(i,2);
%                 end
            end
            
            if (~isempty(pressure)) 
                if strcmp(interpolation_variable(2).order,interpolation_geometry.order) ==1
                    fixnodes_p = pressure;
                else
                ind2=1;
                
                for i = 1:length(pressure(:,1))

%                         [ind,~] = find(interpolation_geometry.T == geometry_fixnodes_p(i,1)); % este para los que tienen minimo un nodo en la pared
                   % siguiente linea para los que tienen una cara en la pared
                [ind,~] = find(external_elements(:,2:3) == geometry_fixnodes_p(i,1)); % troba l'element on esta imposada la p a la geometria 
                fixnodes_p(ind2: ind2+length(ind)-1,:) = [external_elements(ind,1) ones(length(ind),1)*geometry_fixnodes_p(i,2:3)]; % se li aplica la condicio al primer dels elements
                    ind2 = ind2+length(ind);
                end
                fixnodes_p = unique(fixnodes_p,'rows');
                end
%                 for i = 1:length(obj.fixnodes_p(:,1))
%                     obj.iD_p(i) = obj.fixnodes_p(i,1)*nunkn_p - nunkn_p + obj.fixnodes_p(i,2);
%                 end
            end
            
            if (~isempty(Vol_force))
%                 ind=1;
                
%                 for inode = 1:length(interpolation_variable(1).xpoints(:,1))
%                     pos_node= num2cell(interpolation_variable(1).xpoints(inode,1:2));
%                     f = cell2mat(force(pos_node{:}));
%                     F(ind:ind + length(f)-1,:) = [[inode;inode] [1;2] f];
%                     ind=ind+length(f);
%                 end
                for ielem = 1:nelem
                    ind=1;
                    for igaus = 1:geometry_variable(1).ngaus
                        pos_node= num2cell(geometry_variable(1).cart_pos_gp(:,igaus,ielem));
                        f = cell2mat(Vol_force(pos_node{:}));
                        F(:,igaus,ielem) = f;
                        ind=ind+length(f);
                    end
                end
                
                forces = F;
            end
            clear fixnodes;
            fixnodes{1} = fixnodes_u;
            fixnodes{2} = fixnodes_p;
        end
        
        function forces_adjoint=getBC_adjoint(filename)
            run(filename)
            forces_adjoint = pointload_adjoint;
        end
        

    end
end





