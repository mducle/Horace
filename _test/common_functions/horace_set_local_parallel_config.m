function [new_config, old_parallel_conf] = horace_set_local_parallel_config()
    % Set the config directories for the parallel framework
    %
    % The config directory is moved to "tempdir/config" and the shared directories
    % for parallel communications are set to "tempdir/local" and "tempdir/remote".
    %
    % This function is useful for if you're running the same tests in parallel on
    % the same machine (e.g. on a build server), it avoids IO errors when separate
    % processes attempt to read/write the same config/temporary files.
    %
    % Output:
    % -------
    %   new_config      The new parallel_config object
    %   old_config      The old parallel_config data. This can be used to restore
    %                   the settings to the previous state.
    %
    CONFIG_FOLDER = fullfile(tempdir(), 'config');
    SHARED_LOCAL_DIR = fullfile(tempdir(), 'local');
    SHARED_REMOTE_DIR = fullfile(tempdir(), 'remote');
    WORKING_DIR = tempdir();

    old_parallel_conf = parallel_config().get_data_to_store();
    old_herbert_conf = herbert_config().get_data_to_store();
    old_horace_conf = hor_config().get_data_to_store();
    on_cleanup = onCleanup(@() cleanup(old_herbert_conf, old_horace_conf));

    config_store.set_config_folder(CONFIG_FOLDER);

    new_config = parallel_config;
    new_config.shared_folder_on_local = SHARED_LOCAL_DIR;
    new_config.shared_folder_on_remote = SHARED_REMOTE_DIR;
    new_config.working_directory = WORKING_DIR;


function cleanup(herbert_conf, horace_conf)
    set(herbert_config, herbert_conf);
    set(hor_config, horace_conf);