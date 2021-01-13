function names = findfacename_boundary(model)

g=model.Geometry;
tol = 1e-4;
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

cuboid = [max(vertices);min(vertices)];
names = [0,0,0,0,0,0];
for i = 1:g.NumFaces
    cuboidv = vertices(f2v{i},:);
    if all(eqtol(cuboidv(:,3),cuboid(2,3),tol))
        names(1) = i;
    elseif all(eqtol(cuboidv(:,3),cuboid(1,3),tol))
        names(2) = i;
    elseif all(eqtol(cuboidv(:,1),cuboid(2,1),tol))
        names(3) = i;
    elseif all(eqtol(cuboidv(:,1),cuboid(1,1),tol))
        names(4) = i;
    elseif all(eqtol(cuboidv(:,2),cuboid(2,2),tol))
        names(5) = i;
    elseif  all(eqtol(cuboidv(:,2),cuboid(1,2),tol))
        names(6) = i;
    end
end

if min(names)<=0
   error('Not all 6 faces are found, only find %d',sum(names>0)); 
end

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
% % Find the vertices number of the corner of the overall cuboid
% %    8----7
% %   /|   /|
% %  / 4  / 3
% % 5----6 /   z y
% % |/   |/    |/
% % 1----2     --x
% cuboid = [2,4,2];
% corners = zeros(8,1);
% tol = 1e-8;
% for i = 1:g.NumVertices
%     coord = vertices(i,:);
%     if eqtol(coord,[0,0,0],tol)
%         corners(1) = i;
%     elseif eqtol(coord,[cuboid(1),0,0],tol)
%         corners(2) = i;
%     elseif eqtol(coord,[cuboid(1),cuboid(2),0],tol)
%         corners(3) = i;
%     elseif eqtol(coord,[0,cuboid(2),0],tol)
%         corners(4) = i;
%     elseif eqtol(coord,[0,0,cuboid(3)],tol)
%         corners(5) = i;
%     elseif eqtol(coord,[cuboid(1),0,cuboid(3)],tol)
%         corners(6) = i;
%     elseif eqtol(coord,[cuboid(1),cuboid(2),cuboid(3)],tol)
%         corners(7) = i;
%     elseif eqtol(coord,[0,cuboid(2),cuboid(3)],tol)
%         corners(8) = i;
%     end
% end
% if any(corners==0)
%     error("All corners are not found.");
% end