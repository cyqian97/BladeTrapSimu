function pp = PseudoPotential(gx,gy,gz,varargin)

p = inputParser;
addParameter(p,'scale',1000,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'scale'));
addParameter(p,'Omega',2*pi*38e6,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'Omega'));
addParameter(p,'Vrf',1000,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'Vrf'));
addParameter(p,'atomic_mass',171,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'atomic_mass'));
parse(p, varargin{:});

phys = matfile("phys.mat","Writable",false);
scale =  p.Results.scale;
m =  p.Results.atomic_mass * phys.amu;
Omega =  p.Results.Omega;
Vrf =  p.Results.Vrf;

pp = vecnorm([gx(:), gy(:), gz(:)],2,2).^2*scale^2*Vrf^2/4*phys.e/Omega^2/m;
pp = reshape(pp,size(gx));


end