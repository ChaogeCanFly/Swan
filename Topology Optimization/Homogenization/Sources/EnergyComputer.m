classdef EnergyComputer
    
    properties (Access = public)
        EnergyVoigt
        EnergyVoigtPlaneStress
    end
    
    
    methods (Access = public)
        
        function obj = EnergyComputer(StrainIn,ConsTensorIn)
            obj.EnergyVoigt = obj.computeVoigtEnergy(StrainIn,ConsTensorIn);
            obj.EnergyVoigtPlaneStress = obj.computeVoigtEnergyInPlaneStress(StrainIn,ConsTensorIn);
        end
    end
    
    methods (Access = private)
        function En = computeVoigtEnergy(obj,StrainIn,ConsTensorIn)
            Strain = StrainIn.tensorVoigt;
            ConsTensor = ConsTensorIn.tensorVoigt;
            En = obj.computeEnergy(Strain,ConsTensor);
        end
        
        function En = computeVoigtEnergyInPlaneStress(obj,StrainIn,ConsTensorIn)
            Strain = StrainIn.tensorVoigtInPlaneStress;
            ConsTensor = ConsTensorIn.tensorVoigtInPlaneStress;
            En = obj.computeEnergy(Strain,ConsTensor);
        end     

    end
    
    methods (Static,Access = private)
        
        function En = computeEnergy(Strain,ConsTensor)
            dim = size(Strain,1);
            En = 0;
            for i = 1:dim
                for j = 1:dim
                    StrainA = Strain(i);
                    CH      = ConsTensor(i,j);
                    StrainB = Strain(j);
                    Energy = StrainA*CH*StrainB;
                    En = En + Energy;
                end
            end
        end
                
    end
    
    methods (Static, Access = public)
        
        function En = computeTensorEnergy(Strain,ConsTensor)
            dim = size(Strain.tensor,1);
            En = 0;
            for i = 1:dim
                for j = 1:dim
                    for k = 1:dim
                        for l = 1:dim
                            StrainA = Strain.tensor(i,j);
                            CH      = ConsTensor.tensor(i,j,k,l);
                            StrainB = Strain.tensor(k,l);
                            Energy  = StrainA*CH*StrainB;
                            En = En + Energy;
                        end
                    end
                end
            end
            
        end
        
    end
    
    
    
end

