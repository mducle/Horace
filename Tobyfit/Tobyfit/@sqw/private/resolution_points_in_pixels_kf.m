function [iW,iPx,nPt,fst,lst,iPt,VxR] = resolution_points_in_pixels_kf(win,lookup,pnt,pntrun,pnt_head,pnt_list)
% For all pixels in all SQW objects, determine which points of pnt are
% within resolution, and what the value of the pixel resolution-volume 
% times the value of the pixel resolution-function is at the point 
% locations, returning the information in seven vectors.
% A number of important pieces of information must be precalculated by the
% initialization function and placed in the lookup.

% Inputs:
%        win     a vector of SQW objects, needed to pull out nominal kf
%                for all pixels
%
%     lookup     the associated lookup table(s) for win, of which we use
%                .vkf, .irun, .kf_cell, .mat_kf, and .vol_kf
%
%        pnt     The full kf points to be considered, (3,[total points])
%
%   pnt_head     The head of a linked list for all kf points, (1,nCell)
%
%   pnt_list     The list of a linked list for all kf points, (1,[total points])
%
% Outputs:
%       iW      the elements of iW are the indicies of the SQW object that
%               the associated pixel came from.
%
%       iPx     the pixel indicies (within each SQW object) which give the
%               associated detector pixel. Within each constant-iW block,
%               these indicies will always be a permutation of 
%               1:[# SQW pixels] -- if using the external C++ code, they
%               should be in order, otherwise they likely are not.
%
%       nPt     the number of points within resolution of the associated
%               detector pixel
%
%       fst     the first element of the output point index vector and
%               resolution probability vector associated with the 
%               associated detector pixel
%
%       lst     like fst, but the last element (redundant but saves on
%               arithmetic later)
%
%       iPt     A list of all points associated with all pixels in all SQW
%
%       VxR     The resolution volume of the associated pixel times the
%               value of the pixel's resolution function evaluated at its
%               associated points

nwin = numel(win);
nPx = arrayfun( @(x)(size( x.data.pix, 2)), win);

iW  = zeros(1,sum(nPx));
iPx = zeros(1,sum(nPx));
nPt = zeros(1,sum(nPx));
fst = zeros(1,sum(nPx));
lst = zeros(1,sum(nPx));

iPt_cell = cell(nwin,1);
VxR_cell = cell(nwin,1);
offsetPt = 0; % offset for iPt, VxR
offsetPx = 0; % offset for iW, iPx, nPt, Pt1

spanCell = lookup.cell_span;
nCell = lookup.cell_N;
for i=1:nwin 
    % Pull predetermined values from the lookup
    pixX = lookup.vkf{i};
    pixrun = lookup.irun{i};
    pixCell=lookup.kf_cell{i};
    % Pixel (Gaussian width) resolution matrix and its volume
    pixM = lookup.mat_kf{i};
    pixV = lookup.vol_kf{i};

    % For each pixel with kf 'pixX' determine which points with 
    % kf 'pnt' are within the pixel resolution pixM.
    % To make things as complex as possible: 
    %   The total kf space is divided up into cells, described by
    %   spanCell and nCell, and the points are grouped into
    %   the cells using linked list (pnt_head,pnt_list). For a given cell,
    %   only the points in that or neighbouring cells are considered for
    %   resolution-inclusion. 
    %   The pixels are located into cells by pixCell which gives the cell
    %   index for each pixel.
    %   The output is a special set of vectors designed to avoid using
    %   MATLAB cell-arrays. (Wouldn't it be great to have Arrays of Arrays?)
    %       iPx         the pixel indicies, some permutation of 1:npix
    %       nPt         the number of points within resolution for each iPx
    %       fst         the first index into iPt associated with each iPx
    %       lst         the last index into iPt associated with each iPx
    %       iPt         a list of point indicies (up to) npt*npix in
    %                   length, but likely less, containing all point
    %                   indicies for each pixel
    %       VxR         for each point-within-resolution, the pixel
    %                   resolution volume times the probability of being
    %                   within-resolution. [or, the value of
    %                   R{(kf)pix-(kf)pnt} if R is *not* normalized]
    
    % MATLAB wrapper around C++ code with pure-MATLAB fallback
    [this_iPx,this_nPt,this_fst,this_lst,this_iPt,this_VxR] = pointsInResRunPix(nCell,spanCell,pnt,pntrun,pnt_head,pnt_list,pixX,pixM,pixV,pixrun,pixCell,lookup.frac);
    
    k = offsetPx+(1:nPx(i)); 
    iW ( k ) = i;
    iPx( k ) = this_iPx;
    nPt( k ) = this_nPt;
    fst( k ) = this_fst + offsetPt; % must offset the first-point index into iPt, VxR;
    lst( k ) = this_lst + offsetPt; % and the last-point index

    iPt_cell{i} = this_iPt;
    VxR_cell{i} = this_VxR;

    offsetPx = offsetPx+nPx(i);
    offsetPt = offsetPt+numel(this_iPt);
end
iPt = cat(2,iPt_cell{:});
VxR = cat(2,VxR_cell{:});
if numel(iPt) ~= offsetPt || numel(VxR) ~= offsetPt
    error('Something has gone wrong with creation of iPt or VxR')
end

end