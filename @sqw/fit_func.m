function [wout, fitdata] = fit_func(win, varargin)
% Fits a function to an sqw object. If passed an array of 
% sqw objects, then each is fitted independently to the same function.
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
%
%
%
% Input:
% ======
%   win     sqw object or array of sqw objects to be fitted
%
%   func_handle    
%           Function handle to function to be fitted e.g. @gauss
%           Must have form:
%               y = my_function (x1,x2,... ,xn,p)
%
%            or, more generally:
%               y = my_function (x1,x2,... ,xn,p,c1,c2,...)
%
%               - p         a vector of numeric parameters that can be fitted
%               - c1,c2,... any further arguments needed by the function e.g.
%                          they could be the filenames of lookup tables for
%                          resolution effects)
%           
%           e.g. Two dimensional Gaussian:
%               function y = gauss2d(x1,x2,p)
%               y = p(1).*exp(-0.5*(((x1 - p(2))/p(4)).^2+((x2 - p(3))/p(5)).^2);
%
%   pin     Initial function parameter values [pin(1), pin(2)...]
%            - If the function my_function takes just a numeric array of parameters, p, then this
%             contains the initial values [pin(1), pin(2)...]
%            - If further parameters are needed by the function, then wrap as a cell array
%               {[pin(1), pin(2)...], c1, c2, ...}  
%
%   pfree   [Optional] Indicates which are the free parameters in the fit
%           e.g. [1,0,1,0,0] indicates first and third are free
%           Default: all are free
%
%   pbind   [Optional] Cell array that indicates which of the free parameters are bound to other parameters
%           in a fixed ratio determined by the initial parameter values contained in pin:
%             pbind={1,3}               parameter 1 is bound to parameter 3.
%             pbind={{1,3},{4,3},{5,6}} parameter 1 bound to 3, 4 bound to 3, and 5 bound to 6
%                                       In this case, parmaeters 1,3,4,5,6 must all be free in pfree.
%
%           To explicity give the ratio, ignoring that determined from pin:
%             pbind=(1,3,0,7.4)         parameter 1 is bound to parameter 3, ratio 7.4 (the extra '0' is required)
%             pbind={{1,3,0,7.4},{4,3,0,0.023},{5,6}}
%
%           To bind to background parameters (see below), use the function index unity:
%             pbind={1,3,1}             Parameter 1 bound to background parameter 3 
%
%             pbind={1,3,1,3.14}        Give explicit binding ratio.
%
%
%   Optional background function:
%   --------------------------------
%
%   bkdfunc     -|  Arguments for the background function, defined as for the 'foreground'
%   bpin         |  parameters.
%   bpfree       |
%   bpbind      -|
%       
%           Examples of a single binding description:
%               {1,4}         Background parameter (bp) 1 is bound to bp 3, with the fixed
%                                  ratio determined by the initial values
%               
%               {5,11,0}      Bp 5 bound to parameter 11 of the global fitting function, func
%               {5,11,1}      Bp 5 bound to parameter 11 of the background function
%
%               {5,11,0,0.013}      Explicit ratio for binding bp 5 to parameter 11 of the global fitting function
%               {1,4,1,14.15}       Explicit ratio for binding bp 1 to bp 4 of background function
%
%           Several binding descriptions:
%               {{1,3},{2,4,0,1.2},{5,11,1}}
%
%
%   Optional keywords:
%   ------------------
%   'list'  Numeric code to control output to Matlab command window to monitor
%           status of fit
%               =0 for no printing to command window
%               =1 prints iteration summary to command window
%               =2 additionally prints parameter values at each iteration
%
%   'fit'   Array of fit control parameters
%           fcp(1)  relative step length for calculation of partial derivatives
%           fcp(2)  maximum number of iterations
%           fcp(3)  Stopping criterion: relative change in chi-squared
%                   i.e. stops if chisqr_new-chisqr_old < fcp(3)*chisqr_old
%
%   'keep'  Array or cell array of arrays giving ranges of x to retain for fitting.
%            - single array: applies to all elements of w
%            - a cell array of arrays must have length the same as w, and describes the
%             keep ranges for those elements one-by-one.
%
%           A range is specified by an arrayv of numbers which define a hypercube.
%           For example in case of two dimensions:
%               [xlo, xhi, ylo, yhi]
%           or in the case of n-dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi]
%
%           More than one range can be defined in rows,
%               [Range_1; Range_2; Range_3;...; Range_m]
%             where each of the ranges are given in the format above.
%
%  'remove' Ranges to remove from fitting. Follows the same format as 'keep'.
%
%           If a point appears within both xkeep and xremove, then it will
%           be removed from the fit i.e. xremove takes precendence over xkeep.
%
%   'mask'  Array, or cell array of arrays, of ones and zeros, with the same number
%           of elements as the data arrays in the input object(s) in w. Indicates which
%           of the data points are to be retained for fitting.
%
%  'select' Calculates the returned function values, wout, only at the points
%           that were selected for fitting by 'keep', 'remove', 'mask' and were
%           not eliminated for having zero error bar etc; this is useful for plotting the output, as
%           only those points that contributed to the fit will be plotted.
%
% Output:
% =======
%   wout    Array or cell array of the objects evaluated at the fitted parameter values
%
%   fitdata Result of fit for each dataset
%               fitdata.p      - parameter values
%               fitdata.sig    - estimated errors of global parameters (=0 for fixed parameters)
%               fitdata.bp     - background parameter values
%               fitdata.bsig   - estimated errors of background (=0 for fixed parameters)
%               fitdata.corr   - correlation matrix for free parameters
%               fitdata.chisq  - reduced Chi^2 of fit (i.e. divided by
%                                   (no. of data points) - (no. free parameters))
%               fitdata.pnames - parameter names
%               fitdata.bpnames- background parameter names
%
% EXAMPLES: 
%
% Fit a 2D Gaussian, allowing only height and position to vary:
%   >> ht=100; x0=1; y0=3; sigx=2; sigy=1.5;
%   >> [wfit, fdata] = fit(w, @gauss2d, [ht,x0,y0,sigx,0,sigy], [1,1,1,0,0,0])
%
% Allow all parameters to vary, but remove two rectangles from the data
%   >> ht=100; x0=1; y0=3; sigx=2; sigy=1.5;
%   >> [wfit, fdata] = fit(w, @gauss2d, [ht,x0,y0,sigx,0,sigy], ...
%                               'remove',[0.2,0.5,2,0.7; 1,2,1.4,3])
%
% The same, with a planar background:
%   >> ht=100; x0=1; y0=3; sigx=2; sigy=1.5;
%   >> const=0; dfdx=0; dfdy=0;
%   >> [wfit, fdata] = fit(w, @gauss2d, [ht,x0,y0,sigx,0,sigy], ...
%                             @plane, [const,dfdx,dfdy],...
%                               'remove',[0.2,0.5,2,0.7; 1,2,1.4,3])


% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% Check if any objects are zero dimensional before evaluating fuction, to save on possible expensive computations
% before a 0D object is found in the array
for i = 1:numel(win)
    if isempty(win(i).data.pax)
        error('multifit_func not supported for zero dimensional objects');
    end
end

% Parse the input arguments, and repackage for fit func
[pos,func,plist,bpos,bfunc,bplist] = multifit (win(1), varargin{:},'parsefunc_');
plist={func,plist};
if ~isempty(bpos)
    for i=1:numel(bfunc)
        bplist{i}={bfunc{i},bplist{i}};
    end
end
pos=pos-1; bpos=bpos-1;     % Recall that first argument in the call to multifit was win
varargin{pos}=@func_eval;   % The fit function needs to be func_eval
varargin{pos+1}=plist;
if ~isempty(bpos)
    varargin{bpos}=@func_eval;
    varargin{bpos+1}=bplist;
end

% Evaluate function for each element of the array of sqw objects
wout=win;

for i = 1:numel(win)    % use numel so no assumptions made about shape of input array
    if i==1
        [wout(i),fitdata] = multifit (win(i), varargin{:});
        if numel(win)>1
            fitdata=repmat(fitdata,size(win));  % preallocate
        end
    else
        [wout(i),fitdata(i)] = multifit (win(i), varargin{:});
    end
end