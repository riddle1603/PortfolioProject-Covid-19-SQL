use portfolioproject;
-- SELECT *
-- FROM `coviddeaths vaccination`
-- order by 3,4;

SELECT *
FROM `covid19 deaths`
order by 3,4;

-- select  data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM `covid19 deaths`
order by 1,2;

-- looking at total cases vs total deaths --

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM `covid19 deaths`
order by 1,2;

-- Shows likelihood of dying if you contrat covid in your country 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM `covid19 deaths`
WHERE location like '%states%'
and continent is not null
order by 1,2;
  
-- Looking at total cases vs population 
-- Shows what percentage of population got covid

SELECT Location, date, Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfefcted
FROM `covid19 deaths`
-- WHERE location like '%states%'
order by 1,2;

-- Looking at countries with highest Infaction rate compare to population 

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfefcted
FROM `covid19 deaths`
-- WHERE location like '%states%'
group by Location, Population
order by PercentagePopulationInfefcted desc ;

-- Showing counteries Highest Death count per popultion

SELECT Location, MAX(total_deaths) as TotalDeathCount 
FROM `covid19 deaths`
-- WHERE location like '%states%'
group by Location
order by TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(total_deaths) as TotalDeathCount 
FROM `covid19 deaths`
-- WHERE location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc; 

-- GLOBAL NUMBERS

SELECT  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM `covid19 deaths`
-- WHERE location like '%states%'
where continent is not null
-- group by date
order by 1,2;

-- Looking at Total polulation vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location,  dea.date) as RollingPeopleVaccinated
 FROM `covid19 deaths` dea
 JOIN `coviddeaths vaccination`vac 
 ON dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null
 order by 2, 3;
 
 -- USE CTE
 
 with popvsvac ( continent, location, date, population, new_vaccinations,  RollingPeopleVaccinated)
 as
 (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location,  dea.date) as RollingPeopleVaccinated
 FROM `covid19 deaths` dea
 JOIN `coviddeaths vaccination`vac 
 ON dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null
-- order by 2, 3
 ) 
 SELECT *,  (RollingPeopleVaccinated/Population)*100
 FROM popvsvac;

 -- TEMP TABLE
DROP TABLE IF exists PresentPopulationVaccinated;
 CREATE TABLE  PresentPopulationVaccinated
 (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric, 
RollingPeopleVaccinated numeric
);
 
 INSERT INTO PresentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location,  dea.date) as RollingPeopleVaccinated
 FROM `covid19 deaths` dea
 JOIN `coviddeaths vaccination`vac 
 ON dea.location = vac.location
 AND dea.date = vac.date
 -- where dea.continent is not null
-- order by 2, 3
;
SELECT *, (RollingPeopleVaccinated/Population) * 100
 FROM PresentPopulationVaccinated;
 
-- Creatin view to store data for later Visualizations

create view percentpopulationvaccinated  as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location,  dea.date) as RollingPeopleVaccinated
 FROM `covid19 deaths` dea
 JOIN `coviddeaths vaccination`vac 
 ON dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null
-- order by 2, 3
 ;
 SELECT * FROM portfolioproject.percentpopulationvaccinated;
 
 
 