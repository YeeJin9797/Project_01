
--1. SELECT all FROM PortfolioProject.CovidDeath

SELECT*
FROM [Portfolio Project].dbo.CovidDeath
Order BY 3,4;

--2. Looking at Total Cases vs Total Death in Malaysia, 
--with DeathPercentage as to show the likelihood of dying if you contact with covid

SELECT Location,Date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeath
WHERE location like '%Malaysia%'
Order BY 1,2;

--3. Looking at Total Cases vs Population in Malaysia, 
--showing what percentage of people getting covid

SELECT Location,Date,population,total_cases,(total_cases/population)*100 AS Percentage
FROM [Portfolio Project].dbo.CovidDeath
WHERE location like '%Malaysia%'
Order BY 1,2;

--4. Looking at country with highest infection rate compared to population

SELECT Location,population,MAX(total_cases) as HigestInfectionCount,MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM [Portfolio Project].dbo.CovidDeath
GROUP BY location,population
Order BY PercentagePopulationInfected Desc;

--5. Looking at country with highest death count per population.
--(cast) = convert data into INT

SELECT Location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeath
WHERE continent is not Null 
GROUP BY location
Order BY TotalDeathCount Desc;

--6. Looking at Continent with highest death count per population.

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeath
WHERE continent is not Null 
GROUP BY continent
Order BY TotalDeathCount Desc;

--7.Global Numbers according to Date
--(cast) = convert data into INT

SELECT Date,SUM(new_cases) AS NewCases,SUM(cast(new_deaths as int)) AS NewDeath, 
			SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeath
WHERE continent is not null
GROUP BY date
Order BY 1,2;


--8. Looking Total Population vs Vaccination
--(cast) = convert sum data into BIGINT

WITH PopulationVSVaccination (Continent, Location,Date, Population,New_Vaccinations, CumulativeVaccinations)
AS 
(
SELECT Dea.continent, dea.location, DEA.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location,DEA.date) as CumulativeVaccinations
FROM [Portfolio Project].dbo.CovidDeath as Dea
JOIN [Portfolio Project].dbo.CovidVaccination as Vac
	ON dea.location = vac.location
	And dea.date = vac.date
WHERE dea.continent is not null
)

SELECT* ,(CumulativeVaccinations/Population)*100
FROM PopulationVSVaccination;



--9. CREATE a table #PercentPopulationVaccinated
--(cast) = convert sum data into BIGINT

DROP TABLE if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime, 
Population numeric,
new_vaccinations numeric,
CumulativeVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, dea.location, DEA.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location,DEA.date) as CumulativeVaccinations
FROM [Portfolio Project].dbo.CovidDeath as Dea 
JOIN [Portfolio Project].dbo.CovidVaccination as Vac
	ON dea.location = vac.location
	And dea.date = vac.date
WHERE dea.continent is not null;

SELECT*,(CumulativeVaccinations/Population)*100
FROM #PercentPopulationVaccinated;


--10. CREATE view for visualization

DROP View PercentPopulationVaccinated 

USE [Portfolio Project]
GO
Create View PercentPopulationVaccinated  as
SELECT Dea.continent, dea.location, DEA.date,dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location,DEA.date) as CumulativeVaccinations
FROM [Portfolio Project].dbo.CovidDeath as Dea 
JOIN [Portfolio Project].dbo.CovidVaccination as Vac
	ON dea.location = vac.location
	And dea.date = vac.date
WHERE dea.continent is not null;


--Test Run for View

SELECT * 
FROM PercentPopulationVaccinated ;