classdef PdeOptionsBlades3
    %PdeOptionsBlades : Options for my pde solving functions.
    
    properties
        Hmax
        Hmin
        Hgrad
        Vend
        Vmid
        Vcntr
        Vrf
        parent
        symmetrize
        interp_rate
        neumann
    end
    
    methods
        function obj = PdeOptionsBlades3(varargin)
            %PdeOptionsBlades Construct an instance of this class
            %   == Name-Value Pairs ==
            %   neumann : Use neamann boundary condition a x = x_min and x = x_max
            %   faces if is true. Use dirichlet otherwise. Default = true.
            %   interp_rate : Fineness of the boundary condition interpolation. Default
            %   = 3.
            %   symmetrize : Symmetrize the boundary condition if is true. Default =
            %   false;
            p = inputParser;
            var_names = properties(obj);
            var_classes = {{'numeric'},{'numeric'},{'numeric'},{'numeric'}, ...
                {'numeric'},{'numeric'},{'numeric'},{'string'}, ...
                {'logical'},{'numeric'},{'logical'}};
            var_attibutes = {{'scalar'},{'scalar'},{'scalar'},{'scalar'}, ...
                {'scalar'},{'scalar'},{'scalar'},{'scalartext'}, ...
                {'scalar'},{'scalar'},{'scalar'}};
            default_values = {0.05,0.0005,1.2,0,0,0,0,"",false,3,true};
            for i = 1:length(var_names)
                addParameter(p,var_names{i},default_values{i},@(x) validateattributes(x,var_classes{i},var_attibutes{i},mfilename,var_names{i}));
            end
            parse(p,varargin{:});
            for i = 1:length(var_names)
                obj.(var_names{i}) = p.Results.(var_names{i});
            end
        end
    end
end

