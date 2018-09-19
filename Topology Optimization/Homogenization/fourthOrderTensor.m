classdef fourthOrderTensor < handle
    
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
            tensor
            tensorVoigt 
            tensorVoigtInPlaneStress
    end
    
    methods
        
        function obj = fourthOrderTensor()
            
            
        end
        
        function computeTensorVoigtInPlaneStress(obj)
            obj.tensorVoigtInPlaneStress = obj.transform3D_2_PlaneStressInVoigt(obj.tensorVoigt);
        end
        
        function MakeMajorAndMinorSymmetrization(obj)
            A = zeros(3,3,3,3);
             for i = 1:size(A,1)
                for j = 1:size(A,2)
                    for k = 1:size(A,3)
                        for l = 1:size(A,4)
                           A(i,j,k,l) = 1/16*(obj.tensor(i,j,k,l) + ...
                                              obj.tensor(j,i,k,l) + ...
                                              obj.tensor(i,j,l,k) + ...
                                              obj.tensor(j,i,l,k) + ... 
                                              ...
                                              obj.tensor(k,l,i,j) + ...
                                              obj.tensor(l,k,i,j) + ...
                                              obj.tensor(k,l,j,i) + ...
                                              obj.tensor(l,k,j,i) );
                                            %                                               ...
%                                               obj.tensor(i,k,j,l) + ...
%                                               obj.tensor(k,i,j,l) + ...
%                                               obj.tensor(i,k,l,j) + ...
%                                               obj.tensor(k,i,l,j) + ...
%                                               ...
%                                               obj.tensor(j,l,i,k) + ...                                              
%                                               obj.tensor(l,j,i,k) + ...
%                                               obj.tensor(j,l,k,i) + ...
%                                               obj.tensor(l,j,k,i) ...
                                       %   );
                        end
                    end
                end
             end
            
            obj.tensor = A;
            
        end
        
        function createRandomTensor(obj)
            obj.tensor = rand(3,3,3,3);           
        end
        
        
        
        function  Gt = transform3D_2_PlaneStressInVoigt(obj,tensorVoigt)
            
            %epsilon = sym('eps',[3 3],'real');
            %epsilonVoigt = obj.RepresentSymm2ndOrderTensorInVoigt(epsilon);
            epsilonVoigt = sym('eps',[6 1],'real');
            
            %sigma = sym('sig',[3 3],'real');
            %sigmaVoigt = obj.RepresentSymm2ndOrderTensorInVoigt(sigma);
            sigmaVoigt = sym('eps',[6 1],'real');
            
            
            %obj.tensor = sym('C',[3 3 3 3],'real');
            %obj.tensorVoigt = obj.RespresentTensorinVoigt(obj.tensor);
           %  = sym('C',[6 6],'real');
            
            for i=1:6
                for j = 1:i-1
                    obj.tensorVoigt(i,j) = obj.tensorVoigt(j,i);
                end
            end
            
            

            
            iv(1) = obj.transformTensorIndex2VoigtIndex(3,3);
            iv(2) = obj.transformTensorIndex2VoigtIndex(2,3);
            iv(3) = obj.transformTensorIndex2VoigtIndex(1,3);
            
            is(1) = obj.transformTensorIndex2VoigtIndex(1,1);
            is(2) = obj.transformTensorIndex2VoigtIndex(2,2);
            is(3) = obj.transformTensorIndex2VoigtIndex(1,2);

            sigmaVoigt(iv,1) = tensorVoigt(iv,:)*epsilonVoigt(:);
            eq = sigmaVoigt(iv,1) == 0;
          
            [sol] = solve(simplify(eq),epsilonVoigt(iv));
            epsilonVoigt(iv,:) = struct2array(sol);

            sigmaVoigt = tensorVoigt *epsilonVoigt(:);
            sigmaVoigt = simplify(sigmaVoigt);
            Gt = sym(zeros(3,3));
            for i = 1:length(is)
            [R,T] = coeffs(sigmaVoigt(is(i)),epsilonVoigt(is));
              if ~isempty(R)
                for j = 1:length(T)
                    ind = find(epsilonVoigt(is)==T(j));
                    Gt(i,ind) = R(j);
                end
              end
            end
            
            At = sym(zeros(3,3));
            for i = 1:length(is)
                [R,T] = coeffs(epsilonVoigt(iv(i),:),epsilonVoigt(is));
                if ~isempty(R)
                for j = 1:length(T)
                    ind = find(epsilonVoigt(is)==T(j));
                    At(i,ind) = R(j);
                end
                
                end
            end
            At = simplify(At);
            Gt3 = tensorVoigt(is,is) + tensorVoigt(is,iv)*At;
            simplify(Gt3-Gt)
            

        end
        
        function  Cv = RespresentTensorinVoigt(obj,A)
            %Cv = zeros(9,9);
            Cv = sym('Cv',[6 6]);
            for i = 1:size(A,1)
                for j = 1:size(A,2)
                    for k = 1:size(A,3)
                        for l = 1:size(A,4)
                            iv = obj.transformTensorIndex2VoigtIndex(i,j);
                            jv = obj.transformTensorIndex2VoigtIndex(k,l);
                            
                            
                            factor = obj.computeVoigtFactor(iv,jv);
                            
                            
                            Cv(iv,jv) = factor*A(i,j,k,l);
                        end
                    end
                end
            end
        end
        
      
        
    end
    
    methods (Access = protected)
        
   
        function vect = RepresentSymm2ndOrderTensorInVoigt(obj,A)
            
            vect = sym(zeros(6,1));
            for i = 1:size(A,1)
                for j = 1:size(A,2)
                    iv = obj.transformTensorIndex2VoigtIndex(i,j);
                    vect(iv) = A(i,j);
                end
            end
        end
        
        function factor = computeVoigtFactor(obj,iv,jv)
            if iv <= 3 && jv <= 3
                factor = 1;
            elseif iv > 3 && jv <= 3
                factor = sqrt(2);
            elseif iv <= 3 && jv > 3
                factor = sqrt(2);
            elseif iv > 3 && jv > 3
                factor = 0.5;
            end
            factor = 1;
        end

    
        
    end
    
    
    
     methods (Static, Access = protected)
        
  
         
        function  [istre,jstre] = transformVoigt2Tensor(ind)
            
            Voight2Tensor =    [1 1;
                                2 2;
                                3 3;
                                2 3;
                                1 3;
                                1 2];
            
            istre = Voight2Tensor(ind,1);
            jstre = Voight2Tensor(ind,2);
            
            
        end
        
        function ind = transformTensorIndex2VoigtIndex(istre,jstre)
            
            Tensor2Voigt =  [1 6 5;
                             6 2 4;
                             5 4 3];
            
            ind = Tensor2Voigt(istre,jstre);
            
        end
        
        
        
    end
end

