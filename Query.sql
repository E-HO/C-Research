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
ORDER BY interval_start;