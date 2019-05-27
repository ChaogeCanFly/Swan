classdef DesignVariable < handle & matlab.mixin.Copyable
    
    properties (GetAccess = public, SetAccess = protected)
        mesh
        type
        nVariables                
    end
    
    properties (Access = public)
        value   
        alpha
        rho        
    end
    
    properties (GetAccess = public, SetAccess = private)
        scalarProduct
    end
    
    properties (Access = private) 
        valueOld                                        
        alphaOld
    end
    
    methods (Access = public, Abstract)
        update(obj,value)
    end
    
    methods (Access = public, Static)
        
        function designVariable = create(cParams)
            f = DesignVariableFactory();
            designVariable = f.create(cParams);
        end        
        
    end
    
    methods (Access = public)
                
        function restart(obj)
            obj.value = obj.valueOld;
            obj.alpha = obj.alphaOld;
        end
        
        function updateOld(obj)
            obj.valueOld = obj.value;
            obj.alphaOld = obj.alpha;
        end
        
        function objClone = clone(obj)
            objClone = copy(obj);
        end
        
        function norm = computeL2normIncrement(obj)
           x = obj.value;
           x0 = obj.valueOld;
           incX  = x - x0;
           nIncX = obj.scalarProduct.computeSP_M(incX,incX);
           nX0   = obj.scalarProduct.computeSP_M(x0,x0);
           norm  = nIncX/nX0;
        end
        
    end
    
    methods (Access = protected)
        
        function init(obj,cParams)
            obj.type = cParams.type;
            obj.createMesh(cParams); 
            obj.initValue();
            obj.createScalarProduct(cParams);
        end
        
    end
    
    methods (Access = private)
        
        function createMesh(obj,s)
            if ischar(s.mesh)
                fileName = s.mesh;
                d = FemInputReader_GiD().read(fileName);
                obj.mesh = Mesh().create(d.coord,d.connec);
            else
                obj.mesh = s.mesh;
            end
        end
        
        function initValue(obj)
            obj.value = ones(size(obj.mesh.coord,1),1);
        end
        
        function createScalarProduct(obj,cParams)
            s = cParams.scalarProductSettings;
            s.nVariables = obj.nVariables;
            s.femSettings.mesh = obj.mesh;
            obj.scalarProduct = ScalarProduct(s);        
        end
        
    end
    
end

