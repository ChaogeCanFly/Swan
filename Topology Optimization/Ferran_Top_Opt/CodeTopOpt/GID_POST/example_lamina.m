coord = [ 
10 0 0
10 20 0
0 0 15
0 20 15
-10 0 0
-10 20 0             
];         
selem.conec = [
1 2 3 4
3 4 6 5
];
selem.matno = [
1 
2
];
selem.etype = 'Quadrilateral';
fname = 'example02';
istep = 1;
vel = [
00000         00000 
00000         00000 
00000 -9.09923e-001 
00000 -5.52628e-001 
00000        -00001 
00000        -00002 ];
pressure = [           
-2.00475e-001 
-3.25376e-001 
-3.25704e-001 
-2.42826e-001 
 6.46427e-003 
-3.40210e-001 ]; 
stress1 = [
-2.00475e-001  -4.00475e-001  -6.00475e-001  -10.00475e-001 
-3.25376e-001  -9.25376e-001  -9.25376e-001  -15.25376e-001];
stress = stress1';
gid_write_msh(fname,istep,coord,selem);
[fid]=gid_write_headerpost(fname,istep,selem.etype);
nameres='velocidad';
time = 1;
gid_write_vfield(fid,'vel',time,vel);
gid_write_sclfield(fid,'pressure',time,pressure);
%gid_write_tensorfield(fid,'stress',time,stress);

status = fclose(fid);
       
           
 