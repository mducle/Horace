function par = get_par(file_name,varargin)
% Function uses rundata class to read only par data form correspondent file
%
%Usage:
%>>par=get_par(file_name,[-hor])
%
%Parameters:
%file_name   -- the name of the file, which contains par data nxspe or par
%-hor        -- optional key, which request returned par data as horace
%               structure rather then 6-column array

% redefine the file name of the par file
if ~exist(file_name,'file')
    error('GET_PAR:invalid_argument',[' file: ',file_name,' does not exist']);
end
[fpath,fname,fext] = fileparts(file_name);
if strncmpi(fext,'.par',4)||strncmpi(fext,'.phx',4) % it is probably ascii par or phx file
    % create dummy run_data object 
    rd = rundata();   
    rd.par_file_name = file_name;        
    % reconstruct rundata class to have par file, which is different from spe
    % file (spe is empty). The function actually loads the data
    rd = rundata(rd);
else     % it should be an hdf file with par data in it
    rd = rundata(file_name);
end

% return loaded par data from the rundata class
par=get_par(rd,varargin);

