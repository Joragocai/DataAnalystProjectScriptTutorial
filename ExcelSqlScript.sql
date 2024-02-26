CREATE DATABASE PortfolioProject;
USE PortfolioProject;

SELECT * FROM covidvaccinations;
SELECT * FROM coviddeaths;

#Chance of death when contract with covid
SELECT location, date, new_cases, total_cases, 
total_deaths, population, 
(total_deaths/total_cases) * 100 AS ChanceOfDeath
FROM coviddeaths
WHERE location LIKE 'phil%'
ORDER BY location, date;

#Chance of getting covid case
SELECT location, date, population, total_cases,
(total_cases/population) * 100 AS ChanceOfCovidCase
FROM coviddeaths
WHERE location LIKE 'phil%'
ORDER BY location, date;

#Finding the country that has the highest infection rate
SELECT location, population,
MAX(total_cases) AS HighestInfectionCount,
MAX(total_cases/population) * 100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

#Showing countries with Highest Death Count per population
SELECT location, 
MAX(CONVERT(total_deaths, DOUBLE)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

#Continent Highest
SELECT continent, 
MAX(CONVERT(total_deaths, DOUBLE)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

#GLOBAL NUMBERS
SELECT SUM(CONVERT(new_cases, DOUBLE)), 
SUM(CONVERT(new_deaths, DOUBLE)),
SUM(CONVERT(new_deaths, DOUBLE))/SUM(CONVERT(new_cases, DOUBLE)) AS GlobalDeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1;

#USE CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, Total_Vac) 
AS 
(
SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations,
SUM(CONVERT(vc.new_vaccinations,DOUBLE))
OVER (PARTITION BY dt.location 
ORDER BY dt.location AND dt.date) AS Total_Vac
FROM coviddeaths dt
JOIN covidvaccinations vc
	ON dt.location = vc.location
    AND
    dt.date = vc.date    
ORDER BY continent ,location, date
)

SELECT *, (Total_Vac/population) * 100
FROM PopvsVac;

#TempTable
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
	continent varchar(255),
    location varchar(255),
    date datetime,
    population int,
    new_vaccinations double,
    Total_Vac double
);

INSERT INTO PercentPopulationVaccinated
SELECT dt.continent, dt.location, dt.date, dt.population, CONVERT(vc.new_vaccinations, DOUBLE) AS new_vaccinations,
SUM(vc.new_vaccinations)
OVER (PARTITION BY dt.location 
ORDER BY dt.location AND dt.date) AS Total_Vac
FROM coviddeaths dt
JOIN covidvaccinations vc
	ON dt.location = vc.location
    AND
    dt.date = vc.date    
ORDER BY continent ,location, date;

SELECT *, (Total_Vac/population) * 100
FROM PercentPopulationVaccinated;

#CREATE VIEW to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations,
SUM(CONVERT(vc.new_vaccinations,DOUBLE))
OVER (PARTITION BY dt.location 
ORDER BY dt.location AND dt.date) AS Total_Vac
FROM coviddeaths dt
JOIN covidvaccinations vc
	ON dt.location = vc.location
    AND
    dt.date = vc.date    
ORDER BY continent ,location, date;

SELECT *
FROM PercentPopulationVaccinated;