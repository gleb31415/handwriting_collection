-- Run once in Supabase → SQL Editor.
-- One row per written word. Visitors (anon / publishable key) may only INSERT:
-- they cannot read, change or delete anyone's data. You read it in the Table Editor or with the service key.

create table if not exists public.handwriting_items (
  id              bigint generated always as identity primary key,
  received_at     timestamptz not null default now(),
  upload_id       uuid        not null unique,          -- made by the page; makes retries safe (duplicate -> 409)
  participant     text        not null check (char_length(participant) <= 64),
  mode            text        not null check (mode in ('fast', 'neat')),
  word            text        not null check (char_length(word) <= 64),
  word_idx        int,
  split           text,
  block           int,
  ord             int,                                  -- position in the participant's session (0..199)
  started         timestamptz,
  finished        timestamptz,
  dur_ms          int,
  n_strokes       int,
  redo            int,
  canvas          jsonb,                                -- {w, h, dpr} of the writing area
  strokes         jsonb       not null                  -- [[ [x, y, t_ms, pressure], ... ], ...]
                  check (octet_length(strokes::text) < 2000000),
  hand            text,
  pen_only        boolean,
  user_agent      text,
  session_created timestamptz
);

create index if not exists handwriting_items_participant_idx on public.handwriting_items (participant);

alter table public.handwriting_items enable row level security;

drop policy if exists "page can insert" on public.handwriting_items;
create policy "page can insert"
  on public.handwriting_items
  for insert
  to anon
  with check (true);

grant insert on public.handwriting_items to anon;

-- If a participant rewrote a word (Back -> Clear -> write again), both versions are stored.
-- Latest version of every word:
--
-- select distinct on (participant, mode, word) *
-- from public.handwriting_items
-- order by participant, mode, word, finished desc;
