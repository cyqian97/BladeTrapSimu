function [f1,f2,direction] = PseudoFreq2D(coord_1,coord_2,U,varargin)
%[f1,f2,direction] = PseudoFreq2D(coord_1,coord_2,U,varargin)
%   Calculate the trap frequency of a pseudo-potential.
%   == Input ==
%   coord_1 : coordinate 1
%   coord_2 : coordinate 2
%   U : electric potential
%   == Name-Value Pairs ==
%   scale : scale of the coordinates, e.g if the coordinates' unit is in mm, scale = 1000
%   atomic_mass: atomic mass of the ion in amu

p = inputParser;
addRequired(p,'coord_1', @(x) validateattributes(x,{'numeric'},{'nonempty'},mfilename,'coord_1',1));
addRequired(p,'coord_2', @(x) validateattributes(x,{'numeric'},{'size',size(coord_1)},mfilename,'coord_2',2));
addRequired(p,'U', @(x) validateattributes(x,{'numeric'},{'size',size(coord_1)},mfilename,'U',3));
addParameter(p,'scale',1000,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'scale'));
addParameter(p,'atomic_mass',171,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'atomic_mass'));
addParameter(p,'loose',false,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'loose'));
addParameter(p,'sort',true,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'sort'));
parse(p,coord_1,coord_2,U,varargin{:});



phys = matfile("phys.mat","Writable",false);

scale =  p.Results.scale;
m =  p.Results.atomic_mass * phys.amu;

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
f = (abs(D)*scale^2*phys.e*2/m).^(1/2)/2/pi;
f = [f(1,1)*sign(D(1,1)) f(2,2)*sign(D(2,2))];
if p.Results.sort
    f1 = max(f);
    f2 = min(f);
else
    f1 = f(1);
    f2 = f(2);
end
direction = V;
if poly22
    lin = -[fitresult.p10 fitresult.p01]*V'/D*V/2;
    fprintf(1,'x_offset = %.8e\ty_offset = %.8e\n', ...
        lin(1),lin(2));
end

end