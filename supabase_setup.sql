-- Create a table for user profiles
create table if not exists public.users (
  id uuid references auth.users not null primary key,
  level int default 1
);

-- Set up Row Level Security (RLS)
alter table public.users enable row level security;

-- Allow users to view their own profile (or everyone's if needed for admin)
create policy "Public profiles are viewable by everyone."
  on public.users for select
  using ( true );

-- Allow users to insert their own profile
create policy "Users can insert their own profile."
  on public.users for insert
  with check ( auth.uid() = id );

-- Allow users to update their own profile
create policy "Users can update own profile."
  on public.users for update
  using ( auth.uid() = id );

-- Function to handle new user signup automatically
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, level)
  values (new.id, 1);
  return new;
end;
$$ language plpgsql security definer;

-- Trigger the function every time a user is created
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- INSTRUCTIONS:
-- 1. Run this SQL in your Supabase SQL Editor.
-- 2. To change a user's level, you can manually edit the 'level' column in the 'users' table via the Table Editor.
--    - Level 1: Default
--    - Level 2: Intermediate
--    - Level 3: Admin
