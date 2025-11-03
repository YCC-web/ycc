create schema api;

grant usage on schema api to service_role;
alter default privileges in schema api grant all on tables to service_role;

grant usage on schema api to anon, authenticated;

comment on schema api is e'@graphql({"inflect_names": true})';