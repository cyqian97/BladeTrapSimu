function [cuboid,bladesx,cuboidf] =  findfacenameAll(stlname)
%
%   == Output ==
%   bladesx : cell(2,2)(5), (z,y)(x). index = 1, coordinates = minimum

tol = 1e-5;

%% Find the associativities between faces and vertices

[vertices,v2f,f2v,~] = StlTxtRead(stlname);
%% Find the face number of the 6 faces of the overall cuboid

cuboid = [max(vertices);min(vertices)];
cuboidf = [];
for i = 1:length(f2v)
    cuboidv = vertices(f2v{i},:);
    if all(eqtol(cuboidv(:,1),cuboid(2,1),tol)) || all(eqtol(cuboidv(:,1),cuboid(1,1),tol)) || ...
            all(eqtol(cuboidv(:,2),cuboid(2,2),tol)) || all(eqtol(cuboidv(:,2),cuboid(1,2),tol)) || ...
            all(eqtol(cuboidv(:,3),cuboid(2,3),tol)) || all(eqtol(cuboidv(:,3),cuboid(1,3),tol))
        cuboidf = [cuboidf,i];
    end
end
%% Find vertices which belong to each blade
sign_z = [-1,1];
sign_y = {@(x)x<0,@(x)x>0};
bladesx = cell(2,2);
for i=1:2
    for j=1:2
        %% find vertices of the tips of one blade
        blade1z = min(abs(vertices(:,3)));
        blade1v = find(sign_y{j}(vertices(:,2)) & eqtol(vertices(:,3),blade1z*sign_z(i),tol));
        blade1vx = vertices(blade1v,1);
        [~,index] = sort(blade1vx);
        blade1v = blade1v(index);
        %% Find the faces of each electrode
        
        elef = cell(length(blade1v),1);
        elef(:) = {[]};
        for k = 1:length(blade1v)
            elef{k} = setdiff(v2f{blade1v(k)},cuboidf); % Substract faces of the cuboid
            newf = [];
            while true
                newv = [];
                for l = 1:length(elef{k})
                    newv = [newv;f2v{elef{k}(l)}]; % Vertices of all the faces already found
                end
                newv = unique(newv);
                newf = [];
                for l = 1:length(newv)
                    newf = [newf;v2f{newv(l)}]; % Faces contains the vertices already found
                end
                newf = setdiff(newf,cuboidf,'sorted'); % Substract faces of the cuboid
                if isequal(newf,elef{k}) % Whether new faces are found
                    break
                else
                    elef{k} = newf;
                end
            end
        end
        bladesx{i,j} = elef(1);
        k = 1;
        for l = 2:length(blade1v)
            if ~isequal(elef{l},bladesx{i,j}{k})
                k = k+1;
                bladesx{i,j} = [bladesx{i,j};elef{l}];
            end
        end
    end
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