function make_horace_distribution_kit(varargin)
% function creates Horace distribution kit packing all files necessary for
% Horace to work into single zip file
%
%Usage:
%>>make_horace_distribution_kin(['-reveal_code','-nodemo'])
%
%where optional arguments are:
%'-reveal_code'  -- if present, do not request p-code Horace; default pCode
%                    the private horace folders
%'-nodemo'      -- if present, request dropping the demo and test files
%                   with test folders, default -- comress demo and tests
%                   together with main code. 
%
% To use Horace  one has to unpack the resulting zip file and add the folder
% where the function Horace_init.m resides to the matlab search path. 
% alternatively, you can edit the file Horace_on.mt, file and 
% replace the variable $libisis_path$ and $Horathe_path$ by the actual
% folders  where the files Horace_init.m and libisis_init.m reside (Horace
% needs Libisis to work) and add to the search path the file Horace_on.m, 
% after renaming the file Horace_on.mt.
% 
% if called withoug parameters, this function p-codes Horace private
% folders, and removes C source code folders and if with parameter 
% -- compress everything as it is which makes code suitable for further 
% development. 
%
% $Revision: 1851 $ ($Date: 2012-02-02 14:56:47 +0000 (Thu, 02 Feb 2012) $)
%
%
% known keys
keys = {'-reveal_code','-nodemo'};
% default key values
reveal_code = false;
no_demo     = false;
if nargin>0
    if ~all(ismember(varargin,keys))
        non_member=~ismember(varargin,keys);
        for i=1:sum(non_member)
            if non_member(i)
                disp(['Unrecognized key: ',varargin{i}]);
            end
        end
        error('MAKE_HORACE_DISTRIBUTION_KIT:invalid_argument',' unknown or unsupported key');
    end
   % interpret existing keys    
    if ismember('-reveal_code',varargin{:})
        reveal_code =true;
    end
    if ismember('-nodemo',varargin{:})
        no_demo=true;
    end
    
end

rootpath = fileparts(which('horace_init')); % MUST have rootpath so that libisis_init, libisis_off included
%
disp('!===================================================================!')
disp('!==> Preparing HORACE distributon kit  =============================!')
disp('!    Start collecting the Horace program files =====================!')
%

current_dir  = pwd;
root_dir     = current_dir;
% if inside herbert package dir, go avay from there:
if strncmpi(root_dir,current_dir, numel(current_dir))
	cd(rootpath);
	cd('../');
end

target_Dir=[root_dir,'/ISIS'];
horace_dir = [target_Dir,'/Horace'];
% copy everything, which can be found under root Horace folder
copy_files_list(rootpath,horace_dir); 

% remove sqw and intermediate working file if they are there
if exist(fullfile(horace_dir,'demo','fe_demo.sqw'),'file')
    delete(fullfile(horace_dir,'demo','fe_demo.sqw'))
end
delete(fullfile(horace_dir,'demo','*.spe'));
delete(fullfile(horace_dir,'demo','*.nxspe'));    
delete(fullfile(horace_dir,'demo','*.spe_h5'));        
delete(fullfile(horace_dir,'demo','*.tmp'));            

% Delete unwanted directories (with all their sub-directories)
% ------------------------------------------------------------
deldir{1}='_developer_only';
deldir{2}='documentation';  % as for private consumption only at the moment
deldir{3}='work_in_progress';
for i=1:numel(deldir)
    diry = fullfile(horace_dir,deldir{i});
    if exist(diry,'dir')
        rmdir(diry,'s');
    end
end

% if necessary, remove demo and test folders
if no_demo
    rmdir(fullfile(horace_dir,'demo'),'s');
    rmdir(fullfile(horace_dir,'test'),'s');    
    delete(fullfile(horace_dir,'admin','validate_horace.m'));
end
% copy source code files from system directory
copy_files_list(fullfile(rootpath,'_LowLevelCode'),fullfile(horace_dir,'_LowLevelCode'),'+_','h','cpp','c'); 
% copy the file which should initiate Horace (after minor modifications)
% copyfile('horace_on.mt',[target_Dir '/horace_on.mt'],'f');
% copyfile('start_app.m',[target_Dir '/start_app.m'],'f');
install_script=which('horace_on.m.template');
copyfile(install_script,fullfile(target_Dir,'horace_on.m.template'),'f');
%
disp('!    The HORACE program files collected successfully ==============!')
if(~reveal_code)
	disp('!    p-coding private Horace parts and deleting unnecessary fiders=!')
	pCode_Horace_kit(horace_dir);
	disp('!    Horace p-coding completed =====================================!')
end
%
%
disp('!    Start compressing all necessary files together ================!')
% 
if no_demo
    horace_file_name= 'Horace_nodemo.zip';    
else
    horace_file_name= 'horace_distribution_kit.zip';
end
if(exist(horace_file_name,'file'))
    delete(horace_file_name);
end

zip(horace_file_name,target_Dir);
movefile(horace_file_name,current_dir);
cd(current_dir);
%
disp('!    Files compressed. Deleting the auxiliary files and directories=!')
source_len = numel(rootpath);
if ~strncmp(horace_dir,rootpath,source_len)
    rmdir(horace_dir,'s');
end
disp('!    All done folks ================================================!')
sound(-1:0.001:1);

disp('!===================================================================!')