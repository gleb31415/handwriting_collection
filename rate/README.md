# Handwriting beauty rating page

Static page, no build step: `index.html` + `items.json` (960 words; 40 shown twice to check consistency).
Every rating is one INSERT into the Supabase table `beauty_ratings` (same project and publishable key as the collection page).
The table accepts inserts only: visitors cannot read, change or delete anything.

Setup, once: run `beauty_ratings_setup.sql` in Supabase -> SQL Editor.
Deploy: copy this `rate/` folder into the `handwriting_collection` repo and push; GitHub Pages serves it at `<pages-url>/rate/`.

Each rater types a name/code, chooses Russian and/or English, and gets their own shuffled order. Progress is kept in the browser;
coming back with the same name continues where they stopped. Keys: 1-5 rate, Backspace back, T show the word, 0 skip.
