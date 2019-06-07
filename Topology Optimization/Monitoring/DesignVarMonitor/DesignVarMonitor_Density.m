classdef DesignVarMonitor_Density < DesignVarMonitor_Abstract
    
    properties (Access = protected)
        designVarName = 'Density - \rho';
    end
    
    properties (Access = private)
        rhoElem
        filter
    end
    
    methods (Access = public)
        
        function obj = DesignVarMonitor_Density(cParams)
            obj@DesignVarMonitor_Abstract(cParams);
            obj.createFilter(cParams);
        end
        
        function plot(obj)
            obj.filterDensity();
            set(obj.patchHandle,'FaceVertexAlphaData',obj.rhoElem,'FaceAlpha','flat');
        end
        
    end
    
    methods (Access = protected)
        
        function initPlotting(obj)
            obj.patchHandle = patch(obj.axes,'Faces',obj.mesh.connec,'Vertices',obj.mesh.coord,...
                'FaceAlpha','flat','EdgeColor','none','LineStyle','none','FaceLighting','none' ,'AmbientStrength', .75);
            set(obj.axes,'ALim',[0, 1],'XTick',[],'YTick',[]);
            
            obj.BCplotter.plot();
        end
        
    end
    
    methods (Access = protected, Static)
        
        function color = getColor()
            color = [0 0 0];
        end
        
    end
    
    methods (Access = private)
        
        function createFilter(obj,cParams)
            s.filterType = 'P1';
            s.domainType = 'INTERIOR';
            s.designVar = obj.designVar;
            s.quadratureOrder = 'LINEAR';
            s = SettingsFilter(s);
            s.femSettings.scale = cParams.scale;
            obj.filter = Filter_P1_Density(s);
            obj.filter.preProcess();
        end
        
        function rhoElem = filterDensity(obj)
            %rho = obj.designVar.value;
            rho = obj.designVar.rho;
            if obj.isNodal(rho)
                rhoElem = obj.filter.getP0fromP1(rho);
            elseif obj.isElemental(rho)
                rhoElem = rho;
            else
                error('Invalid density vector size')
            end
            obj.rhoElem = double(rhoElem);
        end
        
        function itIs = isNodal(obj,x)
            n = size(x,1);
            nnode = size(obj.mesh.coord,1);
            itIs = n == nnode;
        end
        
        function itIs = isElemental(obj,x)
            n = size(x,1);
            nelem = size(obj.mesh.connec,1);
            itIs = n == nelem;
        end
        
        
    end
    
end