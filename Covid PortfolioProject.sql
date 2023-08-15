use master

select * from master..CovidDeaths 

--select * from CovidVaccinations

-- Select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths order by 1,2


-- looking at Total cases vs Total Deaths

select location, date, total_cases, total_deaths, (cast(total_deaths as float))/cast(total_cases as float)*100 as deathpercentage
from CovidDeaths order by 1,2

-- looking at Total cases vs Total Deaths (Country wise)

select location, date, total_cases, total_deaths, (cast(total_deaths as float))/cast(total_cases as float)*100 as deathpercentage
from CovidDeaths  
where location like '%states%'
order by 1,2

-- looking at the Total cases vs Population
--Shows what percentage of population got Covid

select location, date, total_cases, Population, (cast(total_cases as float))/cast(population as float)*100 as percentpopulation
from CovidDeaths  
where location like '%states%'
order by 1,2

-- looking at countries with Highest Infection Rate Compared to Population

select location, MAX(total_cases) as HighestInfectioncount, Population, 
MAX(cast(total_cases as float)/cast(Population as float))*100 as PercentPopulationinfected
from CovidDeaths 
--where location like '%states%'
Group by location, Population
order by percentPopulationInfected desc


--Showing countries with highest death count per Population

select location, MAX(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
--where location like "%states%"
where continent is not null
Group by location
order by Totaldeathcount desc

--LET's braek things by continents

select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
--where location like "%states%"
where continent is not null
Group by continent
order by Totaldeathcount desc


--Showing the continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
from CovidDeaths
--where location like "%states%"
where continent is not null
Group by continent
order by Totaldeathcount desc


--GLOBAL NUMBERS


select SUM(new_cases) as total_cases, Sum(new_deaths) as total_deaths, 
sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from CovidDeaths 
where continent is not null
order by 1,2


--Looking at Total population vs vaccinations

select * from master..Covidvaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert (float,vac.new_vaccinations)) over(partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from CovidDeaths  dea
Join CovidVaccinations vac
  on dea.location = vac.location
  and dea.date= vac.date
 where dea.continent is not null



 --Use CTE

 with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
 (
 select dea.continent, dea.location, dea.date, dea.population, 
 vac.new_vaccinations, SUM(Convert(float,vac.new_vaccinations)) 
 over(partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths  dea
Join CovidVaccinations vac
  on dea.location = vac.location
  and dea.date= vac.date
 where dea.continent is not null
 )

 select *, ( RollingPeopleVaccinated/population)*100

 From PopvsVac


 --TEMP TABLE

 Drop table if exists #PercentPopulationVaccinated

 create table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location varchar(255),
 Date Datetime,
 population numeric,
 New_vaccinations float,
 RollingPeopleVaccinated numeric)

 insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, 
 vac.new_vaccinations, SUM(Convert(float,vac.new_vaccinations)) 
 over(partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths  dea
Join CovidVaccinations vac
  on dea.location = vac.location
  and dea.date= vac.date
 where dea.continent is not null


 select *, ( RollingPeopleVaccinated/population)*100
 from #PercentPopulationVaccinated



 ------Create View

 create view PercentPopulationVaccinated as
  
  select dea.continent, dea.location, dea.date, dea.population, 
 vac.new_vaccinations, SUM(Convert(float,vac.new_vaccinations)) 
 over(partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths  dea
Join CovidVaccinations vac
  on dea.location = vac.location
  and dea.date= vac.date
 where dea.continent is not null

 
 
 select * from PercentPopulationVaccinated
