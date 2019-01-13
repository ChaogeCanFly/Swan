classdef OptimizerPrinter < handle
    
    properties (Access = private)
        postproc
        fields
        printMode
        mesh
    end
    
    properties (Access = protected)
        cost
        constraint
        dataBase
        dT
        dI
        hasGaussData
    end
    
    methods (Access = public, Static)
        
        function p = create(mesh,optimizer,fileName,printMode,cost,constraint)
            f = OptimizationPrinterFactory();
            p = f.create(printMode);
            p.init(mesh,optimizer,fileName,printMode,cost,constraint)
        end
    end
    
    methods (Access = public)
        
        function init(obj,mesh,optimizer,fileName,printMode,cost,constraint)
            obj.cost = cost;
            obj.constraint = constraint;
            obj.createPostProcessDataBaseStructre(mesh,optimizer,fileName,printMode);
            obj.postproc = Postprocess('TopOptProblem',obj.dataBase,obj.dT);            
            obj.mesh = mesh;
            obj.printMode = printMode;
        end
        
        function print(obj,x,iter,cost,constraint)
            obj.createTopOptFields(x,cost,constraint);
            obj.postproc.print(iter,obj.fields);
        end
        
    end
    
    methods (Access = protected)
        
        function [h,q] = obtainQuadHasGaussData(obj,sh)
            h = true;
            phyPr = sh.getPhysicalProblem();
            q = phyPr.element.quadrature;
        end
        
        function itIs = isShapePrintable(obj,shapeFunc)
            shapeName = class(shapeFunc);
            printingShapes = {'ShFunc_NonSelfAdjoint_Compliance',...
                'ShFunc_Compliance', ...
                'ShFunc_Chomog_alphabeta',...
                'ShFunc_Chomog_fraction'};
            itIs = any(strcmp(printingShapes,shapeName));
        end
        
        function createDataBaseForPostProcess(obj,ps,optimizer,printMode)
            obj.dataBase = ps.getValue();
            obj.dataBase.hasGaussData = obj.hasGaussData;
            obj.dT.optimizer = optimizer;
            obj.dT.printMode = printMode;
        end
        
    end
    
    methods (Access = private)
        
        function createDataBaseInput(obj,mesh,fileName)
            obj.dI.iter    = 0;
            obj.dI.mesh    = mesh;
            obj.dI.outName = fileName;
        end
        
        function createPostProcessDataBaseStructre(obj,mesh,optimizer,fileName,printMode)
            obj.obtainHasGaussDataAndQuad();
            obj.createDataBaseInput(mesh,fileName);
            ps = PostProcessDataBaseCreator.create(obj.hasGaussData,obj.dI);
            obj.createDataBaseForPostProcess(ps,optimizer,printMode)            
        end
        
        function createTopOptFields(obj,x,cost,constraint)
            
            if isequal(obj.printMode,'ElementalDensity') ...
                    || isequal(obj.printMode,'DesignAndElementalDensity')
                
                phi0 = obj.computePhiP0(x,cost);
                dens0  = obj.computeDensityP0(phi0);
                obj.fields.dens = dens0;
                
            elseif isequal(obj.printMode,'DesignElementalDensityAndShape')
                phi0 = obj.computePhiP0(x,cost);
                dens0  = obj.computeDensityP0(phi0);
                obj.fields.dens = dens0;
                
                shapeFuncs = {cost.ShapeFuncs{:},constraint.ShapeFuncs{:}};
                iprint = 0;
                for ishape = 1:numel(shapeFuncs)
                    shapeFun = shapeFuncs{ishape};
                    [f,hasToPrint] = obj.obtainFieldToPrint(shapeFun);
                    if hasToPrint
                        iprint = iprint + 1;
                        obj.fields.shVar{iprint} = f;
                    end
                end
                
            else
                
                shapeFuncs = {cost.ShapeFuncs{:},constraint.ShapeFuncs{:}};
                iprint = 0;
                for ishape = 1:numel(shapeFuncs)
                    shapeFun = shapeFuncs{ishape};
                    [f,hasToPrint] = obj.obtainFieldToPrint(shapeFun);
                    if hasToPrint
                        iprint = iprint + 1;
                        obj.fields.shVar{iprint} = f;
                    end
                end
                
            end
            obj.fields.designVariable = x;
        end
        
        function [f,hasToPrint] = obtainFieldToPrint(obj,shapeFun)
            hasToPrint = false;
            f = [];
            shapeFunName = class(shapeFun);
            switch shapeFunName
                case 'ShFunc_NonSelfAdjoint_Compliance'
                    hasToPrint = true;
                    phyPr = shapeFun.getPhysicalProblem();
                    f{1} = phyPr.variables;
                    adjPr = shapeFun.getAdjointProblem();
                    f{2} = adjPr.variables;
                case 'ShFunc_Compliance'
                    hasToPrint = true;
                    phyPr = shapeFun.getPhysicalProblem();
                    f{1} = phyPr.variables;
                case {'ShFunc_Chomog_alphabeta','ShFunc_Chomog_fraction'}
                    hasToPrint = true;
                    phyPr = shapeFun.getPhysicalProblem();
                    var = phyPr.variables.var2print;
                    f = cell(numel(var),1);
                    for it = 1:numel(var)
                        f{it} = var{it};
                    end
            end
        end
        
        function phiP0 = computePhiP0(obj,x,cost)
            conec = obj.mesh.connec;
            phyPr = cost.ShapeFuncs{1}.getPhysicalProblem();
            shape = phyPr.element.interpolation_u.shape;
            quadr = phyPr.element.quadrature;
            ngaus = quadr.ngaus;
            nelem = size(conec,1);
            nnode = size(shape,1);
            
            phiP0 = zeros(ngaus,nelem);
            phi   = x;
            
            for igaus = 1:ngaus
                for inode = 1:nnode
                    nodes = conec(:,inode);
                    phiN(1,:) = phi(nodes);
                    phiP0(igaus,:) = phiP0(igaus,:) + shape(inode,igaus)*phiN;
                end
            end
            
        end
        
        function dens = computeDensityP0(obj,phi)
            dens = 1 - heaviside(phi);
        end
        
    end
    
    methods (Access = protected, Abstract)
        obtainHasGaussDataAndQuad(obj)
    end
end