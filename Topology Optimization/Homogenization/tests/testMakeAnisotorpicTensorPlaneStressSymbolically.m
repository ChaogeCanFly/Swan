classdef testMakeAnisotorpicTensorPlaneStressSymbolically < testShowingError
    
    properties (Access = protected)
        ChVoigt
        ChSym
        ChNum
        tol = 1e-13;
    end
    
    methods (Access = public)
        
        function obj = testMakeAnisotorpicTensorPlaneStressSymbolically()
           obj.createFourthOrderTensorInVoigt()
           obj.createPlaneStressTensorSymbolically()
           obj.createNumericFourthOrderTensor();
        end
        
    end
    
    methods (Access = private)
        
        function createFourthOrderTensorInVoigt(obj)
            t = SymmetricFourthOrder3DTensor();
            t.createRandomTensor();
            obj.ChVoigt = Tensor2VoigtConverter.convert(t);
        end
        
        function createPlaneStressTensorSymbolically(obj)
            t = obj.ChVoigt.getValue();
            tPS = PST4VoigtFourthOrderTensorSymbolically(t);            
            obj.ChSym = tPS;
        end
        
        function createNumericFourthOrderTensor(obj)
           t = obj.ChVoigt;
           obj.ChNum = PlaneStressTransformer.transform(t); 
        end
    end
    
    
    methods (Access = protected)
        function computeError(obj)
            cSym = double(obj.ChSym.getValue);
            cNum = obj.ChNum.getValue;
            obj.error = norm(cSym(:) - cNum(:));
        end
    end
end


