function V = EqSpacingMMA(dx,l,b,fname)

l = dx/l;
phys = matfile("phys.mat","Writable",false);
load(fname)
a2d2e = phys.e/(8*pi*phys.epsilon0*l^3);
a4d2e = abs(b)*a2d2e/l^2;
p = [fend.b*1e6,fend.c*1e12,fcntr.b*1e6,fcntr.c*1e12];
A = [2*p(2),2*p(4);-p(1),-p(3)];
V =A\[a4d2e;a2d2e];
%[Vend, Vcntr(i)]


end