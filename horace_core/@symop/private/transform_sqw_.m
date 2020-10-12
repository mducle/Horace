function sqw_obj_transf = transform_sqw_(obj,sqw_obj)
% Reverse engineer the full projection and binning descriptor from the
% primary cut for reference in later loops
[proj_ref, pbin_ref] = get_proj_and_pbin (sqw_obj);

header = sqw_obj.header;
% *** assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalized later - but with repercussions in many routines
header_ave=header_average(header);
%
alatt = header_ave.alatt;
angdeg = header_ave.angdeg;
upix_to_rlu = header_ave.u_to_rlu(1:3,1:3);
upix_offset = header_ave.uoffset;


[ok, mess, proj_trans, pbin_trans] = obj.transform_proj (...
    alatt, angdeg, proj_ref, pbin_ref);
if ~ok, error(mess), end
%
data = sqw_obj.data;
[proj_trans, ~, ~, pin, en] = proj_trans.update_pbins(header_ave, data,pbin_trans);

%[ok,mess,proj_trans] = cut_sqw_check_pbins (header_ave, data,...
%   proj_trans, pbin_trans);
%sqw_obj_transf = cut_sqw(sqw_obj,proj_trans,pin{:});
sqw_obj_transf  = sqw_obj;

% Transform pixels
if isa(sqw_obj_transf ,'sqw') && numel(sqw_obj_transf .data.pix.data)>0
    sqw_obj_transf .data.pix.q_coordinates = obj.transform_pix(...
        upix_to_rlu, upix_offset, sqw_obj_transf.data.pix.q_coordinates);
end
