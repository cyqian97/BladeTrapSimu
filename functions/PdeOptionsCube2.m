classdef PdeOptionsCube2
    %MyPdeOptions : Options for my pde solving functions.
    
    properties
        cube
        iter
        reduce
        interp_fineness
        mesh_fineness
        parent
        symmetrize
    end
    
    methods
        function obj = PdeOptionsCube2(varargin)
            %MyPdeOptions Construct an instance of this class
            p = inputParser;
            var_names = properties(obj);
            var_classes = {{'numeric'},{'numeric'},{'numeric'},{'numeric'}, ...
                {'numeric'},{'string'},{'logic'}};
            var_attibutes = {{'size',[1,3]},{'scalar'},{'scalar'},{'size',[1,3]}, ...
                {'size',[1,3]},{'scalartext'},{'scalar'}};
            default_values = {0,0,0,0,0,"",false};
            for i = 1:length(var_names)-1
                addParameter(p,var_names{i},default_values{i},@(x) validateattributes(x,var_classes{i},var_attibutes{i},mfilename,var_names{i}));
            end
            parse(p,varargin{:});
            for i = 1:length(var_names)
                obj.(var_names{i})=p.Results.(var_names{i});
            end
        end
    end
end

