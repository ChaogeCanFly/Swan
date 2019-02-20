classdef ShapesPrinter < CompositeResultsPrinter
    
    properties (Access = private)
        allShapes
        printableIndex
    end
    
    methods (Access = public)
        
        function obj = ShapesPrinter(d)
            obj.obtainAllShapes(d);
            obj.obtainPrintableIndex();
            obj.init(d);
        end
        
    end
    
    methods (Access = protected)
        
        function createPrinters(obj,d)
            pI = obj.printableIndex;
            aS = obj.allShapes;
            nShapes = numel(pI);
            obj.printers = cell(nShapes,1);
            factory = ShapePrinterFactory();
            for ishape = 1:nShapes
                index = obj.printableIndex(ishape);
                shapeName = class(aS{index});
                p = factory.create(d,shapeName);
                obj.printers{ishape} = p;
            end
        end
        
        function storeFieldsToPrint(obj,d)
            obj.obtainAllShapes(d);
            obj.obtainPrintableIndex();            
            for iprinter = 1:numel(obj.printers)
                index = obj.printableIndex(iprinter);
                shape = obj.allShapes{index};   
                d.phyProblems = shape.getPhysicalProblems();
                p = obj.printers{iprinter};
                p.storeFieldsToPrint(d);
            end
        end
        
        function createHeadPrinter(obj,d,dh)
            for iprinter = 1:numel(obj.printers)
                index = obj.printableIndex(iprinter);
                shape = obj.allShapes{index};
                phyPr = shape.getPhysicalProblems(); 
                d.quad = phyPr{1}.element.quadrature;
                p = obj.printers{iprinter};                
                p.createHeadPrinter(d,dh);
                if p.getHasGaussData()
                    h = p.getHeadPrinter();
                    obj.headPrinter = h;
                    return
                else
                    h = p.getHeadPrinter();
                    obj.headPrinter = h;
                end
            end             
        end
               
    end
    
    
    methods (Access = private)
        
        function obtainAllShapes(obj,d)
            obj.allShapes = {d.cost.ShapeFuncs{:},d.constraint.ShapeFuncs{:}};
        end
        
        function obtainPrintableIndex(obj)
            aShapes = obj.allShapes;
            nAllShapes = numel(aShapes);
            iprint = 0;
            for ishape = 1:nAllShapes
                shape = aShapes{ishape};
                if obj.isShapePrintable(shape)
                    iprint = iprint + 1;
                    obj.printableIndex(iprint) = ishape;
                end
            end
        end
        
        function itIs = isShapePrintable(obj,shapeFunc)
            shapeName = class(shapeFunc);
            printingShapes = {'ShFunc_NonSelfAdjoint_Compliance',...
                'ShFunc_Compliance', ...
                'ShFunc_Chomog_alphabeta',...
                'ShFunc_Chomog_fraction'};
            itIs = any(strcmp(printingShapes,shapeName));
        end
        
    end
    
end