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

top_10_volume_players AS (
  SELECT player
  FROM base_shots
  GROUP BY player
  ORDER BY COUNT(*) DESC
  LIMIT 10
),

categorized_shots AS (
  SELECT
    b.player,
    b.team,
    b.is_made,
    b.points_earned,
    CASE
      WHEN b.clean_desc LIKE '%layup%' OR b.clean_desc LIKE '%dunk%' OR b.clean_desc LIKE '%tip%' THEN '1. Restricted Area (0-4ft)'
      WHEN b.clean_desc LIKE '%3pt%' AND (b.clean_desc LIKE '%left side%' OR b.clean_desc LIKE '%left corner%') THEN '4. Left Corner 3'
      WHEN b.clean_desc LIKE '%3pt%' AND (b.clean_desc LIKE '%right side%' OR b.clean_desc LIKE '%right corner%') THEN '5. Right Corner 3'
      WHEN b.clean_desc LIKE '%3pt%' THEN '6. Above-the-Break 3'
      WHEN b.clean_desc LIKE '%floating%' OR b.clean_desc LIKE '%hook%' OR b.clean_desc LIKE '%bank%' THEN '2. Paint / Short Mid (5-14ft)'
      ELSE '3. Long Mid-Range (15ft+)'
    END AS spatial_zone
  FROM base_shots b
  INNER JOIN top_10_volume_players t ON b.player = t.player
),

player_zone_metrics AS (
  SELECT
    player,
    spatial_zone,
    COUNT(*) AS fga,
    SUM(is_made) AS fgm,
    ROUND(SUM(is_made) / COUNT(*), 3) AS fg_pct,
    ROUND((SUM(is_made) + (0.5 * COUNTIF(points_earned = 3))) / COUNT(*), 3) AS efg_pct,
    ROUND(SUM(points_earned) / COUNT(*), 3) AS pps
  FROM categorized_shots
  GROUP BY player, spatial_zone
  HAVING fga >= 10
)

SELECT
  spatial_zone,
  DENSE_RANK() OVER (PARTITION BY spatial_zone ORDER BY efg_pct DESC) AS zone_efficiency_rank,
  player,
  fga,
  fgm,
  efg_pct,
  pps
FROM player_zone_metrics
ORDER BY spatial_zone, zone_efficiency_rank;
