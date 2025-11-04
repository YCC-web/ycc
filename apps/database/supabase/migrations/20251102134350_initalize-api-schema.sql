/**
 * Default schmea for public-facing user interactions.
 * This schema is accessible as a REST API via PostgreREST.
 * This schema is also accessible as a GraphQL API via pg_graphql.
 */
create schema api;

-- privileges are given to the service_role for default tooling within Supabase
grant usage on schema api to service_role;

alter default privileges in schema api
grant all on tables to service_role;

-- required for PostgREST and pg_graphql
grant usage on schema api to anon,
authenticated;

-- default graphql conventions
comment on schema api is e'@graphql({"inflect_names": true})';
