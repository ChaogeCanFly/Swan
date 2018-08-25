clc; clear variables; close all;
addpath(genpath(fileparts(mfilename('fullpath'))));

%% Test
% run('test_fem.m');
run('test_topopt.m');
clear variables;
%% Main
filenames={%'GrippingTriangleCoarse_Case_1_1_1';
    %  'GrippingTriangleCoarse_Case_2_1_1';
    %  'GrippingTriangleCoarse_Case_3_1_1';
    %    'GrippingTriangleCoarse_Case_4_1_1';
    %  'GrippingTriangleFine_Case_1_1_1';
    %     'GrippingTriangleFine_Case_2_1_1';
    %     'GrippingTriangleFine_Case_3_1_1';
    %     'GrippingTriangleFine_Case_4_1_1';
    %     'GrippingQuadCoarse_Case_1_1_1';
    %     'GrippingQuadCoarse_Case_2_1_1';
    %    'GrippingQuadCoarse_Case_1_1_1';
    %     'GrippingQuadCoarse_Case_4_1_1';
    %   'GrippingQuadFine_Case_1_1_1';
    %     'GrippingQuadFine_Case_2_1_1';
    %     'GrippingQuadFine_Case_3_1_1';
    %     'GrippingQuadFine_Case_4_1_1';
%        'GrippingTetrahedraCoarse_Case_1_1_1';
%         'GrippingTetrahedraCoarse_Case_2_1_1';
%         'GrippingTetrahedraCoarse_Case_3_1_1';
%         'GrippingTetrahedraCoarse_Case_4_1_1';
%         'GrippingTetrahedraCoarse_Case_1_2_1';
%         'GrippingTetrahedraCoarse_Case_2_2_1';
%         'GrippingTetrahedraCoarse_Case_3_2_1';
%     'GrippingTetrahedraCoarse_Case_4_2_1'
    %     'CantileverQuadrilateral_Case_1_2_1';
    %     'CantileverQuadrilateral_Case_1_2_2'
    %     'CantileverQuadrilateral_Case_5_2_1'
    %             'CantileverTriangle_Case_1_2_1'
    %     'CantileverTriangle_Case_1_2_4'
    %         'BridgeQuadrilateral_Case_5_1_1'
    %     'CantileverTriangle_Case_4_1_2'
    %     'BridgeQuadrilateral_Case_5_2_1'
    % 'BridgeQuadrilateral_Case_5_2_2'
    %     'BridgeQuadrilateral_Case_5_3_1'
    %     'CantileverHexahedra_Case_1_1_1'
    %     'CantileverHexahedra_Case_5_1_1'
    %     'CantileverHexahedra_Case_5_2_1'
    % 'CantileverHexahedra_Case_5_2_2'
    % 'CantileverHexahedra_Case_5_2_3'
    % 'CantileverHexahedra_Case_5_1_2'
    'CantileverHexahedra_Case_5_1_3'
    % 'CantileverHexahedra_Case_5_1_4'
    % 'CantileverHexahedra_Case_5_1_5'
    % 'CantileverHexahedra_Case_5_1_6'
    % 'CantileverHexahedra_Case_5_1_7'
    };
for icases=1:size(filenames,1)
    clearvars -except filenames icases;
    close all;
    settings=Settings(filenames{icases});
    % --------------------------- !! DELETE !! ----------------------------
    if contains(lower(filenames{icases}),'case_5')
        if ~contains(lower(filenames{icases}),'hexa')
            dim = [2 1]; div = [120 60];
            [A1,b1,A0,b0] = conversionTensors(settings.filename,dim,div);
        else
            dim = [60 20 20]; div = [48 16 16];
            [A1,b1,A0,b0] = conversionTensors3D(settings.filename,dim,div);
        end
        save(fullfile(pwd,'Allaire_ShapeOpt','conversion'),'A0','A1','b0','b1','dim','div');
    end
    % ---------------------------------------------------------------------
    test = TopOpt_Problem(settings);
    test.preProcess;
    test.computeVariables;
    test.postProcess;
end