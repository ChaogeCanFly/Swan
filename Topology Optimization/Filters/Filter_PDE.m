classdef Filter_PDE < Filter
    properties
        dvolu
        epsilon
        Ksmooth %Try to remove
        Msmooth %Try to remove
        solver  %Try to remove
        rhs
        A_nodal_2_gauss
    end
    
    methods
        function obj = Filter_PDE(problemID,scale)
            obj@Filter(problemID,scale);
        end
        
        function preProcess(obj)
            preProcess@Filter(obj);
%             obj.element = params.element;
%             obj.element.dof = params.dof;
            %obj.dof = physicalProblem.dof;
            obj.dvolu = sparse(1:obj.diffReacProb.geometry.interpolation.nelem,1:obj.diffReacProb.geometry.interpolation.nelem,...
                sum(obj.diffReacProb.geometry.dvolu,2));
            obj.Ksmooth = obj.diffReacProb.element.K;
            obj.Msmooth = obj.diffReacProb.element.M;
            obj.solver = Solver.create();
            obj.A_nodal_2_gauss = obj.computeA;
        end

        
        function x_reg = getP1fromP1(obj,x)
            rhs_x = obj.integrate_L2_function_with_shape_function(x);
            x_reg = obj.solve_filter(rhs_x);
        end
        
        function x_reg = getP1fromP0(obj,x)
            rhs_x = obj.integrate_P1_function_with_shape_function(x);
            x_reg = obj.solve_filter(rhs_x);
        end
        
        function x_gp = getP0fromP1(obj,x)
            x_reg =  obj.getP1fromP1(x);
            x_gp = obj.A_nodal_2_gauss*x_reg;
        end
        
        function rhs = integrate_P1_function_with_shape_function(obj,x)
            rhs = (obj.A_nodal_2_gauss'*obj.M0{1}*x);
        end
        
        % !! Can be done as a DiffReact_Problem !!
        function x_reg = solve_filter(obj,rhs_x)
            Rinv = (obj.epsilon^2*obj.Ksmooth + obj.Msmooth);
            Rinv_red = obj.diffReacProb.element.full_matrix_2_reduced_matrix(Rinv);
            rhs_red  = obj.diffReacProb.element.full_vector_2_reduced_vector(rhs_x);
            x_reg = obj.solver.solve(Rinv_red,rhs_red);
            x_reg = obj.diffReacProb.element.reduced_vector_2_full_vector(x_reg);
        end        
    end
end