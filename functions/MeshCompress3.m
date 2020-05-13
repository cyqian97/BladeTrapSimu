function model = MeshCompress3(cube,mesh_finess)

model0 = createpde();
gm0 = multicuboid(mesh_finess(1),mesh_finess(2),mesh_finess(3),'Zoffset',-mesh_finess(3)/2);
model0.Geometry = gm0;

mesh0 = generateMesh(model0,"Hmax",1,"Hmin",1e-2,"Hgrad",1.2);

magnify = cube./mesh_finess;


nodes1 = [mesh0.Nodes(1,:)*magnify(1);mesh0.Nodes(2,:)*magnify(2);mesh0.Nodes(3,:)*magnify(3)];
elements1 = mesh0.Elements;

model = createpde();

geometryFromMesh(model,nodes1,elements1);

% mesh = model.Mesh;
end