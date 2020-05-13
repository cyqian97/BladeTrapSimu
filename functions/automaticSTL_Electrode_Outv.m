classdef automaticSTL_Electrode_Outv
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vertice
        outsurf_paras
        insurf_paras
    end
    
    methods
        function obj = automaticSTL_Electrode_Outv(vcoord,vertice,v2f,f2v,cuboidf)
            %UNTITLED6 Construct an instance of this class
            %   Detailed explanation goes here
            obj.vertice = vertice;
            obj.outsurf_paras = [];
            obj.insurf_paras = [];
            
            assof = v2f{vertice};
            for j = 1:length(assof)
                facet_v = f2v{assof(j)};
                points = vcoord(reshape(facet_v,[],1),:);
                paras = automaticSTL_math.Calc_Surf(points);
                if any(assof(j) == cuboidf)
                    obj.outsurf_paras = [obj.outsurf_paras;paras];
                else
                    obj.insurf_paras = [obj.insurf_paras;paras];
                end
            end
            obj.outsurf_paras = automaticSTL_math.Paras_Unique(obj.outsurf_paras);
            obj.insurf_paras = automaticSTL_math.Paras_Unique(obj.insurf_paras);
            
        end
    end
end

