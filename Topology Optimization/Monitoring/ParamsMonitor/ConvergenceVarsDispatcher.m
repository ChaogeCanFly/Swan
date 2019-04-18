classdef ConvergenceVarsDispatcher < handle
    
    methods (Access = public, Static)
        
        function names = dispatchNames(optimizer)
            switch optimizer
                case {'SLERP','PROJECTED GRADIENT','HAMILTON-JACOBI','PROJECTED SLERP'}
                    names = {'\Deltacost';'Norm L2';'\kappa'};
                case 'MMA'
                    names = {'kktnorm';'outit'};
                case 'IPOPT'
                    names = {'inf_{du}'};
            end
        end
        
    end
end