function FF = form_factor(self,h,k,l,varargin)
% method calculates magnetic form-factor
%
% Inputs:
% self  - instance of Magnetic ion class with defined u_to_rlu matrix converting
%         from crystal cartesian coordinate system to hkl representation
% h,k,l - coordinates of Q-vector in hkl representation
%
% Returns changes of magnetic form factos along input hkl vector for the
% selected ion.
%
%
% $Revision: 1490 $ ($Date: 2017-05-22 18:27:33 +0100 (Mon, 22 May 2017) $)
%

u_2_rlu = self.u_2_rlu_;
q = u_2_rlu\[h';k';l'];

q2 = (q(1,:).*q(1,:)+q(2,:).*q(2,:)+q(3,:).*q(3,:))/(16*pi*pi);
FF=self.J0_ff_(q2).^2+self.J2_ff_(q2).^2+self.J4_ff_(q2).^2+self.J6_ff_(q2).^2;
