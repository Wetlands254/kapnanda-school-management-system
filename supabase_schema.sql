-- Kapnanda School Management System - Supabase setup
-- Run this in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Kapnanda Junior & Primary School',
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  school_id uuid not null references public.schools(id) on delete cascade,
  email text,
  full_name text,
  role text not null default 'staff' check (role in ('admin','staff','teacher')),
  created_at timestamptz not null default now()
);

create table if not exists public.school_data (
  school_id uuid primary key references public.schools(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.schools enable row level security;
alter table public.profiles enable row level security;
alter table public.school_data enable row level security;

create or replace function public.my_school_id() returns uuid
language sql stable security definer set search_path=public
as $$ select school_id from public.profiles where id = auth.uid() limit 1 $$;

revoke all on function public.my_school_id() from public;
grant execute on function public.my_school_id() to authenticated;

drop policy if exists "school members can read school" on public.schools;
create policy "school members can read school" on public.schools for select to authenticated using (id = public.my_school_id());

drop policy if exists "users can read own profile" on public.profiles;
create policy "users can read own profile" on public.profiles for select to authenticated using (id = auth.uid());

drop policy if exists "school members can read data" on public.school_data;
create policy "school members can read data" on public.school_data for select to authenticated using (school_id = public.my_school_id());

drop policy if exists "school members can insert data" on public.school_data;
create policy "school members can insert data" on public.school_data for insert to authenticated with check (school_id = public.my_school_id());

drop policy if exists "school members can update data" on public.school_data;
create policy "school members can update data" on public.school_data for update to authenticated using (school_id = public.my_school_id()) with check (school_id = public.my_school_id());

-- Create the first school record.
insert into public.schools(name) values ('Kapnanda Junior & Primary School') on conflict do nothing;

-- After creating the first administrator in Supabase Auth, create their profile using:
-- insert into public.profiles(id, school_id, email, full_name, role)
-- select id, (select id from public.schools limit 1), email, 'School Administrator', 'admin'
-- from auth.users where email = 'YOUR_ADMIN_EMAIL';
