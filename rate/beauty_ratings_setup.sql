-- Run once in Supabase -> SQL Editor (same project as handwriting_items).
-- One row per rating click. The page (publishable / anon key) may only INSERT:
-- it cannot read, change or delete anything. Read the results with the secret key or in the Table Editor.

create table if not exists public.beauty_ratings (
  id              bigint generated always as identity primary key,
  received_at     timestamptz not null default now(),
  upload_id       uuid        not null unique,          -- made by the page; a retried POST returns 409
  rater           text        not null check (char_length(rater) between 1 and 40),
  item_set        text        not null check (char_length(item_set) <= 32),
  item_id         text        not null check (char_length(item_id) <= 16),
  score           smallint    not null check (score between 0 and 5),   -- 0 = skipped
  pos             int,                                  -- position in this rater's sequence
  is_repeat       boolean,                              -- deliberate second showing (consistency check)
  src             text        check (char_length(src) <= 16),           -- ru_real / ru_gen / en_brush / en_pairs
  text            text        check (char_length(text) <= 64),
  writer          text        check (char_length(writer) <= 64),
  mode            text        check (char_length(mode) <= 8),           -- en_pairs: fast / neat
  bin             text        check (char_length(bin) <= 8),            -- ru_real: clean / mid / hard
  variant         text        check (char_length(variant) <= 32),       -- ru_gen: which beautification
  text_shown      boolean,
  dur_ms          int,
  rated_at        timestamptz,
  langs           text        check (char_length(langs) <= 8),
  user_agent      text        check (char_length(user_agent) <= 300),
  session_created timestamptz
);

create index if not exists beauty_ratings_rater_idx on public.beauty_ratings (rater, item_id);

alter table public.beauty_ratings enable row level security;

drop policy if exists "page can insert" on public.beauty_ratings;
create policy "page can insert"
  on public.beauty_ratings
  for insert
  to anon
  with check (true);

grant insert on public.beauty_ratings to anon;

-- A rater who went back and changed a score has several rows for the same (rater, pos); the latest counts:
-- select distinct on (rater, pos) * from public.beauty_ratings order by rater, pos, rated_at desc;
