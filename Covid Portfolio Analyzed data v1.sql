--QUERYING COVID DEATH TABLE

select * from PortfolioProject..[Covid Deaths]
where continent is not null
order by 3,4

--Avoiding Income based classification data
select * from PortfolioProject..[Covid Deaths]
where location not like '%income%'


--Select the data that are being used
select location , date , total_cases, new_cases, total_deaths, population
from PortfolioProject..[Covid Deaths]
where continent is not null
order by 1,2


--Looking at Total Cases VS Total Deaths

select location , date ,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths]
where continent is not null
order by 1,2



--Shows likelihood of dying If you are contracted with Covid-19 in your Country
select location , date ,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[Covid Deaths]
where location like '%India%'
order by 1,2

--Looking at Total Cases VS Population
--Shows what percentage of population has gotten Covid
select location , date ,total_cases, population, (total_cases/population)*100 as InfectionRate
from PortfolioProject..[Covid Deaths]
where location like '%India%'
order by 1,2


--Looking at countries with highest infection rate compared to the population
select location , population, max(total_cases) as PeakInfectionCount,max((total_cases/population))*100 as PercentofPopulationInfected
from PortfolioProject..[Covid Deaths]
where continent is not null
group by population, location
order by PercentofPopulationInfected desc



--Showing countries with highest death count by population
select location ,max(cast(total_deaths as int )) as TotalDeathCount
from PortfolioProject..[Covid Deaths]
where continent is not null
group by location
order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT

--Showing continents with highest death count per population

select  location,max(cast(total_deaths as int )) as TotalDeathCount
from PortfolioProject..[Covid Deaths]
where continent is null
and location not like '%income%'--removing income based classification
group by location
order by TotalDeathCount desc

--Breaking into global numbers

select date,sum(new_cases) as New_Cases, sum(new_deaths) as Death_Rate , sum(new_deaths)/sum(new_cases)*100 as Mortality_Rate	from PortfolioProject..[Covid Deaths]
where continent is not null and location not like '%income%'
group by date 
order by 1,2


-- total cases,deaths and mortality rate

select sum(new_cases) as New_Cases, sum(new_deaths) as Death_Rate , sum(new_deaths)/sum(new_cases)*100 as Mortality_Rate	from PortfolioProject..[Covid Deaths]
where continent is not null and location not like '%income%' 
order by 1,2


--QUERYING COVID VACCINATIONS TABLE
SELECT DEATH.continent,DEATH.location,DEATH.date, DEATH.population,VAX.new_vaccinations 
, SUM(VAX.new_vaccinations) OVER (PARTITION BY DEATH.LOCATION ORDER BY DEATH.LOCATION ,DEATH.DATE) as			RollingPeopleVaccinated
FROM PortfolioProject..[Covid Deaths] DEATH
JOIN PortfolioProject..[Covid Vaccinations] VAX
	ON DEATH.location = VAX.location
	AND DEATH.date = VAX.date
WHERE DEATH.continent IS NOT NULL AND DEATH.location NOT LIKE '%income%'
ORDER BY 2,3 


--USE CTE
WITH POPULATIONvsVAX (CONTINENT,LOCATION,DATE,POPULATION,new_vaccinations,RollingPeopleVaccinated) AS
(SELECT DEATH.continent,DEATH.location,DEATH.date, DEATH.population,VAX.new_vaccinations 
, SUM(VAX.new_vaccinations) OVER (PARTITION BY DEATH.LOCATION order by DEATH.LOCATION, DEATH.DATE) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..[Covid Deaths] DEATH
JOIN PortfolioProject..[Covid Vaccinations] VAX
	ON DEATH.location = VAX.location
	AND DEATH.date = VAX.date
WHERE DEATH.continent IS NOT NULL  
--ORDER BY 2,3
)
select * ,(RollingPeopleVaccinated/population)*100 as VaccinationRate from POPULATIONvsVAX



--Temp Table
drop table if exists #percentagepopulationvaccinated 
create table #percentagepopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentagepopulationvaccinated
SELECT DEATH.continent,DEATH.location,DEATH.date, DEATH.population,VAX.new_vaccinations 
, SUM(VAX.new_vaccinations) OVER (PARTITION BY DEATH.LOCATION order by DEATH.LOCATION, DEATH.DATE) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..[Covid Deaths] DEATH
JOIN PortfolioProject..[Covid Vaccinations] VAX
	ON DEATH.location = VAX.location
	AND DEATH.date = VAX.date
WHERE DEATH.continent IS NOT NULL  
--ORDER BY 2,3
select * ,(RollingPeopleVaccinated/population)*100 as VaccinationRate from #percentagepopulationvaccinated


--CReating view to store data for later data visualizations
create view  percentagepopulationvaccinated as
SELECT DEATH.continent,DEATH.location,DEATH.date, DEATH.population,VAX.new_vaccinations 
, SUM(VAX.new_vaccinations) OVER (PARTITION BY DEATH.LOCATION order by DEATH.LOCATION, DEATH.DATE) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..[Covid Deaths] DEATH
JOIN PortfolioProject..[Covid Vaccinations] VAX
	ON DEATH.location = VAX.location
	AND DEATH.date = VAX.date
WHERE DEATH.continent IS NOT NULL  
--ORDER BY 2,3

select * from percentagepopulationvaccinated