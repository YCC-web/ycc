create table api.simple_grant (
	like templates.id_primary_key including all,
	like templates.audit_timestamps including all,
	name text
);

call templates.apply_id_primary_key_trigger ('api.simple_grant');

call templates.apply_audit_timestamps_trigger ('api.simple_grant');

grant
select
	on table api.simple_grant to anon;

grant
select
,
	insert,
update,
delete on table api.simple_grant to authenticated;
