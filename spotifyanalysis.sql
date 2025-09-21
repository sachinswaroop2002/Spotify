--Retrieve the names of all tracks that have more than 1 billion streams.

SELECT Track FROM spotif
WHERE Stream > 1000000000;

--List all albums along with their respective artists.

SELECT DISTINCT Album, Artist FROM spotif
ORDER BY Artist, Album;

--Get the total number of comments for tracks where licensed = TRUE.
SELECT SUM(Comments) AS Total_Comments FROM spotif
WHERE Licensed = TRUE;

--Find all tracks that belong to the album type single.

SELECT Track FROM spotif
WHERE Album_type = 'single';

--Count the total number of tracks by each artist.

SELECT Artist, COUNT(*) AS Total_Tracks FROM spotif
GROUP BY Artist
ORDER BY Artist;

----------------------------------------------------------------------------------------
--Bussiness Analysis--Category 2----
----------------------------------------------------------------------------------------
-- 1. Calculate the average danceability of tracks in each album.
SELECT Album, AVG(Danceability) AS Avg_Danceability
FROM spotif GROUP BY Album
ORDER BY Album;

-- 2. Find the top 5 tracks with the highest energy values.
SELECT Track, Artist, Energy FROM spotif
ORDER BY Energy DESC
LIMIT 5;

-- 3. List all tracks along with their views and likes where official_video = TRUE.
SELECT Track, Views, Likes FROM spotif
WHERE official_video = TRUE
ORDER BY Track;

-- 4. For each album, calculate the total views of all associated tracks.
SELECT Album, SUM(Views) AS Total_Views FROM spotif
GROUP BY Album
ORDER BY Album;

-- 5. Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT Track FROM spotif
WHERE most_playedon = 'Spotify'
ORDER BY Track;

------------------------------------------------------------------------------------------------
--Bussiness analysis--Category-3--
------------------------------------------------------------------------------------------------
-- 1. Find the top 3 most-viewed tracks for each artist using window functions.
SELECT Artist, Track, COALESCE(Views, 0) AS Views
FROM (
    SELECT Artist, Track, Views,
           ROW_NUMBER() OVER (PARTITION BY Artist ORDER BY COALESCE(Views, 0) DESC, Track) AS View_Rank
    FROM spotif
    WHERE Views IS NOT NULL
) ranked
WHERE View_Rank <= 3
ORDER BY Artist, View_Rank;

-- 2. Write a query to find tracks where the liveness score is above the average.
WITH AvgLiveness AS (
    SELECT AVG(COALESCE(Liveness, 0)) AS Avg_Liveness
    FROM spotif
)
SELECT Track, Artist, Liveness
FROM spotif
WHERE Liveness > (SELECT Avg_Liveness FROM AvgLiveness)
  AND Liveness IS NOT NULL
ORDER BY Liveness DESC;

-- 3. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH AlbumEnergy AS (
    SELECT Album,
           MAX(COALESCE(Energy, 0)) AS Max_Energy,
           MIN(COALESCE(Energy, 0)) AS Min_Energy
    FROM spotif
    WHERE Energy IS NOT NULL
    GROUP BY Album
)
SELECT Album, Max_Energy, Min_Energy, (Max_Energy - Min_Energy) AS Energy_Difference
FROM AlbumEnergy
ORDER BY Album;