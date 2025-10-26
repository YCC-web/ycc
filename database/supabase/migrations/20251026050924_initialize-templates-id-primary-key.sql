create table
  templates.id_primary_key (id uuid primary key default gen_random_uuid ());

comment on table templates.id_primary_key is 'A primary key "id" column for the table.';

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

comment on function templates.enforce_id_primary_key () is 'Prevents modification of the "id" column and ensures the system always generates a random UUID as the "id".';

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

comment on procedure templates.apply_id_primary_key_trigger (regclass) is 'Applies the enforce_id_primary_key function during inserts and updates of a row.';