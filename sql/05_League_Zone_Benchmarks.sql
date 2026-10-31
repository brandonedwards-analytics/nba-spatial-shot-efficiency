WITH base_shots AS (
  SELECT
    player1_name AS player,
    player1_team_abbreviation AS team,
    eventmsgtype,
    COALESCE(homedescription, visitordescription) AS play_desc,
    LOWER(COALESCE(homedescription, visitordescription)) AS clean_desc,
    CASE WHEN eventmsgtype = 1 THEN 1 ELSE 0 END AS is_made,
    CASE 
      WHEN eventmsgtype = 1 AND LOWER(COALESCE(homedescription, visitordescription)) LIKE '%3pt%' THEN 3
      WHEN eventmsgtype = 1 THEN 2
      ELSE 0
    END AS points_earned
  FROM `thematic-coda-505812-a0.nba_analytics.play_by_play`
  WHERE eventmsgtype IN (1, 2)
    AND player1_name IS NOT NULL
),

categorized_shots AS (
  SELECT
    player,
    team,
    is_made,
    points_earned,
    CASE
      WHEN clean_desc LIKE '%layup%' OR clean_desc LIKE '%dunk%' OR clean_desc LIKE '%tip%' THEN '1. Restricted Area (0-4ft)'
      WHEN clean_desc LIKE '%3pt%' AND (clean_desc LIKE '%left side%' OR clean_desc LIKE '%left corner%') THEN '4. Left Corner 3'
      WHEN clean_desc LIKE '%3pt%' AND (clean_desc LIKE '%right side%' OR clean_desc LIKE '%right corner%') THEN '5. Right Corner 3'
      WHEN clean_desc LIKE '%3pt%' THEN '6. Above-the-Break 3'
      WHEN clean_desc LIKE '%floating%' OR clean_desc LIKE '%hook%' OR clean_desc LIKE '%bank%' THEN '2. Paint / Short Mid (5-14ft)'
      ELSE '3. Long Mid-Range (15ft+)'
    END AS spatial_zone
  FROM base_shots
),

player_zone_metrics AS (
  SELECT
    spatial_zone,
    player,
    COUNT(*) AS fga,
    SUM(is_made) AS fgm,
    ROUND(SUM(is_made) / COUNT(*), 3) AS fg_pct,
    ROUND((SUM(is_made) + (0.5 * COUNTIF(points_earned = 3))) / COUNT(*), 3) AS efg_pct,
    ROUND(SUM(points_earned) / COUNT(*), 3) AS pps
  FROM categorized_shots
  GROUP BY spatial_zone, player
  HAVING fga >= 1000 -- Strict 1,000 FGA threshold to isolate high-volume regulars
),

ranked_specialists AS (
  SELECT
    spatial_zone,
    DENSE_RANK() OVER (PARTITION BY spatial_zone ORDER BY efg_pct DESC) AS zone_rank,
    player,
    fga,
    fgm,
    efg_pct,
    pps
  FROM player_zone_metrics
)

SELECT *
FROM ranked_specialists
WHERE zone_rank <= 5
ORDER BY spatial_zone, zone_rank;
