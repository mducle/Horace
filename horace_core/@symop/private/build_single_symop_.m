function obj = build_single_symop_(obj,varargin)
% method defines single symop object from aray of symmetry operations
% definitions.
% 

[ok,mess_refl,u,v,uoffset] = check_reflection_args (varargin{:});
if ok
    obj.uoffset_ = uoffset;
    obj.u_ = u;
    obj.v_ = v;
    return
end
[ok,mess_rot,n,theta_deg,uoffset] = check_rotation_args (varargin{:});
if ok
    obj.uoffset_ = uoffset;
    obj.n_ = n;
    obj.theta_deg_ = theta_deg;
    return
end
[ok,mess_mot,W,uoffset] = check_motion_args(varargin{:});
if ok
    obj.W_ = W;
    obj.uoffset_ = uoffset;
    return
end
error('dummy:ID','%s\n*OR*\n%s\n*OR*\n%s',mess_refl,mess_rot,mess_mot);

