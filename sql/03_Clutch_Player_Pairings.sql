WITH clutch_events AS (
  SELECT
    game_id,
    eventnum,
    period,
    pctimestring,
    player1_name AS scorer,
    player2_name AS assister,
    player1_team_abbreviation AS team,
    COALESCE(homedescription, visitordescription) AS play_desc,
    CASE 
      WHEN eventmsgtype = 1 AND LOWER(COALESCE(homedescription, visitordescription)) LIKE '%3pt%' THEN 3 
      WHEN eventmsgtype = 1 THEN 2 
      WHEN eventmsgtype = 3 AND LOWER(COALESCE(homedescription, visitordescription)) LIKE '%good%' THEN 1
      ELSE 0
    END AS points_scored
  FROM `thematic-coda-505812-a0.nba_analytics.play_by_play`
  WHERE period >= 4
    AND eventmsgtype IN (1, 3)
    AND (
      scoremargin = 'TIE' 
      OR SAFE_CAST(scoremargin AS INT64) BETWEEN -5 AND 5
    )
)

SELECT
  assister,
  scorer,
  team,
  COUNT(CASE WHEN points_scored > 0 THEN 1 END) AS clutch_assisted_buckets,
  SUM(points_scored) AS total_assisted_clutch_points
FROM clutch_events
WHERE assister IS NOT NULL 
  AND scorer IS NOT NULL 
  AND points_scored > 0
GROUP BY assister, scorer, team
HAVING clutch_assisted_buckets >= 5
ORDER BY total_assisted_clutch_points DESC
LIMIT 10;
