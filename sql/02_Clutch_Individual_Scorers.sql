WITH clutch_events AS (
  SELECT
    game_id,
    eventnum,
    period,
    pctimestring,
    player1_name AS primary_player,
    player2_name AS secondary_player,
    player1_team_abbreviation AS team,
    COALESCE(homedescription, visitordescription) AS play_desc,
    CASE 
      -- 3-Pointer Field Goal
      WHEN eventmsgtype = 1 AND LOWER(COALESCE(homedescription, visitordescription)) LIKE '%3pt%' THEN 3 
      -- 2-Pointer Field Goal
      WHEN eventmsgtype = 1 THEN 2 
      -- Made Free Throw (each is worth 1 point)
      WHEN eventmsgtype = 3 AND LOWER(COALESCE(homedescription, visitordescription)) LIKE '%good%' THEN 1
      ELSE 0
    END AS points_scored
  FROM `thematic-coda-505812-a0.nba_analytics.play_by_play`
  WHERE period >= 4
    AND eventmsgtype IN (1, 3) -- Field goals and Free Throws
    AND (
      scoremargin = 'TIE' 
      OR SAFE_CAST(scoremargin AS INT64) BETWEEN -5 AND 5
    )
)

SELECT
  primary_player,
  team,
  COUNT(CASE WHEN points_scored > 0 THEN 1 END) AS total_clutch_scoring_plays,
  SUM(points_scored) AS total_clutch_points,
  COUNTIF(secondary_player IS NOT NULL) AS assisted_clutch_buckets
FROM clutch_events
WHERE primary_player IS NOT NULL AND points_scored > 0
GROUP BY primary_player, team
HAVING total_clutch_points >= 15
ORDER BY total_clutch_points DESC
LIMIT 10;
