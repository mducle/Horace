classdef test_tobyfit_resfun_2 < TestCaseWithSave
    %TEST_TOBYFIT_RESFUN_2 Tests of resolution function plotting
    
    properties
        inst
        samp
        det_W
        det_E
        det_N
        det_S
        ebin
        ei
        efix
        alatt
        angdeg
        u
        v
        ulen
        vlen
    end
    
    methods
        %--------------------------------------------------------------------------
        function S = test_tobyfit_resfun_2 (name)
            S@TestCaseWithSave(name);
            
            % Make an instrument and sample
            S.inst = maps_instrument_obj_for_tests(90,250,'s');
            S.samp = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
            
            % Make some detectors
            det.x2=6;
            det.phi=30;
            det.azim=0;
            det.width=0.0254;
            det.height=0.0367;
            
            S.det_W = det;
            S.det_E = det; S.det_E.azim = 180;
            S.det_N = det; S.det_N.azim = 90;
            S.det_S = det; S.det_S.azim = 270;
            
            % Some useful parameters
            S.ebin = [12.5,13.5];
            S.ei = 100;
            S.efix = 1;
            S.alatt = [3,4,5];
            S.angdeg = [90,90,90];
            S.u = [1,1,0];
            S.v = [0,0,1];
            
            S.ulen = 2*pi*sqrt(1/S.alatt(1)^2 + 1/S.alatt(2)^2);
            S.vlen = 2*pi/S.alatt(3);
            
            S.save()
        end
        
        
        %--------------------------------------------------------------------------
        function test_indepOfSampleOrientation(S)
            % Test that the sample orientation does not alter the resolution
            % ellipsoid when expressed in terms of the spectrometer axes
            %
            % The two plots should look identical
            
            ww1 = resolution_plot(S.ebin, S.inst, S.samp, S.det_W, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0);
            
            ww2 = resolution_plot(S.ebin, S.inst, S.samp, S.det_W, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 24, 0, 0, 0, 0);
            
            ww3 = resolution_plot(S.ebin, S.inst, S.samp, S.det_W, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 24, 4, 2, 5, 7);
            
            % Should be the same, as does not depend on crystal orientation
            assertEqualToTol (ww1, ww2, 'tol', [1e-12,1e-12])
            assertEqualToTol (ww1, ww3, 'tol', [1e-12,1e-12])
            
            % Save
            assertEqualToTolWithSave (S, ww1, 'tol', [1e-12,1e-12])
            assertEqualToTolWithSave (S, ww2, 'tol', [1e-12,1e-12])
            assertEqualToTolWithSave (S, ww3, 'tol', [1e-12,1e-12])
            
        end
        
        
        %--------------------------------------------------------------------------
        function test_differentDetectors(S)
            % Test that the ellipsoid has the correct kinematic behaviour in
            % N,S,E,W detectors (always tilted towards incident wavevector)
            
            % All four plots should have the intersection  at +ve de on right of plot
            
            % Envelope pointing slightly in 1st quadrant
            wwW = resolution_plot(S.ebin, S.inst, S.samp, S.det_W, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0);
            
            % Envelope pointing slightly in 4th quadrant
            wwE = resolution_plot(S.ebin, S.inst, S.samp, S.det_E, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0);
            
            % Envelope pointing slightly in 1st quadrant
            wwN = resolution_plot(S.ebin, S.inst, S.samp, S.det_N, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0, [1,3,4]);
            
            % Envelope pointing slightly in 4th quadrant
            wwS = resolution_plot(S.ebin, S.inst, S.samp, S.det_S, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0, [1,3,4]);
            
            % Save
            assertEqualToTolWithSave (S, wwW, 'tol', [1e-12,1e-12])
            assertEqualToTolWithSave (S, wwE, 'tol', [1e-12,1e-12])
            assertEqualToTolWithSave (S, wwN, 'tol', [1e-12,1e-12])
            assertEqualToTolWithSave (S, wwS, 'tol', [1e-12,1e-12])
            
        end
        
        
        %--------------------------------------------------------------------------
        function test_projaxes_1(S)
            % Test when projection axes are the same as the spectrometer axes
            %
            % The two plots should look identical
            
            ww1 = resolution_plot(S.ebin, S.inst, S.samp, S.det_W, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0);
            
            proj = projaxes (S.u, S.v, 'type', 'aaa');
            ww2 = resolution_plot(S.ebin, S.inst, S.samp, S.det_W, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0, proj);
            
            % Should be the same, as does not depend on crystal orientation
            assertEqualToTol (ww1, ww2, 'tol', [1e-12,1e-12])
            
            % Save
            assertEqualToTolWithSave (S, ww1, 'tol', [1e-12,1e-12])
            assertEqualToTolWithSave (S, ww2, 'tol', [1e-12,1e-12])
            
        end
        
        
        %--------------------------------------------------------------------------
        function test_projaxes_2(S)
            % Test that when the projection axes are normalised to rlu that the
            % plot axes are scaled correctly
            %
            % The plots should look the same, but the axes changed
            
            ww1 = resolution_plot(S.ebin, S.inst, S.samp, S.det_W, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0);
            aspect1 = get(gca,'DataAspectRatio');
            
            proj = projaxes (S.u, S.v, 'type', 'rrr');
            ww2 = resolution_plot(S.ebin, S.inst, S.samp, S.det_W, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0, proj);
            aspect2 = get(gca,'DataAspectRatio');
            
            % Check aspect ratio of plots
            assertEqualToTol (aspect1(1:2), [1,1], 'tol', [1e-12,1e-12])
            assertEqualToTol (aspect2(1:2), [1/S.ulen,1/S.vlen], 'tol', [1e-12,1e-12])
            
            % Save
            assertEqualToTolWithSave (S, ww1, 'tol', [1e-12,1e-12])
            assertEqualToTolWithSave (S, ww2, 'tol', [1e-12,1e-12])
            
        end
        
        
        %--------------------------------------------------------------------------
        function test_projaxes_3(S)
            % Test that when the projection axes are rotated by 90 degrees that the
            % covariance matrix is appropriately changed.
            %
            % The second plot should look like the first, but rotated clockwise by 90 deg
            
            proj = projaxes (S.u, S.v, 'type', 'rrr');
            ww1 = resolution_plot(S.ebin, S.inst, S.samp, S.det_W, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 0, 0, 0, 0, 0, proj);
            aspect1 = get(gca,'DataAspectRatio');
            
            proj = projaxes (S.u, S.v, 'type', 'rrr');
            ww2 = resolution_plot(S.ebin, S.inst, S.samp, S.det_W, S.ei, S.efix,...
                S.alatt, S.angdeg, S.u, S.v, 90, 0, 0, 0, 0, proj);
            aspect2 = get(gca,'DataAspectRatio');
            
            % Check aspect ratio of plots
            assertEqualToTol (aspect1(1:2), [1/S.ulen,1/S.vlen], 'tol', [1e-12,1e-12])
            assertEqualToTol (aspect2(1:2), [1/S.ulen,1/S.vlen], 'tol', [1e-12,1e-12])
            
            % Save
            assertEqualToTolWithSave (S, ww1, 'tol', [1e-12,1e-12])
            assertEqualToTolWithSave (S, ww2, 'tol', [1e-12,1e-12])
            
            
            %--------------------------------------------------------------------------
        end
    end
end
