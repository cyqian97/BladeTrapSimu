classdef PdeOptionsBlades
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
    end
    
    methods
        function obj = PdeOptionsBlades(varargin)
            %PdeOptionsBlades Construct an instance of this class
            p = inputParser;
            var_names = properties(obj);
            var_attibutes = {{'scalar'},{'scalar'},{'scalar'},{'scalar'},{'scalar'},{'scalar'},{'scalar'}};
            default_values = {0.05,0.0005,1.2,0,0,0,0,""};
            for i = 1:length(var_names)-1
                addParameter(p,var_names{i},default_values{i},@(x) validateattributes(x,{'numeric'},var_attibutes{i},mfilename,var_names{i}));
            end
            i=i+1;
            addParameter(p,var_names{i},default_values{i},@(x) validateattributes(x,{'string'},{'scalartext'},mfilename,var_names{i}));
            parse(p,varargin{:});
            for i = 1:length(var_names)
                obj.(var_names{i}) = p.Results.(var_names{i});
            end
        end
    end
end

