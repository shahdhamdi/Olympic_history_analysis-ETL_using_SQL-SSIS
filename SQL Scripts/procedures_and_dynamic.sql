--Create a stored procedure to get the medal tally for a specific country and year.
CREATE PROCEDURE Get_Medal_Tally @country_noc VARCHAR(3), @year INT
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



--Create a stored procedure UpdateAthleteInfo that takes an athlete's ID, a column name, and a new value as input parameters. It updates the specified column for the given athlete with the new value.
CREATE PROCEDURE Update_Athlete_Info 
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
CREATE PROCEDURE Athletes_by_Medal_Type @medal_type VARCHAR(6)
AS
BEGIN
    SELECT athlete, medal
    FROM Olympic_Athlete_Event_Results
    WHERE medal = @medal_type;
END;

