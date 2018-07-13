classdef ShFunc_Chomog_CC < ShFunc_Chomog %%NOT WORKING%%
    properties (Access = private)
        selectiveC_Cstar = [1, 1,1
                            1, 1,1
                            1,1,1];
    end
    methods
        function obj=ShFunc_Chomog_CC(settings)
            obj@ShFunc_Chomog(settings);
            obj.compute_Ch_star(settings.TOL, settings.selectiveC_Cstar);
%             obj.selectiveC_Cstar=settings.selectiveC_Cstar;
        end
        function computef(obj,x)
            obj.computePhysicalData(x);
            
            %Cost
            costfunc = obj.Chomog - obj.Ch_star;
            costfunc = obj.selectiveC_Cstar.*costfunc;
            
            %Gradient
            nelem = obj.physicalProblem.element.nelem;
            ngaus = size(obj.tstrain,2);
            nstre = obj.physicalProblem.element.nstre;
            
            obj.compute_Chomog_Derivatives(x);
            DtC1 = zeros(ngaus,nelem);
            gradient = zeros(ngaus,nelem);
            for igaus=1:ngaus
                for a=1:nstre
                    for b=1:nstre
                        DtC1(igaus,:) = squeeze(obj.Chomog_Derivatives(a,b,igaus,:));
                        gradient(igaus,:) = gradient(igaus,:) + 2*costfunc(a,b)*DtC1(igaus,:);
                    end
                end
            end
            
            %Cost
            costfunc = sum(bsxfun(@times,costfunc(:),costfunc(:)));
            
            mass=obj.Msmooth;
            gradient=obj.filter.getP1fromP0(gradient(:));
            gradient = mass*gradient;
            if isempty(obj.h_C_0)
                obj.h_C_0 = costfunc;
            end
            costfunc = costfunc/abs(obj.h_C_0);
            gradient=gradient/abs(obj.h_C_0);
            %             obj.h_C_0 = costfunc;
            
            obj.value = costfunc;
            obj.gradient = gradient;
            
            
        end
    end
end