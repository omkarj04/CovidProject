use covidproject;

select * from covidproject..CovidDeaths
where continent is not null
order by 3,4

--select * from covidproject..CovidVaccinations
--order by 3,4

--select data 


select Location, date, total_cases, new_cases, total_deaths, population
from covidproject..CovidDeaths
order by 1,2

--Total deaths vs Total cases

--removing the total cases with 0 value
delete from covidproject..CovidDeaths
where total_cases = 0

--Cases in India
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covidproject..CovidDeaths
where location like '%India'
order by 1,2


--Cases in USA
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covidproject..CovidDeaths
where location like '%States'
order by 1,2


--Total cases vs population
 --what percentage of population had covid

 --Cases for INDIA
 select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from covidproject..CovidDeaths
where location like '%INDIA'
order by 1,2

 --Cases for USA
select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from covidproject..CovidDeaths
where location like '%States'
order by 1,2

--cases for world
select Location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from covidproject..CovidDeaths
where continent is not null
order by 1,2


--Countries with highest infection rate compared to population ordered by HighestInfection Count is World
select Location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from covidproject..CovidDeaths
where continent is not null
group by location, population
order by HighestInfectionCount desc


--Countries with highest infection rate compared to population ordered by Percent of population Infected is World
select Location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from covidproject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc


--Country with highest death count per population for India
select Location,population, max(total_deaths) as TotalDeathCount
from covidproject..CovidDeaths
where location = 'India'
group by location, population
order by TotalDeathCount desc



--Country with highest death count per population for World
select Location,population, max(total_deaths) as TotalDeathCount
from covidproject..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc



--Continet with highest death count per population for World
select continent, max(total_deaths) as TotalDeathCount
from covidproject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



select date, sum(new_cases) total_cases ,sum(new_deaths) total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathsPercentage
from covidproject..CovidDeaths
where new_cases != 0
group by date
order by 1,2


--#Total cases, total deaths and deaths percentage 
select sum(new_cases) total_cases ,sum(new_deaths) total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathsPercentage
from covidproject..CovidDeaths
where new_cases is not null
order by total_cases


--Getting into advanced


--Joining both tables

select * from covidproject..CovidDeaths dea
join covidproject..CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location



--Total vaccinations vs population
--use of rolling sum
select dea.date,dea.continent,dea.location,population, new_vaccinations, sum(convert( bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as TotalV from covidproject..CovidDeaths dea
join covidproject..CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location
where (dea.continent) is not null 
order by 1,3



--Using CTE

with PopVsVac(Continet, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated) as 
(
select dea.continent,dea.location, dea.date,population, new_vaccinations, sum(convert( bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from covidproject..CovidDeaths dea
join covidproject..CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location
where (dea.continent) is not null 
--order by 2,3
)

select Location, Population, new_vaccinations, (RollingPeopleVaccinated/Population)*100 PopulationVSVaccination
from PopVsVac



--Creating a Temp Table

Drop table  if exists PercentPopulationVaccinated

create table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into PercentPopulationVaccinated

select dea.continent,dea.location, dea.date,population, new_vaccinations, sum(convert( bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from covidproject..CovidDeaths dea
join covidproject..CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location
--where (dea.continent) is not null 
--order by 2,3


select *, (RollingPeopleVaccinated/Population)*100 PopulationVSVaccination
from PercentPopulationVaccinated



--Creating Views for Visualizations

DROP VIEW IF EXISTS PercentPopulationVaccination;

Create View PercentPopulationVaccination as
select dea.continent,dea.location, dea.date,population, new_vaccinations, sum(convert( bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from covidproject..CovidDeaths dea
join covidproject..CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location
where (dea.continent) is not null 
--order by 2,3


Create View DeathCountPerContinet as
select continent, max(total_deaths) as TotalDeathCount
from covidproject..CovidDeaths
where continent is not null
group by continent
--order by TotalDeathCount desc
