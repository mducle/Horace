function horace_mex
% Usage:
% horace_mex;
% Create mex files for all the Horace fortran and C(++) routines
% assuming that proper mex file compilers are configured for Matlab
%
% to configure a gcc compiler (version >= 4.3 requested)  to produce omp
% code one have to edit  ~/.matlab/mexoptions.sh file and add -fopenmp key
% to the proprer compiler and linker keys
% $Revision: 595 $ ($Date: 2012-01-25 13:05:54 +0000 (Wed, 25 Jan 2012) $)

start_dir=pwd;
C_compiled=false;
try % mex C++
    disp('**********> Creating mex files from C++ code')
    % root directory is assumed to be that in which this function resides
    rootpath = fileparts(which('horace_init'));
    cd(rootpath);

    fortran_in_rel_dir = ['_LowLevelCode',filesep,'intel',filesep];
    cpp_in_rel_dir = ['_LowLevelCode',filesep,'cpp',filesep];
    % get folder names corresponding to the current Matlab version and OS
    [VerFolderName,versionDLLextention,OSdirname]=matlab_version_folder();
     out_rel_dir = ['DLL',filesep,OSdirname,filesep,VerFolderName];
     if(~exist(out_rel_dir,'dir'))
         mkdir(out_rel_dir);
     end
         

    mex_single([cpp_in_rel_dir 'get_ascii_file/get_ascii_file'], out_rel_dir,'get_ascii_file.cpp','IIget_acii_file.cpp');
    mex_single([cpp_in_rel_dir 'accumulate_cut_c/accumulate_cut_c'], out_rel_dir,'accumulate_cut_c.cpp');
    mex_single([cpp_in_rel_dir 'bin_pixels_c/bin_pixels_c'], out_rel_dir,'bin_pixels_c.cpp');
    mex_single([cpp_in_rel_dir 'calc_projections_c/calc_projections_c'], out_rel_dir,'calc_projections_c.cpp');
    mex_single([cpp_in_rel_dir 'sort_pixels_by_bins/sort_pixels_by_bins'], out_rel_dir,'sort_pixels_by_bins.cpp');

    disp('**********> Succesfully created all required mex files from C++')
    C_compiled=true;
catch
    message=lasterr();
    warning('**********> Can not create C++ mex files, reason: %s. Please try to do it manually.',message);
  
end
%
F_compiled=false;
try  % mex FORTRAN
    disp('**********> Creating mex files from FORTRAN code')
%    mex_single(fortran_in_rel_dir, out_rel_dir,'get_par_fortran.F','IIget_par_fortran.f');
%    mex_single(fortran_in_rel_dir, out_rel_dir,'get_phx_fortran.f','IIget_phx_fortran.f');
%    mex_single([fortran_in_rel_dir 'get_spe_fortran' filesep 'get_spe_fortran'], out_rel_dir,'get_spe_fortran.F','IIget_spe_fortran.F');
%
%    disp('**********> Succesfully created all requsted mex files from FORTRAN')
     disp('**********> No FORTRAN functions used at the moment')
     F_compiled=true;
catch 
    message=lasterr();    
    warning('**********> Can not create FORTRAN mex files, reason: %s Please try to do it manually.',message);
end
cd(start_dir);
if C_compiled && F_compiled
    set(hor_config,'use_mex',true);
end


%%----------------------------------------------------------------
function mex_single (in_rel_dir, out_rel_dir, varargin)
% Usage:
% mex_single (in_rel_dir, out_rel_dir, varargin)
%
% mex a set of files to produce a single mex file, the file with the mex
% function has to be first in the  list of the files to compile
%

curr_dir = pwd;
if(nargin<1)
    error(' mex_single request at leas one file name to process');
end
nFiles   = (nargin-2);  % files go in varargin
nCells   = 2*nFiles-1;
add_files=cell(nCells,1);
add_fNames=cell(nCells,1);
outdir = fullfile(curr_dir,out_rel_dir);
for i=1:nCells
    if((i/2-floor(i/2))>0) % fractional part
        add_files{i} = fullfile(curr_dir,in_rel_dir,varargin{floor(i/2)+1});
        add_fNames{i}=varargin{floor(i/2)+1};
    else
        add_files{i}  = ' ';
        add_fNames{i} = ' ';
    end
end
short_fname = cell2str(add_fNames);
disp(['Mex file creation from ',short_fname,' ...'])

if(nFiles==1)
    fname      = add_files{1};
    mex(fname, '-outdir', outdir);
else
    flname1 = add_files{1};
    flname2 =  cell2str(add_files{3:nCells});

    mex(flname1,flname2, '-outdir', outdir);
end


%%
function str = cell2str(c)
%CELL2STR Convert cell array into evaluable string.
%
%   See also MAT2STR


if ~iscell(c)

   if ischar(c)
      str = c;
   elseif isnumeric(c)
      str = mat2str(c);
   else
      error('Illegal array in input.')
   end

else

   N = length(c);
   if N > 0
      if ischar(c{1})
         str = c{1};
         for ii=2:N
            if ~ischar(c{ii})
               error('Inconsistent cell array');
            end
            str = [str,c{ii}];
         end
      else
         error(' char cells requested');
      end
   else
      str = '';
   end

end
