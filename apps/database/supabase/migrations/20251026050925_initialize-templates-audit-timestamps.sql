/**
 * The default metadata columns for tracking timestamps for auditing.
 *
 * Example:
 * create table <schema>.<table> ( like templates.id_primary_key including all );
 */
create table templates.audit_timestamps (
	-- timestamp of when the row was created, never updated
	created_at timestamp with time zone not null default now(),
	-- timestamp of the latest time this row was updated
	updated_at timestamp with time zone,
	-- timestamp of when the row was "deleted", this column is used as a "soft-delete"
	deleted_at timestamp with time zone
);

/**
 * Function to enforce proper timestamp values for all timestamp related metadata fields.
 */
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

/**
 * Applies a trigger that executes enforce_audit_timestamps () during inserts and updates of a row.
 * This procedure should be called if utilizing "templates.audit_timestamps".
 *
 * Example:
 * call templates.audit_timestamps('<schema>.<table>');
 */
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
