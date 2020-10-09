classdef symop
    % Symmetry operator describing equivalent points
    %
    % A symmetry operator object describes how equivalent points are defined by
    % operations performed with respect to a reference frame by:
    %   - Rotation about an axis through a given point
    %   - Reflection thrugh a plane passing through a given point
    %
    % An array, O, of the symmetry operator objects can be created to express a
    % more complex operation, in which operations are applied in sequence O(1), O(2),...
    %
    % EXAMPLES:
    %   Mirror plane defined by [1,0,0] and [0,1,0] directions passing through [1,1,1]
    %       s1 = symop ([1,0,0], [0,1,0], [1,1,1]);
    %
    %   Equivalent points are reached by rotation by 90 degrees about c* passing
    %   through [0,2,0]:
    %       s2 = symop([0,0,1], 90, [0,2,0]);
    %
    %   Equivalent points are reached by first reflection in the mirror plane and
    %   then rotating:
    %       stot = [s1,s2]
    %
    % symop Methods:
    % --------------------------------------
    %   symop           - Create a symmetry operator object
    %   transform_pix   - Transform pixel coordinates into symmetry related coordinates
    %   transform_proj  - Transform projection axes description by the symmetry operation
    %   is_identity     - Determine if a symmetry operation is the identity operation
    %   is_rotation     - Determine if a symmetry operation is a rotation
    %   is_reflection   - Determine if a symmetry operation is a reflection
    %   is_motion       - Determine if a symmetry operation was supplied as a complete motion
    properties(Dependent)
        % return the information about the symop
        info
        % if a symmetry operation is the identity operation
        is_identity
        % if a symmetry operation is a rotation
        is_rotation
        % - if a symmetry operation is a reflection
        is_reflection
        % Determine if a symmetry operation was supplied as a complete motion
        is_motion
    end
    
    properties (Access=private)
        uoffset_ = [];  % offset vector for symmetry operator (rlu) (row)
        u_ = [];        % first vector defining reflection plane (rlu) (row)
        v_ = [];        % second vector defining reflection plane (rlu) (row)
        n_ = [];        % rotation axis (un-normalised) (rlu) (row)
        theta_deg_ = [];% rotation angle (deg)
        W_ = [];        % motion transformation operation (real space matrix)
    end
    %     methods(Static)
    %         function infr= info(obj)
    %             if
    %         end
    %
    %     end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = symop (varargin)
            % Create a symmetry operator object.
            %
            % Valid operators are:
            %   Rotation:
            %       >> this = symop (axis, angle)
            %       >> this = symop (axis, angle, offset)
            %
            %       Input:
            %       ------
            %       axis    Vector defining the rotation axis
            %               (in reciprocal lattice units: (h,k,l))
            %       angle   Angle of rotation in degrees
            %       offset  [Optional] Vector defining a point in reciprocal lattice units
            %               through which the rotation axis passes
            %               Default: [0,0,0] i.e. the rotation axis goes throught the origin
            %
            %   Reflection:
            %       >> this = symop (u, v)
            %       >> this = symop (u, v, offset)
            %
            %       Input:
            %       ------
            %       u, v    Vectors giving two directions that lie in a mirror plane
            %               (in reciprocal lattice units: (h,k,l))
            %       offset  [Optional] Vector connecting the mirror plane to the origin
            %               i.e. is an offset vector (in reciprocal lattice units: (h,k,l))
            %               Default: [0,0,0] i.e. the mirror plane goes throught the origin
            %
            %   Symmetry Motion operator:
            %       >> this = symop(W, offset)
            %
            %       Input:
            %       ------
            %       W       A transformation operation in matrix form.
            %               W can represent the identity element {eye(3)},
            %               the inversion element {-eye(3)}, any rotation
            %               or any rotoinversion. The elements of W are
            %               almost certainly integers.
            %       offset  [Optional] The origin at which the transformation
            %               is performed, expressed in r.l.u.
            %               Default: [0,0,0]
            %
            %   Sequence of operations:
            %
            %
            % EXAMPLES:
            %   Rotation of 120 degress about [1,1,1]:
            %       this = symop ([1,1,1], 120)
            %
            %   Reflection through a plane going through the [2,0,0] reciprocal lattice point:
            %       this = symop ([1,1,0], [0,0,1], [2,0,0])
            
            if numel(varargin)>0
                if iscell(varargin{1})
                    inputs = varargin{1};
                    n_obj = numel(inputs);
                    obj(n_obj) = obj;
                    for i=1:n_obj
                        in = inputs{i};
                        obj(i) = build_single_symop_(obj(i),in{:});
                    end
                else
                    obj = build_single_symop_(obj,varargin{:});
                end
            end
        end
        function objsec = vertcat(obj,varargin)        
            objsec = concat_seq_(obj,varargin{:});            
        end
        %
        function objsec = horzcat(obj,varargin)
            %
            objsec = concat_seq_(obj,varargin{:});
        end
        
        function infr= get.info(obj)
            % Return information about the symmetry operator
            %
            %   >>info(obj) -- display information about the object
            
            % Format three vector as string:
            vec2str = @(v)(['[',num2str(v(1)),', ',num2str(v(2)),', ',num2str(v(3)),']']);
            
            if isempty(obj)
                infr = 'Empty symmetry operation object';
                return;
            end
            
            
            if obj.is_identity
                infr = sprintf('Identity operator (no symmetrisation)\n');
            elseif obj.is_rotation
                infr = sprintf(['Rotation operator:\n',...
                    '       axis (rlu): %s\n',...
                    '      angle (deg): %d\n',...
                    '     offset (rlu): %s\n'],...
                    vec2str(obj.n_),obj.theta_deg_,vec2str(obj.uoffset_));
            elseif obj.is_reflection
                infr = sprintf(['Reflection operator:\n',...
                    ' In-plane u (rlu): %s\n',...
                    ' In-plane v (rlu): %s\n',...
                    '     offset (rlu): %s\n'],...
                    vec2str(obj.u_),vec2str(obj.v_),vec2str(obj.uoffset_));
            elseif obj.is_motion
                if sum(abs(obj.uoffset_))>0
                    infr = sprintf(['Motion:\n',...
                        ' % 1d % 1d % 1d  + % g\n',...
                        ' % 1d % 1d % 1d  + % g\n',...
                        ' % 1d % 1d % 1d  + % g\n'],...
                        obj.W_(1,:),obj.uoffset_(1),...
                        obj.W_(2,:),obj.uoffset_(2),...
                        obj.W_(3,:),obj.uoffset_(3));
                else
                    infr = sprintf(['%sMotion:\n',...
                        ' % 1d % 1d % 1d\n',...
                        ' % 1d % 1d % 1d\n',...
                        ' % 1d % 1d % 1d\n'],...
                        obj.W_(1,:),...
                        obj.W_(2,:),...
                        obj.W_(3,:));
                end
            else
                error('Logic error - see developers')
            end
            
        end
        
        %------------------------------------------------------------------
        % Other methods
        function status = get.is_identity(obj)
            % Determine if a symmetry operation is the identity operation
            %
            %   >> status = is_identity (this)
            if isscalar(obj)
                
                status = isempty(obj.uoffset_);
            else
                status = false(size(obj));
                for i=1:numel(obj)
                    status(i) = isempty(obj(i).uoffset_);
                end
            end
        end
        
        function status = get.is_rotation(obj)
            % Determine if a symmetry operation is a rotation
            %
            %   >> status = is_rotation (this)
            if isscalar(obj)
                status = ~isempty(obj.n_);
            else
                status = false(size(obj));
                for i=1:numel(obj)
                    status(i) = ~isempty(obj(i).n_);
                end
            end
        end
        
        function status = get.is_reflection(obj)
            % Determine if a symmetry operation is a reflection
            %
            %   >> status = is_reflection (this)
            if isscalar(obj)
                status = ~isempty(obj.u_);
            else
                status = false(size(obj));
                for i=1:numel(obj)
                    status(i) = ~isempty(obj(i).u_);
                end
            end
        end
        
        function status = get.is_motion(obj)
            if isscalar(obj)
                status = ~isempty(obj.W_);
            else
                status = false(size(obj));
                for i=1:numel(obj)
                    status(i) = ~isempty(obj(i).W_);
                end
            end
        end
        
        %------------------------------------------------------------------
        % Interfaces
        [ok, mess, proj, pbin] = transform_proj (obj, alatt, angdeg, proj_in, pbin_in)
        
        pix = transform_pix (obj, upix_to_rlu, upix_offset, pix_in)
    end
end
