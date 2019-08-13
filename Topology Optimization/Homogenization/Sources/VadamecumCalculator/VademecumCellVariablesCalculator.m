classdef VademecumCellVariablesCalculator < handle
    
    properties (Access = public)
       variables 
    end
    
    properties (Access = private)
        fileNames        
        homog
        
        iMxIndex
        iMyIndex
        mxV
        myV
        iter
        freeFemSettings
        print
        superEllipseExponent
    end
    
    methods (Access = public)
        
        function obj = VademecumCellVariablesCalculator(d)
            obj.init(d);
        end
        
        function computeVademecumData(obj)
            nMx = length(obj.mxV);
            nMy = length(obj.myV);
            for imx = 1:nMx
                for imy = 1:nMy
                    obj.storeIndex(imx,imy);
                    obj.iter = (imy + nMx*(imx -1));
                    %disp([num2str(obj.iter/(nMx*nMy)*100),'% done']);                    
                    obj.generateMeshFile();
                    obj.computeNumericalHomogenizer();
                    obj.obtainHomogenizerData();
                end
            end
        end        
        
        function saveVademecumData(obj)
           d = obj.getData();
           fN = obj.fileNames.fileName;
           pD = obj.fileNames.printingDir;
           file2SaveName = [pD,'/',fN,'.mat'];
           save(file2SaveName,'d');
        end
        
        function d = getData(obj)
            d.variables        = obj.variables;
            d.domVariables.mxV = obj.mxV;
            d.domVariables.myV = obj.myV;
            d.outPutPath    = obj.fileNames.outPutPath;
            d.fileName      = obj.fileNames.fileName;
        end
         
    end    
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.computeFileNames(cParams);
            nMx = cParams.nMx;
            nMy = cParams.nMy;
            obj.mxV = linspace(cParams.mxMin,cParams.mxMax,nMx);
            obj.myV = linspace(cParams.myMin,cParams.myMax,nMy);
            obj.print = cParams.print;
            obj.freeFemSettings = cParams.freeFemSettings;
            obj.createSuperEllipseExponent(cParams);
        end
        
        function computeFileNames(obj,d)
            fN = d.fileName;
            oP = d.outPutPath;
            pD = fullfile(pwd,'Output',fN);
            gF = [fullfile(pD,fN),'.msh'];
            fNs.fileName    = fN;
            fNs.outPutPath  = oP;
            fNs.printingDir = pD;                        
            fNs.gmsFile     = gF;
            fNs.freeFemFileName = d.freeFemFileName;
            obj.fileNames = fNs;
        end        
        
        function createSuperEllipseExponent(obj,cParams)
            s = cParams.superEllipseExponentSettings;
            exponent = SuperEllipseExponent.create(s);
            obj.superEllipseExponent = exponent;            
        end
        
        function storeIndex(obj,imx,imy)
            obj.iMxIndex = imx;
            obj.iMyIndex = imy;
        end
        
        function generateMeshFile(obj)
            d = obj.freeFemSettings;
            d.mxV             = obj.mxV(obj.iMxIndex);
            d.myV             = obj.myV(obj.iMyIndex);
            d.fileName        = obj.fileNames.fileName;
            d.freeFemFileName = obj.fileNames.freeFemFileName;
            d.printingDir     = obj.fileNames.printingDir;
            d.qNorm           = obj.computeCornerSmoothingExponent();
            fG = FreeFemMeshGenerator(d);
            fG.generate();
        end
        
        function q = computeCornerSmoothingExponent(obj)
            exponent = obj.superEllipseExponent;
            mx = obj.mxV(obj.iMxIndex);
            my = obj.myV(obj.iMyIndex);
            q = exponent.computeValue(mx,my);
        end
             
        function computeNumericalHomogenizer(obj)
            d.gmsFile = obj.fileNames.gmsFile;
            d.outFile = [obj.fileNames.fileName];
            d.print   = obj.print;
            d.iter = obj.iter;
            nH = NumericalHomogenizerCreatorFromGmsFile(d);
            obj.homog = nH.getHomogenizer();
        end
        
        function obtainHomogenizerData(obj)
            obj.obtainComputedCellVariables();
            obj.obtainIntegrationVariables();
        end
        
        function obtainComputedCellVariables(obj)
            obj.obtainVolume();   
            obj.obtainCtensor();
            obj.obtainStressesAndStrain();
            obj.obtainDisplacements();
        end
        
        function obtainVolume(obj)
            v = obj.homog.integrationVar.geoVol;
            imx = obj.iMxIndex;
            imy = obj.iMyIndex;
            obj.variables{imx,imy}.volume = v;
        end      
        
        function obtainCtensor(obj)
            Ch = obj.homog.cellVariables.Ch;
            imx = obj.iMxIndex;
            imy = obj.iMyIndex;
            obj.variables{imx,imy}.Ctensor = Ch;
        end
        
        function obtainStressesAndStrain(obj)
            stress = obj.homog.cellVariables.tstress;            
            strain = obj.homog.cellVariables.tstrain;                        
            imx = obj.iMxIndex;
            imy = obj.iMyIndex;
            obj.variables{imx,imy}.tstress = stress;
            obj.variables{imx,imy}.tstrain = strain;            
        end
        
        function obtainDisplacements(obj)
            displ = obj.homog.cellVariables.displ;                        
            imx = obj.iMxIndex;
            imy = obj.iMyIndex;
            obj.variables{imx,imy}.displ = displ;
        end
        
        function obtainIntegrationVariables(obj)
            intVar = obj.homog.integrationVar;
            imx = obj.iMxIndex;
            imy = obj.iMyIndex;            
            obj.variables{imx,imy}.integrationVar = intVar;
        end
        
    end
    
end