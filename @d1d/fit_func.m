function [wout, fitdata] = fit_func(win, varargin)
% Fits a function to an object. If passed an array of 
% objects, then each is fitted independently to the same function.
%
% For full help, read documentation for sqw object  fit_func:
%   >> help sqw/fit_func
%
% Differs from multifit_func, which fits all objects in the array simultaneously
% but with independent backgrounds.
%
% Fit several objects in succession to a given function:
%   >> [wout, fitdata] = fit_func (w, func, pin)                 % all parameters free
%   >> [wout, fitdata] = fit_func (w, func, pin, pfree)          % selected parameters free to fit
%   >> [wout, fitdata] = fit_func (w, func, pin, pfree, pbind)   % binding of various parameters in fixed ratios
%
% With optional 'background' function added to the function
%   >> [wout, fitdata] = fit_func (..., bkdfunc, bpin)
%   >> [wout, fitdata] = fit_func (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = fit_func (..., bkdfunc, bpin, bpfree, bpbind)
%
% Additional keywords controlling which ranges to keep, remove from objects, control fitting algorithm etc.
%   >> [wout, fitdata] = fit_func (..., keyword, value, ...)
%   Keywords are:
%       'keep'      range of x values to keep
%       'remove'    range of x values to remove
%       'mask'      logical mask array (true for those points to keep)
%       'select'    if present, calculate output function only at the points retained for fitting
%       'list'      indicates verbosity of output during fitting
%       'fit'       alter convergence critera for the fit etc.
%
%   Example:
%   >> [wout, fitdata] = fit_func (..., 'keep', xkeep, 'list', 0)


% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

[wout, fitdata] = fit_func(sqw(win), varargin{:});
wout=dnd(wout);