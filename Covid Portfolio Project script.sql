select * from dbo.Deaths
select * from dbo.Vaccinated

select * from Port_Covid_Project..Deaths order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from Port_Covid_Project..Deaths
order by 1, 2

-- Looking at total cases vs Total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPer
from Port_Covid_Project..Deaths
where location like '%states'
order by 1, 2

-- looking at the total cases vs the population
select location, date, population, total_cases, (total_cases/population)*100 as PopInfPer
from Port_Covid_Project..Deaths
where location like 'Mexico'
order by 1, 2

-- looking at countries with the highest infection rate per population
select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as PercentagePopulationInfected
from Port_Covid_Project..Deaths
--where location like 'Mexico'
group by location, population
order by PercentagePopulationInfected desc


--countries with the highest death count per population
alter table dbo.Deaths alter column total_deaths int


Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Port_Covid_Project..Deaths
Where continent is not null
group by location
order by TotalDeathCount desc


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Port_Covid_Project..Deaths
Where continent is not null
group by location
order by TotalDeathCount desc


-- showing the continents with the highest death count percentage
select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
from Port_Covid_Project..Deaths
--where location like '%states"'
where continent is not null
group by continent
order by TotalDeathsCount desc

-- global numbers 
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Port_Covid_Project..Deaths
where continent is not null
group by date
order by 1, 2


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Port_Covid_Project..Deaths
where continent is not null
--group by date
order by 1, 2



--looking total vactination population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
from Port_Covid_Project..Deaths dea
join Port_Covid_Project..Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- use CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Port_Covid_Project..Deaths dea
join Port_Covid_Project..Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac


-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated1
create table #PercentPopulationVaccinated1
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated1
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Port_Covid_Project..Deaths dea
join Port_Covid_Project..Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
select *, (RollingPeopleVaccinated/Population)*100 as PeopleVaccinatedPercentage 
from #PercentPopulationVaccinated1

--select * from Port_Covid_Project..Vaccination



--creating view to store data for later visualizat
USE Port_Covid_Project
GO
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Port_Covid_Project..Deaths dea
join Port_Covid_Project..Vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


select * from PercentPopulationVaccinated