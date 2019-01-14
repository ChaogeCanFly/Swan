classdef UnfittedMesh_FlatSurface < UnfittedMesh_AbstractBuilder
    properties (GetAccess = public, SetAccess = private)
        meshType = 'INTERIOR';
        max_subcells = 6;
        nnodes_subcell = 3;
        
        subcells_Mesher = SubcellsMesher_Interior;
        cutPoints_Calculator = CutPoints_Calculator_2D;
        meshPlotter = MeshPlotter_Interior_2D;
    end
end

