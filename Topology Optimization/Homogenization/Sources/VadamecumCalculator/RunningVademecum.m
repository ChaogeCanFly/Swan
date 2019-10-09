function RunningVademecum


dSmooth = obtainSettings('VademecumSmoothCorner','SmoothRectangle');
d.smoothingExponentSettings.type = 'Optimal';
computeVademecum(dSmooth);


dSmooth = obtainSettings('VademecumCorner','Rectangle');
d.smoothingExponentSettings.type = 'Given';
d.smoothingExponentSettings.q = 32;
computeVademecum(dSmooth);

end

function computeVademecum(d)
vc = VademecumCellVariablesCalculator(d);
vc.computeVademecumData()
vc.saveVademecumData();
end

function d = obtainSettings(prefix,freeFemFile)
d = SettingsVademecumCellVariablesCalculator();
d.freeFemFileName = freeFemFile;
d.fileName   = prefix;
d.mxMin = 0.01;
d.mxMax = 0.99;
d.myMin = 0.01;
d.myMax = 0.99;
d.nMx   = 20;
d.nMy   = 20;
d.outPutPath = [];
d.print = true;
d.freeFemSettings.hMax = 0.02;%0.0025;
end