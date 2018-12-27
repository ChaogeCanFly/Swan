classdef NumericalRectangleHomogenizer < NumericalRectangleTypeHomogenizer
    
    methods (Access = public)
        
        function obj = NumericalRectangleHomogenizer(fileName,print,m1,m2,iter)
            obj.compute(fileName,print,m1,m2,iter)  
            obj.captureImage(iter)
        end        
        
    end
 
    
    methods (Access = protected)
        
        function createLevelSet(obj,m1,m2)
            input.mesh = obj.microProblem.mesh;
            input.settings = obj.setting;
            input.epsilon = 0.1;
            input.m1 = m1;
            input.m2 = m2;
            input.coord = obj.microProblem.mesh.coord;
            input.ndim = obj.microProblem.mesh.ndim;
            designVar = LevelSetRectangleInclusion(input); 
            obj.nodalLevelSet = designVar.getValue();
        end
        
        function captureImage(obj,iter) 
            f = obj.resFile;
            outPutName = ['RectangularInclusion',num2str(iter)];
            GiDImageCapturer(f,outPutName);
        end
        
    end
    
end

