-- Meeting Action Tracker: database schema.
-- Already applied to the Supabase project. Keep this file to recreate it elsewhere.

create table if not exists public.actions (
  id uuid primary key default gen_random_uuid(),
  text text not null check (char_length(btrim(text)) between 1 and 160),
  owner text not null check (char_length(btrim(owner)) between 1 and 40),
  due date not null,
  done boolean not null default false,
  example boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists actions_owner_idx on public.actions (lower(owner));

alter table public.actions enable row level security;

-- Open access by design: anyone with the site link can view and change actions.
-- To restrict this later, replace these policies with ones that check auth.uid().
create policy "actions_select_all" on public.actions for select to anon, authenticated using (true);
create policy "actions_insert_all" on public.actions for insert to anon, authenticated with check (true);
create policy "actions_update_all" on public.actions for update to anon, authenticated using (true) with check (true);
create policy "actions_delete_all" on public.actions for delete to anon, authenticated using (true);

-- Optional example data (dates are relative to the day you run this).
insert into public.actions (text, owner, due, done, example) values
  ('Send the revised budget to finance', 'Priya', current_date - 3, false, true),
  ('Share customer interview notes with the team', 'Priya', current_date + 2, false, true),
  ('Schedule the design review', 'Priya', current_date - 2, true, true),
  ('Fix the login timeout bug', 'Dan', current_date - 1, false, true),
  ('Update the onboarding checklist', 'Dan', current_date, false, true),
  ('Book a venue for the offsite', 'Marcus', current_date + 4, false, true),
  ('Draft the Q4 hiring plan', 'Marcus', current_date + 9, false, true),
  ('Confirm the vendor contract', 'Marcus', current_date - 5, true, true);
