create procedure templates.enable_row_level_security_with_user_id (target_table regclass) as $$
  declare
    schema_name text := (parse_ident(target_table::text))[1];
    table_name text := (parse_ident(target_table::text))[2];
    index_name text := table_name || '_user_id';
  begin
    execute format('alter table %s enable row level security;', target_table);
    raise log 'row level security enabled for table="%s"', target_table;

    execute format(
      'alter table %s add column user_id uuid not null default auth.uid () references auth.users (id) on delete cascade;',
      target_table
    );
    raise log 'user_id column added for table="%s"', target_table;

    execute format(
      'create index %I on %s using btree (user_id)',
      index_name,
      target_table
    );
    execute format(
      'comment on index %I.%I is ''The "user_id" column is indexed to improve RLS performance.'';',
      schema_name,
      index_name
    );
    raise log 'created index="%s" for "user_id" on table="%s"', index_name, target_table;
  end;
$$ language plpgsql
set
  search_path = '';

comment on procedure templates.enable_row_level_security_with_user_id (regclass) is 'Alters the given target table to enable row level security (RLS) and attaches the necessary "user_id" column.';

create procedure templates.create_policy (target_table regclass, policy_type text) as $$
  begin
    case policy_type
      when 'self_create' then
        execute format(
          'grant insert on %s to authenticated;',
          target_table
        );
        execute format(
          'create policy "An authenticated user can create their own records" on %s '
          'for insert '
          'to authenticated '
          'with check ((select auth.uid()) = user_id);',
          target_table
        );
      when 'self_read' then
        execute format(
          'grant select on %s to authenticated;',
          target_table
        );
        execute format(
          'create policy "An authenticated user can read their own records" on %s '
          'for select '
          'to authenticated '
          'using ((select auth.uid()) = user_id);',
          target_table
        );
      when 'self_update' then
        execute format(
          'grant update on %s to authenticated;',
          target_table
        );
        execute format(
          'create policy "An authenticated user can update their own records" on %s '
          'for update '
          'to authenticated '
          'with check ((select auth.uid()) = user_id);',
          target_table
        );
      when 'self_delete' then
        execute format(
          'grant delete on %s to authenticated;',
          target_table
        );
        execute format(
          'create policy "An authenticated user can delete their own records" on %s '
          'for delete '
          'to authenticated '
          'using ((select auth.uid()) = user_id);',
          target_table
        );
      when 'authenticated_read' then
        execute format(
          'grant select on %s to authenticated;',
          target_table
        );
        execute format(
          'create policy "An authenticated user can read all records" on %s '
          'for select '
          'to authenticated '
          'using (true);',
          target_table
        );
      when 'public_read' then
        execute format(
          'grant select on %s to anon, authenticated;',
          target_table
        );
        execute format(
          'create policy "Any user can read all records" on %s '
          'for select '
          'to authenticated, anon '
          'using (true);',
          target_table
        );
      else
        raise exception 'Unknown policy_type="%s"', policy_type;
    end case;

    raise log 'policy="%s" applied to table="%s"', policy_type, target_table;
  end;
$$ language plpgsql
set
  search_path = '';

comment on procedure templates.create_policy (regclass, text) is 'Applies a specified policy type to the given target table to be used in conjunction with RLS.';