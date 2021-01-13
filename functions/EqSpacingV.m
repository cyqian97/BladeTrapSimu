function V = EqSpacingV(nion,dx,fend,fcntr)

alphatable = COMSOLdataread(fullfile(cd(),'results',"betatable.txt"));
a = alphatable(:,alphatable(1,:)==nion);
l = dx/a(3);
phys = matfile("phys.mat","Writable",false);
a2d2e = phys.e/(8*pi*phys.epsilon0*l^3);
a4d2e = abs(a(2))*a2d2e/l^2;
p = [fend.b*1e6,fend.c*1e12,fcntr.b*1e6,fcntr.c*1e12];
A = [2*p(2),2*p(4);-p(1),-p(3)];
V =A\[a4d2e;a2d2e];
%[Vend, Vcntr(i)]


end