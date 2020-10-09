classdef test_symop < TestCaseWithSave
    % Test of various operations associated with symmetrisation
    properties
        log_level
        data_source
        data
        tol_sp
    end
    
    methods
        % Constructor
        function this = test_symop(name)
            % First line - must always be here
            if nargin<1
                name = 'test_symop ';
            end
            this@TestCaseWithSave(name)
            
            % Get Horace log level
            this.log_level = get(hor_config,'log_level');
            
            % Read in data
            this_path = fileparts(mfilename('fullpath'));
            this.data_source = fullfile(this_path,'test_cut_sqw_sym.sqw');
            this.data = read_horace(this.data_source);
            
            
            % Tolerance
            this.tol_sp = [1e-6,1e-6];
            
        end
        
        %------------------------------------------------------------------------
        % Tests
        %------------------------------------------------------------------------
        function test_concat(~)
            sy = [symop([1,1,0], [0,0,1], [2,0,0]),symop([1,1,1], 120,[1,1,0])];    
            infr = [sy.info];
            assertEqual(infr,sprintf(['Reflection operator:\n',...
                        ' In-plane u (rlu): [1, 1, 0]\n',...
                        ' In-plane v (rlu): [0, 0, 1]\n',...
                        '     offset (rlu): [2, 0, 0]\n',...
                        'Rotation operator:\n',...
                        '       axis (rlu): [1, 1, 1]\n',...
                        '      angle (deg): 120\n',...
                        '     offset (rlu): [1, 1, 0]\n']));
            
        end
        
        function test_array(~)
            sy = symop({{[1,1,0], [0,0,1], [2,0,0]},{[1,1,1], 120,[1,1,0]}});            
            infr = [sy.info];
            assertEqual(infr,sprintf(['Reflection operator:\n',...
                        ' In-plane u (rlu): [1, 1, 0]\n',...
                        ' In-plane v (rlu): [0, 0, 1]\n',...
                        '     offset (rlu): [2, 0, 0]\n',...
                        'Rotation operator:\n',...
                        '       axis (rlu): [1, 1, 1]\n',...
                        '      angle (deg): 120\n',...
                        '     offset (rlu): [1, 1, 0]\n']));
            
        end
        
        function test_refl_info(~)

            sy = symop([1,1,0], [0,0,1], [2,0,0]);
            assertEqual(sy.info,sprintf(['Reflection operator:\n',...
                        ' In-plane u (rlu): [1, 1, 0]\n',...
                        ' In-plane v (rlu): [0, 0, 1]\n',...
                        '     offset (rlu): [2, 0, 0]\n']));
        end
        function test_rot_info(~)
            sy = symop ([1,1,1], 120,[1,1,0]);
            
            assertEqual(sy.info,sprintf(['Rotation operator:\n',...
                '       axis (rlu): [1, 1, 1]\n',...
                '      angle (deg): 120\n',...
                '     offset (rlu): [1, 1, 0]\n']));
        end
        
        function test_empty_info(~)
            sy = symop();
            
            assertEqual(sy.info,sprintf('Identity operator (no symmetrisation)\n'));
        end
        
        %------------------------------------------------------------------------
    end
end
