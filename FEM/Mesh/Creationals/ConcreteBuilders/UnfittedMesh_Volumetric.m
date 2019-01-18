classdef UnfittedMesh_Volumetric < UnfittedMesh_AbstractBuilder
    properties (GetAccess = public, SetAccess = private)
        meshType = 'INTERIOR';
        maxSubcells = 20;
        nnodesSubcell = 4;
        
        subcellsMesher = SubcellsMesher_Interior;
        cutPointsCalculator = CutPointsCalculator_3D;
        meshPlotter = MeshPlotter_Interior_3D;
    end
end

