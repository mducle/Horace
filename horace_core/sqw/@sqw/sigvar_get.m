function [s,var,mask_null] = sigvar_get (w)
% Get signal and variance from sqw object, and a logical array of which values to ignore
% 
%   >> [s,var,mask_null] = sigvar_get (w)

% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)

s = w.data.s;
var = w.data.e;
mask_null = logical(w.data.npix);
