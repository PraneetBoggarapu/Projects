-- Dates from 24/02/2020 to 5/04/2022

-- selecting Total data
SELECT * 
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM PortfolioProject1..CovidVaccinations 
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Data used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases Vs total Deaths
-- Indicates the Percentage chance of dying if infected with covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE 'India'
AND continent IS NOT NULL
ORDER BY 1,2

-- Total cases Vs Population
-- Indicates the Percentage of population infected with COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPopulation
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE 'India'
AND continent IS NOT NULL
ORDER BY 1,2

-- Worldwide Infected Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPopulation
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Countries with Highest Infection
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS InfectedPopulation
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with highest death count 
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Highest Death Count By continent
--SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
--FROM PortfolioProject1..CovidDeaths
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC

-- WRONG method but using for visualisation 
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE location IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global total death percentage
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS bigint)) AS TotalDeaths, SUM(CAST(new_deaths AS bigint))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total death percentage in the world till now  (death % = % of chance of dying if infected)
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS bigint)) AS TotalDeaths, SUM(CAST(new_deaths AS bigint))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Population Vs Vaccinatoions
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
FROM PortfolioProject1..CovidDeaths cd
JOIN PortfolioProject1..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE
WITH PopVsVac (Continent, LLocation, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths cd
JOIN PortfolioProject1..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac


-- TEMP Table
DROP Table if exists #PercentPopulationVaccinated
CREATE Table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths cd
JOIN PortfolioProject1..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to tore data for visualizations later
CREATE VIEW PercentPopulationVaccinated
AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths cd
JOIN PortfolioProject1..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL


SELECT * 
FROM PercentPopulationVaccinated






-- Queries used for Tableau 

-- 1. 
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS bigint)) AS total_deaths, SUM(cast(new_deaths AS bigint))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(cast(new_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3.

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- 4.


SELECT Location, Population, date, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC
