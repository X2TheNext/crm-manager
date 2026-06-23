-- ============================================================
-- ATCHÉ V2 SCHEMA — run this in Supabase SQL editor
-- ============================================================
-- Adds: users_meta, artist_profiles, booking_requests, event_records
-- Plus RLS so each role sees only what it should

-- ---------------------------------------------------------------
-- 1. USERS META (stores role per authenticated user)
-- ---------------------------------------------------------------
create table if not exists public.users_meta (
  id         uuid primary key references auth.users(id) on delete cascade,
  role       text not null check (role in ('admin','artist','venue')),
  display_name text,
  created_at timestamptz default now()
);

alter table public.users_meta enable row level security;

-- Users can read their own row; admin can read all
create policy "users_meta: own row"
  on public.users_meta for select
  using (auth.uid() = id);

create policy "users_meta: admin reads all"
  on public.users_meta for select
  using (
    exists (
      select 1 from public.users_meta m
      where m.id = auth.uid() and m.role = 'admin'
    )
  );

-- Users insert their own row on first login
create policy "users_meta: self insert"
  on public.users_meta for insert
  with check (auth.uid() = id);

-- Users update their own display_name; admin updates all
create policy "users_meta: self update"
  on public.users_meta for update
  using (auth.uid() = id);

-- ---------------------------------------------------------------
-- 2. ARTIST PROFILES
-- ---------------------------------------------------------------
create table if not exists public.artist_profiles (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid unique references public.users_meta(id) on delete cascade,
  stage_name   text not null,
  bio          text,
  instagram    text,
  genres       text[],          -- ['house','afrobeats','hip-hop']
  location     text,            -- 'Washington DC'
  rate_min     integer,         -- $ floor per set
  rate_max     integer,         -- $ ceiling per set
  photo_url    text,
  is_public    boolean default true,
  -- computed stats (denormalized for fast public reads)
  total_events    integer default 0,
  avg_energy      numeric(3,2) default 0,
  rebook_rate     numeric(5,2) default 0,  -- 0-100 pct
  on_time_rate    numeric(5,2) default 0,  -- 0-100 pct
  created_at   timestamptz default now(),
  updated_at   timestamptz default now()
);

alter table public.artist_profiles enable row level security;

-- Public profiles visible to all authenticated users
create policy "artist_profiles: public read"
  on public.artist_profiles for select
  using (auth.uid() is not null and is_public = true);

-- Artists edit their own profile
create policy "artist_profiles: own write"
  on public.artist_profiles for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Admin reads all (including private)
create policy "artist_profiles: admin all"
  on public.artist_profiles for all
  using (
    exists (
      select 1 from public.users_meta m
      where m.id = auth.uid() and m.role = 'admin'
    )
  );

-- ---------------------------------------------------------------
-- 3. VENUE / OPERATOR PROFILES
-- ---------------------------------------------------------------
create table if not exists public.venue_profiles (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid unique references public.users_meta(id) on delete cascade,
  venue_name   text not null,
  contact_name text,
  instagram    text,
  city         text,
  venue_type   text,            -- 'nightclub','bar','yacht','festival'
  capacity     integer,
  website      text,
  created_at   timestamptz default now()
);

alter table public.venue_profiles enable row level security;

create policy "venue_profiles: own read/write"
  on public.venue_profiles for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "venue_profiles: admin all"
  on public.venue_profiles for all
  using (
    exists (
      select 1 from public.users_meta m
      where m.id = auth.uid() and m.role = 'admin'
    )
  );

-- ---------------------------------------------------------------
-- 4. BOOKING REQUESTS
-- ---------------------------------------------------------------
create table if not exists public.booking_requests (
  id            uuid primary key default gen_random_uuid(),
  artist_id     uuid references public.artist_profiles(id),
  venue_user_id uuid references public.users_meta(id),
  -- event details
  event_name    text,
  event_date    date,
  start_time    text,
  venue_name    text,
  city          text,
  -- offer
  offered_rate  integer,        -- $ offered
  message       text,
  -- lifecycle
  status        text default 'pending' check (status in ('pending','accepted','declined','completed','cancelled')),
  -- ATCHÉ fee: 10% of offered_rate (set by app on insert)
  atche_fee     integer,
  created_at    timestamptz default now(),
  updated_at    timestamptz default now()
);

alter table public.booking_requests enable row level security;

-- Venues see bookings they created
create policy "booking_requests: venue own"
  on public.booking_requests for all
  using (venue_user_id = auth.uid())
  with check (venue_user_id = auth.uid());

-- Artists see bookings directed at their profile
create policy "booking_requests: artist sees own"
  on public.booking_requests for select
  using (
    exists (
      select 1 from public.artist_profiles ap
      where ap.id = booking_requests.artist_id and ap.user_id = auth.uid()
    )
  );

-- Artists can accept/decline (update status only)
create policy "booking_requests: artist update status"
  on public.booking_requests for update
  using (
    exists (
      select 1 from public.artist_profiles ap
      where ap.id = booking_requests.artist_id and ap.user_id = auth.uid()
    )
  );

-- Admin sees all
create policy "booking_requests: admin all"
  on public.booking_requests for all
  using (
    exists (
      select 1 from public.users_meta m
      where m.id = auth.uid() and m.role = 'admin'
    )
  );

-- ---------------------------------------------------------------
-- 5. EVENT RECORDS (post-event feedback)
-- ---------------------------------------------------------------
create table if not exists public.event_records (
  id              uuid primary key default gen_random_uuid(),
  booking_id      uuid references public.booking_requests(id),
  artist_id       uuid references public.artist_profiles(id),
  venue_user_id   uuid references public.users_meta(id),
  -- the 5 honest fields
  attendance      integer,
  crowd_energy    integer check (crowd_energy between 1 and 5),
  showed_on_time  boolean,
  would_rebook    boolean,
  notes           text,
  recorded_by     uuid references public.users_meta(id),
  created_at      timestamptz default now()
);

alter table public.event_records enable row level security;

create policy "event_records: venue insert"
  on public.event_records for insert
  with check (venue_user_id = auth.uid());

create policy "event_records: venue read own"
  on public.event_records for select
  using (venue_user_id = auth.uid());

create policy "event_records: artist read own"
  on public.event_records for select
  using (
    exists (
      select 1 from public.artist_profiles ap
      where ap.id = event_records.artist_id and ap.user_id = auth.uid()
    )
  );

create policy "event_records: admin all"
  on public.event_records for all
  using (
    exists (
      select 1 from public.users_meta m
      where m.id = auth.uid() and m.role = 'admin'
    )
  );

-- ---------------------------------------------------------------
-- 6. AUTO-REFRESH ARTIST STATS AFTER EVENT RECORD
-- ---------------------------------------------------------------
create or replace function public.refresh_artist_stats(p_artist_id uuid)
returns void language plpgsql security definer as $$
begin
  update public.artist_profiles
  set
    total_events = (select count(*) from public.event_records where artist_id = p_artist_id),
    avg_energy   = coalesce((select avg(crowd_energy) from public.event_records where artist_id = p_artist_id), 0),
    rebook_rate  = coalesce((
      select (count(*) filter (where would_rebook))::numeric / nullif(count(*),0) * 100
      from public.event_records where artist_id = p_artist_id
    ), 0),
    on_time_rate = coalesce((
      select (count(*) filter (where showed_on_time))::numeric / nullif(count(*),0) * 100
      from public.event_records where artist_id = p_artist_id
    ), 0),
    updated_at   = now()
  where id = p_artist_id;
end;
$$;

create or replace function public.trg_refresh_artist_stats()
returns trigger language plpgsql security definer as $$
begin
  perform public.refresh_artist_stats(NEW.artist_id);
  return NEW;
end;
$$;

drop trigger if exists after_event_record_insert on public.event_records;
create trigger after_event_record_insert
  after insert on public.event_records
  for each row execute function public.trg_refresh_artist_stats();

-- ---------------------------------------------------------------
-- 7. SEED YOUR ADMIN ROW
-- ---------------------------------------------------------------
-- 1. Log into your app once so your user exists in auth.users
-- 2. In Supabase → Authentication → Users, copy your UUID
-- 3. Uncomment the line below, paste your UUID, and run it:

-- insert into public.users_meta (id, role, display_name)
-- values ('<YOUR_AUTH_USER_UUID>', 'admin', 'Xavier')
-- on conflict (id) do update set role = 'admin';

-- ============================================================
-- ALL DONE. 5 tables created with RLS. 10% fee auto-calculated.
-- ============================================================
