classdef Quadrature_Line<Quadrature
    properties
    end
    methods
        function computeQuadrature(obj,order)
            computeQuadrature@Quadrature(obj,order);
            switch order
                case 'CONSTANT'
                    obj.ngaus = 1;
                    obj.weigp = 1;    
                    obj.posgp = [0];
                case 'LINEAR'
                    obj.ngaus = 2;        
                    obj.weigp = [1/2,1/2];
                    obj.posgp = [-1/sqrt(3);1/sqrt(3)];
                case 'QUADRATIC'
                    obj.ngaus = 3;         
                    obj.weigp = [5/18,8/18,5/18];
                    obj.posgp = [-3/sqrt(5);0;3/sqrt(5)];
                otherwise
                    disp('Quadrature not implemented for triangle elements')
            end
        end
    end
end