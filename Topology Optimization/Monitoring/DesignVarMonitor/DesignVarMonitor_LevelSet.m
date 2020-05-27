classdef DesignVarMonitor_LevelSet < DesignVarMonitor_Abstract
    
    properties (Access = protected, Abstract)
        unfittedType
        meshIncludeBoxContour
    end
    
    properties (Access = protected)
        designVarName = 'Level Set - \phi';
        meshUnfitted
    end
    
    methods (Access = public)
        
        function obj = DesignVarMonitor_LevelSet(cParams)
            obj@DesignVarMonitor_Abstract(cParams);
            obj.createUnfittedMesh();
        end
        
        function plot(obj)
            obj.updateMesh();
            obj.refreshFigure();
        end
        
    end
    
    methods (Access = protected)
        
        function initPlotting(obj)
            obj.patchHandle = patch('Faces',obj.mesh.connec,'Vertices',obj.mesh.coord,...
                'FaceColor',obj.getColor(),'EdgeColor',[0 0 0],'EdgeAlpha',0.5,...
                'FaceLighting','flat','EdgeLighting','flat');
            
            set(obj.axes,'CLim',[0, 1],'XTick',[],'YTick',[]);
        end
        
    end
    
    methods (Access = protected, Static)
        
        function color = getColor()
            color = [1 0 0];
        end
        
    end
    
    methods (Access = private)
        
        function createUnfittedMesh(obj)
            interpolation = Interpolation.create(obj.mesh,'LINEAR');
            s = SettingsMeshUnfitted(obj.unfittedType,obj.mesh,interpolation,obj.meshIncludeBoxContour);
            s.includeBoxContour = true;
            s.unfittedType = 'INTERIOR';
            s.type = 'INTERIOR';
            obj.meshUnfitted = UnfittedMesh(s);
            
            % uM = obj.designVar.getUnfittedMesh()
            
            
        end
        
        function updateMesh(obj)
            phi = obj.designVar.value;
            obj.meshUnfitted.compute(phi);
        end
        
        function refreshFigure(obj)
            cla(obj.axes);
            rDim = obj.mesh.removedDimensions;
            rCoord = obj.mesh.removedDimensionCoord;
            %            obj.meshUnfitted.add2plot(obj.axes,rDim,rCoord);

            figure(obj.figHandle.Number)
            light(obj.axes)
            obj.BCplotter.plot();
            hold on
            obj.meshUnfitted.plot()%(obj.axes,rDim,rCoord);                        
        end
        
    end
    
end