-- **** QUERY 1 ****
CREATE INDEX idx_matches_home_tourn ON matches(tournament_id, home_team_id);
CREATE INDEX idx_matches_away_tourn ON matches(tournament_id, away_team_id);
CREATE INDEX idx_appearances_player_match ON player_appearances(player_id, match_id);

SELECT 
    p.family_name, 
    p.given_name, 
    t.team_name, 
    tr.tournament_name
FROM players p
JOIN squads s ON p.player_id = s.player_id
JOIN teams t ON s.team_id = t.team_id
JOIN tournaments tr ON s.tournament_id = tr.tournament_id
WHERE NOT EXISTS (
    SELECT m.match_id
    FROM matches m
    WHERE m.tournament_id = s.tournament_id
      AND (m.home_team_id = s.team_id OR m.away_team_id = s.team_id)
      AND m.match_id NOT IN (
          SELECT pa.match_id
          FROM player_appearances pa
          WHERE pa.player_id = s.player_id
      )
);

-- QUERY 2
-- Technique: Adding views derived from existing tables
-- This view calculates the total matches and clean sheets for every goalkeeper
-- in a single, highly efficient pass, eliminating the N+1 correlated subqueries.

CREATE VIEW view_goalkeeper_stats AS
SELECT 
    pa.player_id,
    -- Count total matches played by the player
    COUNT(m.match_id) AS total_matches,
    -- Count clean sheets only for those matches
    SUM(CASE 
        WHEN (m.home_team_id = pa.team_id AND m.away_team_score = 0) OR 
             (m.away_team_id = pa.team_id AND m.home_team_score = 0) 
        THEN 1 ELSE 0 
    END) AS total_clean_sheets
FROM player_appearances pa
JOIN matches m ON pa.match_id = m.match_id
WHERE pa.player_id IN (
    SELECT s.player_id 
    FROM squads s 
    WHERE s.position_name = 'goal keeper'
)
GROUP BY pa.player_id


SELECT 
    p.given_name, 
    p.family_name,
    v.total_matches,
    v.total_clean_sheets,
    ROUND((v.total_clean_sheets::numeric / v.total_matches::numeric) * 100, 2) AS career_percentage
FROM players p
JOIN view_goalkeeper_stats v ON p.player_id = v.player_id
ORDER BY p.family_name ASC;

-- **** QUERY 3 ****
CREATE INDEX idx_goals_player ON goals(player_id, match_id);
CREATE INDEX idx_goals_team_player ON goals(team_id, player_id, match_id);
CREATE INDEX idx_matches_tourn_match ON matches(match_id, tournament_id);

SELECT 
    p.family_name, 
    t.team_name, 
    tr.tournament_name,
    (
        SELECT COUNT(g1.goal_id) 
        FROM goals g1 JOIN matches m1 ON g1.match_id = m1.match_id
        WHERE g1.player_id = p.player_id AND m1.tournament_id = tr.tournament_id
    ) AS player_goals,
    (
        SELECT COUNT(g_tot.goal_id) 
        FROM goals g_tot JOIN matches m_tot ON g_tot.match_id = m_tot.match_id
        WHERE g_tot.team_id = t.team_id AND m_tot.tournament_id = tr.tournament_id
    ) AS total_team_goals
FROM players p
JOIN squads s ON p.player_id = s.player_id
JOIN teams t ON s.team_id = t.team_id
JOIN tournaments tr ON s.tournament_id = tr.tournament_id
WHERE (
    SELECT COUNT(g1.goal_id) 
    FROM goals g1 JOIN matches m1 ON g1.match_id = m1.match_id
    WHERE g1.player_id = p.player_id AND m1.tournament_id = tr.tournament_id
) > (
    SELECT COUNT(g2.goal_id) 
    FROM goals g2 JOIN matches m2 ON g2.match_id = m2.match_id
    WHERE g2.team_id = t.team_id 
      AND m2.tournament_id = tr.tournament_id 
      AND g2.player_id != p.player_id
)
ORDER BY player_goals DESC;

-- **** QUERY 4 ****
-- We completely eliminate the CROSS JOIN and the 5 correlated subqueries. 
-- Instead, we use a dynamic INNER JOIN to find the opponent, and Conditional 
-- Aggregation (SUM CASE) to calculate all statistics in a single, fast pass.

SELECT 
    t1.team_name AS team,
    t2.team_name AS opponent,
    -- We just count the matches directly from the JOIN
    COUNT(m.match_id) AS total_encounters,
    -- Subquery 2 replacement: Calculate Wins
    SUM(CASE 
        WHEN (m.home_team_id = t1.team_id AND m.home_team_score > m.away_team_score) OR 
             (m.away_team_id = t1.team_id AND m.away_team_score > m.home_team_score) 
        THEN 1 ELSE 0 
    END) AS wins,
    -- Subquery 3 replacement: Calculate Draws
    SUM(CASE 
        WHEN m.home_team_score = m.away_team_score 
        THEN 1 ELSE 0 
    END) AS draws,
    -- Subquery 4 replacement: Calculate Lost
    SUM(CASE 
        WHEN (m.home_team_id = t1.team_id AND m.home_team_score < m.away_team_score) OR 
             (m.away_team_id = t1.team_id AND m.away_team_score < m.home_team_score) 
        THEN 1 ELSE 0 
    END) AS losses

FROM teams t1
-- Getting only the matches that Team 1 actually played in
JOIN matches m ON t1.team_id IN (m.home_team_id, m.away_team_id)

-- finding the opponent for each match
JOIN teams t2 ON t2.team_id = CASE 
    WHEN m.home_team_id = t1.team_id THEN m.away_team_id 
    ELSE m.home_team_id 
END
GROUP BY t1.team_id, t2.team_id, t1.team_name, t2.team_name
ORDER BY t1.team_name, total_encounters, opponent DESC;