classdef Optimizer < handle
    properties
        fhtri
        kappa
        objfunc
        stop_criteria = 1;
        Msmooth
        Ksmooth
        target_parameters = struct;
        epsilon_scalar_product_P1
        name
        niter = 0
        optimizer
        maxiter
        plotting
        printing
        monitoring
        stop_vars      
        mesh
    end
    methods
        function obj = Optimizer(settings,monitoring)
            obj.target_parameters = settings.target_parameters;
            obj.optimizer = settings.optimizer;
            obj.maxiter = settings.maxiter;
            obj.plotting = settings.plotting;
            obj.printing = settings.printing;
            obj.monitoring = Monitoring(settings,monitoring);
        end
        function x = solveProblem(obj,x_ini,cost,constraint)
            cost.computef(x_ini);
            constraint.computef(x_ini);
            obj.plotX(x_ini)
            %             obj.print(x_ini,filter.getP0fromP1(x_ini),obj.niter);
            while obj.stop_criteria && obj.niter < obj.maxiter
                obj.niter = obj.niter+1;
                x = obj.updateX(x_ini,cost,constraint);
                obj.plotX(x)
                %                 obj.print(x,filter.getP0fromP1(x),obj.niter);
                obj.monitoring.display(obj.niter,cost,constraint,obj.stop_vars,obj.stop_criteria && obj.niter < obj.maxiter);
                x_ini = x;
            end
            obj.stop_criteria = 1;
        end
        
        %% HAS TO BE REMOVED FROM OPTIMIZER CLASS --> Physical Problem with Element_Dif_React
        function sp = scalar_product(obj,f,g)
            f = f(:);
            g = g(:);
            try
            sp = f'*(((obj.epsilon_scalar_product_P1)^2)*obj.Ksmooth+obj.Msmooth)*g;
            catch
                disp('error')
            end
        end
    end
    methods (Access = private)
        function print(obj,design_variable,design_variable_reg,iter)
            if ~(obj.printing)
                return
            end
            postprocess = Postprocess_TopOpt.Create(obj.optimizer);
            results.physicalVars = obj.physicalProblem.variables;
            results.design_variable = design_variable;
            results.design_variable_reg = design_variable_reg;
            postprocess.print(obj.physicalProblem,obj.physicalProblem.problemID,iter,results);
        end
    end
    methods (Access = protected)
        function plotX(obj,x)
            if ~(obj.plotting)
                return
            end
            
            if any(x<0)
                rho_nodal = x<0;
            else
                rho_nodal = x;
            end
            if isempty(obj.fhtri)
                fh = figure;
                mp = get(0, 'MonitorPositions');
                select_screen = 1;
                if size(mp,1) < select_screen
                    select_screen = size(mp,1);
                end
                width = mp(1,3);
                height = mp(1,4);
                size_screen_offset = round([0.7*width,0.52*height,-0.71*width,-0.611*height],0);
                set(fh,'Position',mp(select_screen,:) + size_screen_offset);
                obj.fhtri = trisurf(obj.mesh.connec,obj.mesh.coord(:,1),obj.mesh.coord(:,2),double(rho_nodal), ...
                    'EdgeColor','none','LineStyle','none','FaceLighting','phong');
                view([0,90]);
                colormap(flipud(gray));
                set(gca,'CLim',[0, 1],'XTick',[],'YTick',[]);
                drawnow;
            else
                set(obj.fhtri,'FaceVertexCData',double(rho_nodal));
                set(gca,'CLim',[0, 1],'XTick',[],'YTick',[]);
                drawnow;
            end
        end
    end
    
    methods (Access = protected, Static)
        function N_L2 = norm_L2(x,x_ini,M)
            inc_x = x-x_ini;
            N_L2 = (inc_x'*M*inc_x)/(x_ini'*M*x_ini);
        end
        
    end
    
end
