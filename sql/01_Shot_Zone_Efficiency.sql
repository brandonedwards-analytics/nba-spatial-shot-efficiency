WITH parsed_shots AS (
  SELECT
    game_id,
    eventnum,
    COALESCE(homedescription, visitordescription) AS play_desc,
    LOWER(COALESCE(homedescription, visitordescription)) AS clean_desc,
    eventmsgtype,
    CASE WHEN eventmsgtype = 1 THEN 1 ELSE 0 END AS is_made,
    CASE 
      WHEN eventmsgtype = 1 AND LOWER(COALESCE(homedescription, visitordescription)) LIKE '%3pt%' THEN 3
      WHEN eventmsgtype = 1 THEN 2
      ELSE 0
    END AS points_earned
  FROM `thematic-coda-505812-a0.nba_analytics.play_by_play`
  WHERE eventmsgtype IN (1, 2)
),

categorized_zones AS (
  SELECT
    *,
    CASE
      -- 1. Restricted Area / Rim
      WHEN clean_desc LIKE '%layup%' OR clean_desc LIKE '%dunk%' OR clean_desc LIKE '%tip%' THEN '1. Restricted Area (0-4ft)'
      
      -- 2. Corner 3s vs Above-the-Break 3s
      WHEN clean_desc LIKE '%3pt%' AND (clean_desc LIKE '%left side%' OR clean_desc LIKE '%left corner%') THEN '4. Left Corner 3'
      WHEN clean_desc LIKE '%3pt%' AND (clean_desc LIKE '%right side%' OR clean_desc LIKE '%right corner%') THEN '5. Right Corner 3'
      WHEN clean_desc LIKE '%3pt%' THEN '6. Above-the-Break 3'
      
      -- 3. Paint & Mid-Range Split
      WHEN clean_desc LIKE '%floating%' OR clean_desc LIKE '%hook%' OR clean_desc LIKE '%bank%' THEN '2. Paint / Short Mid (5-14ft)'
      ELSE '3. Long Mid-Range (15ft+)'
    END AS spatial_zone
  FROM parsed_shots
)

SELECT
  spatial_zone,
  COUNT(*) AS total_fga,
  SUM(is_made) AS total_fgm,
  SUM(CASE WHEN clean_desc LIKE '%3pt%' AND is_made = 1 THEN 1 ELSE 0 END) AS total_3pm,
  SUM(points_earned) AS total_points,
  ROUND(SAFE_DIVIDE(SUM(is_made) + (0.5 * SUM(CASE WHEN clean_desc LIKE '%3pt%' AND is_made = 1 THEN 1 ELSE 0 END)), COUNT(*)), 3) AS eFG_pct,
  ROUND(SAFE_DIVIDE(SUM(points_earned), COUNT(*)), 3) AS PPS
FROM categorized_zones
GROUP BY spatial_zone
ORDER BY eFG_pct DESC;
