coord = [0 0;1 0;1 1;0 1;2 0;2 1;0 2;1 2;2 2];
connec = [1 2 3 4; 2 5 6 3; 4 3 8 7; 3 6 9 8];
s.coord = coord;
s.connec = connec;
m = Mesh_Total(s);

ls = [-0.05 0.2 -0.5 0.1 0.1 -1 1 -0.2 -0.5]';

inter = Interpolation.create(m,'LINEAR');
s.unfittedType = 'INTERIOR';
s.meshBackground = m;
s.interpolationBackground = inter;
s.includeBoxContour = true;
uMesh = UnfittedMesh(s);
uMesh.compute(ls); 
uMesh.plot()