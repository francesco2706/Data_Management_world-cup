-- 1. Tabella TOURNAMENTS
ALTER TABLE tournaments 
ALTER COLUMN start_date TYPE DATE USING (DATE '1970-01-01' + NULLIF(start_date, '')::numeric::integer),
ALTER COLUMN end_date TYPE DATE USING (DATE '1970-01-01' + NULLIF(end_date, '')::numeric::integer);

-- 2. Tabella TOURNAMENT_STAGES
ALTER TABLE tournament_stages 
ALTER COLUMN start_date TYPE DATE USING (DATE '1970-01-01' + NULLIF(start_date, '')::numeric::integer),
ALTER COLUMN end_date TYPE DATE USING (DATE '1970-01-01' + NULLIF(end_date, '')::numeric::integer);

-- 3. Tabella MATCHES (Data e Ora)
ALTER TABLE matches 
ALTER COLUMN match_date TYPE DATE USING (DATE '1970-01-01' + NULLIF(match_date, '')::numeric::integer),
ALTER COLUMN match_time TYPE TIME USING (NULLIF(match_time, '')::time);

-- 4. Tabella PLAYERS (Data di nascita - Formato YYYY-MM-DD)
ALTER TABLE players 
ALTER COLUMN birth_date TYPE DATE USING (NULLIF(birth_date, '')::date);

-- 1. Tabella PLAYERS (Ruoli e Genere)
ALTER TABLE players 
ALTER COLUMN female TYPE BOOLEAN USING (female::integer::boolean),
ALTER COLUMN goal_keeper TYPE BOOLEAN USING (goal_keeper::integer::boolean),
ALTER COLUMN defender TYPE BOOLEAN USING (defender::integer::boolean),
ALTER COLUMN midfielder TYPE BOOLEAN USING (midfielder::integer::boolean),
ALTER COLUMN forward TYPE BOOLEAN USING (forward::integer::boolean);

-- 2. Tabella MANAGERS
ALTER TABLE managers 
ALTER COLUMN female TYPE BOOLEAN USING (female::integer::boolean);

-- 3. Tabella TOURNAMENTS 
ALTER TABLE tournaments 
ALTER COLUMN host_won TYPE BOOLEAN USING (host_won::integer::boolean);

-- 4. Tabella GOALS
ALTER TABLE goals 
ALTER COLUMN penalty TYPE BOOLEAN USING (penalty::integer::boolean),
ALTER COLUMN own_goal TYPE BOOLEAN USING (own_goal::integer::boolean);

-- 5. Tabella MATCHES
ALTER TABLE matches 
ALTER COLUMN extra_time TYPE BOOLEAN USING (extra_time::integer::boolean),
ALTER COLUMN penalty_shootout TYPE BOOLEAN USING (penalty_shootout::integer::boolean);

ALTER TABLE award_winners 
ALTER COLUMN shared TYPE BOOLEAN USING (shared::integer::boolean);

ALTER TABLE bookings 
ALTER COLUMN home_team TYPE BOOLEAN USING (home_team::integer::boolean),
ALTER COLUMN away_team TYPE BOOLEAN USING (away_team::integer::boolean),
ALTER COLUMN yellow_card TYPE BOOLEAN USING (yellow_card::integer::boolean),
ALTER COLUMN second_yellow_card TYPE BOOLEAN USING (second_yellow_card::integer::boolean),
ALTER COLUMN sending_off TYPE BOOLEAN USING (sending_off::integer::boolean),
ALTER COLUMN red_card TYPE BOOLEAN USING (red_card::integer::boolean);

ALTER TABLE goals 
ALTER COLUMN home_team TYPE BOOLEAN USING (home_team::integer::boolean),
ALTER COLUMN away_team TYPE BOOLEAN USING (away_team::integer::boolean);

ALTER TABLE group_standings 
ALTER COLUMN advanced TYPE BOOLEAN USING (advanced::integer::boolean);

ALTER TABLE manager_appearances 
ALTER COLUMN home_team TYPE BOOLEAN USING (home_team::integer::boolean),
ALTER COLUMN away_team TYPE BOOLEAN USING (away_team::integer::boolean);

ALTER TABLE matches 
ALTER COLUMN group_stage TYPE BOOLEAN USING (group_stage::integer::boolean),
ALTER COLUMN knockout_stage TYPE BOOLEAN USING (knockout_stage::integer::boolean),
ALTER COLUMN replayed TYPE BOOLEAN USING (replayed::integer::boolean),
ALTER COLUMN replay TYPE BOOLEAN USING (replay::integer::boolean),
ALTER COLUMN home_team_win TYPE BOOLEAN USING (home_team_win::integer::boolean),
ALTER COLUMN away_team_win TYPE BOOLEAN USING (away_team_win::integer::boolean);

ALTER TABLE penalty_kicks 
ALTER COLUMN home_team TYPE BOOLEAN USING (home_team::integer::boolean),
ALTER COLUMN away_team TYPE BOOLEAN USING (away_team::integer::boolean);

ALTER TABLE penalty_kicks 
ALTER COLUMN converted TYPE BOOLEAN USING (converted::integer::boolean);

ALTER TABLE player_appearances 
ALTER COLUMN home_team TYPE BOOLEAN USING (home_team::integer::boolean),
ALTER COLUMN away_team TYPE BOOLEAN USING (away_team::integer::boolean),
ALTER COLUMN starter TYPE BOOLEAN USING (starter::integer::boolean),
ALTER COLUMN substitute TYPE BOOLEAN USING (substitute::integer::boolean);

ALTER TABLE referees 
ALTER COLUMN female TYPE BOOLEAN USING (female::integer::boolean);

ALTER TABLE substitutions 
ALTER COLUMN away_team TYPE BOOLEAN USING (away_team::integer::boolean),
ALTER COLUMN home_team TYPE BOOLEAN USING (home_team::integer::boolean),
ALTER COLUMN going_off TYPE BOOLEAN USING (going_off::integer::boolean),
ALTER COLUMN coming_on TYPE BOOLEAN USING (coming_on::integer::boolean);

ALTER TABLE team_appearances 
ALTER COLUMN away_team TYPE BOOLEAN USING (away_team::integer::boolean),
ALTER COLUMN home_team TYPE BOOLEAN USING (home_team::integer::boolean),
ALTER COLUMN extra_time TYPE BOOLEAN USING (extra_time::integer::boolean),
ALTER COLUMN penalty_shootout TYPE BOOLEAN USING (penalty_shootout::integer::boolean),
ALTER COLUMN penalties_against TYPE BOOLEAN USING (penalties_against::integer::boolean),
ALTER COLUMN win TYPE BOOLEAN USING (win::integer::boolean),
ALTER COLUMN lose TYPE BOOLEAN USING (lose::integer::boolean),
ALTER COLUMN draw TYPE BOOLEAN USING (draw::integer::boolean),
ALTER COLUMN penalties_for TYPE BOOLEAN USING (penalties_for::integer::boolean);

ALTER TABLE teams 
ALTER COLUMN mens_team TYPE BOOLEAN USING (mens_team::integer::boolean),
ALTER COLUMN womens_team TYPE BOOLEAN USING (womens_team::integer::boolean);

ALTER TABLE tournament_stages
ALTER COLUMN group_stage TYPE BOOLEAN USING (group_stage::integer::boolean),
ALTER COLUMN knockout_stage TYPE BOOLEAN USING (knockout_stage::integer::boolean),
ALTER COLUMN unbalanced_groups TYPE BOOLEAN USING (unbalanced_groups::integer::boolean);

ALTER TABLE tournaments
RENAME COLUMN final TO final_match;

ALTER TABLE tournaments 
ALTER COLUMN group_stage TYPE BOOLEAN USING (group_stage::integer::boolean),
ALTER COLUMN second_group_stage TYPE BOOLEAN USING (second_group_stage::integer::boolean),
ALTER COLUMN final_round TYPE BOOLEAN USING (final_round::integer::boolean),
ALTER COLUMN round_of_16 TYPE BOOLEAN USING (round_of_16::integer::boolean),
ALTER COLUMN quarter_finals TYPE BOOLEAN USING (quarter_finals::integer::boolean),
ALTER COLUMN third_place_match TYPE BOOLEAN USING (third_place_match::integer::boolean),
ALTER COLUMN final_match TYPE BOOLEAN USING (final_match::integer::boolean),
ALTER COLUMN semi_finals TYPE BOOLEAN USING (semi_finals::integer::boolean);

ALTER TABLE confederations 
DROP COLUMN confederation_wikipedia_link;

ALTER TABLE managers 
DROP COLUMN manager_wikipedia_link;

ALTER TABLE players 
DROP COLUMN player_wikipedia_link;

ALTER TABLE referees 
DROP COLUMN referee_wikipedia_link;

ALTER TABLE teams 
DROP COLUMN mens_team_wikipedia_link,
DROP COLUMN womens_team_wikipedia_link,
DROP COLUMN federation_wikipedia_link;

ALTER TABLE stadiums 
DROP COLUMN stadium_wikipedia_link,
DROP COLUMN city_wikipedia_link;

ALTER TABLE group_standings 
ALTER COLUMN draws TYPE BOOLEAN USING (draws::integer::boolean);

UPDATE public.squads
SET shirt_number = NULL
WHERE shirt_number = 0;

ALTER TABLE matches
ALTER COLUMN draw TYPE BOOLEAN USING (draw::integer::boolean);

-- Setting Not Applicable given name to null
UPDATE players
SET given_name = NULL
WHERE given_name = 'not applicable';

-- Setting shirt numbers in goals
UPDATE goals
SET shirt_number = NULL
WHERE shirt_number = 0;