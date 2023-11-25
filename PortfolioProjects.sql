-- Selecting Data to Use 
Select 
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population
From `orbital-broker-385207.CovidData.CovidDeaths`
Order by 1,2

-- Looking Total Cases vs Total Deaths
-- Shows the Likelihood of dying if you contracted Covid in your country.
Select
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 as TotalDeathPercentage
From `orbital-broker-385207.CovidData.CovidDeaths`
Where location like 'United States'
Order by 1,2

-- Looking at Total Cases vs. Population
-- Shows what percentage of population got Covid
Select 
  location, 
  date,  
  population, 
  total_cases, 
  (total_cases/population)*100 as TotalDeathPercentage
From `orbital-broker-385207.CovidData.CovidDeaths`
Where location like 'United States'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select 
  location, 
  population, 
  max(total_cases) as HighestInfectionCount, 
  max((total_cases/population))*100 as TotalPercentPopulationInfected
From `orbital-broker-385207.CovidData.CovidDeaths`
--Where location like 'United States'
Group by Location, population
Order by TotalPercentPopulationInfected desc

-- Looking at Countries with Highest Death Count per Population
-- Cast Death Data set as Int

Select 
  location, 
  max(cast(total_deaths as int)) as TotalDeathCount, 
From `orbital-broker-385207.CovidData.CovidDeaths`
--Where location like 'United States'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Beaking things down by continent 
-- Showing Continent with the highest death count per population

Select 
  Continent, 
  max(cast(total_deaths as int)) as TotalDeathCount
From `orbital-broker-385207.CovidData.CovidDeaths`
-- Where location like 'United States'
Where continent is not null
Group by Continent
Order by TotalDeathCount desc

-- Global Numbers 

SELECT
  date,
  sum(new_cases) as TotalCases,
  sum(cast(new_deaths as int)) as TotalDeaths,
  CASE
    WHEN sum(new_cases) = 0 THEN NULL
    ELSE (sum(cast(new_deaths as int)) / sum(new_cases)) * 100.0
  END as TotalDeathPercentage
FROM
  `orbital-broker-385207.CovidData.CovidDeaths`
-- Where location like 'United States'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


SELECT
  --date,
  sum(new_cases) as TotalCases,
  sum(cast(new_deaths as int)) as TotalDeaths,
  CASE
    WHEN sum(new_cases) = 0 THEN NULL
    ELSE (sum(cast(new_deaths as int)) / sum(new_cases)) * 100.0
  END as TotalDeathPercentage
FROM
  `orbital-broker-385207.CovidData.CovidDeaths`
-- Where location like 'United States'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2;


-- looking at Total Population vs Vacinations

SELECT *
from `orbital-broker-385207.CovidData.CovidDeaths` dea
join `orbital-broker-385207.CovidData.CovidVaccinations` vac
  on dea.location = vac.location
  and dea.date = vac.date;

SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations
FROM 
  `orbital-broker-385207.CovidData.CovidDeaths` dea
JOIN 
  `orbital-broker-385207.CovidData.CovidVaccinations` vac
ON 
  dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL
ORDER BY 
  2, 3;

-- Rolling count of people Vaccination 

SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as int)) over
  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM 
  `orbital-broker-385207.CovidData.CovidDeaths` dea
JOIN 
  `orbital-broker-385207.CovidData.CovidVaccinations` vac
ON
  dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  2,3


-- Total Population vs Vacinations
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as int)) over
  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM 
  `orbital-broker-385207.CovidData.CovidDeaths` dea
JOIN 
  `orbital-broker-385207.CovidData.CovidVaccinations` vac
ON
  dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  2,3


-- USE CTE

With PopvsVac as 
(
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as int)) over
  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM 
  `orbital-broker-385207.CovidData.CovidDeaths` dea
JOIN 
  `orbital-broker-385207.CovidData.CovidVaccinations` vac
ON
  dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)* 100
FROM PopvsVac;


--  TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
  Continent nvarchar (225),
  Location nvarchar (225),
  Date datetime,
  population numeric,
  vac.new_vaccinations numeric,
  RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  sum(cast(vac.new_vaccinations as int)) over
  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM 
  `orbital-broker-385207.CovidData.CovidDeaths` dea
JOIN 
  `orbital-broker-385207.CovidData.CovidVaccinations` vac
ON
  dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)* 100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;


-- CTE Instead of table 
WITH PercentPopulationVaccinated AS (
  SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
  `orbital-broker-385207.CovidData.CovidDeaths` dea
JOIN 
  `orbital-broker-385207.CovidData.CovidVaccinations` vac
  ON
    dea.location = vac.location
    AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL
  ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;