# COVID-19 Data Exploration Project

This project uses SQL to explore and analyze COVID-19 data (cases, deaths, and vaccinations). The dataset comes from the **Portfolio Project Database** (`portfolioproject`) which contains two main tables:

* `coviddeaths`
* `covidvaccinations`

The analysis is designed to uncover insights about infection rates, mortality, vaccination progress, and global trends. It also demonstrates SQL techniques such as **aggregations, window functions, CTEs, temporary tables, and views**.

---

## Objectives

* Explore relationships between **total cases, total deaths, and population**.
* Calculate **death likelihood** from COVID-19 across different countries.
* Identify **countries and continents most affected**.
* Compare **cases and deaths globally over time**.
* Track **vaccination progress** at country and continental levels.
* Practice SQL concepts (JOINs, GROUP BY, CTEs, temp tables, and views).

---

## Key Queries & Insights

### 1. Basic Exploration

```sql
SELECT * 
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date;
```

* Filters out aggregated rows (e.g., “World”, “European Union”).
* Provides a clean dataset for further exploration.

---

### 2. Cases vs Deaths

```sql
SELECT location, date, total_cases, total_deaths,
       (total_deaths/total_cases) * 100 AS DeathPercentage
FROM portfolioproject.coviddeaths
WHERE location LIKE '%states%'
ORDER BY date;
```

* Shows the **likelihood of dying** if infected with COVID-19.

---

### 3. Cases vs Population

```sql
SELECT location, date, total_cases, population,
       (total_cases/population) * 100 AS PercentPopulationInfected
FROM portfolioproject.coviddeaths
WHERE location LIKE '%states%'
ORDER BY date;
```

* Tracks **infection penetration rate** in the population.

---

### 4. Highest Infection & Death Counts

* **Countries with highest infection rate** compared to population.
* **Countries and continents with highest death count**.

---

### 5. Global Numbers

```sql
SELECT date,
       SUM(new_cases) AS TotalCases,
       SUM(CAST(new_deaths AS UNSIGNED)) AS TotalDeaths,
       (SUM(CAST(new_deaths AS UNSIGNED)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY TotalCases, TotalDeaths;
```

* Tracks global case and death trends over time.

---

### 6. Vaccination Progress

```sql
SELECT dea.continent, dea.location, dea.date, dea.population,
       vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER 
           (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
     ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
```

* Uses **window functions** to calculate cumulative vaccinations.

---

### 7. Using CTE

```sql
WITH PopVsVac AS (
   ...
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 AS PercentVaccinated
FROM PopVsVac;
```

* Creates a **CTE** to compare vaccination rates across countries.

---

### 8. Using Temp Table

```sql
CREATE TEMPORARY TABLE PercentPopulationVaccinated (...);
INSERT INTO PercentPopulationVaccinated (...);
SELECT *, (RollingPeopleVaccinated/Population) * 100 AS PercentVaccinated
FROM PercentPopulationVaccinated;
```

* Stores intermediate vaccination data for further exploration.

---

### 9. Creating Views

```sql
CREATE VIEW PercentPopulationVaccinated AS
SELECT ...
```

* Saves vaccination analysis as a **view** for reuse in visualization (e.g., Tableau, Power BI).

---

## Concepts Demonstrated

* **Filtering & Ordering** (`WHERE`, `ORDER BY`)
* **Aggregations** (`SUM`, `MAX`, `GROUP BY`)
* **Window Functions** (`SUM() OVER (PARTITION BY ...)`)
* **Common Table Expressions (CTE)**
* **Temporary Tables**
* **Views**
