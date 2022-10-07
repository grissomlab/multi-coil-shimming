function x_line=onepoint09(r,theta,phi)
% X_LINE = ONEPOINT09(R,THETA,PHI) returns vector
% r^n*Pnm(cos(theta))*cos(m*phi)|sin(m*phi) of one point in spherical coordinate.
%         r: radius; theta: angle displacement ; phi: azimuth
% 0th order, 1st order and 2nd order terms.
% 9 shim terms: 
%  ------------------------
%  #    n     m   shim
%  01   0     0    Z0
%  02   1     0    Z1
%  03   2     0    Z2
%  04   1     1c   X
%  05   2     1c   ZX
%  06   2     2c   X2-Y2
%  07   1     1s   Y
%  08   2     1s   ZY
%  09   2     2s   XY
%  ------------------------
%  c : cos term , s: sin term

%   Created by Yansong Zhao, Yale University Oct. 1999
%   This is a function of Shimming Toolbox

s=sin(theta);
c=cos(theta);

% Legendre polynomials (m=0) n=1 to 2
Pn0(1)= c;
Pn0(2)=(3*c^2-1)/2;

% Associated Legendre functions n=1 to 2
Pnm(1,1)=s;
% Pnm(2,1)=3*s*c; 
% Pnm(2,2)=3*s*s;

Pnm(2,1)= s*c; 
Pnm(2,2)= s*s;

x_line = zeros(1,9);

%%%% Defining X matrix.

%P00 ( Z0 )
x_line(1)=1;

%r^n*Pn0(cos(theta))  ( Z1 and Z2 )
x_line(2)=r*Pn0(1);
x_line(3)=r^2*Pn0(2);

%r^n*Pnm(cos(theta))*cos(m*phi)   ( X ~ X2-Y2 )
x_line(4)=r*Pnm(1,1)*cos(phi);
x_line(5)=r^2*Pnm(2,1)*cos(phi);
x_line(6)=r^2*Pnm(2,2)*cos(2*phi);

%r^n*Pnm(cos(theta))*sin(m*phi)  ( Y ~ XY )
x_line(7)=r*Pnm(1,1)*sin(phi);
x_line(8)=r^2*Pnm(2,1)*sin(phi);
x_line(9)=r^2*Pnm(2,2)*sin(2*phi);

% END of onepoint09.m  
% This is a function of Shimming Toolbox
