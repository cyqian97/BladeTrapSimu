classdef automaticSTL
    %automaticSTL Automatic slt file generator for blade trap model.
    
    properties
        vcoord
        v2f
        f2v
        f2n
        cuboid
        cuboidf
        electrodes
        bladesx
        tol = 1e-5
        r0 
        x 
        y 
        cntrcap
        midcap
        gap 
        bladeangle = 30
        bladeversion
        current = fullfile(getenv('TRAPSIMU'),'stl');
    end
    
    methods
        function obj = automaticSTL()
            %automaticSTL Construct an instance of this class
            stlname = 'cut_r205c250m250g20x4.0y2.5b4.1_txt_onshape.stl';
            expression = 'r(?<r0>[\d.]+)c(?<cntrcap>[\d.]+)m(?<midcap>[\d.]+)g(?<gap>[\d.]+)x(?<x>[\d.]+)y(?<y>[\d.]+)b(?<bladeversion>[\d.]+)';
            tokenNames = regexp(stlname,expression,'names');
            obj.r0 = str2double(tokenNames.r0)/1000;
            obj.cntrcap = str2double(tokenNames.cntrcap)/1000;
            obj.midcap = str2double(tokenNames.midcap)/1000;
            obj.gap = str2double(tokenNames.gap)/1000;
            obj.x = str2double(tokenNames.x);
            obj.y = str2double(tokenNames.y);
            obj.bladeversion = tokenNames.bladeversion;
            
            [obj.vcoord,obj.v2f,obj.f2v,obj.f2n] = StlTxtRead(fullfile(obj.current,stlname));
            [obj.cuboid,obj.bladesx,obj.cuboidf] =  findfacenameAll(fullfile(obj.current,stlname));
            obj = obj.Symmetrize();
            obj.electrodes = cell(2,2,5);% (z,y,x). indices = 1, coordinates = min
            obj = ElectrodeGen(obj);
        end
        
        function obj = ElectrodeGen(obj)
            for i = 1:2
                for j= 1:2
                    for k = 1:5
                        obj.electrodes{i,j,k} = automaticSTL_Electrode(obj.vcoord,obj.bladesx{i,j}{k},...
                            obj.cuboid,obj.v2f,obj.f2v,obj.f2n,obj.cuboidf,k);
                    end
                end
            end
        end
        
        function [obj, stlname] = NewStl(obj,varargin)
            p = inputParser;
            addParameter(p,'gap',obj.gap,@(x) validateattributes(x,{'numeric'},{'scalar'},'NewStl','gap'));
            addParameter(p,'cntrcap',obj.cntrcap,@(x) validateattributes(x,{'numeric'},{'scalar'},'NewStl','cntrcap'));
            addParameter(p,'midcap',obj.midcap,@(x) validateattributes(x,{'numeric'},{'scalar'},'NewStl','midcap'));
            addParameter(p,'r0',obj.r0,@(x) validateattributes(x,{'numeric'},{'scalar'},'NewStl','r0'));
            addParameter(p,'x',obj.x,@(x) validateattributes(x,{'numeric'},{'scalar'},'NewStl','x'));
            addParameter(p,'y',obj.y,@(x) validateattributes(x,{'numeric'},{'scalar'},'NewStl','y'));
            parse(p,varargin{:});
            
            if p.Results.r0 ~= obj.r0
                obj = obj.Modify_R0(p.Results.r0);
            end
            
            obj = obj.ElectrodeGen();
            if p.Results.gap~=obj.gap
                obj = obj.Modify_Gap(p.Results.gap);
            end
            if p.Results.midcap~=obj.midcap
                obj = obj.Modify_Midcap(p.Results.midcap);
            end
            if p.Results.cntrcap~=obj.cntrcap
                obj = obj.Modify_Cntrcap(p.Results.cntrcap);
            end
            
            obj = obj.Symmetrize();
            obj = ElectrodeGen(obj);
            
            if p.Results.x~=obj.x
                obj = obj.Modify_X(p.Results.x);
            end
            
            if p.Results.y~=obj.y
                obj = obj.Modify_Y(p.Results.y);
            end
            
            
            stlname = obj.NewStl_Write(p.Results);
        end
        
        function obj = Modify_Gap(obj,gap)
            ks = [2,4];
            for i = 1:2
                for j = 1:2
                    for k = ks
                        obj.vcoord(obj.electrodes{i,j,k}.vertices,1) = ...
                            obj.vcoord(obj.electrodes{i,j,k}.vertices,1)+(obj.gap-gap)*(3-k);
                    end
                end
            end
            ks = [1,5];
            for i = 1:2
                for j = 1:2
                    for k = ks
                        obj.vcoord(obj.electrodes{i,j,k}.xmovevertices,1) = ...
                            obj.vcoord(obj.electrodes{i,j,k}.xmovevertices,1)+(obj.gap-gap)*2*(3-k)/2;
                    end
                end
            end
            obj.gap = gap;
        end
        
        function obj = Modify_Cntrcap(obj,cntrcap)
            k = 3;
            for i = 1:2
                for j = 1:2
                    obj.vcoord(obj.electrodes{i,j,k}.vertices,1) = ...
                        obj.vcoord(obj.electrodes{i,j,k}.vertices,1)- ...
                        sign(obj.vcoord(obj.electrodes{i,j,k}.vertices,1))* ...
                        (obj.cntrcap-cntrcap)/2;
                end
            end
            ks = [2,4];
            for i = 1:2
                for j = 1:2
                    for k = ks
                        obj.vcoord(obj.electrodes{i,j,k}.vertices,1) = ...
                            obj.vcoord(obj.electrodes{i,j,k}.vertices,1)+(obj.cntrcap-cntrcap)/2*(3-k);
                    end
                end
            end
            ks = [1,5];
            for i = 1:2
                for j = 1:2
                    for k = ks
                        obj.vcoord(obj.electrodes{i,j,k}.xmovevertices,1) = ...
                            obj.vcoord(obj.electrodes{i,j,k}.xmovevertices,1)+(obj.cntrcap-cntrcap)/2*(3-k)/2;
                    end
                end
            end
            obj.cntrcap = cntrcap;
        end
        
        function obj = Modify_Midcap(obj,midcap)
            ks = [2,4];
            for i = 1:2
                for j = 1:2
                    for k = ks
                        obj.vcoord(obj.electrodes{i,j,k}.xmovevertices,1) = ...
                            obj.vcoord(obj.electrodes{i,j,k}.xmovevertices,1)+(obj.midcap-midcap)*(3-k);
                    end
                end
            end
            ks = [1,5];
            for i = 1:2
                for j = 1:2
                    for k = ks
                        obj.vcoord(obj.electrodes{i,j,k}.xmovevertices,1) = ...
                            obj.vcoord(obj.electrodes{i,j,k}.xmovevertices,1)+(obj.midcap-midcap)*(3-k)/2;
                    end
                end
            end
            obj.midcap = midcap;
        end
        
        function obj = Modify_R0(obj,r0)
            move = [0,(obj.r0-r0)*cos(obj.bladeangle/180*pi),(obj.r0-r0)*sin(obj.bladeangle/180*pi)];
            for i = 1:2
                for j = 1:2
                    for k = 1:5
                        obj.vcoord(obj.electrodes{i,j,k}.in_v,:) = ...
                            obj.vcoord(obj.electrodes{i,j,k}.in_v,:)+move.*[0,sign(1.5-j),sign(1.5-i)];
                        for l = 1:length(obj.electrodes{i,j,k}.out_v)
                            obj.vcoord(obj.electrodes{i,j,k}.out_v{l}.vertice,:) = ...
                                reshape(automaticSTL_math.Calc_Point(...
                                [obj.electrodes{i,j,k}.out_v{l}.outsurf_paras; ...
                                automaticSTL_math.Move_Face(obj.electrodes{i,j,k}.out_v{l}.insurf_paras,move.*[0,sign(1.5-j),sign(1.5-i)])]),1,3);
                        end
                    end
                end
            end
            obj.r0 =r0;
        end
        
        function obj = Modify_X(obj,x)
            move = [(x-obj.x)/2,0,0];
            for i = 1:2
                for j = 1:2
                    for k = [1,5]
                        for l = 1:length(obj.electrodes{i,j,k}.out_v)
                            obj.vcoord(obj.electrodes{i,j,k}.out_v{l}.vertice,:) = ...
                                reshape(automaticSTL_math.Calc_Point(...
                                [automaticSTL_math.Move_Face(obj.electrodes{i,j,k}.out_v{l}.outsurf_paras,move*(k-3)/2); ...
                                obj.electrodes{i,j,k}.out_v{l}.insurf_paras]),1,3);
                        end
                    end
                end
            end
            obj.x =x;
            obj.cuboid(1,1) = max(obj.vcoord(:,1));
            obj.cuboid(2,1) = min(obj.vcoord(:,1));
            obj = obj.ElectrodeGen();
        end
        
        function obj = Modify_Y(obj,y)
            move = [0,(obj.y-y)/2,(obj.y-y)/2*tan(obj.bladeangle/180*pi)];
%             for l = 1:length(obj.electrodes{1,1,1}.out_v)
%                 new_coord = reshape(automaticSTL_math.Calc_Point(...
%                     [automaticSTL_math.Move_Face(obj.electrodes{1,1,1}.out_v{l}.outsurf_paras,move.*[0,sign(1.5-1),sign(1.5-1)]); ...
%                     obj.electrodes{1,1,1}.out_v{l}.insurf_paras]),1,3);
%                 if abs(new_coord(1))>obj.cuboid(1,1)+obj.tol
%                     obj = obj.Modify_X(2*abs(new_coord(1))+0.1);
%                 end
%             end
            for i = 1:2
                for j = 1:2
                    for k = 1:5
                        for l = 1:length(obj.electrodes{i,j,k}.out_v)
                            obj.vcoord(obj.electrodes{i,j,k}.out_v{l}.vertice,:) = ...
                                reshape(automaticSTL_math.Calc_Point(...
                                [automaticSTL_math.Move_Face(obj.electrodes{i,j,k}.out_v{l}.outsurf_paras,move.*[0,sign(1.5-j),sign(1.5-i)]); ...
                                obj.electrodes{i,j,k}.out_v{l}.insurf_paras]),1,3);  
                        end
                    end
                end
            end
            obj.y =y;
            obj.cuboid(1,2) = max(obj.vcoord(:,2));
            obj.cuboid(2,2) = min(obj.vcoord(:,2));
            obj.cuboid(1,3) = max(obj.vcoord(:,3));
            obj.cuboid(2,3) = min(obj.vcoord(:,3));
            obj = obj.ElectrodeGen();
        end
        
        function obj = Symmetrize(obj)
            for i = 1:length(obj.vcoord)
                symmetic_points = all(abs(obj.vcoord(i,:))-obj.tol<abs(obj.vcoord) & abs(obj.vcoord)<abs(obj.vcoord(i,:))+obj.tol,2);
                avg_point = mean(abs(obj.vcoord(symmetic_points,:)));
                obj.vcoord(symmetic_points,:) = sign(obj.vcoord(symmetic_points,:)).*avg_point;
            end
        end
        
        function stlname = NewStl_Write(obj,results)
            stlname = strcat(num2str([round(results.r0*1000),round(results.cntrcap*1000),round(results.midcap*1000),round(results.gap*1000),results.x,results.y], ...
                'cut_r%dc%dm%dg%dx%.1fy%.1fb'),obj.bladeversion,'_txt.stl');
            fid = fopen(fullfile(obj.current,stlname),'w');
            fprintf(fid,'');
            fprintf(fid,'solid automaticSTL\n');
            for i = 1:length(obj.f2v)
                fprintf(fid,'  facet normal ');
                n_0 = reshape(obj.f2n{i},1,[]);
                points = automaticSTL_math.GetFaceCoord(i,obj.f2v,obj.vcoord);
                n_1 = cross(points(1,:)-points(3,:),points(2,:)-points(3,:));
                n_1 = n_1/norm(n_1)*sign(n_1*n_0');
                fprintf(fid,'%.10f %.10f %.10f\n',n_1(1),n_1(2),n_1(3));
                fprintf(fid,'    outer loop\n');
                fprintf(fid,'      vertex %.10f %.10f %.10f\n',points(1,1),points(1,2),points(1,3));
                fprintf(fid,'      vertex %.10f %.10f %.10f\n',points(2,1),points(2,2),points(2,3));
                fprintf(fid,'      vertex %.10f %.10f %.10f\n',points(3,1),points(3,2),points(3,3));
                fprintf(fid,'    endloop\n');
                fprintf(fid,'  endfacet\n');
            end
            fprintf(fid,'endsolid automaticSTL');
            fclose(fid);
        end
    end
end

