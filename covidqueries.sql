-- Looking at total cases vs total deaths
-- Shows likelihood of dying if covid is contracted in a country

SELECT Location, date, total_cases, ROUND((total_deaths/total_cases) * 100, 2) as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%states%'
ORDER BY 1, 2;

-- Looking at total cases vs population
-- Shows what percentage of population got covid

SELECT Location, date, total_cases, Population, ROUND((total_cases/Population) * 100, 4) as CasePercentageOfPopulation
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location like '%states%'
ORDER BY 1, 2;

-- Show countries with highest infection rate compared to population

SELECT Location, MAX(total_cases) as HighestInfectionCount, Population, ROUND((MAX(total_cases)/Population) * 100, 4) as PercentOfPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
GROUP BY Location, Population
ORDER BY PercentOfPopulationInfected DESC;


-- Show the countries with the highest death counts

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Location NOT IN ('World', 'Europe', 'South America', 'North America', 'Asia', 'Africa', 'European Union')
GROUP BY Location
ORDER BY TotalDeathCount DESC;


-- Digging into differences in deaths across continents

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Location IN ('Europe', 'South America', 'North America', 'Asia', 'Africa', 'European Union', 'Oceania')
GROUP BY Location
ORDER BY TotalDeathCount DESC;

-- Global numbers
SELECT date, sum(new_cases) AS total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

SELECT date, 
	sum(new_cases) AS total_new_cases, 
	sum(cast(new_deaths as int)) as total_new_deaths, 
	ROUND(sum(cast(new_deaths as int)) / sum(new_cases) * 100, 2) as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


-- Looking at total vaccinations vs population
WITH PopVsVac(Continent, location, date, population, new_vaccinations, rolling_vaccinations)
as
(SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	va.new_vaccinations,
	SUM(CONVERT(int, va.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM PortfolioProject.dbo.CovidDeaths$ dea
	JOIN PortfolioProject.dbo.CovidVaccinations$ va
	ON dea.location = va.location
	AND dea.date = va.date
WHERE dea.continent IS NOT NULL
)

SELECT *, ROUND((rolling_vaccinations / population) * 100, 4)
FROM PopVsVac;

-- Use temp table
DROP TABLE IF EXISTS PercentPopulationVaccinated

CREATE TABLE PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date DateTime,
Population int,
new_vaccinations int,
rolling_vaccinations int,
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	va.new_vaccinations,
	SUM(CONVERT(int, va.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM PortfolioProject.dbo.CovidDeaths$ dea
	JOIN PortfolioProject.dbo.CovidVaccinations$ va
	ON dea.location = va.location
	AND dea.date = va.date
WHERE dea.continent IS NOT NULL;

SELECT *, ROUND((rolling_vaccinations / population) * 100, 4)
FROM PercentPopulationVaccinated;

-- Creating view to store data for future visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	va.new_vaccinations,
	SUM(CONVERT(int, va.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM PortfolioProject.dbo.CovidDeaths$ dea
	JOIN PortfolioProject.dbo.CovidVaccinations$ va
	ON dea.location = va.location
	AND dea.date = va.date
WHERE dea.continent IS NOT NULL;