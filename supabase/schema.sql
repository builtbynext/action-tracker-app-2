-- Meeting Action Tracker: database schema.
-- Already applied to the Supabase project. Keep this file to recreate it elsewhere.

-- ---------------------------------------------------------------------------
-- Actions
-- ---------------------------------------------------------------------------
create table if not exists public.actions (
  id uuid primary key default gen_random_uuid(),
  text text not null check (char_length(btrim(text)) between 1 and 160),
  owner text not null check (char_length(btrim(owner)) between 1 and 40),
  due date not null,
  done boolean not null default false,
  example boolean not null default false,
  created_at timestamptz not null default now(),
  created_by uuid default auth.uid() references auth.users(id) on delete set null
);

create index if not exists actions_owner_idx on public.actions (lower(owner));

alter table public.actions enable row level security;

-- Only signed-in users can read or change actions.
create policy "actions_select_signed_in" on public.actions for select to authenticated using (true);
create policy "actions_insert_signed_in" on public.actions for insert to authenticated with check (true);
create policy "actions_update_signed_in" on public.actions for update to authenticated using (true) with check (true);
create policy "actions_delete_signed_in" on public.actions for delete to authenticated using (true);

revoke all on public.actions from anon;

-- ---------------------------------------------------------------------------
-- Profiles: one row per user (auth.users), shown in the Users panel
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique check (username ~ '^[a-z0-9._-]{2,30}$'),
  display_name text not null check (char_length(btrim(display_name)) between 1 and 40),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Signed-in users can see the team. Rows are written only by the trigger below.
create policy "profiles_select_signed_in" on public.profiles for select to authenticated using (true);

revoke all on public.profiles from anon;

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = ''
as $$
declare uname text;
begin
  uname := lower(coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)));
  insert into public.profiles (id, username, display_name)
  values (
    new.id,
    uname,
    coalesce(nullif(btrim(new.raw_user_meta_data->>'display_name'), ''), initcap(uname))
  );
  return new;
end;
$$;

revoke execute on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Users sign in with a username. It maps to username@tracker.internal in Supabase Auth.
-- New users are added from the Users panel, which calls the create-user edge function
-- (supabase/functions/create-user/index.ts). That function holds the admin key.
-- ---------------------------------------------------------------------------
