function [RX,blade0y0,blademym] =  findfacenameOnline_Pautrap(model)

% pdegplot(model,'FaceLabels','on')
g=model.Geometry;
tol = 1e-5;
%% Find the coordinates of all the vertices

vertices = zeros(g.NumVertices,3);
for i = 1:g.NumVertices
    vertices(i,:) = g.vertexCoordinates(i);
end
%% Find the associativities between faces and vertices

f2v = cell(g.NumFaces,1);
v2f = cell(g.NumVertices,1);
f2v(:) = {[]};
v2f(:) = {[]};
for i = 1:g.NumFaces
    f2v{i} = g.findVertices('region','Face',i);
    for j = 1:length(f2v{i})
        v2f{f2v{i}(j)} = [v2f{f2v{i}(j)};i];
    end
end
%% Find the face number of the 6 faces of the overall cuboid

R = max(max(vecnorm(vertices(:,2:3),2,2)));
X = max(abs(vertices(:,1)));

RX = [R X];

cuboidf = [];
for i = 1:g.NumFaces
    if all(eqtol(vecnorm(vertices(f2v{i},2:3),2,2),R,tol)) || ...
            all(eqtol(vertices(f2v{i},1),X,tol)) || ...
            all(eqtol(vertices(f2v{i},1),-X,tol))
        cuboidf = [cuboidf,i];
    end
end
%% Find vertices which belong to one blade
blademym = [];
for i = 1:g.NumFaces
    if all(all(vertices(f2v{i},2:3)>0))
        blademym = [blademym,i];
    end
end
blademym = setdiff(blademym,cuboidf);


blade0y0 = [];
for i = 1:g.NumFaces
    if all(all(vertices(f2v{i},2:3)<0))
        blade0y0 = [blade0y0,i];
    end
end
blade0y0 = setdiff(blade0y0,cuboidf);


end
%%
function r = eqtol(x,y,tol)
% equal function with tolerance
if  isequal(size(y) , [1,1])
    r = (y-tol<x)&(x<y+tol);
    return
end
cmp = [y-tol<x,x<y+tol];
r = all(cmp(:));
end
