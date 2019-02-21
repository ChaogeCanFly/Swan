classdef SmoothingRectangleVademecum < handle
    
    properties (Access = private)
        outPutPath
        smoothVad
        nonSmoothVad
        difDB
    end
    
    methods (Access = public)
        
        function obj = SmoothingRectangleVademecum()
            obj.init();           
            obj.smoothVad    = obj.computeVademecum('SmoothRectangle');
            obj.nonSmoothVad = obj.computeVademecum('Rectangle');
            obj.postprocessDifVademecum();
        end
        
    end
    
    methods (Access = private)
        
        function init(obj)
            obj.createOutPutPath();
        end
        
        function createOutPutPath(obj)
            firstPart  = fullfile( '/home','alex','Dropbox');
            secondPart = fullfile('Amplificators','Images','MicroWithHole/');
            obj.outPutPath = fullfile(firstPart,secondPart);
        end        
        
        function vc = computeVademecum(obj,fileName)
            d.fileName = fileName;
            d.outPutPath = fullfile(obj.outPutPath,[d.fileName,'/']);
            vc = VademecumComputer(d);
            vc.compute();
        end
                
        function postprocessDifVademecum(obj)
            obj.createDifferenceDataBase();
            a  = load('fIs');
            fIs = a.fIs;
            a  = load('fIn');
            fIn = a.fIn;
            obj.postprocessDiference(fIs,fIn)
        end
        
        function createDifferenceDataBase(obj)
            dS = obj.smoothDB;
            dN = obj.nonSmoothDB;
            dD.volume     = dS.postData.volume     - dN.postData.volume;
            dD.Ctensor    = dS.postData.Ctensor    - dN.postData.Ctensor;
            dD.Ptensor    = dS.postData.Ptensor    - dN.postData.Ptensor;
            dD.PinvTensor = dS.postData.PinvTensor - dN.postData.PinvTensor;
            dD.mxV        = dS.postData.mxV;
            dD.myV        = dS.postData.myV;
            obj.difDB.postData   = dD;
            obj.difDB.fileName   = 'ReactangleDifference';
            obj.difDB.outPutPath = fullfile(obj.outPutPath,'/');
        end
        
        function fI = postprocess(obj,d)
            p  = VademecumPostProcessor(d);
            p.postprocess();
            fI = p.feasibleIndex;
        end
        
        function postprocessDiference(obj,iS,iN)
            mxV = obj.smoothDB.postData.mxV;
            myV = obj.smoothDB.postData.myV;
            for i = 1:length(mxV)
                for j = 1:length(myV)
                    txi(i,j) = mxV(i)/myV(j);
                end
            end
            
            
            rhoS = obj.smoothDB.postData.volume(iS);
            C1 = obj.smoothDB.postData.Ctensor(1,1,:,:);
            C1 = squeeze(C1);
            Cs(:,1)   = C1(iS);
            txiS = txi(iS);
            
            rhoN = obj.nonSmoothDB.postData.volume(iN);
            C1 = obj.nonSmoothDB.postData.Ctensor(1,1,:,:);
            C1 = squeeze(C1);
            Cn(:,1)   = C1(iN);
            txiN = txi(iN);
            
            Csp(:,1)  = griddata(txiS,rhoS,Cs,txiN,rhoN);
            Cnp(:,1)  = griddata(txiN,rhoN,Cn,txiS,rhoS);
            
            dif = Cs - Cnp;
            
            x = txiN;
            y = rhoN;
            z = dif;            
            hold on
            plot(x,y,'+');
            xlabel('$\frac{m1}{m2}$','Interpreter','latex');
            ylabel('\rho');      
            plot(txiS,rhoS,'+')
            
            ind = ~isnan(z);
            ncolors = 50;
            tri = delaunay(x(ind),y(ind));
            tricontour(tri,x(ind),y(ind),z(ind),ncolors)            
        end
        
        
        
        
    end
    
end