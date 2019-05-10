filename='CantileverBeam_Triangle_Linear_Fine';
ptype = 'MACRO';
method = 'SIMPALL';
materialType = 'ISOTROPIC';
initial_case = 'full';
cost = {'compliance','perimeter'};
weights = [1 0.01];
constraint = {'volumeConstraint'};
optimizer = 'PROJECTED SLERP'; 
kappaMultiplier = 1;
designVariable = 'LevelSet';
filterType = 'P1';
constraint_case = 'EQUALITY'; %'INEQUALITY';
line_search = 'DIMENSIONALLY CONSISTENT';
showBC = true;

nsteps = 30;
Vfrac_final = 0.3;
Perimeter_target = 1;
optimality_final = 1e-3;
constr_final =1e-3;

Vfrac_initial = 1;
optimality_initial = 1e-2;
constr_initial = 1e-3;
TOL.rho_plus = 1;
TOL.rho_minus = 0;
TOL.E_plus = 1;
TOL.E_minus = 1e-3;
TOL.nu_plus = 1/3;
TOL.nu_minus = 1/3;

monitoring_interval = 1;
optimalityInitial = 1e-3;