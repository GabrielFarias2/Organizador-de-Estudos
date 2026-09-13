-- Rode este script inteiro no SQL Editor do seu projeto Supabase
-- (https://app.supabase.com/project/_/sql/new)

create table public.blocks (
  id text primary key,
  user_id uuid references auth.users not null default auth.uid(),
  name text not null,
  color text not null,
  priority text not null default 'media',
  time text,
  goal_min int not null default 30,
  order_num int not null default 0,
  sessions jsonb not null default '{}',
  checks jsonb not null default '{}',
  updated_at timestamptz not null default now()
);

-- ativa Row Level Security: cada usuário só enxerga/edita as próprias linhas
alter table public.blocks enable row level security;

create policy "select own blocks" on public.blocks
  for select using (auth.uid() = user_id);

create policy "insert own blocks" on public.blocks
  for insert with check (auth.uid() = user_id);

create policy "update own blocks" on public.blocks
  for update using (auth.uid() = user_id);

create policy "delete own blocks" on public.blocks
  for delete using (auth.uid() = user_id);

-- mantém updated_at sempre atual em cada upsert
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger blocks_set_updated_at
  before update on public.blocks
  for each row execute function public.set_updated_at();
