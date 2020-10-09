function objsec = concat_seq_(obj,varargin)
% concatenate sequence of symop into array of symop-s
%
numel1 = numel(obj);
numel2 = numel(varargin{:});
n_obj = numel1+numel2;
objsec(n_obj) = symop();
for i=1:numel1
    objsec(i) = obj(i);
end
for i=1:numel2
    objsec(numel1+i) = varargin{i};
end
