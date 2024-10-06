--Create a new table to store the average height and weight of athletes by country.
CREATE TABLE Athlete_Avg_Stats (
    country_noc VARCHAR(3),
    avg_height DECIMAL(5,2),
    avg_weight DECIMAL(5,2)
);

--Insert a new record into the Olympics_Country table for a newly recognized country.
INSERT INTO Olympics_Country (noc, country)
VALUES ('NEW', 'Newland');

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

--Create a new table called ‘Country_Medal_Count’ with the total number of medals won by each country and insert the data.
SELECT country_noc, SUM(CASE WHEN medal IS NOT NULL THEN 1 ELSE 0 END) AS total_medals
INTO Country_Medal_Count
FROM Olympic_Athlete_Event_Results
GROUP BY country_noc;


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


--Create a stored procedure to get the medal tally for a specific country and year.
CREATE PROCEDURE GetMedalTally @country_noc VARCHAR(3), @year INT
AS
BEGIN
    SELECT SUM(gold + silver + bronze) AS total_medals
    FROM Olympic_Games_Medal_Tally
    WHERE country_noc = @country_noc AND year = @year;
END;

--Store the total number of medals won by a specific country -ex: ‘USA’- in a variable.
DECLARE @total_medals INT;
SELECT @total_medals = SUM(gold + silver + bronze)
FROM Olympic_Games_Medal_Tally
WHERE country_noc = 'USA';

--Create a dynamic SQL statement to retrieve medal data for a specific sport.
DECLARE @sql NVARCHAR(MAX) = 'SELECT * FROM Olympic_Athlete_Event_Results WHERE sport = ''Basketball''';
EXEC sp_executesql @sql;

--Check if a country has won more than 50 medals then print the country name and ‘High Medal Count’, if not, print ‘Low Medal Count’ behind the country name.
SELECT country_noc,
    CASE 
        WHEN total >= 50 THEN CONCAT(country_noc, ' - High Medal Count')
        ELSE CONCAT(country_noc, ' - Low Medal Count')
    END AS medal_status
FROM Olympic_Games_Medal_Tally;

--Loop through each athlete in a list and print their name along with their country.
DECLARE athlete_cursor CURSOR FOR
SELECT name, country_noc FROM Olympic_Athlete_Bio;

OPEN athlete_cursor;
FETCH NEXT FROM athlete_cursor INTO @name, @country_noc;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @name + ' - ' + @country_noc;
    FETCH NEXT FROM athlete_cursor INTO @name, @country_noc;
END;

CLOSE athlete_cursor;
DEALLOCATE athlete_cursor;



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

--Create a stored procedure UpdateAthleteInfo that takes an athlete's ID, a column name, and a new value as input parameters. It updates the specified column for the given athlete with the new value.
CREATE PROCEDURE UpdateAthleteInfo 
    @athlete_id INT, 
    @column_name NVARCHAR(50), 
    @new_value NVARCHAR(MAX)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = 'UPDATE Olympic_Athlete_Bio SET ' + @column_name + ' = ''' + @new_value + ''' WHERE athlete_id = ' + CAST(@athlete_id AS NVARCHAR);
    EXEC sp_executesql @sql;
END;

--Create a stored procedure GetAthletesByMedalType that takes a medal type as an input parameter and dynamically generates a report of athletes who have won that type of medal.
CREATE PROCEDURE GetAthletesByMedalType @medal_type VARCHAR(6)
AS
BEGIN
    SELECT athlete, medal
    FROM Olympic_Athlete_Event_Results
    WHERE medal = @medal_type;
END;

