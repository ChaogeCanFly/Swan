function RunningVademecum


dSmooth = obtainSettings('VademecumSmoothCorner','SmoothRectangle');
computeVademecum(dSmooth);


dSmooth = obtainSettings('VademecumCorner','Rectangle');
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
expParams.gamma = 4;
expParams.alpha = 6;
expParams.beta  = 20;
expParams.type  = 'Hyperbolic';
d.superEllipseExponentSettings = expParams;
d.freeFemSettings.hMax = 0.02;%0.0025;
end