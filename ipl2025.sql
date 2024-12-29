Select * from iplplayers

-- Q1 : Find the total spending on players for each team;
SELECT Team, SUM(Price_in_cr) AS TotalSpending
FROM iplplayers
GROUP BY Team
ORDER BY TotalSpending DESC;

-- Q2: Find the top 3 highest-paid "All-Rounders" accross all teams.
SELECT Player, Team, Price_in_cr
FROM iplplayers
WHERE Role = 'All-Rounder'
ORDER BY Price_in_cr DESC
LIMIT 3;

-- Q3 : Find the highest- priced player in each team
WITH CTE_HP AS (
    SELECT Team, MAX(Price_in_cr) AS MaxPrice
    FROM iplplayers
    GROUP BY Team
)
SELECT i.Player, i.Team, hp.MaxPrice
FROM iplplayers i
JOIN CTE_HP hp ON i.Team = hp.Team
WHERE i.Price_in_cr = hp.MaxPrice 
ORDER BY MaxPrice DESC

-- Q4 : Rank Players by their Price within each team and list the top 2 for every team.
WITH RankedPlayer AS (
    SELECT Player, Team, Price_in_cr,
           ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS RankwithinTeam
    FROM iplplayers
)
SELECT Player, Team, Price_in_cr, RankwithinTeam
FROM RankedPlayer
WHERE RankwithinTeam <= 2;

--  Q5 : Find the most expensive player from each team along with the second most expensive palyer's name and price
Select * from iplplayers
WITH RankedPlayer AS (
    SELECT Player, Team, Price_in_cr,
           ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS RankwithinTeam
    FROM iplplayers
)
SELECT Team,
       MAX(CASE WHEN RankwithinTeam = 1 THEN Player ELSE NULL END) AS MostExpensivePlayer,
       MAX(CASE WHEN RankwithinTeam = 1 THEN Price_in_cr ELSE NULL END) AS HighestPrice,
       MAX(CASE WHEN RankwithinTeam = 2 THEN Player ELSE NULL END) AS SecondMostExpensivePlayer,
       MAX(CASE WHEN RankwithinTeam = 2 THEN Price_in_cr ELSE NULL END) AS SecondHighestPrice
FROM RankedPlayer
GROUP BY Team;


-- Q6 Calulate the percentage contribution of each player's price to their teams total spending
SELECT Player, Team, Price_in_cr,
       CAST((Price_in_cr / SUM(Price_in_cr) OVER (PARTITION BY Team)) * 100 AS DECIMAL(10, 2)) AS ContributionPercent
FROM iplplayers;




-- Q7 : Classify Players as "High" , "MEdium" or "Low" priced based on the following rules:
-- High Price >15Crore
-- Medium Price between 5crore and 15 Crore
-- Low Price <5 Crore and find out players in each bracket
WITH CTE_PC AS( 
SELECT Team, Player, Price_in_cr,
       CASE
           WHEN Price_in_cr > 15 THEN 'High'
           WHEN Price_in_cr BETWEEN 5 AND 15 THEN 'Medium'
           ELSE 'Low'
       END AS PriceCategory
FROM iplplayers
)
SELECT TEAM, PriceCategory, COUNT(*) AS NumofPLayers
FROM CTE_PC 
GROUP BY Team, PriceCategory
ORDER BY Team, PriceCategory


-- Q8 Find the Average price of Indian Players and compare it with overseas Players
SELECT 'Indian' AS PlayerType,
       (SELECT AVG(Price_in_cr)
        FROM iplplayers
        WHERE Type LIKE 'Indian%') AS AveragePrice
UNION ALL
SELECT 'Overseas' AS PlayerType,
       (SELECT AVG(Price_in_cr)
        FROM iplplayers
        WHERE Type LIKE 'Overseas%') AS AveragePrice;
        

-- Q9: Identfy Palyers who earn more than the average price in their team
SELECT Player, Team, Price_in_cr
FROM iplplayers AS p
WHERE Price_in_cr > (
    SELECT AVG(Price_in_cr)
    FROM iplplayers
    WHERE Team = p.Team
);


-- Q10: For each Role, find the most expensive player and their price using a corelated subquery 
SELECT Player, Team, Role, Price_in_cr
FROM iplplayers AS p1
WHERE Price_in_cr = (
    SELECT MAX(Price_in_cr)
    FROM iplplayers
    WHERE Role = p1.Role
);




 
