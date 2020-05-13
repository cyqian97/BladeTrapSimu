classdef MyPdeOptions
    %MyPdeOptions : Options for my pde solving functions.
    
    properties
        Hmax
        Hmin
        Hgrad
        Vend
        Vmid
        Vcntr
        Vrf 
        cube
        iter
        reduce
        interp_fineness
        mesh_fineness
    end
    
    methods
        function obj = MyPdeOptions(varargin)
            %MyPdeOptions Construct an instance of this class
            p = inputParser;
            var_names = properties(obj);
            var_attibutes = {{'scalar'},{'scalar'},{'scalar'},{'scalar'},{'scalar'},{'scalar'},{'scalar'}, ...
                {'size',[1,3]},{'scalar'},{'scalar'},{'size',[1,3]},{'size',[1,3]}};
            default_values = {0.05,0.0005,1.2,0,0,0,0,[],0,0,[],[]};
            for i = 1:length(var_names)
                addParameter(p,var_names{i},default_values{i},@(x) validateattributes(x,{'numeric'},var_attibutes{i},mfilename,var_names{i}));
            end
            parse(p,varargin{:});
            for i = 1:length(var_names)
                eval("obj."+var_names{i}+"=p.Results."+var_names{i}+";");
            end
        end
    end
end

