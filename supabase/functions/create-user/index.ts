import { createClient } from 'npm:@supabase/supabase-js@2';

// Lets a signed-in user add a new user with a chosen password.
// The caller's session token is checked here, because the browser never holds the admin key.
// Deployed with verify_jwt = false; authentication is done in the code below.

const EMAIL_DOMAIN = 'tracker.internal';
const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function reply(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  if (req.method !== 'POST') return reply({ error: 'Use POST.' }, 405);

  const token = (req.headers.get('Authorization') || '').replace(/^Bearer\s+/i, '');
  if (!token) return reply({ error: 'Sign in first.' }, 401);

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { autoRefreshToken: false, persistSession: false } },
  );

  const { data: caller, error: callerError } = await admin.auth.getUser(token);
  if (callerError || !caller?.user) return reply({ error: 'Your session has expired. Sign in again.' }, 401);

  let payload: { username?: string; display_name?: string; password?: string };
  try { payload = await req.json(); } catch { return reply({ error: 'Invalid request.' }, 400); }

  const username = String(payload.username || '').trim().toLowerCase();
  const displayName = String(payload.display_name || '').trim() || username.charAt(0).toUpperCase() + username.slice(1);
  const password = String(payload.password || '');

  if (!/^[a-z0-9._-]{2,30}$/.test(username)) {
    return reply({ error: 'Username must be 2 to 30 characters: letters, numbers, dot, dash or underscore.' }, 400);
  }
  if (displayName.length > 40) return reply({ error: 'Display name must be 40 characters or fewer.' }, 400);
  if (password.length < 8) return reply({ error: 'Password must be at least 8 characters.' }, 400);

  const { data, error } = await admin.auth.admin.createUser({
    email: `${username}@${EMAIL_DOMAIN}`,
    password,
    email_confirm: true,
    user_metadata: { username, display_name: displayName },
  });

  if (error) {
    const taken = /already|exists|registered/i.test(error.message);
    return reply({ error: taken ? 'That username is already taken.' : error.message }, taken ? 409 : 400);
  }

  return reply({ id: data.user?.id, username, display_name: displayName }, 201);
});
