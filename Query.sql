-- Idea 1 :
SELECT
    -- Convert the time into seconds and determines how many intervals of 30 have elapsed since the unix time.
    -- Then convert them back into a readable time to group and count results. Simply said like the principle of "modulo"
    datetime(strftime('%s', timestamp) / 1800 * 1800, 'unixepoch') AS interval_start,
    COUNT(*) AS count
FROM wikimedia_changes
GROUP BY interval_start
-- Ok for interval of 30 minutes, but unable to apply it the same way for 15 minutes of delays
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

-- Idea 3
-- Based on Idea 2, on SQL Server could have used DATE_BUCKET() for something similar but more broad on period (week, day, hour, ...)
-- https://learn.microsoft.com/en-us/sql/t-sql/functions/date-bucket-transact-sql?view=sql-server-ver16

-- Show the number of changes made per page, ordered by what have more changes
SELECT
    pageid, COUNT(*) AS count
FROM wikimedia_changes
GROUP BY pageid
ORDER BY count DESC;


-- Show how many pages are changed
SELECT COUNT(DISTINCT pageid) AS count
FROM wikimedia_changes;