classdef test_hpc_works< TestCase
    % Testing default configuration manager, selecting
    % configuration as function of a pc type
    %
    properties
    end
    methods
        %
        function this=test_hpc_works(name)
            if nargin<1
                name = 'test_pc_spec_config';
            end
            this = this@TestCase(name);
        end
        %
        function test_load_config(obj)
            pc = hpc_config;
            data_2restore = pc.get_data_to_store();
            clOb = onCleanup(@()set(pc,data_2restore));
            pc.saveable = false;
            
            [old_config,new_hpc_config]=hpc();
            old_dte = old_config.get_data_to_store();
            assertEqual(old_dte,data_2restore);
            
            pc.build_sqw_in_parallel = false;
            
            hpc('off');
            assertEqual(pc.build_sqw_in_parallel,false);
            
            new_hpc_config.build_sqw_in_parallel = false; % ensure this property is set to false
            % on any machine, as we just set it to false for this config
            new_config = pc.get_data_to_store();
            assertEqual(new_hpc_config,new_config);
        end
        
        
    end
end

