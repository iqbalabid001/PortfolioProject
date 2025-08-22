SELECT *
FROM portfolioproject.coviddeaths
where continent is not null
ORDER BY 3,4

-- Select *
-- From portfolioproject.covidvaccinations 
-- order by 3,4

-- select data that we are going to be using

SELECT location , `date`, total_cases, new_cases, total_deaths, population 
FROM portfolioproject.coviddeaths
where continent is not null
ORDER BY 1,2

-- Looking at the Total cases Vs Total deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location , `date`, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM portfolioproject.coviddeaths
where location like '%states%'
ORDER BY 1,2

-- looking at Total Cases Vs Population
-- shows what perchantage of population got Covid
SELECT location , `date`, total_cases, population, (total_deaths/population) * 100 as PercentPolulationInfected
FROM portfolioproject.coviddeaths
where location like '%states%'
ORDER BY 1,2

-- looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as PercentPolulationInfected
FROM portfolioproject.coviddeaths
-- where location like '%states%'
group by population, location 
ORDER BY PercentPolulationInfected desc

-- showing countries with highest death count per Population
SELECT location, MAX(CAST(total_deaths as UNSIGNED)) as TotalDeathCount
FROM portfolioproject.coviddeaths
-- where location like '%states%'
where continent is not null
group by location 
ORDER BY TotalDeathCount desc

-- now let's break things down by continent
-- showing continents with highest death per population
SELECT continent, MAX(CAST(total_deaths as UNSIGNED)) as TotalDeathCount
FROM portfolioproject.coviddeaths
-- where location like '%states%'
where continent is not null 
group by continent 
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT
    `date` ,
    SUM(new_cases) as TotalCases,
    SUM(CAST(new_deaths AS UNSIGNED)) as TotalDeaths,
    (SUM(CAST(new_deaths AS UNSIGNED)) / SUM(new_cases)) * 100 as DeathPercentage
FROM
    portfolioproject.coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY
    date
ORDER BY
    TotalCases, TotalDeaths
    

-- Looking at total population Vs vaccination
SELECT
    dea.continent,
    dea.location,
    dea.`date`,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.`date`) as RollingPeopleVaccinated
FROM
    portfolioproject.coviddeaths dea
JOIN
    portfolioproject.covidvaccinations vac
ON
    dea.location = vac.location
    AND dea.`date` = vac.`date`
WHERE
    dea.continent IS NOT NULL
ORDER BY
    dea.location, dea.date
    
    
-- USE CTE   

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT
    dea.continent,
    dea.location,
    dea.`date`,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.`date`) as RollingPeopleVaccinated
FROM
    portfolioproject.coviddeaths dea
LEFT JOIN
    portfolioproject.covidvaccinations vac
ON
    dea.location = vac.location
    AND dea.`date` = vac.`date`
WHERE
    dea.continent IS NOT NULL
-- ORDER BY
  --  dea.location, dea.date
)
select *, (rollingpeoplevaccinated/population) * 100 
from PopVsVac 


-- TEMP TABLE

-- DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    Continent VARCHAR(255),
    Location VARCHAR(255),
    `date` DATE,
    Population BIGINT,
    New_Vaccinations INT,
    RollingPeopleVaccinated BIGINT
);


INSERT INTO PercentPopulationVaccinated
(Continent, Location, `date`, Population, New_Vaccinations, RollingPeopleVaccinated)
SELECT
    dea.continent,
    dea.location,
    STR_TO_DATE(dea.`date`, '%c/%e/%Y') AS `date`,
    dea.population,
    NULLIF(vac.new_vaccinations, '') AS New_Vaccinations,
    SUM(CAST(NULLIF(vac.new_vaccinations, '') AS UNSIGNED))
        OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.`date`, '%c/%e/%Y')) AS RollingPeopleVaccinated
FROM portfolioproject.coviddeaths AS dea
LEFT JOIN portfolioproject.covidvaccinations AS vac
  ON dea.location = vac.location
 AND STR_TO_DATE(dea.`date`, '%c/%e/%Y') = STR_TO_DATE(vac.`date`, '%c/%e/%Y')
WHERE dea.continent IS NOT NULL;


SELECT *,
       (RollingPeopleVaccinated / Population) * 100 AS PercentVaccinated
FROM PercentPopulationVaccinated;

-- Creating view to store data for later visualization

-- DROP VIEW IF EXISTS PercentPopulationVaccinated;

CREATE VIEW PercentPopulationVaccinated as 
SELECT
    dea.continent,
    dea.location,
    STR_TO_DATE(dea.`date`, '%c/%e/%Y') AS `date`,
    dea.population,
    NULLIF(vac.new_vaccinations, '') AS New_Vaccinations,
    SUM(CAST(NULLIF(vac.new_vaccinations, '') AS UNSIGNED))
        OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.`date`, '%c/%e/%Y')) AS RollingPeopleVaccinated
FROM portfolioproject.coviddeaths AS dea
LEFT JOIN portfolioproject.covidvaccinations AS vac
  ON dea.location = vac.location
 AND STR_TO_DATE(dea.`date`, '%c/%e/%Y') = STR_TO_DATE(vac.`date`, '%c/%e/%Y')
WHERE dea.continent IS NOT NULL;

select *
from PercentPopulationVaccinated

