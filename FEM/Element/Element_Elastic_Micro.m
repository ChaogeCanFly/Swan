classdef Element_Elastic_Micro < handle
    
    properties (Access = protected)
        vstrain
    end
    
    methods (Access = public)
        
        function setVstrain(obj,s)
            obj.vstrain = s;
        end
        
    end
    
    methods (Access = protected)
        
        function variables = computeStressStrainAndCh(obj,variables)

            
            variables.stress_fluct = variables.stress;
            variables.strain_fluct = variables.strain;
            Cmat = obj.material.C;
            
            variables.stress = zeros(obj.quadrature.ngaus,obj.nstre,obj.nelem);
            variables.strain = zeros(obj.quadrature.ngaus,obj.nstre,obj.nelem);
            variables.stress_homog = zeros(obj.nstre,1);
            vol_dom = sum(sum(obj.geometry.dvolu));
            
            for igaus = 1:obj.quadrature.ngaus
                variables.strain(igaus,1:obj.nstre,:) = obj.vstrain.*ones(1,obj.nstre,obj.nelem) + variables.strain_fluct(igaus,1:obj.nstre,:);
                for istre = 1:obj.nstre
                    for jstre = 1:obj.nstre
                        variables.stress(igaus,istre,:) = squeeze(variables.stress(igaus,istre,:)) + 1/vol_dom*squeeze(squeeze(Cmat(istre,jstre,:))).* squeeze(variables.strain(igaus,jstre,:));
                    end
                end
                % contribucion a la C homogeneizada
                for istre = 1:obj.nstre
                    variables.stress_homog(istre) = variables.stress_homog(istre) +  1/vol_dom *(squeeze(variables.stress(igaus,istre,:)))'*obj.geometry.dvolu(:,igaus);
                end
            end

            
        end
        
    end
   
    
    
    
    
    
    
end