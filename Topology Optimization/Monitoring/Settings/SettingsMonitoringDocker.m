classdef SettingsMonitoringDocker < AbstractSettings
    
    properties (Access = protected)
        defaultParamsName = 'paramsMonitoringDocker.json'
    end
    
    properties (Access = public)
        showOptParams
        refreshInterval
        shallDisplayDesignVar
        shallShowBoundaryConditions
        
        problemID
        costFuncNames
        costWeights
        constraintFuncs
        dim
        
        designVariable
        dualVariable
        optimizerName
        cost
        constraint
        
        convergenceVars
    end
    
    methods (Access = public)
        
        function obj = SettingsMonitoringDocker(varargin)
            if nargin == 1
                obj.loadParams(varargin{1});
            end
            obj.init();
        end
        
    end
    
    methods (Access = private)
        
        function init(obj)
            if ischar(obj)
            end
        end
        
    end
    
end