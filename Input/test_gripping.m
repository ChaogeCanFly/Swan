filename = 'Tests_Triangle_Linear';
ptype = 'MACRO';
method = 'SIMPALL';
materialType = 'ISOTROPIC';
initial_case = 'full';
cost = {'nonadjoint_compliance'};
weights = [1];
constraint = {'volume'}; kappaMultiplier = [];
optimizer = 'SLERP';
filterType = 'P1';

nsteps = 1;
Vfrac_final = 1;
optimality_final =1e-3;
constr_final =1e-3;

Vfrac_initial = 1;
optimality_initial = 1e-3;
constr_initial = 1e-3;
Perimeter_target = 5;

TOL.rho_plus = 1;
TOL.rho_minus = 0;
TOL.E_plus = 1;
TOL.E_minus = 1e-3;
TOL.nu_plus = 1/3;
TOL.nu_minus = 1/3;

% For all tests
plotting = false;
printing = false;
monitoring = false;
maxiter = 3;
