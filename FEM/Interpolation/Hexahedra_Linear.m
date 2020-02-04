classdef Hexahedra_Linear < Interpolation
    
    methods (Access = public)

        function obj = Hexahedra_Linear(cParams)
            obj.init(cParams);
            obj.type  = obj.mesh.geometryType;
            obj.ndime = 3;
            obj.nnode = 8;
            obj.isoDv = 8;
            obj.pos_nodes=[-1 -1 -1;
                +1 -1 -1;
                +1 +1 -1;
                -1 +1 -1;
                -1 -1 +1;
                +1 -1 +1;
                +1 +1 +1;
                -1 +1 +1];
            obj.computeCases();
            obj.computeCoordAndConnec();
        end
        
        function computeShapeDeriv(obj,posgp)
            obj.shape=[];
            obj.deriv=[];
            s=posgp(1,:);
            t=posgp(2,:);
            u=posgp(3,:);
            lcord(1,1)= -1; lcord(1,2)= -1; lcord(1,3)= -1;
            lcord(2,1)=  1; lcord(2,2)= -1; lcord(2,3)= -1;
            lcord(3,1)=  1; lcord(3,2)=  1; lcord(3,3)= -1;
            lcord(4,1)= -1; lcord(4,2)=  1; lcord(4,3)= -1;
            lcord(5,1)= -1; lcord(5,2)= -1; lcord(5,3)=  1;
            lcord(6,1)=  1; lcord(6,2)= -1; lcord(6,3)=  1;
            lcord(7,1)=  1; lcord(7,2)=  1; lcord(7,3)=  1;
            lcord(8,1)= -1; lcord(8,2)=  1; lcord(8,3)=  1;
            for inode=1:obj.nnode
                obj.shape(inode,:)=(ones(1,size(posgp,2))+lcord(inode,1)*s).*(ones(1,size(posgp,2))+lcord(inode,2)*t).*(ones(1,size(posgp,2))+lcord(inode,3)*u)/8;
                obj.deriv(1,inode,:)=lcord(inode,1).*(ones(1,size(posgp,2))+lcord(inode,2)*t).*(ones(1,size(posgp,2))+lcord(inode,3)*u)/8;
                obj.deriv(2,inode,:)=lcord(inode,2).*(ones(1,size(posgp,2))+lcord(inode,1)*s).*(ones(1,size(posgp,2))+lcord(inode,3)*u)/8;
                obj.deriv(3,inode,:)=lcord(inode,3).*(ones(1,size(posgp,2))+lcord(inode,1)*s).*(ones(1,size(posgp,2))+lcord(inode,2)*t)/8;
            end
        end
        
    end
    
    methods (Access = private)
        
        function computeCases(obj)
            obj.iteration=[1 1 1 2 2 3 3 4 5 5 6 7;
                2 4 5 3 6 4 7 8 6 8 7 8];
            %Case 1 to 8: Node i different
            %Case 9 to 20: Nodes iteration(:,i) different
            %Case 21 to 45: Three consecutive nodes equal
            %Case 1: -1 1 1 1 1 1 1 1
            
            %Case 1: -1 1 1 1 1 1 1 1
            obj.cases(:,:,1)=[
                10     8    11     7
                5    11     8     6
                4     8    10     3
                6    11     8     7
                10     7     9     3
                10     8     7     3
                9     7     6     3
                9     6     2     3
                9     7    11     6
                10     7    11     9
                10    11     1     9
                zeros(4,4)
                ];
            
            %Case 2: 1 -1 1 1 1 1 1 1
            obj.cases(:,:,2)=[
                4    10     8     9
                4     5     1     9
                4     8     5     9
                7    10     8     3
                4     3     8    10
                11     5     8     9
                10    11     8     9
                2    11    10     9
                7    11     8    10
                7     6     8    11
                6     5     8    11
                zeros(4,4)
                ];
            
            %Case 3: 1 1 -1 1 1 1 1 1
            obj.cases(:,:,3)=[
                11     5     8    10
                4     5     1    10
                4     8     5    10
                6     5     8    11
                9    11     3    10
                7     6     8    11
                9     5    11    10
                1     5     9    10
                1     5     2     9
                2     5     6     9
                6     5    11     9
                zeros(4,4)
                ];
            
            %Case 4: 1 1 1 -1 1 1 1 1
            obj.cases(:,:,4)=[
                11     6     5     9
                10     9     2     6
                10     6     2     3
                9     5     2     6
                10     7     6     3
                11     8     5     6
                11     7     6    10
                11     8     6     7
                11     9     4    10
                11     6     9    10
                9     5     1     2
                zeros(4,4)
                ];
            
            %Case 5: 1 1 1 1 -1 1 1 1
            obj.cases(:,:,5)=[
                11     5     9    10
                11    10     9     3
                4     8    11     3
                4     9     2     3
                4    11     9     3
                11     8     7     3
                2     9    10     3
                10     7     6     3
                11     7    10     3
                2    10     6     3
                4     9     1     2
                zeros(4,4)
                ];
            
            %Case 6: 1 1 1 1 1 -1 1 1
            obj.cases(:,:,6)=[
                4     5     1    10
                4     3     8    11
                4     9     3    11
                4     8     5    10
                4     9    11    10
                3     7     8    11
                4    11     8    10
                4     1     9    10
                11     9     6    10
                4     2     3     9
                4     1     2     9
                zeros(4,4)
                ];
            
            %Case 7: 1 1 1 1 1 1 -1 1
            obj.cases(:,:,7)=[
                4     5     1    11
                4     8     5    11
                4     1     2     9
                4     2     3     9
                4     1     9    11
                1     5    10    11
                9    10     7    11
                1    10     9    11
                2     5     6    10
                1     5     2    10
                1     2     9    10
                zeros(4,4)
                ];
            
            %Case 8: 1 1 1 1 1 1 1 -1
            obj.cases(:,:,8)=[
                7     6    11     3
                6     2    10    11
                9    10     2    11
                6     2    11     3
                9    11     2     3
                9     2     4     3
                9     1     4     2
                5     2    10     6
                9     8    10    11
                5     1    10     2
                9    10     1     2
                zeros(4,4)
                ];
            
            %Case 9: -1 -1 1 1 1 1 1 1
            obj.cases(:,:,9)=[
                9     8    12    11
                4     8     9    11
                9    12     2    11
                4     3     8    11
                3     7     8    11
                7    12     8    11
                6    12     8     7
                9    10     1     2
                5    12     8     6
                5    10     8    12
                9     8    10    12
                9    10     2    12
                zeros(3,4)
                ];
            
            %Case 10: -1 1 1 -1 1 1 1 1
            obj.cases(:,:,10)=[
                12     9     4    11
                2     6     3    11
                12     6    10     9
                12     5    10     6
                9     6     2    11
                12     8     5     6
                12     6     9    11
                12    10     4     9
                6     7     3    11
                12     7     6    11
                12     8     6     7
                4    10     1     9
                zeros(3,4)
                ];
            
            %Case 11: -1 1 1 1 -1 1 1 1
            obj.cases(:,:,11)=[
                9    12    11     3
                4    12    10     3
                8     7    12     3
                9    12     5    11
                4     8    12     3
                10    12     9     3
                9    11     2     3
                7     6    11     3
                6     2    11     3
                7    11    12     3
                10     5     1     9
                10    12     5     9
                zeros(3,4)
                ];
            
            %Case 12: 1 -1 -1 1 1 1 1 1
            obj.cases(:,:,12)=[
                11     4     9     8
                1     5     9     4
                4     5     9     8
                5    10     9     8
                5     6    10     8
                2    11     9    10
                10    11     9     8
                6     7    12     8
                10     6    12     8
                12    11    10     8
                3    11    10    12
                3    11     2    10
                zeros(3,4)
                ];
            
            %Case 13: 1 -1 1 1 1 -1 1 1
            obj.cases(:,:,13)=[
                9     5    11     8
                4     5     9     8
                1     5     9     4
                7     3    12     8
                3    10    12     8
                12    10    11     8
                10     9    11     8
                10     4     9     8
                3     4    10     8
                2     9    11    10
                6     2    11    10
                6    10    11    12
                zeros(3,4)
                ];
            
            %Case 14: 1 1 -1 -1 1 1 1 1
            obj.cases(:,:,14)=[
                12    11    10     3
                5     2     9     6
                12     8     5     6
                12     5     9     6
                12    10     4     3
                12     9     4    10
                8     7     6    11
                12     8     6    11
                5     1     9     2
                12     6     9    10
                10     6     9     2
                12     6    10    11
                zeros(3,4)
                ];
            
            %Case 15: 1 1 -1 1 1 1 -1 1
            obj.cases(:,:,15)=[
                10     5    12     8
                4     5    10     8
                1     5    10     4
                10     5     1     9
                12     5    10     9
                12     9    10     3
                9     5     2     6
                9     5     1     2
                11     5     9     6
                12     5     9    11
                12     9     3    11
                12    11     3     7
                zeros(3,4)
                ];
            
            %Case 16: 1 1 1 -1 1 1 1 -1
            obj.cases(:,:,16)=[
                12     7     6     3
                4    11     9    10
                4     8    11    10
                11     2     9    10
                11     8    12    10
                11    12     2    10
                11    12     6     2
                11     5     2     6
                12     3     6     2
                12     3     2    10
                5     1     9     2
                11     5     9     2
                zeros(3,4)
                ];
            
            %Case 17: 1 1 1 1 -1 -1 1 1
            obj.cases(:,:,17)=[
                11     6    10    12
                4    12    10     3
                12     8     7     3
                4    11     9    10
                4     8    12     3
                4     8    11    12
                4    11    10    12
                4    10     2     3
                4     9     1     2
                11     5     9    10
                11     5    10     6
                4     9     2    10
                zeros(3,4)
                ];
            
            %Case 18: 1 1 1 1 -1 1 1 -1
            obj.cases(:,:,18)=[
                12     6     2     3
                12     7     6     3
                10    12     2     3
                10     2     4     3
                10    12    11     2
                10     8     5    11
                10     5     9    11
                12     6    11     2
                10     8    11    12
                10    11     9     2
                10     9     4     2
                4     9     1     2
                zeros(3,4)
                ];
            
            %Case 19: 1 1 1 1 1 -1 -1 1
            obj.cases(:,:,19)=[
                12     4    11     8
                1     5    11     4
                4     5    11     8
                10     4     9    12
                7    10     6    12
                9     4    11    12
                6    10     9    12
                3     9    10     4
                6     9    11    12
                3     2     9     4
                2     1     9     4
                9     1    11     4
                zeros(3,4)
                ];
            
            %Case 20: 1 1 1 1 1 1 -1 -1
            obj.cases(:,:,20)=[
                6     2    11    12
                10     8    11    12
                10     9     2     3
                10    12     2     9
                10    11     2    12
                10     2     4     3
                10     8    12     9
                8     7    12     9
                5     2    11     6
                10     1     4     2
                10    11     1     2
                5     1    11     2
                zeros(3,4)
                ];
            
            %Case 21: -1 -1 -1 1 1 1 1 1
            obj.cases(:,:,21)=[
                5    10     8    11
                11    10     8    13
                7     6     8    13
                6     5     8    11
                6    11     8    13
                9    10     1     2
                9    11     2    12
                12    13    11     3
                9    10     2    11
                12    11     2     3
                12     8    10    13
                12    13    10    11
                9    12    10    11
                4     8     9    12
                9     8    10    12
                ];
            
            %Case 22: -1 -1 1 -1 1 1 1 1
            obj.cases(:,:,22)=[
                13     9     4    12
                11     8     6     7
                4     9     1    12
                10     7     3    12
                1     9    10    12
                13     7    11    12
                11     8     5     6
                13    11     9    12
                11     7    10    12
                13     5     9    11
                13     8     5    11
                13     8    11     7
                10     9    11    12
                2     9    11    10
                1     9     2    10
                ];
            
            %Case 23: -1 -1 1 1 -1 1 1 1
            obj.cases(:,:,23)=[
                8     7    10     3
                9    13    12    11
                8     7    13    10
                7    12    13    11
                9    12     1    11
                6    12     7    11
                4     8    10     3
                4     8    13    10
                4    13     9    10
                9    13     5    12
                9     5     1    12
                7    11    13    10
                9    13    11    10
                9    11     2    10
                9    11     1     2
                ];
            
            %Case 24: -1 -1 1 1 1 -1 1 1
            obj.cases(:,:,24)=[
                9     8    10    12
                4     8    11     3
                5    10     8    12
                7    13     8     3
                11    12     6    13
                9    12    11    13
                11     8     9    13
                11     8    13     3
                9     8    12    13
                9    10     1     2
                4     8     9    11
                9    10     2    11
                11    10     2    12
                2    12     6    11
                9    10    11    12
                
                ];
            
            %Case 25: -1 1 -1 -1 1 1 1 1
            obj.cases(:,:,25)=[
                13     6    10    12
                13    12    11     3
                13     8     6    12
                9     6     2    11
                7     6     8    12
                10     6    11    12
                13    11     4     3
                13    12    10    11
                13     8     5     6
                13     5    10     6
                13    10     4     9
                4    10     1     9
                13     9     4    11
                13    11    10     9
                10     6     9    11
                
                ];
            
            %Case 26: -1 1 1 -1 -1 1 1 1
            obj.cases(:,:,26)=[
                10     7    12     6
                12     2    10     6
                11     7    12    10
                12     9    10     2
                10     7     6     3
                11     8    13     7
                11     7    13    12
                6     2    10     3
                5     9    13    12
                11    13     9    12
                11    12     9    10
                11     9     4    10
                5     1    13     9
                11    13     1     9
                11     1     4     9
                
                ];
            
            %Case 27: -1 1 1 -1 1 1 1 -1
            obj.cases(:,:,27)=[
                12     6     9    13
                4    12    10    11
                11    13     2     3
                11    13     9     2
                4     8    12    11
                13     7     6     3
                11     8    12    13
                2    13     9     6
                2    13     6     3
                12     5    10     6
                11    12     9    13
                11    12    10     9
                12     6    10     9
                4    10     9    11
                4    10     1     9
                
                ];
            
            %Case 28: -1 1 1 1 -1 -1 1 1
            obj.cases(:,:,28)=[
                13     8     7     3
                9    11     2     3
                12     6    11    13
                13    11    10     3
                4     8    13     3
                4    13    10     3
                4    12    10    13
                4     8    12    13
                11     9    10     3
                12    11    10    13
                12     5    11     6
                12     5     9    11
                12     9    10    11
                12     5    10     9
                5     1    10     9
                
                ];
            
            %Case 29: -1 1 1 1 -1 1 1 -1
            obj.cases(:,:,29)=[
                11    10     4     3
                13     7     6     3
                13     6    12     2
                13     2    12     9
                11     5    10    12
                13     6     2     3
                13     2     9     3
                1    10     5     9
                9    10     5    12
                11     8    12    13
                11     8     5    12
                11    12     9    13
                11    13     9     3
                11     9    10     3
                11    12    10     9
                
                ];
            
            %Case 30: 1 -1 -1 -1 1 1 1 1
            obj.cases(:,:,30)=[
                13    10     4     3
                8     6    11    12
                13    12    10     3
                8     6     5    11
                8     7     6    12
                2     9    11     3
                1    10     5     9
                13     8    11    12
                13     8     5    11
                13     5    10     9
                13     9    10    12
                9    10    12     3
                11     9    12     3
                13     5     9    11
                13    11     9    12
                
                ];
            
            %Case 31: 1 -1 -1 1 1 -1 1 1
            obj.cases(:,:,31)=[
                9     4     5     8
                9     1     5     4
                4     9    10     8
                10    12    13     8
                7    11    13     8
                10     9    12     8
                12     9     5     8
                10    13    11     8
                10     9     2    11
                10     2     3    11
                2     9    13    11
                10     9    11    13
                10     9    13    12
                2     9    12    13
                6     2    12    13
                
                ];
            
            %Case 32: 1 -1 -1 1 1 1 -1 1
            obj.cases(:,:,32)=[
                3    12     7    13
                9    10     2    11
                2    10     3    11
                11    12     3    13
                10     5     6    12
                10    12     3    11
                11    10    12    13
                10     5    12    13
                8     9     4    11
                8     9    11    13
                11     9    10    13
                9     5    10    13
                8     5     9    13
                8     5     4     9
                5     1     4     9
                
                ];
            
            %Case 33: 1 -1 1 1 -1 -1 1 1
            obj.cases(:,:,33)=[
                8    12     4    11
                8     7    13     3
                5    10    12     6
                8    11     4     3
                6    10    12    13
                11    12     9    13
                4    12     9    11
                9     6    11    13
                8    13    11     3
                10     6     9    13
                9    12    10    13
                4    12    10     9
                4    10     1     9
                9     6     2    11
                8    12    11    13
                
                ];
            
            %Case 34: 1 -1 1 1 1 -1 -1 1
            obj.cases(:,:,34)=[
                9     4     5     8
                9     1     5     4
                11    10    12    13
                %10 11 12 13
                6    11    12    13
                9     4     8    13
                10     9    12    13
                2     9    12    10
                7    11     6    13
                9     8    12    13
                9     8     5    12
                4    10    11    13
                4     9    10    13
                4    10     3    11
                6    10    12    11
                6     2    12    10
                
                ];
            
            %Case 35: 1 1 -1 -1 1 1 -1 1
            obj.cases(:,:,35)=[
                13    12    10     3
                13     7    12     3
                11    13    10     3
                11     8     5    13
                11     5     9    13
                11    10     4     3
                5     2     9     6
                5     6     9    12
                5    12     9    13
                5     1     9     2
                11     9     4    10
                11    13     9    10
                13    12     9    10
                12     6     9    10
                10     6     9     2
                
                ];
            
            %Case 36: 1 1 -1 -1 1 1 1 -1
            obj.cases(:,:,36)=[
                4    13     9    11
                11    10     6    13
                2    12     6    10
                7     6    13    11
                4    11    10     3
                4     8    12    13
                4    12     9    13
                10    12     6    13
                2    12     5     6
                9    12     5     2
                9     5     1     2
                9    10    11    13
                9    12    10    13
                9    12     2    10
                4    11     9    10
                
                ];
            
            %Case 37: 1 1 -1 1 1 -1 -1 1
            obj.cases(:,:,37)=[
                7    10     6    13
                11     4    12     8
                1     5    12     4
                4     5    12     8
                13    11    12     8
                11     1    12     4
                6    10    12    13
                2     1    10     9
                10    11    12    13
                9    11    10    13
                9     1    10    11
                10     1    12    11
                7     9    10    13
                7     3     9    13
                3    11     9    13
                
                ];
            
            %Case 38: 1 1 -1 1 1 1 -1 -1
            obj.cases(:,:,38)=[
                9     1    12    10
                7     3    13    10
                13     9    12    10
                11     1     4    10
                11    12     1    10
                11    13    12    10
                6     9    12    13
                11     7    13    10
                6     2    12     9
                2     1    12     9
                13     3     9    10
                11     8    13     7
                11     8    12    13
                5     2    12     6
                5     1    12     2
                
                ];
            
            %Case 39: 1 1 1 -1 -1 1 1 -1
            obj.cases(:,:,39)=[
                9    12     2    11
                13    12    11     2
                12    10     8    13
                9     8    10    13
                7     6    13     3
                13     6     2     3
                13     2    11     3
                4     8     9    11
                9     8    13    11
                9    13    10    12
                5    10     8    12
                9    13    12    11
                13    12     2     6
                9    10     2    12
                9    10     1     2
                
                ];
            
            %Case 40: 1 1 1 -1 1 1 -1 -1
            obj.cases(:,:,40)=[
                10    11    13     2
                10    12    13    11
                8    13    12    11
                9    13     2    10
                10    11     2     3
                10     8    12    11
                8     7    13    11
                9    12    13    10
                4     8    12    10
                4    12     9    10
                2    12     5     6
                2    12     6    13
                9    12     2    13
                9    12     5     2
                9     5     1     2
                
                ];
            
            %Case 41: 1 1 1 1 -1 -1 -1 1
            obj.cases(:,:,41)=[
                5    10    12     6
                4    11    10     3
                6    10    12    13
                4    12     9    13
                4    11     9    10
                8    12     4    13
                11    13     9    10
                4    13     9    11
                10     9    12    13
                5     9    12    10
                4    10     2     3
                4     9     2    10
                4     9     1     2
                6    11    13     7
                6    10    13    11
                
                ];
            
            %Case 42: 1 1 1 1 -1 -1 1 -1
            obj.cases(:,:,42)=[
                12     5     9    10
                10    13    12     3
                11    13    10     3
                13     7    12     3
                11     5     9    13
                11     2     4     3
                11     8     5    13
                10    13     9    12
                11    10     2     3
                13     5     9    12
                4     9     1     2
                11     9     4     2
                11    13     9    10
                11    10     9     2
                12     5    10     6
                
                ];
            
            %Case 43: 1 1 1 1 -1 1 -1 -1
            obj.cases(:,:,43)=[
                11    13     9    10
                11    12     9    13
                9    13    12     2
                9    10    13     2
                11     8    12    13
                7    13     8    10
                11     8    13    10
                12    13     6     2
                11     8     5    12
                11     5     9    12
                11     2     4     3
                11    10     2     3
                11    10     9     2
                4     9     1     2
                11     9     4     2
                
                ];
            
            %Case 44: 1 1 1 1 1 -1 -1 -1
            obj.cases(:,:,44)=[
                12    10     6     9
                8     7    13    10
                11    13    12    10
                11    12     9    10
                6    12     7    10
                7    12    13    10
                11     8    13    10
                11     9     2     3
                5     1    13    12
                11    13     1    12
                11    10     9     3
                11     2     4     3
                11     1     4     2
                11     9     1     2
                11    12     1     9
                
                ];
            
            %Case 45: -1 -1 -1 -1 1 1 1 1
            obj.cases(:,:,45)=[
                10     8     6    11
                7     6     8    11
                12     2     4     3
                12    10     2     3
                10     8     5     6
                12     8    10    11
                12    11    10     3
                4     9     1     2
                12     9     4     2
                12    10     9     2
                12     5     9    10
                12     8     5    10
                zeros(3,4)
                ];
            
            %Case 46: -1 1 1 -1 -1 1 1 -1
            obj.cases(:,:,46)=[
                1     5     9     4
                10    11     2    12
                5    11     9     8
                5     8     9     4
                9     8    10     4
                9    11    10     8
                10    11    12     8
                9    11     2    10
                10     2     3    12
                2     6     3    12
                3     6     7    12
                2    11     6    12
                zeros(3,4)
                ];
            
            %Case 47: -1 -1 1 1 -1 -1 1 1
            obj.cases(:,:,47)=[
                10    11     6    12
                8     7    12     3
                10     8    12     3
                10     8    11    12
                4     8    10     3
                2    11     5     6
                9     5     1     2
                9    11     5     2
                4    11     9    10
                9    11     2    10
                2    11     6    10
                4     8    11    10
                zeros(3,4)
                ];
            
            %Case 48: -1 -1 1 -1 -1 1 1 1
            obj.cases(:,:,48)=[
                11    12    13     7
                1     5    13    14
                12     1    13    14
                9    11    10     7
                11     1    13    12
                10     1    13    11
                8    12     7    14
                10    11    13     7
                9     1    10    11
                7    12    13    14
                6    10    13     7
                4     1    11    12
                2     1    10     9
                3    11     9     7
                zeros(1,4)
                ];
            
            %Case 49: -1 -1 -1 1 1 -1 1 1
            obj.cases(:,:,49)=[
                1    10     2     9
                12    11    14     8
                10     5    13     8
                9    10    13     8
                4     9    11     8
                11     2    13     9
                2    10    13     9
                7    12    14     8
                14     6    13     2
                2    11    14    12
                14    11    13     8
                11     9    13     8
                3    11     2    12
                14     2    13    11
                zeros(1,4)
                ];
            
            %Case 50: 1 -1 -1 -1 1 1 -1 1
            obj.cases(:,:,50)=[
                8     5    12    14
                3    13     7    14
                12    10     4     3
                12    10     3     9
                11     5     6    13
                9    11     2     3
                5    13    11    14
                13     3    11    14
                12     9     3    14
                11     3     9    14
                5    11     9    14
                12     5     9    14
                12     5    10     9
                5     1    10     9
                zeros(1,4)
                ];
            
            %Case 51: -1 1 -1 -1 1 1 1 -1
            obj.cases(:,:,51)=[
                11    12     4    14
                11     3     4    12
                11     6    12    14
                13     4     8    14
                12     6     7    14
                9    11     4    14
                9     4    13    14
                9     6    11    14
                9     2    11     6
                6     9    13    14
                5    10    13     6
                10     1     4     9
                10     4    13     9
                6    10    13     9
                zeros(1,4)
                ];
            obj.selectcases(1,1)=1;
            obj.selectcases(35,502)=1;
            obj.selectcases(2,2)=2;
            obj.selectcases(34,501)=2;
            obj.selectcases(3,4)=3;
            obj.selectcases(33,499)=3;
            obj.selectcases(4,16)=4;
            obj.selectcases(32,487)=4;
            obj.selectcases(5,32)=5;
            obj.selectcases(31,471)=5;
            obj.selectcases(6,64)=6;
            obj.selectcases(30,439)=6;
            obj.selectcases(7,128)=7;
            obj.selectcases(29,375)=7;
            obj.selectcases(8,256)=8;
            obj.selectcases(28,247)=8;
            obj.selectcases(3,3)=9;
            obj.selectcases(33,500)=9;
            obj.selectcases(5,17)=10;
            obj.selectcases(31,486)=10;
            obj.selectcases(6,33)=11;
            obj.selectcases(30,470)=11;
            obj.selectcases(5,6)=12;
            obj.selectcases(31,497)=12;
            obj.selectcases(8,66)=13;
            obj.selectcases(28,437)=13;
            obj.selectcases(7,20)=14;
            obj.selectcases(29,483)=14;
            obj.selectcases(10,132)=15;
            obj.selectcases(26,371)=15;
            obj.selectcases(12,272)=16;
            obj.selectcases(24,231)=16;
            obj.selectcases(11,96)=17;
            obj.selectcases(25,407)=17;
            obj.selectcases(13,288)=18;
            obj.selectcases(23,215)=18;
            obj.selectcases(13,192)=19;
            obj.selectcases(23,311)=19;
            obj.selectcases(15,384)=20;
            obj.selectcases(21,119)=20;
            obj.selectcases(6,7)=21;
            obj.selectcases(30,496)=21;
            obj.selectcases(7,19)=22;
            obj.selectcases(29,484)=22;
            obj.selectcases(8,35)=23;
            obj.selectcases(28,468)=23;
            obj.selectcases(9,67)=24;
            obj.selectcases(27,436)=24;
            obj.selectcases(8,21)=25;
            obj.selectcases(28,482)=25;
            obj.selectcases(10,49)=26;
            obj.selectcases(26,454)=26;
            obj.selectcases(13,273)=27;
            obj.selectcases(23,230)=27;
            obj.selectcases(12,97)=28;
            obj.selectcases(24,406)=28;
            obj.selectcases(14,289)=29;
            obj.selectcases(22,214)=29;
            obj.selectcases(9,22)=30;
            obj.selectcases(27,481)=30;
            obj.selectcases(11,70)=31;
            obj.selectcases(25,433)=31;
            obj.selectcases(12,134)=32;
            obj.selectcases(24,369)=32;
            obj.selectcases(13,98)=33;
            obj.selectcases(23,405)=33;
            obj.selectcases(15,194)=34;
            obj.selectcases(21,309)=34;
            obj.selectcases(14,148)=35;
            obj.selectcases(22,355)=35;
            obj.selectcases(15,276)=36;
            obj.selectcases(21,227)=36;
            obj.selectcases(16,196)=37;
            obj.selectcases(20,307)=37;
            obj.selectcases(18,388)=38;
            obj.selectcases(18,115)=38;
            obj.selectcases(17,304)=39;
            obj.selectcases(19,199)=39;
            obj.selectcases(19,400)=40;
            obj.selectcases(17,103)=40;
            obj.selectcases(18,224)=41;
            obj.selectcases(18,279)=41;
            obj.selectcases(19,352)=42;
            obj.selectcases(17,151)=42;
            obj.selectcases(20,416)=43;
            obj.selectcases(16,87)=43;
            obj.selectcases(21,448)=44;
            obj.selectcases(15,55)=44;
            obj.selectcases(10,23)=45;
            obj.selectcases(26,480)=45;
            obj.selectcases(18,305)=46;
            obj.selectcases(18,198)=46;
            obj.selectcases(14,99)=47;
            obj.selectcases(22,404)=47;
            obj.selectcases(12,51)=48;
            obj.selectcases(24,452)=48;
            obj.selectcases(12,71)=49;
            obj.selectcases(24,432)=49;
            obj.selectcases(16,150)=50;
            obj.selectcases(20,353)=50;
            obj.selectcases(16,277)=51;
            obj.selectcases(20,226)=51;
        end
        
    end
    
end
