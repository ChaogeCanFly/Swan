classdef DiffReact_Problem < FEM
    %DiffReact_Problem Summary of this class goes here
    % Detailed explanation goes here
    
    %% Public GetAccess properties definition =============================
    properties (GetAccess = public, SetAccess = public)
    end
    
    %% Restricted properties definition ===================================
    properties %(GetAccess = {?Postprocess,?Physical_Problem_Micro}, SetAccess = protected)
        material % !! Preguntar si necessita material
    end
    
    %% Public methods definition ==========================================
    methods (Access = public)
        function obj = DiffReact_Problem(problemID)
            obj.problemID = problemID;
            obj.mesh = Mesh(problemID); % Mesh defined twice, but almost free
            obj.createGeometry(obj.mesh);
            obj.mesh.ptype = 'DIFF-REACT';
            obj.dof = DOF_DiffReact(problemID,obj.geometry);
        end
        
        function preProcess(obj)
            obj.element = Element_DiffReact(obj.mesh,obj.geometry,obj.material,obj.dof);
            obj.solver = Solver.create;
        end
        
        function computeVariables(obj)
            tol = 1e-6;
            for ifield = 1:obj.geometry(1).nfields
                free_dof(ifield) = length(obj.dof.free{ifield});
            end
            x = obj.solve_steady_problem(free_dof,tol);
            obj.variables = obj.element.computeVars(x);
        end
        
        function postProcess(obj)
            % ToDo
            % Inspire in TopOpt
        end
        
        % !! THIS SHOULD BE DEFINED BY THE USER !!
        function createGeometry(obj,mesh)
            obj.geometry = Geometry(mesh,'LINEAR');
        end
    end
end

