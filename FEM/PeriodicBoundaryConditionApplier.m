classdef PeriodicBoundaryConditionApplier < handle
    
    properties (Access = private)
        nfields
        dof        
    end
    
    methods (Access = public)
        
        function obj = PeriodicBoundaryConditionApplier(nfields,dof)
            obj.nfields = nfields;
            obj.dof = dof;            
        end
        
        function [dirichlet,uD,free] = compute_global_dirichlet_free_uD(obj)
            uD = obj.computeUd();
            dirichlet = obj.computeDirichlet();
            free = obj.computeGlobalFree();            
        end
        
        function uD = computeUd(obj)
            global_ndof=0;
            for ifield=1:obj.nfields
                uD{ifield,1} = obj.dof.dirichlet_values{ifield};
                global_ndof=global_ndof+obj.dof.ndof(ifield);
            end
            uD = cell2mat(uD);
        end
        
        function dirichlet = computeDirichlet(obj)
            global_ndof=0;
            for ifield=1:obj.nfields
                dirichlet{ifield,1} = obj.dof.dirichlet{ifield}+global_ndof;
                global_ndof=global_ndof+obj.dof.ndof(ifield);
            end
            dirichlet = cell2mat(dirichlet);
        end
        
        function free = computeGlobalFree(obj)
            global_ndof=0;
            free = cell(obj.nfields,1);
            for ifield=1:obj.nfields
                free{ifield,1} = obj.dof.free{ifield}' + global_ndof;
                global_ndof=global_ndof+obj.dof.ndof(ifield);
            end
            free = cell2mat(free);
        end
        
        function Ared = full_matrix_2_reduced_matrix(obj,A)                
            vF = obj.dof.free;
            vP = obj.dof.periodic_free;
            vQ = obj.dof.periodic_constrained;
            vI = setdiff(vF{1},vP);
            
            A_II = A(vI,vI);
            A_IP = A(vI,vP) + A(vI,vQ); %Grouping P and Q nodal values
            A_PI = A(vP,vI) + A(vQ,vI); % Adding P  and Q equation
            A_PP = A(vP,vP) + A(vP,vQ) + A(vQ,vP) + A(vQ,vQ); % Adding and grouping
            
            Ared = [A_II, A_IP; A_PI, A_PP];
        end
        
        function b_red = full_vector_2_reduced_vector(obj,b)
            vF = obj.dof.free{1};
            vP = obj.dof.periodic_free;
            vQ = obj.dof.periodic_constrained;
            vI = setdiff(vF,vP);
            
            b_I = b(vI);
            b_P = b(vP) + b(vQ);
            b_red = [b_I; b_P];
        end
        
        function b = reduced_vector_2_full_vector(obj,bfree)
            % HEAD
            % b = zeros(obj.dof.ndof,1);
            % b(obj.dof.free{1}) = bfree;
            % b(obj.dof.dirichlet{1}) = obj.dof.dirichlet_values{1};
            
            % MASTER
            
            vF = obj.dof.free;
            vP = obj.dof.periodic_free;
            vI = setdiff(vF{1},vP);
            
            b = zeros(obj.dof.ndof,1);
            b(vI) = bfree(1:1:size(vI,2));
            b(obj.dof.periodic_free) = bfree(size(vI,2)+1:1:size(bfree,1));
            b(obj.dof.periodic_constrained) = b(obj.dof.periodic_free);
            
            %             b(obj.dof.free) = bfree;
            %             b(obj.dof.dirichlet) = obj.dof.dirichlet_values;
            %             b(obj.dof.periodic_constrained) = b(obj.dof.periodic_free);

        end
        
        
        
    end
    
end

