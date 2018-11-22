classdef LevelSetCreator < handle
    
    properties (Access = protected)
        x
    end
    
    properties (Access = protected)
        mesh
        optimizerName
        hole_value
        nodeCoord
        levelSet
        lsSize
        ndim
        ini_design_value
    end
    
    properties (Access = private)
        optimizer
        scalar_product
    end
    
    methods (Access = public)
        
        function xVal = compute_initial_design(obj)
            obj.computeInitialLevelSet();
            xVal = obj.x;
            % !! PROVISIONAL !!
            if strcmp(obj.optimizerName,'SLERP') %|| strcmp(optimizer,'HAMILTON-JACOBI')
                sqrt_norma = obj.scalar_product.computeSP(xVal,xVal);
                xVal = xVal/sqrt(sqrt_norma);
            end
            
        end
        
        function x = getValue(obj)
            x = obj.x;
        end
        
    end
    
    methods (Access = public, Static)
        
        function obj = create(settings,mesh,epsilon)
            factory = LevelSetFactory();
            input.settings = settings;
            input.mesh     = mesh;
            input.epsilon  = epsilon;
            input.nHoles  = settings.N_holes;
            input.rHoles  = settings.R_holes;
            input.phaseHoles = settings.phase_holes;
            input.warningHoleBC = settings.warningHoleBC;
            input.ndim = mesh.ndim;
            input.coord = mesh.coord;
            input.m = settings.widthSquare;
            input.m1 = settings.widthH;
            input.m2 = settings.widthV;
            obj = factory.create(settings.initial_case,input);
        end
    end
    
    methods (Access = protected)
        
        function obj = compute(obj,input)
            obj.mesh = input.mesh;
            obj.lsSize = size(input.coord(:,1));
            obj.ndim   = input.ndim;
            obj.scalar_product = ScalarProduct(input.settings.filename,input.epsilon);
            obj.optimizerName = input.settings.optimizer;
            obj.createNodalCoordinates(input.coord);
            obj.computeInitialValue()
        end
        
        function computeDesignVariable(obj)
            classType = class(obj);            
            switch classType                
                case {'LevelSetCircle',...
                        'LevelSetSphere',...
                        'LevelSetWithSeveralHoles',...
                        'LevelSetOrientedFiber'}
                      obj.computeDesignVariableLS()
                case {'LevelSetFeasible','LevelSetRandom','LevelSetFull'}
                    phi = obj.levelSet;
                    obj.x = obj.ini_design_value*ones(obj.lsSize);
                    obj.x(phi > 0) = obj.hole_value;
                case {'LevelSetWithCircleInclusion',...
                        'LevelSetWithSphereInclusion',...
                        'LevelSetSquareInclusion',...
                        'LevelSetSmoothSquareInclusion',...
                        'LevelSetRectangleInclusion',...
                        'LevelSetSmoothRectangleInclusion',...
                        'LevelSetHorizontalInclusion'}
                    phi = obj.levelSet;
                    phi = -phi;
                    obj.x = obj.ini_design_value*ones(obj.lsSize);
                    obj.x( phi > 0 ) = obj.hole_value;
            end
            
        end
    end
    
    methods (Access = private)
        
        function computeDesignVariableLS(obj)
            phi = obj.levelSet;
            switch obj.optimizerName
                case {'SLERP','HAMILTON-JACOBI'}
                    obj.x = phi;
                otherwise
                    initial_holes = ceil(max(phi,0))>0;
                    obj.x = obj.ini_design_value*ones(obj.lsSize);
                    obj.x(initial_holes) = obj.hole_value;
            end
        end
        
        function createNodalCoordinates(obj,coord)
            obj.nodeCoord = coord;
        end
        
        function computeInitialValue(obj)
            obj.computeInitDesignValue();
            obj.computeHoleValue();
            geometry = Geometry(obj.mesh,'LINEAR');
            obj.x = obj.ini_design_value*ones(geometry.interpolation.npnod,1);
        end
        
        function computeInitDesignValue(obj)
            switch obj.optimizerName
                case {'SLERP', 'PROJECTED SLERP'}
                    obj.ini_design_value = -1.015243959022692;
                case 'HAMILTON-JACOBI'
                    obj.ini_design_value = -0.1;
                otherwise
                    obj.ini_design_value = 1;
            end
        end
        
        function computeHoleValue(obj)
            switch obj.optimizerName
                case {'SLERP', 'PROJECTED SLERP'}
                    obj.hole_value = 0.507621979511346;
                case 'HAMILTON-JACOBI'
                    obj.hole_value = 0.1;
                otherwise
                    obj.hole_value = 0;
            end
        end
        
    end
    
    methods (Abstract, Access = protected)
        x = computeInitialLevelSet(obj)
    end
    
end

