classdef automaticSTL_Electrode
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vertices
        faces
        in_v
        out_v_list
        out_v
        xmovevertices
    end
    
    methods
        function obj = automaticSTL_Electrode(vcoord,faces,cuboid,v2f,f2v,f2n,cuboidf,k)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.faces = faces;
            obj.vertices = automaticSTL_math.F2v_Unique(faces,f2v);
            obj.in_v =  automaticSTL_math.Inside_Vertices(vcoord,obj.vertices,cuboid);
            obj.out_v_list = setdiff(obj.vertices,obj.in_v);
            xmovefaces = [];
            tol = 1e-6;
            if k == 1 || k == 4
                for i = 1:length(faces)
                    if f2n{faces(i)}(1)<-tol
                        xmovefaces = [xmovefaces;faces(i)];
                    end
                end
            elseif k == 2 || k == 5
                for i = 1:length(faces)
                    if f2n{faces(i)}(1)>tol
                        xmovefaces = [xmovefaces;faces(i)];
                    end
                end
            end
            obj.xmovevertices = automaticSTL_math.F2v_Unique(xmovefaces,f2v);
            obj.out_v = cell(length(obj.out_v_list),1);
            for i = 1:length(obj.out_v)
                obj.out_v{i} = automaticSTL_Electrode_Outv(vcoord,obj.out_v_list(i),v2f,f2v,cuboidf);
            end
        end
    end
    
    
end

