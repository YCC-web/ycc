create table api.simple_rls_table (
  like templates.id_primary_key including all,
  like templates.audit_timestamps including all,

  name text
);

call templates.apply_id_primary_key_trigger('api.simple_rls_table');
call templates.apply_audit_timestamps_trigger('api.simple_rls_table');

call templates.enable_row_level_security_with_user_id('api.simple_rls_table');

call templates.create_policy('api.simple_rls_table', 'self_create');
call templates.create_policy('api.simple_rls_table', 'self_read');
call templates.create_policy('api.simple_rls_table', 'self_update');
call templates.create_policy('api.simple_rls_table', 'self_delete');
call templates.create_policy('api.simple_rls_table', 'public_read');
