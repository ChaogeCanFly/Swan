classdef TopOpt_Problem < handle
    properties (GetAccess = public,SetAccess = public)
        cost
        constraint
        TOL
        x
        interpolation
        filter
        algorithm
        optimizer
        physicalProblem
        settings
        incropt
    end
    methods (Static)
        function obj=create(settings)
            switch settings.ptype
                case 'Compliance_st_Volume'
                    settings.nconstr=1;
                    obj=TopOpt_Problem_Compliance_st_Volume(settings);
                    obj.physicalProblem=Physical_Problem(obj.settings.filename);
                case 'Compliance_st_VolumePerimeter'
                    settings.nconstr=2;
                    obj=TopOpt_Problem_Compliance_st_VolumePerimeter(settings);
                    obj.physicalProblem=Physical_Problem(obj.settings.filename);
                case 'ComplianceLamPerimeter_st_Volume'
                    settings.nconstr=1;
                    obj=TopOpt_Problem_ComplianceLamPerimeter_st_Volume(settings);
                    obj.physicalProblem=Physical_Problem(obj.settings.filename);
                case 'Micro_Chomog_alphabeta'
                    settings.nconstr=1;
                    obj=TopOpt_Problem_Micro_Chomog(settings);
                    obj.physicalProblem=Physical_Problem_Micro(obj.settings.filename);
                otherwise
                    disp('Problem not added')
            end
        end
    end
    methods (Access = public)
        function obj=TopOpt_Problem(settings)
            obj.settings=settings;
            obj.TOL=obj.settings.TOL;
            obj.interpolation=Interpolation.create(obj.TOL,settings.material,settings.method);
            switch obj.settings.optimizer
                case 'SLERP'
                    obj.optimizer=Optimizer_AugLag(settings,Optimizer_SLERP(settings));
                    obj.settings.ini_value=-0.7071;
                case 'PROJECTED GRADIENT'
                    obj.optimizer=Optimizer_AugLag(settings,Optimizer_PG(settings));
                    obj.settings.ini_value=1;
                case 'MMA'
                    obj.optimizer=Optimizer_MMA(settings);
                    obj.settings.ini_value=1;
                case 'IPOPT'
                    obj.optimizer=Optimizer_IPOPT(settings);
                    obj.settings.ini_value=1;
            end
            obj.filter=Filter.create(obj.settings.filter,obj.settings.optimizer);
        end
        
        function preProcess(obj)
            %initialize design variable
            obj.physicalProblem.preProcess;
            obj.filter.preProcess(obj.physicalProblem);
            switch obj.settings.initial_case
                case 'full'
                    obj.x=obj.settings.ini_value*ones(obj.physicalProblem.mesh.npnod,obj.physicalProblem.geometry.ngaus);
            end
            nsteps=obj.settings.nsteps;
            obj.incropt.alpha_vol = obj.generate_incr_sequence(1/nsteps,1,nsteps,'linear');
            obj.incropt.alpha_constr = obj.generate_incr_sequence(0,1,nsteps,'linear');
            obj.incropt.alpha_optimality= obj.generate_incr_sequence(0,1,nsteps,'linear');
        end
        function computeVariables(obj)
            for t = 1:obj.settings.nsteps
                incremental_step=t
                obj.update_target_parameters(t)
%                 obj.physicalProblem.computeVariables; %HAS TO BE MODIFIED FOR MICRO
                obj.cost.computef(obj.x,obj.physicalProblem,obj.interpolation,obj.filter);
                obj.constraint.computef(obj.x, obj.physicalProblem, obj.interpolation,obj.filter);
                obj.x=obj.optimizer.solveProblem(obj.x,obj.cost,obj.constraint,obj.physicalProblem,obj.interpolation,obj.filter);
            end
        end
        function update_target_parameters(obj,t)
            target_parameters.Vfrac = (1-obj.incropt.alpha_vol(t))*obj.settings.Vfrac_initial+obj.incropt.alpha_vol(t)*obj.settings.Vfrac_final;
            % target_parameters.epsilon = update_parameter(target_parameters.epsilon_ini,target_parameters.epsilon_final,target_parameters.alpha_eps(t));
            %target_parameters.epsilon_isotropy = update_parameter(target_parameters.epsilon_isotropy_ini,target_parameters.epsilon_isotropy_final,target_parameters.alpha_isotropy2d(t));
            target_parameters.constr_tol = (1-obj.incropt.alpha_constr(t))*obj.settings.constr_initial+obj.incropt.alpha_constr(t)*obj.settings.constr_final;
            target_parameters.optimality_tol = (1-obj.incropt.alpha_optimality(t))*obj.settings.optimality_initial+obj.incropt.alpha_optimality(t)*obj.settings.optimality_final;
            obj.cost.target_parameters=target_parameters;
            %            obj.cost.h_C_0=[];
            obj.constraint.target_parameters=target_parameters;
            obj.optimizer.target_parameters=target_parameters;
        end
        function postProcess(obj)
        end
    end
    methods (Static)
        function x = generate_incr_sequence (x1,x2,nsteps,type,factor)
            
            switch type
                case 'linear'
                    x = linspace(x1,x2,nsteps);
                    
                case 'epsilon_sequence'
                    frac = 2;
                    kmax = ceil(log10(x1/x2)/log10(frac));
                    x = epsilon0./frac.^(1:kmax);
                    
                case 'logarithmic'
                    x = logspace(log10(x1),log10(x2),nsteps);
                    
                case 'custom'
                    if nsteps < 2
                        x = x2;
                    else
                        isteps = 0:nsteps-1;
                        x = 1-(1-isteps/(nsteps-1)).^(factor);
                        x = (x2-x1)*x + x1;
                    end
                    
                case 'free'
                    x = zeros(1,nsteps);
                    x(end) = 1;
                    
                otherwise
                    error('Incremental sequence type not detected.')
            end
            
        end
    end
    
end
