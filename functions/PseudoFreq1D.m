function f = PseudoFreq1D(coord_1, U,varargin)
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
addRequired(p,'U', @(x) validateattributes(x,{'numeric'},{'size',size(coord_1)},mfilename,'U',3));
addParameter(p,'scale',1000,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'scale'));
addParameter(p,'Omega',2*pi*38e6,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'Omega'));
addParameter(p,'Vrf',1000,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'Vrf'));
addParameter(p,'atomic_mass',171,@(x) validateattributes(x,{'numeric'},{'scalar'},mfilename,'atomic_mass'));
addParameter(p,'loose',false,@(x) validateattributes(x,{'logical'},{'scalar'},mfilename,'loose'));
parse(p,coord_1,U,varargin{:});



phys = matfile("phys.mat","Writable",false);

scale =  p.Results.scale;
m =  p.Results.atomic_mass * phys.amu;
Omega =  p.Results.Omega;
Vrf =  p.Results.Vrf;


% 2D harmonic fitting
[xData, zData] = prepareCurveData( coord_1, U );

ft = fittype( 'p0 + p2*x^2', 'independent', 'x', 'dependent', 'z' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares', 'StartPoint' ,[0 0] );
opts.Display = 'Off';
[fitresult, gof] = fit( xData, zData, ft, opts );
if gof.rsquare<0.99 && ~p.Results.loose
    h = plot( fitresult, xData, zData );
    legend( h, 'U vs. x', 'fit', 'Location', 'NorthEast', 'Interpreter', 'none' );
    error('Low gof! rsquare = %.4f',gof.rsquare);
end

f = (fitresult.p2*scale^2*phys.e*2/m).^(1/2)/2/pi;
    
end