/**
 * Templates schema for shared common columns and utility functions, procedures, etc.
 */
create schema templates;

/**
 * Tables in the templates schema aren't intended to be written to and can cause issues if data exists in them.
 * The goal would be to utilize "like templates.<template_table> including all" to properly enforce standards.
 */
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

/**
 * Triggers enforce_read_only_templates () when tables are created.
 */
create event trigger enforce_read_only_templates on ddl_command_end when tag in ('create table', 'create table as')
execute function templates.enforce_read_only_templates ();
