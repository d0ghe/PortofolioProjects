SELECT *
FROM Portofolio..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM Portofolio..CovidVactinations
--ORDER BY 3,4



SELECT Location ,date , total_cases , new_cases , total_deaths , population
FROM Portofolio..CovidDeaths
ORDER BY 1,2

--DeathPercentage

SELECT Location ,date , total_cases , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
FROM Portofolio..CovidDeaths
Where location like '%romania%'
ORDER BY 1,2


--Looking at Total Cases vs Population

SELECT Location ,date , total_cases , population , (total_cases/population)*100 as CasesPercentage
FROM Portofolio..CovidDeaths
Where location like '%romania%'
ORDER BY 1,2


--Looking at Country with Highest Infection Rate Compared

SELECT Location, population , MAX(total_cases)AS HighestInfection , MAX((total_cases/population))*100 as HighestPercent
FROM Portofolio..CovidDeaths
--Where location like '%romania%'
GROUP BY location , population
ORDER BY HighestPercent desc

--LET'S BREAK BY CONTINENT

SELECT location , MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portofolio..CovidDeaths
--Where location like '%romania%'
Where continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing th Countries with the Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portofolio..CovidDeaths
--Where location like '%romania%'
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--Showing the Continents with the highest death count per population

SELECT location , MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portofolio..CovidDeaths
--Where location like '%romania%'
Where continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


--Global Numbers

SELECT date ,SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deahts , SUM(cast(new_deaths as int))/SUM(New_cases)*100 DeathPercentage
FROM Portofolio..CovidDeaths
--Where location like '%romania%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Global Total

SELECT SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deahts , SUM(cast(new_deaths as int))/SUM(New_cases)*100 DeathPercentage
FROM Portofolio..CovidDeaths
--Where location like '%romania%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at total Population vs Vactination

SELECT dea.continent ,dea.location , dea.date , dea.population,vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations )) OVER (Partition by dea.location ORDER BY dea.location, dea.date ) as VaccinatedPeople  --(VaccinatedPeople/population)*100
FROM Portofolio..CovidDeaths dea
Join Portofolio..CovidVactinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--CTE

WITH PopvsVac(Continents, location ,date ,population , PeopleVaccinated ,new_vaccinations)
as
(
SELECT dea.continent ,dea.location , dea.date , dea.population,vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations )) OVER (Partition by dea.location ) as PeopleVaccinated
 -- (PeopleVaccinated/population)*100
FROM Portofolio..CovidDeaths dea
Join Portofolio..CovidVactinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
Select *, (PeopleVaccinated/population)*100
From PopVSVac


--TEMP TABLE

CREATE TABLE #percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #percentpopulationvaccinated

SELECT dea.continent ,dea.location , dea.date , dea.population,vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations )) OVER (Partition by dea.location ) as PeopleVaccinated
 -- (PeopleVaccinated/population)*100
FROM Portofolio..CovidDeaths dea
Join Portofolio..CovidVactinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select *, (PeopleVaccinated/population)*100
From #percentpopulationvaccinated


--View to store

CREATE VIEW percentpopulationvaccinated as
SELECT dea.continent ,dea.location , dea.date , dea.population,vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations )) OVER (Partition by dea.location ) as PeopleVaccinated
 -- (PeopleVaccinated/population)*100
FROM Portofolio..CovidDeaths dea
Join Portofolio..CovidVactinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM percentpopulationvaccinated