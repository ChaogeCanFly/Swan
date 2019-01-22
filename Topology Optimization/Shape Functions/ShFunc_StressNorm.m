classdef ShFunc_StressNorm < ShFunWithElasticPdes
    
    properties (Access = private)
        pNorm = 2;
    end
    
    methods (Access = public)
        
        function obj = ShFunc_StressNorm(settings)
            obj@ShFunWithElasticPdes(settings);
            obj.createEquilibriumProblem(settings.filename);
        end
        
        function v = getValue(obj)
            v = obj.value;
        end
        
        function setVstrain(obj,s)
            sV(1,:) = s;
            obj.physProb.element.setVstrain(sV);
        end
        
        function setPnorm(obj,p)
            obj.pNorm = p;
        end
        function computeCostAndGradient(obj,x)
            obj.updateMaterialProperties(x);
            obj.solvePDEs();
            obj.computeFunctionValue();
            obj.computeGradient();
        end
        
    end
    
    methods (Access = protected)
        
        function updateGradient(obj)
        end
        
        function computeGradient(obj)
            obj.gradient = 0;
        end
        
        function solvePDEs(obj)
            obj.physProb.setMatProps(obj.matProps);
            obj.physProb.computeVariables();
        end
        
        function computeFunctionValue(obj)
            stress       = obj.physProb.variables.stress;
            stress_fluct = obj.physProb.variables.stress_fluct;
            v = obj.integrateStressNorm(obj.physProb);
            obj.value = v;
        end
        
    end
    
    methods (Access = private)
        
        function value = integrateStressNorm(obj,physProb)
            nstre = physProb.element.getNstre();
            V = sum(sum(physProb.geometry.dvolu));
            ngaus = physProb.element.quadrature.ngaus;
            dV    = physProb.element.geometry.dvolu;
            stress = obj.physProb.variables.stress;
            value = obj.integratePNormOfL2Norm(stress,ngaus,nstre,dV,V);
        end
        
        
        function v = integratePNormOfL2Norm(obj,stress,ngaus,nstre,dV,V)
            p = obj.pNorm;
            v = 0;
            for igaus = 1:ngaus
                s = zeros(size(stress,3),1);
                for istre = 1:nstre
                    Si = squeeze(stress(igaus,istre,:));
                    factor = obj.computeVoigtFactor(istre,nstre);
                    Sistre = factor*(Si.^2);
                    s = s + Sistre;
                end
                s = sqrt(s);
                sigmaNorm = s.^p;
                v = v + 1/V*sigmaNorm'*dV(:,igaus);
            end
        end
        
        function v = integratePNormOfComponents(obj,stress,ngaus,nstre,dV,V)
            p = obj.pNorm;
            v = 0;
            for igaus = 1:ngaus
                s = zeros(size(stress,1),size(stress,3));
                for istre = 1:nstre
                    Si = squeeze(stress(igaus,istre,:));
                    factor = obj.computeVoigtFactor(istre,nstre);
                    Sistre = factor*(Si.^p);
                    s = s + Sistre;
                end
                v = v + 1/V*s'*dV(:,igaus);
            end
        end
        
        function f = computeVoigtFactor(obj,k,nstre)
            if nstre == 3
                if k < 3
                    f = 1;
                else
                    f = 2;
                end
            elseif nstre ==6
                if k <= 3
                    f = 1;
                else
                    f = 2;
                end
            end
        end
        
        
    end
    
end