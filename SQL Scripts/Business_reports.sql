/*Analyze the Performance of Athletes Across Multiple Editions and Determine Medal Trends
Description: Create a report that shows the total number of medals won by athletes who have participated in at least two editions of the Olympics.
For each athlete, display their name, country, the total medals won, the average position, and a classification based on the total number of medals as 'Exceptional', 'Outstanding', or 'Remarkable'. 
Include athletes' participation and performance details. The total medals should order the results won, and handle cases where some athletes might miss data.*/


WITH Total_medals AS (
    SELECT [athlete_id], athlete, [country_noc], 
           AVG(TRY_CONVERT(INT, Pos)) AS avg_Pos, 
           COUNT(CASE WHEN medal IS NOT NULL THEN 1 ELSE 0 END) AS total_medals
    FROM [dbo].[Olympic_Athlete_Event_Results]
    GROUP BY [athlete_id], athlete, [country_noc]
),
Participation AS (
    SELECT [athlete_id], COUNT(DISTINCT Edition) AS ParticipationCount
    FROM [dbo].[Olympic_Athlete_Event_Results]
    GROUP BY [athlete_id]
    HAVING COUNT(DISTINCT Edition) >= 5
)
SELECT M.athlete_id, M.athlete, M.[country_noc], M.avg_Pos, M.total_medals, P.ParticipationCount,
    CASE 
        WHEN total_medals > 10 THEN 'Exceptional'
        WHEN total_medals > 5 THEN 'Outstanding'
        ELSE 'Remarkable'
    END AS Classification
FROM Total_medals M
JOIN Participation P ON M.athlete_id = P.athlete_id
GROUP BY athlete, country_noc, avg_Pos, total_medals, M.athlete_id, P.ParticipationCount
ORDER BY total_medals;



/*Identify Countries with the Most Consistent Medal Performance
Description: Create a report with the countries that have won medals in every edition they participated in. 
For each country, list the number of editions they participated in, the total number of medals won, and their average medal count per edition. 
Classify the consistency of performance as 'Highly Consistent', 'Moderately Consistent', or 'Inconsistent' based on the ratio of total medals to editions.
Use a dynamic SQL query to display results for either Summer or Winter Olympics based on the input.*/


CREATE PROCEDURE Countries_performance
    @OlympicType NVARCHAR(10)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
    WITH Country_Participation AS (
        SELECT [country_noc], COUNT(DISTINCT Edition) AS Total_Editions
        FROM [dbo].[Olympic_Athlete_Event_Results]
        WHERE OlympicType = @OlympicType
        GROUP BY [country_noc]
    ),
    Country_Medals AS (
        SELECT [country], [medals], COUNT(DISTINCT Edition) AS Editions
        FROM [dbo].[Country_Medal_Count] M
        JOIN [dbo].[Olympic_Games_Medal_Tally] T ON M.[country] = T.[country]
    ),
    
),
    Consistent_Countries AS (
     SELECT P.country_noc,
            P.Total_Editions,
            M.medals, M.Editions
            CAST(M.medals AS FLOAT) / P.Total_Editions AS Avg_Medals_Per_Edition,
            CASE
            WHEN M.Editions = P.Total Editions THEN "Highly Consistent"
            WHEN M.Editions >= (P.TotalEditions * 0.7) THEN "Moderately Consistent" ELSE "Inconsistent"
            END AS Consistency
            FROM Country_Participation P
            INNER JOIN Country_Medals M ON P.Country = M.Country
            WHERE M.Editions P.Total_Editions
            SELECT Country,
            Total_Editions,
            Total_Medals,
            Avg_Medals_Per_Edition,
            Consistency
            FROM Consistent_Countries
            ORDER BY TotalMedals DESC;'
        EXEC sp_executesql @SQL, N'@OlympicType NVARCHAR(10)', @OlympicType = @OlympicType;
    END;



/*Evaluate Athlete's Peak Performance Ages and Their Influence on Medal Wins 
Description: Create a report that finds each athlete's age at the time of their medal wins and determines the age range during which athletes are most likely to win medals.
Categorize the athletes into different age brackets (under 20, 20-24, 25-29, 30-34, 35+) and count the total medals won in each bracket. Also, identify the top sport for each age bracket where athletes have won the most medals.
*/
SELECT 
    CASE 
        WHEN YEAR(g.start_date) - YEAR(a.born) < 20 THEN 'Under 20'
        WHEN YEAR(g.start_date) - YEAR(a.born) BETWEEN 20 AND 24 THEN '20-24'
        WHEN YEAR(g.start_date) - YEAR(a.born) BETWEEN 25 AND 29 THEN '25-29'
        WHEN YEAR(g.start_date) - YEAR(a.born) BETWEEN 30 AND 34 THEN '30-34'
        ELSE '35+'
    END AS age_bracket,
    r.sport,
    COUNT(r.medal) AS total_medals
FROM Olympic_Athlete_Bio a
INNER JOIN Olympic_Athlete_Event_Results r ON a.athlete_id = r.athlete_id
INNER JOIN Olympics_Games g ON r.edition = g.edition
WHERE r.medal IS NOT NULL  
GROUP BY 
    CASE 
        WHEN YEAR(g.start_date) - YEAR(a.born) < 20 THEN 'Under 20'
        WHEN YEAR(g.start_date) - YEAR(a.born) BETWEEN 20 AND 24 THEN '20-24'
        WHEN YEAR(g.start_date) - YEAR(a.born) BETWEEN 25 AND 29 THEN '25-29'
        WHEN YEAR(g.start_date) - YEAR(a.born) BETWEEN 30 AND 34 THEN '30-34'
        ELSE '35+'
    END,
    r.sport
ORDER BY age_bracket, total_medals DESC;
