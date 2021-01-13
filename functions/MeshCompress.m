function mesh = MeshCompress(model0,mesh_finess)

g=model0.Geometry;

vertices = zeros(g.NumVertices,3);
for i = 1:g.NumVertices
    vertices(i,:) = g.vertexCoordinates(i);
end

g_size = [max(vertices(:,1))-min(vertices(:,1)), ...
    max(vertices(:,2))-min(vertices(:,2)), ...
    max(vertices(:,3))-min(vertices(:,3))];


magnify = mesh_finess./g_size;

mesh0 = generateMesh(model0,"Hmax",min(g_size)/10,"Hmin",min(g_size)/10000,"Hgrad",1.2);

nodes1 = [mesh0.Nodes(1,:)*magnify(1);mesh0.Nodes(2,:)*magnify(2);mesh0.Nodes(3,:)*magnify(3)];
elements1 = mesh0.Elements;

model1 = createpde();
geometryFromMesh(model1,nodes1,elements1);
mesh1 = generateMesh(model1,'Hmax',1,'Hmin',0.001,"Hgrad",1.2,'GeometricOrder','linear');

nodes2 = [mesh1.Nodes(1,:)/magnify(1);mesh1.Nodes(2,:)/magnify(2);mesh1.Nodes(3,:)/magnify(3)];
elements2 = mesh1.Elements;

model = createpde();
geometryFromMesh(model,nodes2,elements2);
mesh = model.Mesh;
end