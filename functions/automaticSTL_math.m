classdef automaticSTL_math
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    methods(Static)
        function in_v = Inside_Vertices(vcoord,vertices,cuboid)
            v = vcoord(reshape(vertices,[],1),:);
            tol = 1e-5;
            in_v = vertices(v(:,1)<(cuboid(1,1)-tol) ...
                & v(:,1)>(cuboid(2,1)+tol) ...
                & v(:,2)<(cuboid(1,2)-tol) ...
                & v(:,2)>(cuboid(2,2)+tol) ...
                & v(:,3)<(cuboid(1,3)-tol) ...
                & v(:,3)>(cuboid(2,3)+tol));
        end
        function paras = Calc_Surf(p)
            % p = [p1;p2;p3]
            % a x + b y + d = -z
            % paras = [a b 1 d]
            % To prevent matrix A below from being singular, the projection
            % of p1 p2 p3 on the x-y plane must not on the same line.
            vv = [(p(1,1:2)-p(3,1:2));(p(1,1:2)-p(2,1:2))];
            if cond(vv)>1e5
                vn = [norm(vv(1,:)),norm(vv(2,:))];
                index = find(max(vn)==vn);
                v = vv(index(1),:);
                paras = [v(2),-v(1),0,-(p(1,1)*v(2)-p(1,2)*v(1))];
                return
            end
            A = [p(1,1),p(2,1),p(3,1);p(1,2),p(2,2),p(3,2);1,1,1];
            b = -[p(1,3),p(2,3),p(3,3)];
            paras = b/A;
            paras = [paras(1),paras(2),1,paras(3)];
        end
        
        function paras = Paras_Unique(paras)
            p = 1;
            t = 1;
            for i = 1:size(paras,1)
                if cond(paras([t,i],:)) < 1e5
                    t = i;
                    p = [p,i];
                end
            end
            paras = paras(p,:);
        end
        
        function point = Calc_Point(s)
            % s = [s1;s2;s3]
            point = linsolve(s(:,1:3),-s(:,4));
        end
        
        function paras = Move_Face(paras,move)
           paras(:,4) = paras(:,4)-paras(:,1:3)*reshape(move,3,1); 
        end
        
        function vertices = F2v_Unique(faces,f2v)
            faces = faces(:);
            vertices = [];
            for i = 1:length(faces)
                vertices = [vertices;reshape(f2v{faces(i)},[],1)];
            end
            vertices = unique(vertices,'stable');
        end
        
        function coords = GetVertexCoord(vertices,vcoord)
           coords = []; 
           for i = 1:length(vertices)
                coords = [coords;reshape(vcoord(vertices(i),:),1,[])];
            end
        end
        
        function points = GetFaceCoord(faces,f2v,vcoord)
            vertices = automaticSTL_math.F2v_Unique(faces,f2v);
            points = [];
            for i = 1:length(vertices)
                points = [points;reshape(vcoord(vertices(i),:),1,[])];
            end
        end
    end
    
end
%             if rank(p(1:2,1:2))<2
%                 % line (p1,p2) will intersection with z axis
%                 % have rank(p(1:2,1:2))<2 will result in singularity in A
%                 % below
%                 if rank(p(2:3,1:2))<2 && rank(p([1,3],1:2))<2
%                     % project p1,p2,p3 on xy plane, p3 on line (p1,p2).
%                     % In this case a x + b y + d = -z is not suitble.But
%                     % p(1:2,1:2) is singular so I cannot use the method
%                     % below to identify that.
%                     ns = [norm(p(1,:)),norm(p(2,:)),norm(p(3,:))];
%                     paras = [p(max(ns)==ns,2),-p(max(ns)==ns,1),0,0];
%                     return
%                 end
%
%             elseif sum(p(3,1:2)/p(1:2,1:2))<1+e-6 && sum(p(3,1:2)/p(1:2,1:2))>1-e-6
%                 paras = [p(1,2)-p(2,2),-(p(1,1)-p(2,1)),0, ...
%                     -[p(1,2)-p(2,2),-(p(1,1)-p(2,1))]*p(1,1:2)'];
%                 return
%             end
%             if all([p(1,1)==p(2,1),p(1,1)==p(3,1)])
%                 paras = [1,0,0,-p(1,1)];
%                 return
%             end
%             if all([p(1,2)==p(2,2),p(1,2)==p(3,2)])
%                 paras = [0,1,0,-p(1,2)];
%                 return
%             end
