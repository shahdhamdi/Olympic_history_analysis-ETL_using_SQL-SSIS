--Find all distinct sports from the Olympic_Results table where the number of participants is greater than 20.
SELECT DISTINCT sport
FROM Olympic_Results
WHERE result_participants > 20;


--Classify athletes' performance in Olympic_Athlete_Event_Results as 'Winner', 'Runner-up', 'Finalist', or 'Participant' based on their position.
--(1 = Winner, 2 = Runner-Up, less than or equal 8 = Finalist, other is Participant).
SELECT athlete, pos,
    CASE
        WHEN pos = 1 THEN 'Winner'
        WHEN pos = 2 THEN 'Runner-up'
        WHEN pos <= 8 THEN 'Finalist'
        ELSE 'Participant'
    END AS performance
FROM Olympic_Athlete_Event_Results;


--Retrieve the top 10 events with the most participants, ordered by the number of participants in descending order.
SELECT TOP 10 event_title, result_participants
FROM Olympic_Results
ORDER BY result_participants DESC;


--Get the top 5 athletes who have won the most medals.
SELECT TOP 5 athlete, COUNT(medal) AS medal_count
FROM Olympic_Athlete_Event_Results
WHERE medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY athlete
ORDER BY medal_count DESC;

--Replace null values in the description column of Olympic_Athlete_Bio with 'No description available'. (Use SELECT)
SELECT athlete_id, ISNULL(description, 'No description available') AS description
FROM Olympic_Athlete_Bio;

--Convert the born date in Olympic_Athlete_Bio to the year only.
SELECT athlete_id, YEAR(born) AS birth_year
FROM Olympic_Athlete_Bio;

--Retrieve the athlete name and their country in one column.
SELECT CONCAT(name, ' - ', country) AS athlete_country
FROM Olympic_Athlete_Bio;


--Retrieve the first three letters of the athletes' names in uppercase.
SELECT UPPER(LEFT(name, 3)) AS name_initials
FROM Olympic_Athlete_Bio;

--Find the current date and time of the server as current_datetime.
SELECT GETDATE() AS current_datetime;


--Find the total number of medals won by each country that has won more than 10 medals.
SELECT country_noc, SUM(CASE WHEN medal IS NOT NULL THEN 1 ELSE 0 END) AS total_medals
FROM Olympic_Athlete_Event_Results
GROUP BY country_noc
HAVING SUM(CASE WHEN medal IS NOT NULL THEN 1 ELSE 0 END) > 10;

--Rank athletes within each sport by the number of medals won.
SELECT athlete, sport, RANK() OVER (PARTITION BY sport ORDER BY COUNT(medal) DESC) AS rank
FROM Olympic_Athlete_Event_Results
WHERE medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY athlete, sport;

--Classify countries based on total medals won as 'High', 'Medium', or 'Low'.
--(more than 50 = ‘High’, between 20 and 50 = ‘Medium, other = ‘Low’).
SELECT country_noc, 
    CASE
        WHEN total >= 50 THEN 'High'
        WHEN total BETWEEN 20 AND 49 THEN 'Medium'
        ELSE 'Low'
    END AS classification
FROM Olympic_Games_Medal_Tally;

--Check if a country has won more than 50 medals then print the country name and ‘High Medal Count’, if not, print ‘Low Medal Count’ behind the country name.
SELECT country_noc,
    CASE 
        WHEN total >= 50 THEN CONCAT(country_noc, ' - High Medal Count')
        ELSE CONCAT(country_noc, ' - Low Medal Count')
    END AS medal_status
FROM Olympic_Games_Medal_Tally;

--Loop through each athlete in a list and print their name along with their country.
DECLARE @name NVARCHAR(255);
DECLARE @country_noc NVARCHAR(10);
DECLARE @counter INT = 1;
DECLARE @totalRows INT;


SELECT @totalRows = COUNT(*) FROM Olympic_Athlete_Bio;
WHILE @counter <= @totalRows
BEGIN
    SELECT @name = name, @country_noc = country_noc 
    FROM (
        SELECT name, country_noc, ROW_NUMBER() OVER (ORDER BY name) AS RowNum
        FROM Olympic_Athlete_Bio
    ) AS AthleteList
    WHERE RowNum = @counter;
    PRINT @name + ' - ' + @country_noc;
    SET @counter = @counter + 1;
END;

--Find the athletes who have participated in more than one edition of the Olympics.
SELECT athlete, COUNT(DISTINCT edition) AS edition_count
FROM Olympic_Athlete_Event_Results
GROUP BY athlete
HAVING COUNT(DISTINCT edition) > 1;

--List the athletes who have won medals in both Summer and Winter Olympics.
SELECT athlete
FROM Olympic_Athlete_Event_Results
WHERE medal IS NOT NULL
GROUP BY athlete
HAVING SUM(CASE WHEN sport IN ('Summer Sports') THEN 1 ELSE 0 END) > 0
AND SUM(CASE WHEN sport IN ('Winter Sports') THEN 1 ELSE 0 END) > 0;
