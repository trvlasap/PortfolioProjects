select * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--select data that we going to be using

select location , date , total_cases , new_cases , total_deaths , population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Looking at total cases vs Total Deaths
--show likelyhood of dying if you are contract covid in your country
select location , date , total_cases, total_deaths , (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at total cases vs population
--show what % got covid
select location , date ,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--what countries have highest infection rates to population

select location , MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location,population
order by PercentPopulationInfected desc

--LETS BREAK THINGS DOWN BY CONTINENT



--showing the countries with the highest death count per population
select continent , MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
Group by continent
order by TotalDeathCount desc

--GLOBAL numbers
select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
--Group by date
order by 1,2



--LOOKING FOR TOTAL POPULATION VS VACINATION
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--dd
	SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , SUM(CAST(vac.new_vaccinations as int)) 
	OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,

from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	--USE CTE 

	with POPvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
	as 
	(
	SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
	SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
    from PortfolioProject..CovidDeaths dea
    join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	Select * , (RollingPeopleVaccinated/Population)*100
	from PopvsVac



	--Temp Table
DROP Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #percentPopulationVaccinated
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
	SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
    from PortfolioProject..CovidDeaths dea
    join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3
	Select * , (RollingPeopleVaccinated/Population)*100
	from #percentPopulationVaccinated

	

	--creating view to store data for visualization

	Create View percentPopulationVaccinated as
	SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
	SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
    from PortfolioProject..CovidDeaths dea
    join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	select * 
	from percentPopulationVaccinated
	order by location asc
