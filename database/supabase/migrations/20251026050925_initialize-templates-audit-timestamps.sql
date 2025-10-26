create table
  templates.audit_timestamps (
    created_at timestamp with time zone not null default now(),
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
  );

comment on table templates.audit_timestamps is 'Default timestamp columns for tracking audit history of a row.';

create function templates.enforce_audit_timestamps () returns trigger as $$
  begin
    if tg_op = 'insert' then
      new.created_at := now();
      new.updated_at := null;
      new.deleted_at := null;
    elseif tg_op = 'update' then
      new.created_at := old.created_at;
      new.updated_at := now();

      -- Soft Delete, null -> now()
      if new.deleted_at is not null 
      and old.deleted_at is null then
        new.deleted_at := now();
      -- Modification Prevention
      elseif new.deleted_at is not null 
      and old.deleted_at is not null then
        new.deleted_at := old.deleted_at;
      -- Otherwise, un-delete by setting to null
      end if;
    end if;
    return new;
  end;
$$ language plpgsql
set
  search_path = '';

comment on function templates.enforce_audit_timestamps () is 'Ensures data consistency on the audit timestamp columns (created_at, updated_at, deleted_at) by ensuring the values are always the appropriate timestamp.';

create procedure templates.apply_audit_timestamps_trigger (target_table regclass) as $$
  declare
    trigger_name text := replace(target_table::text, '.', '__') || '__enforce_audit_timestamps';
  begin
    execute format(
      'create trigger %I '
      'before insert or update on %s '
      'for each row '
      'execute function templates.enforce_audit_timestamps ();',
      trigger_name,
      target_table
    );
    raise log 'trigger="%s" applied to table="%s"', trigger_name, target_table;
  end;
$$ language plpgsql
set
  search_path = '';

comment on procedure templates.apply_audit_timestamps_trigger (regclass) is 'Applies the enforce_audit_timestamps function during inserts and updates of a row.';