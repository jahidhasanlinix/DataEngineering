SELECT * FROM player_seasons;

DROP TYPE IF EXISTS season_stats;
-- Create the type
CREATE TYPE season_stats AS (
    season INTEGER,
    gp INTEGER,
    pts REAL,
    reb REAL,
    ast REAL
);



-- Create table
CREATE TABLE players_details (
player_name TEXT,
height TEXT,
college TEXT,
country TEXT,
draft_year TEXT,
draft_round TEXT,
draft_number TEXT,
season_stats season_stats[],
current_season INTEGER,
PRIMARY KEY(player_name, current_season)
);


SELECT MIN(season) FROM player_seasons;

-- WITH yesterday AS (
-- SELECT * FROM players_details
-- WHERE current_season = 1995
-- ),
-- today AS (
-- SELECT * FROM player_seasons
-- WHERE season = 1996
-- )
-- SELECT * FROM today t FULL OUTER JOIN yesterday y
-- ON t.player_name = y.player_name


-- CTE
-- SELECT *
-- FROM player_seasons t
-- FULL OUTER JOIN players_details y
-- ON t.player_name = y.player_name
-- AND t.season = 1996
-- AND y.current_season = 1995;


-- More efficient way to do it using COALESCE, seed queries
-- WITH yesterday AS (
-- SELECT * FROM players_details
-- WHERE current_season = 1995
-- ),
-- today AS (
-- 	SELECT * FROM player_seasons
-- 	WHERE season = 1996
-- 	)
-- SELECT 
-- COALESCE(t.player_name, y.player_name) AS player_name,
-- COALESCE(t.height, y.height) AS height,
-- COALESCE(t.college, y.college) AS college,
-- COALESCE(t.draft_year, y.draft_year) AS draft_year,
-- COALESCE(t.draft_round, y.draft_round) AS draft_round,
-- COALESCE(t.draft_number, y.draft_number) AS draft_number
-- FROM today t FULL OUTER JOIN yesterday y
-- ON t.player_name = y.player_name


-- With Array, ::season_stats casetd struct type def, concat ops
WITH yesterday AS (
SELECT * FROM players_details
WHERE current_season = 1995
),
today AS (
	SELECT * FROM player_seasons
	WHERE season = 1996
	)
SELECT 
COALESCE(t.player_name, y.player_name) AS player_name,
COALESCE(t.height, y.height) AS height,
COALESCE(t.college, y.college) AS college,
COALESCE(t.draft_year, y.draft_year) AS draft_year,
COALESCE(t.draft_round, y.draft_round) AS draft_round,
COALESCE(t.draft_number, y.draft_number) AS draft_number,
CASE WHEN y.season_stats IS NULL
THEN ARRAY[ROW(
t.season,
t.gp,
t.pts,
t.reb,
t.ast
)::season_stats]
WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[ROW(
t.season,
t.gp,
t.pts,
t.reb,
t.ast
)::season_stats]
ELSE y.season_stats
END as season_stats,
COALESCE(t.season, y.current_season + 1) as current_season
FROM today t FULL OUTER JOIN yesterday y
ON t.player_name = y.player_name




-- CREATE PIPELINE of above code
INSERT INTO players_details
WITH yesterday AS (
SELECT * FROM players_details
WHERE current_season = 2000
),
today AS (
	SELECT * FROM player_seasons
	WHERE season = 2001
	)
SELECT 
	COALESCE(t.player_name, y.player_name) AS player_name,
	COALESCE(t.height, y.height) AS height,
	COALESCE(t.college, y.college) AS college,
	COALESCE(t.country, y.country) AS country,
	COALESCE(t.draft_year, y.draft_year) AS draft_year,
	COALESCE(t.draft_round, y.draft_round) AS draft_round,
	COALESCE(t.draft_number, y.draft_number) AS draft_number,
CASE WHEN y.season_stats IS NULL
	THEN ARRAY[ROW(
	t.season,
	t.gp,
	t.pts,
	t.reb,
	t.ast
	)::season_stats]
WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[ROW(
	t.season,
	t.gp,
	t.pts,
	t.reb,
	t.ast
	)::season_stats]
ELSE y.season_stats
END as season_stats,
	COALESCE(t.season, y.current_season + 1) as current_season
FROM today t FULL OUTER JOIN yesterday y
ON t.player_name = y.player_name;

-- SELECT * FROM players_details;
-- SELECT * FROM players_details WHERE current_season = 2001;
-- SELECT * FROM players_details WHERE current_season = 2001 AND player_name = 'Michael Jordan';
WITH unnested AS (
	SELECT player_name, 
		UNNEST(season_stats)::season_stats AS season_stats
	FROM players_details
	WHERE current_season = 2001 
		-- AND player_name = 'Michael Jordan'
)
SELECT player_name, (season_stats::season_stats).*
FROM unnested




-- Analyze players rating, performance
-- DROP TABLE players_details;

CREATE TYPE scoring_class AS ENUM('star', 'good', 'avg', 'bad');

CREATE TABLE players_details (
player_name TEXT,
height TEXT,
college TEXT,
country TEXT,
draft_year TEXT,
draft_round TEXT,
draft_number TEXT,
season_stats season_stats[],
scoring_class scoring_class,
years_since_last_season INTEGER,
current_season INTEGER,
PRIMARY KEY(player_name, current_season)
);

INSERT INTO players_details
WITH yesterday AS (
SELECT * FROM players_details
-- yesterday 
WHERE current_season = 1999
),
today AS (
	SELECT * FROM player_seasons
	-- today
	WHERE season = 2000
	)
SELECT 
	COALESCE(t.player_name, y.player_name) AS player_name,
	COALESCE(t.height, y.height) AS height,
	COALESCE(t.college, y.college) AS college,
	COALESCE(t.country, y.country) AS country,
	COALESCE(t.draft_year, y.draft_year) AS draft_year,
	COALESCE(t.draft_round, y.draft_round) AS draft_round,
	COALESCE(t.draft_number, y.draft_number) AS draft_number,
CASE WHEN y.season_stats IS NULL
	THEN ARRAY[ROW(
	t.season,
	t.gp,
	t.pts,
	t.reb,
	t.ast
	)::season_stats]
WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[ROW(
	t.season,
	t.gp,
	t.pts,
	t.reb,
	t.ast
	)::season_stats]
ELSE y.season_stats
END as season_stats,
CASE
-- scoring class
	WHEN t.season IS NOT NULL THEN
	CASE WHEN t.pts > 20 THEN 'star'
		WHEN t.pts > 15 THEN 'good'
		WHEN t.pts > 10 THEN 'avg'
		ELSE 'bad'
	END::scoring_class
	-- last year or most recent year scoring class
	ELSE y.scoring_class
END as scoring_class,
CASE
-- current season
	WHEN t.season IS NOT NULL THEN 0
	-- one more year they play
	ELSE y.years_since_last_season + 1
END as years_since_last_season,

	COALESCE(t.season, y.current_season + 1) as current_season
FROM today t FULL OUTER JOIN yesterday y
ON t.player_name = y.player_name;

SELECT * FROM players_details;
SELECT * FROM players_details WHERE current_season = 2000;

SELECT player_name,
	season_stats[1] AS first_season,
	season_stats[CARDINALITY(season_stats)] as latest_season
FROM players_details 
WHERE current_season = 2000;

SELECT player_name,
	(season_stats[1]::season_stats).pts AS first_season,
	(season_stats[CARDINALITY(season_stats)]::season_stats).pts as latest_season
FROM players_details 
WHERE current_season = 2000;

SELECT player_name,
       (season_stats[CARDINALITY(season_stats)]::season_stats).pts /
       CASE WHEN (season_stats[1]::season_stats).pts = 0 THEN 1 ELSE (season_stats[1]::season_stats).pts END AS improved_player_pts
FROM players_details
WHERE current_season = 2000
-- ORDER BY improved_player_pts DESC;

-- Faster because not use of Order by or group by
SELECT player_name,
       (season_stats[CARDINALITY(season_stats)]::season_stats).pts /
       CASE WHEN (season_stats[1]::season_stats).pts = 0 THEN 1 ELSE (season_stats[1]::season_stats).pts END AS improved_player_pts
FROM players_details
WHERE current_season = 2000
AND scoring_class = 'star'