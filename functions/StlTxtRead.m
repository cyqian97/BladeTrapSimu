function [vertices,v2f,f2v,f2n] = StlTxtRead(stlname)
%[vertices,v2f,f2v,f2n] = StlTxtRead(stlname)
%   StlTxtRead reads the text version slt files, and generate the
%   relastionship table between vertices, faces and normals.
%   == Output ==
%   vertices : The coordiantes of each vertices.
%   v2f : Vertices to faces. v2f{vertex_id} gives the ids of all the faces
%   connected to this vertex.
%   f2v : Faces to vertices.
%   f2n : Faces to normals.

fid = fopen(stlname,'r');
vertices = [];
f2v = {};
f2n = {};
v2f = {};
l = 1;
face_num = 0;
vertex_num = 0;
while l ~= -1
    l = fgetl(fid);
    newface = strfind(l,'facet normal');
    if ~isempty(newface)
        face_num = face_num+1;
        f2n{face_num} = str2num(l(newface+13:length(l)));
        f2v{face_num} = [];
        continue
    end
    newvertex = strfind(l,'vertex');
    if ~isempty(newvertex)
        vertex = str2num(l(newvertex+7:length(l)));
        if isempty(vertices)
            vertex_num = vertex_num+1;
            vertices = vertex;
            f2v{face_num} = [f2v{face_num};vertex_num];
            continue
        end
        isfound = all(vertex'==vertices');
        if any(isfound)
            v2f{isfound} = [v2f{isfound};face_num];
            f2v{face_num} = [f2v{face_num};find(isfound)];
        else
            vertex_num = vertex_num+1;
            vertices = [vertices;vertex];
            v2f{vertex_num} = face_num;
            f2v{face_num} = [f2v{face_num};vertex_num];
        end
        
    end
    
end
fclose(fid);
end