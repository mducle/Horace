function hw = resolution_halfwidths(C,frac)
% For a set of d-dimensional resolution centres, x, and d by d covariance
% matricies, C, calculate the extent along the d dimensions of the
% equal-probability surface of the resolution ellipsoid for fractional
% probability, frac.
% The first part of this algorithm is independent of dimensionality however
% the second part is tailored to 4-D at the moment. With some thought an
% algorithm to efficiently project any d-Dimensional ellipsoid onto its
% d-axes could be written.
%
%   Inputs:
%       x       (d,1) or (d,N) resolution ellipsoid centre(s)
%       C       (d,d) or (d,d,N) resolution covariance matricies
%       frac    the equal-probability fractional height to use for the
%               ellipsoid surface

% Check inputs
%--------------
d=size(C,1);
N=size(C,3);
if ndims(C)>3 || size(C,2) ~= d 
    error('C should be one or more square matricies')
end

if nargin < 2 || ~isnumeric(frac)
    frac=0.5; % half-height probability by default
end

% The resolution matrix is the inverse of the covariancem matrix, and has
% elements that are inverse squared Gaussian widths, i.e., 1/sigma_ij^2
% but we would like to consider fractional-height equal-probability widths,
% where the 'half-width fractional-height' (hwfh) is
%   hwfh = sqrt(2)*log(1/fraction) * sigma
% We must therefore multiply inv(C) by (sigma/hwfh)^2 = 1/2/log(1/fraction)^2
M = resolution_ellipsoid_from_covariance(C,frac);

% Project M onto each of the d axes to get the size of the d-D box which
% fully contains the resolution ellipsoid.
% A simple algorithm needs d*(d-1) evaluations of ip but recomputes
% the same partial projection of M at least once (for d>3).
% There is likely a better general algorithm that can avoid recomputing
% projections, but for now just use a switch case for 3- and 4-D.

switch d
    case 4   
        % 9 evaluations of ip instead of 12:
        M123 = ip(M   ,4); % (d-1, d-1, N)
        M12  = ip(M123,3); % (d-2, d-2, N)
        hw1 = m_t_w( ip(M12 ,2) );        % (d-3, d-3, N) -> (1,1,N)
        hw2 = m_t_w( ip(M12 ,1) );        % (d-3, d-3, N) -> (1,1,N)
        hw3 = m_t_w( ip(ip(M123,2), 1) ); % (d-3, d-3, N) -> (1,1,N)
        hw4 = m_t_w( ip(ip(ip(M,3),2),1) );% (d-3, d-3, N) -> (1,1,N)
        hw = squeeze(cat(1,hw1,hw2,hw3,hw4)); % (d,N)     
    otherwise
        hw = zeros(d,N);
        Mt = M;
        for j=d:-1:2
            Mtt = Mt;
            for k=j-1:-1:1
                Mtt = ip(Mtt,k);
            end
            hw(j,:) = m_t_w( Mtt );
            Mt = ip(Mt,j);
        end
        hw(1,:) = m_t_w(Mt);
end
end

function w=m_t_w(m)
w=1./sqrt(m);
end

%==========================================================================
function Mp = integrate_project(M,i)
% if ~ismatrix(M)
%     error('integrate_project only works for matricies')
% elseif size(M,1)~=size(M,2)
%     error('integrate_project only works for square matricies')
% elseif (i<1)||(i>size(M,1))
%     error('integrate_project needs a valid row/column index')
% elseif size(M,1)==1
if size(M,1) == 1
    Mp=M;
    return;
end
a=size(M,1);
k=(1:a)~=i;
b=(M(k,i)+M(i,k)')/2;
Mp= M(k,k) - (b*b')/M(i,i);
end
%==========================================================================
function Mp = ip(M,i)
if ismatrix(M)
    Mp = integrate_project(M,i);
else
    s = size(M);
    Mp = zeros([s(1)-1,s(2)-1,s(3:end)]);
    for j=1:prod(s(3:end))
        Mp(:,:,j) = integrate_project(M(:,:,j),i);
    end
end
end