/*
 * Enables row level security (RLS) and attaches a "user_id" column with a foreign-key (FK) constaint to the Supabase authentication table.
 * RLS is critical when writing tables designed to be utilized in "public-facing" workflows to ensure that a user only has access to data
 * they are intended to have access to.
 *
 * Example:
 * call templates.enable_row_level_security_with_user_id('<schema>.<table>');
 */
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

    -- an index is created for user_id to help improve the performance of RLS queries
    execute format(
      'create index %I on %s using btree (user_id)',
      index_name,
      target_table
    );
    raise log 'created index="%s" for "user_id" on table="%s"', index_name, target_table;
  end;
$$ language plpgsql
set
	search_path = '';

/**
 * When RLS is enabled, policies must be attached to the table for them to be useful.
 * Supabase has two default roles: anon, and authenticated
 * The "anon" role represents a user who is unauthenticated and is not logged-in. This is essentially any public user.
 * The "authenticated" role represents a user who created an account and is logged-in.
 *
 * Policies can be combined together to create more complex restrictions. For example, image a "reviews" table where
 * only logged-in users may create reviews, but any user may read them:
 *
 * call templates.create_policy('api.reviews', 'self_create'); -- users can create their own reviews and those reviews are attributed to them
 * call templates.create_policy('api.reviews', 'public_read'); -- any user may read any other user's reviews, regardless of attribution
 */
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
