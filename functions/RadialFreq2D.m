function [f1,f2,direction] = RadialFreq2D(coord_1,coord_2,U,varargin)
%[f1,f2,direction] = RadialFreq2D(coord_1,coord_2,U,varargin)
%   Calculate the RF radial frequency of an ion trap. Using the static electric potential data on a
%   surface perpendicular to the trap axis while applying 1 volt on two RF blades.
%   == Input ==
%   coord_1 : coordinate 1
%   coord_2 : coordinate 2
%   U : electric potential
%   == Name-Value Pairs ==
%   scale : scale of the coordinates, e.g if the coordinates' unit is in mm, scale = 1000
%   Omega : RF frequency applied on two RF blades
%   Vrf : RF voltage applied on two RF blades
%   atomic_mass: atomic mass of the ion in amu

p = inputParser;
addRequired(p,'coord_1', @(x) validateattributes(x,{'numeric'},{'2d','nonempty'},mfilename,'coord_1',1));
addRequired(p,'coord_2', @(x) validateattributes(x,{'numeric'},{'size',size(coord_1)},mfilename,'coord_2',2));
addRequired(p,'U', @(x) validateattributes(x,{'numeric'},{'size',size(coord_1)},mfilename,'U',3));
addParameter(p,'scale',1000,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'scale'));
addParameter(p,'Omega',2*pi*38e6,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'Omega'));
addParameter(p,'Vrf',1000,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'Vrf'));
addParameter(p,'atomic_mass',171,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'atomic_mass'));
addParameter(p,'loose',false,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'loose'));
parse(p,coord_1,coord_2,U,varargin{:});



phys = matfile("phys.mat","Writable",false);

scale =  p.Results.scale;
m =  p.Results.atomic_mass * phys.amu;
Omega =  p.Results.Omega;
Vrf =  p.Results.Vrf;

poly22 = false;

% 2D harmonic fitting
[xData, yData, zData] = prepareSurfaceData( coord_1, coord_2, U );
ft = fittype( 'p00 + p11*x*y + p20*x^2 + p02*y^2', 'independent', {'x', 'y'}, 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares', 'StartPoint' ,[0.4985 18.9989 1.4921  -1.4662] );
opts.Display = 'Off';
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );
if gof.rsquare<0.99
    ft = fittype( 'poly22' );
    [fitresult, gof] = fit( [xData, yData], zData, ft );
    if gof.rsquare<0.99 && ~p.Results.loose
        error('Low gof! rsquare = %.4f',gof.rsquare);
    else
        fprintf(1,'Centered quadratic has low gof. Use poly22.\n');
        poly22 = true;
    end
end
if gof.rsquare<0.99 && ~p.Results.loose
    error('Low gof! rsquare = %.4f',gof.rsquare);
end
% Find principle axes and frequencies
[V,D] = eig([fitresult.p20,fitresult.p11/2;fitresult.p11/2,fitresult.p02]);
f = D*sqrt(2)*scale^2*phys.e*Vrf/(m*Omega)/2/pi;
f = [f(1,1) f(2,2)];
f1 = max(f);
f2 = abs(min(f));
direction = V;
if poly22
    lin = -[fitresult.p10 fitresult.p01]*V'/D*V/2;
    fprintf(1,'x_offset = %.8e\ty_offset = %.8e\n', ...
        lin(1),lin(2));
end
    
end