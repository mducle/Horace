function wout = smooth_units (win,varargin)
% Smooth method - gataway to dnd object smoothing only.

% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)

% Only applies to dnd datasets at the moment. Check all elements before smoothing (avoids possibly costly wasted computation if error)
for i=1:numel(win)
    if is_sqw_type(win(i))
        error('No smoothing of sqw data implemented. Convert to corresponding dnd object and smooth that.')
    end
end

wout=win;   % initalise the output
for i=1:numel(win)
    wout(i).data = smooth_dnd(win(i).data,true,varargin{:});
end
