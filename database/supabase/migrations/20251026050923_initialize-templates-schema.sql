create schema templates;

create function templates.enforce_read_only_templates () returns event_trigger as $$
  declare
    event_record record;
  begin
    for event_record in select * from pg_event_trigger_ddl_commands () loop
      if event_record.object_type = 'table' and event_record.schema_name = 'templates' then
        execute format('revoke insert, update, delete on %s from public;', event_record.object_identity);
        raise log 'revoked public usage of table="%"', event_record.object_identity;
      end if;
    end loop;
  end;
$$ language plpgsql
set
  search_path = '';

comment on function templates.enforce_read_only_templates () is 'Tables within the "templates" schema should be read-only to be used with SQL LIKE clauses.';

create event trigger enforce_read_only_templates on ddl_command_end when tag in ('create table', 'create table as')
execute function templates.enforce_read_only_templates ();

comment on event trigger enforce_read_only_templates is 'Triggers the enforce_read_only_templates function when tables are created.';