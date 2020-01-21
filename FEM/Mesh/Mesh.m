classdef Mesh < AbstractMesh & matlab.mixin.Copyable
    
    properties (GetAccess = public, SetAccess = protected)
%         coord
%         connec
        ndim
        nnode
        npnod
%         nelem
    end
    
    properties (Access = public)
       % unfittedType
        meshBackground
    end
    
    methods (Access = public)
        
        function obj = create(obj,coord,connec)
            obj.coord  = coord;
            obj.connec = connec;
            obj.computeDescriptorParams();
            obj.unfittedType = 'SIMPLE';
        end
        
        function objClone = clone(obj)
            objClone = copy(obj);
        end
        
        function plot(obj)
            figure;
            patch('vertices',obj.coord,'faces',obj.connec,...
                'edgecolor',[0.5 0 0], 'edgealpha',0.5,'edgelighting','flat',...
                'facecolor',[1 0 0],'facelighting','flat')
            axis('equal');
        end
        
        function S = computeMeanCellSize(obj)
            x1(:,1) = obj.coord(obj.connec(:,1),1);
            x1(:,2) = obj.coord(obj.connec(:,1),2);
            x2(:,1) = obj.coord(obj.connec(:,2),1);
            x2(:,2) = obj.coord(obj.connec(:,2),2);
            x3(:,1) = obj.coord(obj.connec(:,3),1);
            x3(:,2) = obj.coord(obj.connec(:,3),2);
            
            x1x2 = (x2-x1);
            x2x3 = (x3-x2);
            x1x3 = (x1-x3);
            
            n12 = sqrt(x1x2(:,1).^2 + x1x2(:,2).^2);
            n23 = sqrt(x2x3(:,1).^2 + x2x3(:,2).^2);
            n13 = sqrt(x1x3(:,1).^2 + x1x3(:,2).^2);
                        
            hs = max([n12,n23,n13]');
            
            S = max(hs);
            

%             x1 = obj.coord(obj.connec(:,1));
%             x2 = obj.coord(obj.connec(:,2));
%             x3 = obj.coord(obj.connec(:,3));
%             
%             
%             x1x2 = abs(x2-x1);
%             x2x3 = abs(x3-x2);
%             x1x3 = abs(x1-x3);
%             hs = max([x1x2,x2x3,x1x3]');
%             
%             S = max(hs);

            
        end
        
        function L = computeCharacteristicLength(obj)
            xmin = min(obj.coord);
            xmax = max(obj.coord);
            L = norm(xmax-xmin);%/2;
        end
        
        function changeCoordinates(obj,newCoords)
            obj.coord = newCoords;
        end
        
        function setCoord(obj,newCoord)
            obj.coord = newCoord;
        end
        
        function setConnec(obj,newConnec)
            obj.connec = newConnec;
        end
        
    end
    
    methods (Access = protected)
        
        function computeDescriptorParams(obj)
            obj.npnod = size(obj.coord ,1);
            obj.ndim  = size(obj.coord, 2);
            obj.nelem = size(obj.connec,1);
            obj.nnode = size(obj.connec,2);
            obj.computeGeometryType();
        end
        
    end
    
    methods (Access = private)
        
        function computeGeometryType(obj)
            factory = MeshGeometryType_Factory();
            obj.geometryType = factory.getGeometryType(obj.ndim,obj.nnode);
        end
        
    end
    
end

