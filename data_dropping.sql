DROP TABLE stadiums CASCADE;

DROP TABLE awards CASCADE;

DROP TABLE award_winners CASCADE;

ALTER TABLE matches DROP COLUMN stadium_id;

-- Considering only men world cup 
DELETE FROM bookings WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM goals WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM penalty_kicks WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM player_appearances WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM referee_appearances WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM substitutions WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM team_appearances WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM manager_appearances WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');

-- 2. Delete Matches, Squads, and Standings
DELETE FROM bookings WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM goals WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM penalty_kicks WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM player_appearances WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM referee_appearances WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM substitutions WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM team_appearances WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM manager_appearances WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');

DELETE FROM group_standings WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM host_countries WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM manager_appointments WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM qualified_teams WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM referee_appointments WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM squads WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM tournament_standings WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM matches WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');

DELETE FROM groups WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');
DELETE FROM tournament_stages WHERE tournament_id IN (SELECT tournament_id FROM tournaments WHERE tournament_name ILIKE '%Women%');

DELETE FROM tournaments WHERE tournament_name ILIKE '%Women%';

DELETE FROM players WHERE player_id NOT IN (SELECT player_id FROM squads);
DELETE FROM managers WHERE manager_id NOT IN (SELECT manager_id FROM manager_appointments);
DELETE FROM referees WHERE referee_id NOT IN (SELECT referee_id FROM referee_appointments);

DELETE FROM teams WHERE team_id NOT IN (SELECT home_team_id FROM matches) AND team_id NOT IN (SELECT away_team_id FROM matches);

ALTER TABLE teams DROP COLUMN womens_team;
ALTER TABLE players DROP COLUMN female;
ALTER TABLE managers DROP COLUMN female;
ALTER TABLE referees DROP COLUMN female;

DROP TABLE referee_appearances CASCADE;
DROP TABLE referee_appointments CASCADE;
DROP TABLE referees CASCADE;

DROP TABLE manager_appearances CASCADE;
DROP TABLE manager_appointments CASCADE;
DROP TABLE managers CASCADE;

DROP TABLE confederations CASCADE;

ALTER TABLE teams DROP COLUMN confederation_id; 