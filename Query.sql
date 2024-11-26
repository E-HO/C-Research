-- Idea 1 :
SELECT
    -- Convert the time into seconds and determines how many intervals of 30 have elapsed since the unix time.
    -- Then convert them back into a readable time to group and count results
    datetime(strftime('%s', timestamp) / 1800 * 1800, 'unixepoch') AS interval_start,
    COUNT(*) AS count
FROM wikimedia_changes
GROUP BY interval_start
-- Ok for interval of 30 minutes, but unable to apply it for 15 minutes of delays
-- UNION ALL
-- SELECT
--   datetime(strftime('%s', timestamp) / 1800 * 1800 + 900, 'unixepoch') AS interval_start,
--   COUNT(*) AS count
-- FROM wikimedia_changes
-- GROUP BY interval_start
ORDER BY count DESC;


-- Idea 2
SELECT
    -- timestamp,
    strftime('%H',timestamp) AS Hour,
    -- unixepoch(timestamp) % 3600 / 60 AS Minutes,
    CASE
        WHEN unixepoch(timestamp) % 3600 / 60 >= 15 AND unixepoch(timestamp) % 3600 / 60 < 45 THEN 15
        ELSE 45
    END Bucket,
    COUNT(*) AS count
FROM wikimedia_changes
GROUP BY Hour, bucket
ORDER BY count DESC;
