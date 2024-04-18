select *
from PortfolioProject..CovidDeaths
order by 3,4



select *
from PortfolioProject..CovidVaccinations
order by 3,4



--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2



--total cases vs total deaths
--likelihood of dying of corona in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%malawi%'
order by 1, 2



--total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
where location like '%malawi%'
order by 1, 2



--looking at countries with highest infection rate compared to population
select location, MAX(total_cases), population, Max((total_cases/population))*100 as PopulationInfectionRate
from PortfolioProject..CovidDeaths
--where location like '%malawi%'
Group by location, population
order by PopulationInfectionRate desc



--countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%malawi%'
where continent is not null
Group by location
order by TotalDeathCount desc


--countries with the highest death count per population in africa
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent like '%Africa%'
Group by location
order by TotalDeathCount desc


--showing the continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%malawi%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select date, sum(new_cases) as TOTAL_CASES, sum(cast(new_deaths as int)) as TOTAL_DEATHS, sum(cast(new_deaths as int))/sum(new_cases)*100 as DEATH_PERCENTAGE
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2

---------------------------------------------------------------------
--joining the two tables
select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total population vs vaccination
--use CTE
with PopvsVac (Continent, location, date, population, New_vaccinations, RollingCountOfVaccinations)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingCountOfVaccinations/population)*100
from PopvsVac

--use temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountOfVaccinations numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingCountOfVaccinations/population)*100 as PercentVaccinated
from #PercentPopulationVaccinated


--creating view to store data for later visualizations

create view PercentVaccinated as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingCountOfVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3