-- QUERY 1: ALL TIME PLAYERS APPEARANCES LEADERBOARD
-- This query calculates the total number of players World Cup match appearances for each player. 
-- It joins the player data with their match records and national team names, aggregating the 
-- total matches played and ranking the results in descending order to highlight the players with most appareances
SELECT 
    p.given_name, 
    p.family_name, 
    t.team_name, 
    COUNT(pa.match_id) AS total_presences
FROM players p
JOIN player_appearances pa ON p.player_id = pa.player_id
JOIN teams t ON pa.team_id = t.team_id 
GROUP BY p.player_id, p.given_name, p.family_name, t.team_name
ORDER BY total_presences DESC;

-- QUERY 2: HIGHEST AVERAGE GOALS PER MATCH
-- This query calculates the average number of goals scored per match for every 
-- World Cup tournament, and then filters the results to show only the most
-- entertaining tournaments where the average was greater than 2.5 goals per match.
SELECT 
    t.tournament_name, 
    ROUND(AVG(mg.goals_in_match), 2) AS avg_goals_per_match
FROM tournaments t
JOIN (
    SELECT 
        m.tournament_id, 
        m.match_id, 
        COUNT(g.goal_id) AS goals_in_match
    FROM matches m
    LEFT JOIN goals g ON m.match_id = g.match_id
    GROUP BY m.tournament_id, m.match_id
) mg ON t.tournament_id = mg.tournament_id
GROUP BY t.tournament_id, t.tournament_name
HAVING AVG(mg.goals_in_match) > 2.5
ORDER BY avg_goals_per_match DESC;

-- QUERY 3: TEAMS NEVER REACHING KNOCKOUTS
-- This query identifies national teams that have qualified for the World Cup
-- but have never advanced past the group stages in their entire history.

SELECT t.team_name
FROM teams t
JOIN qualified_teams qt ON t.team_id = qt.team_id
EXCEPT
SELECT t.team_name
FROM teams t
JOIN team_appearances ta ON t.team_id = ta.team_id
JOIN matches m ON ta.match_id = m.match_id
WHERE m.stage_name != 'group stage'
ORDER BY team_name ASC;


-- QUERY 4: This query identifies players who have represented more than one national team in World Cup
-- history. For each of these players, it calculates the total number of distinct nations they played for
SELECT 
    p.given_name, p.family_name,
    COUNT(DISTINCT s.team_id)  AS num_nations,
    STRING_AGG(DISTINCT t.team_name, ', '
        ORDER BY t.team_name) AS nations
FROM players p
JOIN squads s ON p.player_id = s.player_id
JOIN teams  t ON s.team_id   = t.team_id
GROUP BY p.player_id, p.given_name, p.family_name
HAVING COUNT(DISTINCT s.team_id) > 1
ORDER BY num_nations DESC, p.family_name;


-- Query 5: This query analyzes the scoring profile of forwards by calculating their 
-- total goals, penalty goals, and the percentage of goals scored via penalties. 
SELECT 
    p.given_name,
    p.family_name,
    COUNT(g.goal_id) AS total_goals,
    SUM(CASE WHEN g.penalty = TRUE THEN 1 ELSE 0 END) AS penalty_goals,
    ROUND(
        (SUM(CASE WHEN g.penalty = TRUE THEN 1.0 ELSE 0.0 END) / COUNT(g.goal_id)) * 100, 
        2
    ) AS penalty_percentage
FROM players p
JOIN goals g ON p.player_id = g.player_id
JOIN matches m ON g.match_id = m.match_id
JOIN squads s ON p.player_id = s.player_id AND m.tournament_id = s.tournament_id
WHERE s.position_name = 'forward'
GROUP BY 
    p.player_id, 
    p.given_name, 
    p.family_name
ORDER BY 
    total_goals DESC;

-- QUERY 6: Find players who scored the most goals in extreme late-game situations 
-- (either in extra time or stoppage time) across all World Cup history.

SELECT 
    p.given_name, 
    p.family_name, 
    COUNT(g.goal_id) AS late_goals
FROM players p
JOIN goals g ON p.player_id = g.player_id
WHERE g.minute_regulation > 90 OR g.minute_stoppage > 0
GROUP BY p.player_id, p.given_name, p.family_name
ORDER BY late_goals DESC
LIMIT 20;


-------------------------------------------------------------
-------------------------------------------------------------
-- ** PERFORMANCE PROBLEM QUERIES
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;


-- QUERY 7
-- This query identifies players who were officially part of a World Cup 
-- squad and played in every single match their national team participated in during 
-- that specific tournament.
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



-- Query 8:
SELECT 
    given_name, 
    family_name,
    total_matches,
    total_clean_sheets,
    CASE 
        WHEN total_matches = 0 THEN 0
        ELSE ROUND((total_clean_sheets::numeric / total_matches::numeric) * 100, 2)
    END AS career_percentage
FROM (
    SELECT 
        p.given_name, p.family_name, 
        -- Counting the number of matches played
        (SELECT COUNT(*) 
         FROM player_appearances pa
         WHERE pa.player_id = p.player_id
        ) AS total_matches,
        -- Counting the number of clean sheets
        (SELECT COUNT(*) 
         FROM player_appearances pa
         JOIN matches m ON pa.match_id = m.match_id
         WHERE pa.player_id = p.player_id
           AND (
               (m.home_team_id = pa.team_id AND m.away_team_score = 0) OR 
               (m.away_team_id = pa.team_id AND m.home_team_score = 0)
           )
        ) AS total_clean_sheets
    FROM players p
    WHERE EXISTS (
        SELECT 1 FROM squads s WHERE s.player_id = p.player_id AND s.position_name = 'goal keeper'
    )
) AS subquery
WHERE total_matches > 0
ORDER BY family_name ASC;


-- Query 9 
--This query identifies the players that scored more than 50% of the total goals scored by their team in the tournament
SELECT 
    p.family_name, 
    t.team_name, 
    tr.tournament_name,
    --Computing the goals scored by the player in a certain tournament
    (
        SELECT COUNT(g1.goal_id) 
        FROM goals g1 JOIN matches m1 ON g1.match_id = m1.match_id
        WHERE g1.player_id = p.player_id AND m1.tournament_id = tr.tournament_id
    ) AS player_goals,
    --Computing the goals scored by the whole team in that tournament
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
    -- Subquery 1: 
    SELECT COUNT(g1.goal_id) 
    FROM goals g1 JOIN matches m1 ON g1.match_id = m1.match_id
    WHERE g1.player_id = p.player_id AND m1.tournament_id = tr.tournament_id
) > (
    -- Subquery 2: 
    SELECT COUNT(g2.goal_id) 
    FROM goals g2 JOIN matches m2 ON g2.match_id = m2.match_id
    WHERE g2.team_id = t.team_id 
      AND m2.tournament_id = tr.tournament_id 
      AND g2.player_id != p.player_id
)
ORDER BY player_goals DESC;


-- Query 10
-- This query generates a comprehensive head-to-head historical dashboard for every pair of national 
-- teams that have ever faced each other. For every reference team, it lists their specific opponents 
-- and calculates their exact historical match record (total matches, wins, draws, and losses) against
-- them.
SELECT 
    t1.team_name AS team,
    t2.team_name AS opponent,
    
    (SELECT COUNT(*) FROM matches m0 
     WHERE (m0.home_team_id = t1.team_id AND m0.away_team_id = t2.team_id)
        OR (m0.away_team_id = t1.team_id AND m0.home_team_id = t2.team_id)
    ) AS total_encounters,
    
    (SELECT COUNT(*) FROM matches m1 
     WHERE (m1.home_team_id = t1.team_id AND m1.away_team_id = t2.team_id AND m1.home_team_score > m1.away_team_score)
        OR (m1.away_team_id = t1.team_id AND m1.home_team_id = t2.team_id AND m1.away_team_score > m1.home_team_score)
    ) AS wins,
   
    (SELECT COUNT(*) FROM matches m2 
     WHERE ((m2.home_team_id = t1.team_id AND m2.away_team_id = t2.team_id) OR (m2.home_team_id = t2.team_id AND m2.away_team_id = t1.team_id))
       AND m2.home_team_score = m2.away_team_score
    ) AS draws,
    
    (SELECT COUNT(*) FROM matches m3 
     WHERE (m3.home_team_id = t1.team_id AND m3.away_team_id = t2.team_id AND m3.home_team_score < m3.away_team_score)
        OR (m3.away_team_id = t1.team_id AND m3.home_team_id = t2.team_id AND m3.away_team_score < m3.home_team_score)
    ) AS losses
FROM teams t1
CROSS JOIN teams t2
WHERE t1.team_id <> t2.team_id
  AND EXISTS (
      SELECT 1 FROM matches m4 
      WHERE (m4.home_team_id = t1.team_id AND m4.away_team_id = t2.team_id) 
         OR (m4.home_team_id = t2.team_id AND m4.away_team_id = t1.team_id)
  )
ORDER BY t1.team_name, total_encounters, opponent DESC;