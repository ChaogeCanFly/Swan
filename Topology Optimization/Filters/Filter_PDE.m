classdef Filter_PDE < Filter
    properties
        dvolu
        rhs
        A_nodal_2_gauss
    end
    
    methods       
        function preProcess(obj)
            preProcess@Filter(obj);
            obj.P_operator=obj.computePoperator(obj.diffReacProb.element.M);
            obj.dvolu = sparse(1:obj.diffReacProb.geometry.interpolation.nelem,1:obj.diffReacProb.geometry.interpolation.nelem,...
                sum(obj.diffReacProb.geometry.dvolu,2));
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
        
        function x_reg = regularize(obj,x,F)
            rhs_x = obj.integrate_function_along_facets(x,F);            
            x_reg = obj.solve_filter(rhs_x);
        end
        
        function rhs = integrate_P1_function_with_shape_function(obj,x)
            gauss_sum = 0;
            for igauss = 1:size(obj.M0,2)
                gauss_sum = gauss_sum+obj.A_nodal_2_gauss'*obj.M0{igauss}*x(:,igauss);
            end
            rhs = gauss_sum;
        end
        
        function x_reg = solve_filter(obj,rhs_x)
            obj.diffReacProb.computeVariables(rhs_x);
            x_reg = obj.diffReacProb.variables.x;
        end
        
        function obj = updateEpsilon(obj,epsilon)
            obj.diffReacProb.setEpsilon(epsilon);
        end
    end
end