function [fs,xs] = RFHomogeneityAll(result_rf,result_dc,V,xs,varargin)
%[fs,xs] = RFHomogeneityAll(result_rf,result_dc,V,xs,varargin)
%   Get the mean radial frequency at each x along the trap.
p = inputParser;
addRequired(p,'xs',@(x) validateattributes(x,{'numeric'},{'vector'},mfilename,'xs'));
addParameter(p,'yz_range',0.01,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'yz_range'));
addParameter(p,'ismean',true,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'ismean'));
addParameter(p,'Omega',2*pi*38e6,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'Omega'));
addParameter(p,'Vrf',1000,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'Vrf'));
addParameter(p,'atomic_mass',171,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'atomic_mass'));
parse(p,xs,varargin{:});

fs = [xs;xs];
[yy,zz] = meshgrid(linspace(-p.Results.yz_range,p.Results.yz_range,50));


for j = 1:length(xs)
    pp = yy(:)*0;
    xx = ones(size(yy))*xs(j);
    if ~isempty(result_rf)
        [gx,gy,gz] = evaluateGradient(result_rf,xx,yy,zz);
        pp = pp + PseudoPotential(gx,gy,gz,'Omega',p.Results.Omega,'Vrf',p.Results.Vrf);
    end
    for i = 1:length(result_dc)
        pp = pp + interpolateSolution(result_dc(i),xx,yy,zz)*V(i);
    end
    [f1,f2,~] = PseudoFreq2D(yy(:),zz(:),pp);
    fs(:,j) = [f1;f2];
end

if p.Results.ismean
    fs = (fs(1,:)+fs(2,:))/2;
end

end