filename='Cantilever_triangle_coarse';
% filename = '';
 ptype = 'MACRO';
% method = 'SIMP_Adaptative';
method = '';
materialType = 'ISOTROPIC';
% initial_case = 'full';
initial_case = '';
% cost = {'compliance','perimeter'};
cost = {''};
weights = [1, 0.1];
% constraint = {'volumeConstraint'};
constraint = {''};
% optimizer = 'IPOPT'; 
optimizer = ''; 
kappaMultiplier = 1;
% designVariable = 'Density';
designVariable = '';
filterType = 'P1';

nsteps = 1;
% Vfrac_final = 0.4;
Vfrac_final = '';
Perimeter_target = 1;
% optimality_final = 1e-3;
optimality_final = '';
% constr_final =1e-3;
constr_final = '';

% Vfrac_initial = 1;
Vfrac_initial = '';
% optimality_initial = 1e-3;
optimality_initial = '';
% constr_initial = 1e-3;
constr_initial = '';

TOL.rho_plus = '';
TOL.rho_minus = '';
TOL.E_plus = '';
TOL.E_minus = '';
TOL.nu_plus = '';
TOL.nu_minus = '';

% TOL.rho_plus = 1;
% TOL.rho_minus = 0;
% TOL.E_plus = 1;
% TOL.E_minus = 1e-3;
% TOL.nu_plus = 1/3;
% TOL.nu_minus = 1/3;

% printing = '';
% printing_physics = '';
plotting = '';
showBC = '';
monitoring = '';
monitoring_interval = 5;

isOld = false;