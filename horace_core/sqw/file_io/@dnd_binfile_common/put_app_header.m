function obj = put_app_header(obj)
% store binary data block, which describes object as sqw or dnd object
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
%
obj.check_obj_initated_properly();
%
% store sqw file header
head = obj.build_app_header();
%
head_form = obj.app_header_form_;

% write sqw header
bytes = obj.sqw_serializer_.serialize(head,head_form);
fseek(obj.file_id_,0,'bof');
check_error_report_fail_(obj,'Error moving to the beginning of the file');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the sqw file header');

