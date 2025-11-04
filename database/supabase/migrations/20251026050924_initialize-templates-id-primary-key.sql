/**
 * The default Primary Key (PK) column for entity-based tables that represents a unique identity (id).
 *
 * Example:
 * create table <schema>.<table> ( like templates.id_primary_key including all );
 */
create table
  templates.id_primary_key (id uuid primary key default gen_random_uuid ());

/**
 * Function to prevent modification of the "id" column and ensures that the value is always a randomly generated UUID.
 */
create function templates.enforce_id_primary_key () returns trigger as $$
  begin
    if tg_op = 'insert' then
      new.id := gen_random_uuid ();
    elseif tg_op = 'update' then
      new.id := old.id;
    end if;
    return new;
  end;
$$ language plpgsql
set
  search_path = '';

/**
 * Applies a trigger that executes enforce_id_primary_key () during inserts and updates of a row.
 * This procedure should be called if utilizing "templates.id_primary_key".
 *
 * Example:
 * call templates.apply_id_primary_key_trigger('<schema>.<table>');
 */
create procedure templates.apply_id_primary_key_trigger (target_table regclass) as $$
  declare
    trigger_name text := replace(target_table::text, '.', '__') || '__enforce_id_primary_key';
  begin
    execute format(
      'create trigger %I '
      'before insert or update on %s '
      'for each row '
      'execute function templates.enforce_id_primary_key ();',
      trigger_name,
      target_table
    );
    raise log 'trigger="%s" applied to table="%s"', trigger_name, target_table;
  end;
$$ language plpgsql
set
  search_path = '';