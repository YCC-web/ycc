/**
 * Deny by default actions on the public schema.
 */
alter default privileges
revoke
execute on functions
from
	public;

alter default privileges in schema public
revoke
execute on functions
from
	anon,
	authenticated;
