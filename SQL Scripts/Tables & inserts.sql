--Create a new table to store the average height and weight of athletes by country.
CREATE TABLE Athlete_Avg_Stats (
    country_noc VARCHAR(3),
    avg_height DECIMAL(5,2),
    avg_weight DECIMAL(5,2)
);

--Insert a new record into the Olympics_Country table for a newly recognized country.
INSERT INTO Olympics_Country (noc, country)
VALUES ('NEW', 'Newland');

--Create a new table called ‘Country_Medal_Count’ with the total number of medals won by each country and insert the data.
SELECT country_noc, SUM(CASE WHEN medal IS NOT NULL THEN 1 ELSE 0 END) AS total_medals
INTO Country_Medal_Count
FROM Olympic_Athlete_Event_Results
GROUP BY country_noc;
