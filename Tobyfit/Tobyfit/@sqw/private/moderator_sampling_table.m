function lookup=moderator_sampling_table(moderator,ei,varargin)
% Create moderator lookup table and index arrays
%
%   >> lookup=moderator_sampling_table(fermi)
%   >> lookup=moderator_sampling_table(fermi,npnt)
%   >> lookup=vmoderator_sampling_table(...,opt1,opt2,..)
%
% Input:
% ------
%   moderator   Cell array of moderator object arrays, one per sqw object
%   ei          Cell array of incident energy arrays, one per sqw object
%   npnt        [Optional] Number of points in sampling table (uses default if not given)
%   opt         [Optional] Purge the lookup table if set to 'purge'
%
%               For further options, see method:
%                   IX_moderator/buffered_sampling_table
%
% Output:
% -------
%   lookup      Structure with fields:
%                 lookup.ind    Cell array of indicies into table, where
%                              ind{i} is a row vector of indicies for ith
%                              sqw object; length(ind{i})=no. runs in sqw object
%                 lookup.table  Lookup table size(npnt,nmod), where nmod is
%                              the number of unique tables. 
%                               Use the look-up table to convert a random number
%                              from uniform distribution in the range 0 to 1 into
%                              reduced time deviation 0 <= t_red <= 1. Convert
%                              to true time using the equation
%                                   t = t_av * (t_red/(1-t_red))
%                 lookup.t_av   First moment of time distribution (row vector)
%                              Time here is in seconds (NOT microseconds)
%                 lookup.fwhh   Full width half height of distribution (row vector)
%                              Time here is in seconds (NOT microseconds)
%                 lookup.profile Lookup table size(npnt,nmod), where nmod is
%                              the number of unique tables. 
%                               Use the look-up table to get the pulse profile
%                              at reduced time deviation 0 <= t_red <= 1. Convert
%                              to true time using the equation
%                                   t = t_av * (t_red/(1-t_red))
%                               The pulse profile is normalised so that the peak
%                              value is unity.


% Assemble the moderator objects and get unique entries
nw=numel(moderator);
if numel(ei)~=nw, error('Inconsistent number of arrays in moderator and energy arguments'), end
nr=zeros(1,nw);
for i=1:nw
    nr(i)=numel(moderator{i});
    if numel(ei{i})~=nr(i), error('Number of elements in corresponding moderator and energy arrays do not match'), end
end
nrend=cumsum(nr);
nrbeg=1+[0,nrend(1:end-1)];
nrtot=nrend(end);

moderator_all=repmat(IX_moderator,[nrtot,1]);
ei_all=zeros(nrtot,1);
for i=1:nw
    moderator_all(nrbeg(i):nrend(i))=moderator{i};
    ei_all(nrbeg(i):nrend(i))=ei{i};
end

% Create lookup table, using any buffered results
[table,t_av,ind,fwhh,profile]=buffered_sampling_table(moderator_all,ei_all,varargin{:});

% Create output structure
t_av=1e-6*t_av;     % Convert to seconds
fwhh=1e-6*fwhh;     % Convert to seconds
lookup=struct('ind',{mat2cell(ind,1,nr)},'table',table,'t_av',t_av,'fwhh',fwhh,'profile',profile);