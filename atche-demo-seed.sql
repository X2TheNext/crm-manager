-- ============================================================
-- ATCHÉ DEMO SEED — run AFTER atche-booking-schema.sql
-- Populates the platform with realistic DC artists + event history
-- so the browse page never looks empty on first view
-- ============================================================

-- Allow user_id to be null for demo/seeded profiles
alter table public.artist_profiles
  alter column user_id drop not null;

-- ---------------------------------------------------------------
-- DEMO ARTISTS
-- ---------------------------------------------------------------
insert into public.artist_profiles
  (id, stage_name, bio, instagram, genres, location, rate_min, rate_max, is_public, total_events, avg_energy, rebook_rate, on_time_rate)
values

(
  'a1000000-0000-0000-0000-000000000001',
  'Deja Reign',
  'Open format DJ based in the DMV. Known for reading the room and keeping the floor locked from first drop to last call. Hip-hop, afrobeats, RnB — seamless transitions, no ego.',
  'dejarofficialdc',
  array['Hip-Hop','RnB','Afrobeats','Open Format'],
  'Washington DC',
  200, 400,
  true,
  0, 0, 0, 0
),

(
  'a2000000-0000-0000-0000-000000000002',
  'Marcus Blaze',
  'House head and Afrobeats specialist. Residencies across DC and Maryland. Brings the energy up slow and keeps it there — venues rebook because the crowd keeps coming back.',
  'marcusblaze_dc',
  array['House','Afrobeats','Amapiano','Club'],
  'Washington DC',
  150, 350,
  true,
  0, 0, 0, 0
),

(
  'a3000000-0000-0000-0000-000000000003',
  'Aaliyah Skye',
  'Neo-soul and RnB with hip-hop roots. Creates atmospheres, not just playlists. The go-to for upscale events, brunches, rooftops, and brand activations in the DMV.',
  'aaliyahskye',
  array['Neo-Soul','RnB','Hip-Hop','Soul'],
  'Washington DC',
  175, 325,
  true,
  0, 0, 0, 0
),

(
  'a4000000-0000-0000-0000-000000000004',
  'DJ K-Way',
  'Caribbean, dancehall, and afro fusion. Born in the DMV, shaped by the islands. Brings a different energy — the crowd moves differently when K-Way is on.',
  'djkwaydc',
  array['Dancehall','Caribbean','Afrobeats','Hip-Hop'],
  'Washington DC',
  200, 450,
  true,
  0, 0, 0, 0
),

(
  'a5000000-0000-0000-0000-000000000005',
  'Soleil',
  'Latin, reggaeton, and Afrobeats. Multilingual sets for multilingual crowds. Known for peak-hour management and set construction that keeps venues at capacity until close.',
  'soleildjdc',
  array['Latin','Reggaeton','Afrobeats','House'],
  'Washington DC',
  250, 500,
  true,
  0, 0, 0, 0
)

on conflict (id) do nothing;

-- ---------------------------------------------------------------
-- EVENT RECORDS — builds verified stats for each artist
-- (venue_user_id null = platform-seeded record)
-- ---------------------------------------------------------------

-- Deja Reign — 9 events
insert into public.event_records (artist_id, crowd_energy, showed_on_time, would_rebook, notes, attendance)
values
  ('a1000000-0000-0000-0000-000000000001', 5, true,  true,  'Crowd was locked in all night. Will def be back.', 180),
  ('a1000000-0000-0000-0000-000000000001', 4, true,  true,  'Solid set, good crowd interaction.', 140),
  ('a1000000-0000-0000-0000-000000000001', 5, true,  true,  'Best set of the night. Floor packed 11-2.', 220),
  ('a1000000-0000-0000-0000-000000000001', 4, true,  true,  'Smooth transitions, crowd stayed late.', 160),
  ('a1000000-0000-0000-0000-000000000001', 5, true,  true,  'Outstanding energy management.', 200),
  ('a1000000-0000-0000-0000-000000000001', 4, true,  true,  'Consistent as always.', 150),
  ('a1000000-0000-0000-0000-000000000001', 5, true,  true,  'Crowd didn''t want to leave.', 190),
  ('a1000000-0000-0000-0000-000000000001', 3, true,  false, 'Slow start, picked up after midnight.', 120),
  ('a1000000-0000-0000-0000-000000000001', 5, true,  true,  'Perfect set for the event.', 175);

-- Marcus Blaze — 13 events
insert into public.event_records (artist_id, crowd_energy, showed_on_time, would_rebook, notes, attendance)
values
  ('a2000000-0000-0000-0000-000000000002', 5, true,  true,  'House set was immaculate.', 200),
  ('a2000000-0000-0000-0000-000000000002', 4, true,  true,  'Great read on the crowd early.', 165),
  ('a2000000-0000-0000-0000-000000000002', 5, true,  true,  'People were asking who was playing.', 220),
  ('a2000000-0000-0000-0000-000000000002', 4, false, true,  'Showed up 15 min late but delivered.', 180),
  ('a2000000-0000-0000-0000-000000000002', 5, true,  true,  'Best crowd of the season.', 240),
  ('a2000000-0000-0000-0000-000000000002', 4, true,  true,  'Consistent energy throughout.', 155),
  ('a2000000-0000-0000-0000-000000000002', 5, true,  true,  'Will be back next quarter.', 195),
  ('a2000000-0000-0000-0000-000000000002', 4, true,  true,  'Crowd loved the afrobeats transition.', 170),
  ('a2000000-0000-0000-0000-000000000002', 5, true,  true,  'Full dance floor midnight to 2am.', 210),
  ('a2000000-0000-0000-0000-000000000002', 4, true,  true,  'Always delivers.', 160),
  ('a2000000-0000-0000-0000-000000000002', 5, true,  true,  'Set the tone for the whole night.', 225),
  ('a2000000-0000-0000-0000-000000000002', 4, true,  true,  'Reliable and talented.', 175),
  ('a2000000-0000-0000-0000-000000000002', 5, true,  true,  'Perfect close to the night.', 200);

-- Aaliyah Skye — 7 events
insert into public.event_records (artist_id, crowd_energy, showed_on_time, would_rebook, notes, attendance)
values
  ('a3000000-0000-0000-0000-000000000003', 5, true, true,  'Created an atmosphere. Guests stayed 2hrs longer than planned.', 90),
  ('a3000000-0000-0000-0000-000000000003', 5, true, true,  'Perfect for our brand activation.', 75),
  ('a3000000-0000-0000-0000-000000000003', 5, true, true,  'Guests kept asking for her contact.', 110),
  ('a3000000-0000-0000-0000-000000000003', 4, true, true,  'Very professional, great vibe.', 80),
  ('a3000000-0000-0000-0000-000000000003', 5, true, true,  'Exactly the energy we needed.', 95),
  ('a3000000-0000-0000-0000-000000000003', 5, true, true,  'Third time booking her. Never disappoints.', 100),
  ('a3000000-0000-0000-0000-000000000003', 5, true, true,  'Crowd energy was off the charts for a brunch.', 85);

-- DJ K-Way — 16 events
insert into public.event_records (artist_id, crowd_energy, showed_on_time, would_rebook, notes, attendance)
values
  ('a4000000-0000-0000-0000-000000000004', 5, true,  true,  'Caribbean set was unmatched.', 250),
  ('a4000000-0000-0000-0000-000000000004', 4, true,  true,  'Crowd was moving the whole set.', 200),
  ('a4000000-0000-0000-0000-000000000004', 5, true,  true,  'Different energy entirely — loved it.', 280),
  ('a4000000-0000-0000-0000-000000000004', 3, false, false, 'Late and crowd energy was low.', 150),
  ('a4000000-0000-0000-0000-000000000004', 5, true,  true,  'Best DJ we''ve had this year.', 300),
  ('a4000000-0000-0000-0000-000000000004', 4, true,  true,  'High energy from open to close.', 220),
  ('a4000000-0000-0000-0000-000000000004', 5, true,  true,  'Crowd was chanting.', 260),
  ('a4000000-0000-0000-0000-000000000004', 4, true,  true,  'Versatile set.', 190),
  ('a4000000-0000-0000-0000-000000000004', 5, true,  true,  'Will be back for our summer series.', 240),
  ('a4000000-0000-0000-0000-000000000004', 4, true,  true,  'Crowd stayed until last call.', 210),
  ('a4000000-0000-0000-0000-000000000004', 5, true,  true,  'Knew how to work our crowd.', 230),
  ('a4000000-0000-0000-0000-000000000004', 3, true,  true,  'Started slow but finished strong.', 180),
  ('a4000000-0000-0000-0000-000000000004', 5, true,  true,  'Incredible mix of dancehall and afro.', 270),
  ('a4000000-0000-0000-0000-000000000004', 4, true,  true,  'Consistent and professional.', 200),
  ('a4000000-0000-0000-0000-000000000004', 5, true,  true,  'Kept it going past 2am.', 255),
  ('a4000000-0000-0000-0000-000000000004', 4, true,  true,  'Great crowd awareness.', 215);

-- Soleil — 11 events
insert into public.event_records (artist_id, crowd_energy, showed_on_time, would_rebook, notes, attendance)
values
  ('a5000000-0000-0000-0000-000000000005', 5, true, true,  'Latin crowd went crazy. Capacity all night.', 310),
  ('a5000000-0000-0000-0000-000000000005', 5, true, true,  'Perfect for our brand collab event.', 280),
  ('a5000000-0000-0000-0000-000000000005', 4, true, true,  'Great set construction and timing.', 240),
  ('a5000000-0000-0000-0000-000000000005', 5, true, true,  'Best closing set we''ve had.', 300),
  ('a5000000-0000-0000-0000-000000000005', 5, true, true,  'Multilingual crowd, she handled all of it.', 270),
  ('a5000000-0000-0000-0000-000000000005', 4, true, true,  'Professional and prepared.', 220),
  ('a5000000-0000-0000-0000-000000000005', 5, true, true,  'Floor packed 11pm to 3am.', 320),
  ('a5000000-0000-0000-0000-000000000005', 5, true, true,  'Highest grossing night of the quarter.', 290),
  ('a5000000-0000-0000-0000-000000000005', 4, true, true,  'Excellent vibe control.', 250),
  ('a5000000-0000-0000-0000-000000000005', 5, true, true,  'Booked again immediately after.', 305),
  ('a5000000-0000-0000-0000-000000000005', 5, true, true,  'Brought her own crowd on top of ours.', 340);

-- ---------------------------------------------------------------
-- REFRESH STATS for all demo artists
-- ---------------------------------------------------------------
select public.refresh_artist_stats('a1000000-0000-0000-0000-000000000001');
select public.refresh_artist_stats('a2000000-0000-0000-0000-000000000002');
select public.refresh_artist_stats('a3000000-0000-0000-0000-000000000003');
select public.refresh_artist_stats('a4000000-0000-0000-0000-000000000004');
select public.refresh_artist_stats('a5000000-0000-0000-0000-000000000005');

-- ============================================================
-- DONE. 5 artists seeded with verified event history.
-- Browse page will look live immediately.
-- Public profiles: atche-public.html?id=a1000000-0000-0000-0000-000000000001
--                  atche-public.html?id=a2000000-0000-0000-0000-000000000002
--                  atche-public.html?id=a3000000-0000-0000-0000-000000000003
--                  atche-public.html?id=a4000000-0000-0000-0000-000000000004
--                  atche-public.html?id=a5000000-0000-0000-0000-000000000005
-- ============================================================
