classdef SettingsHomogenizedVarComputerFromInterpolation < ....
        AbstractSettings
    
    properties (Access = protected)
        defaultParamsName = 'paramsHomogenizedVarComputerFromInterpolation'
    end
    
    properties (Access = public)
        interpolation
        dim
        typeOfMaterial
        constitutiveProperties
        nelem
        ngaus
        ptype
    end
    
    methods (Access = public)
        function obj = SettingsHomogenizedVarComputerFromInterpolation(varargin)
            if nargin == 1
                obj.loadParams(varargin{1})
            end
        end
    end
    
    
end