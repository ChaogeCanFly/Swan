classdef Triangle_Quadratic<Interpolation
    %Triangle_Quadratic Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        % Constructor
        function obj = Triangle_Quadratic(mesh)
            obj = obj@Interpolation(mesh);
            obj.type = 'TRIANGLE_QUADRATIC';
            obj.order = 'QUADRATIC';
            obj.ndime = 2;         
            obj.nnode = 6;
            obj.pos_nodes = [0,0 ; 1 0; 0,1 ; 0.5,0 ; 0.5,0.5 ; 0,0.5];
        end
        function computeShapeDeriv(obj,posgp)
            for igaus=1:size(posgp,2)
                s = posgp(1,igaus);
                t = posgp(2,igaus);
                obj.shape(:,igaus) = [(1.0-s-t)*(1.0-2*s-2*t);s*(2*s-1.0);t*(2*t-1.0);4*s*(1.0-s-t);4*s*t;4*t*(1.0-s-t)];
                obj.deriv(:,:,igaus) = [4*(s+t)-3,    4*s-1 , 0.0     4*(1.0-t)-8*s ,  4*t ,    -4*t;
                    4*(s+t)-3.0,  0.0  ,  4*t-1.0 ,    -4*s    ,   4*s  ,   4*(1.0-s)-8*t];
            end
        end
    end
end