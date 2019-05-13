classdef SettingsLevelSetCreatorFactory < handle
    
    methods (Access = public, Static)
        
        function obj = create(s)
            switch s.type
                case 'circle'
                    obj = SettingsLevelSetSphereNdim(s);
                case 'circleInclusion'
                    obj = SettingsLevelSetSphereNdim(s);
                case 'sphere'
                    obj = SettingsLevelSetSphereNdim(s);
                case 'sphereInclusion'
                    obj = SettingsLevelSetSphereNdim(s);
                case 'cylinder'
                    obj = SettingsLevelSetSphereNdim(s);
                case 'horizontal'
                    obj = SettingsLevelSetHorizontalInclusion(s);
                case 'square'
                    obj = SettingsLevelSetSquareInclusion(s);
                case 'smoothSquare'                    
                    obj = SettingsLevelSetSmoothSquareInclusion(s);
                case 'rectangle'
                    obj = SettingsLevelSetRectangleInclusion(s);
                case 'smoothRectangle'
                    obj = SettingsLevelSetSmoothRectangleInclusion(s);
                case 'feasible'
                    obj = SettingsLevelSetCreator(s);
                case 'rand'
                    obj = SettingsLevelSetCreator(s);
                case 'holes'                                       
                    obj = SettingsLevelSetSeveralHoles(s);
                case 'full'
                    obj = SettingsLevelSetCreator(s);
                case 'horizontalFibers'
                    obj = SettingsLevelSetHorizontalFibers(s);
                case 'given'
                    obj = SettingsLevelSetGiven(s);
                otherwise
                    error('Invalid initial value of design variable.');
            end
            
        end
    end

end

