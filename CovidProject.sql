SELECT *
FROM CovidDeaths$
order by 3, 4




--SELECT *
--FROM CovidVaccinations$
--order by 3, 4


Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
order by 1, 2 

--Looking at Total Cases vs Total Deaths
--Shows the Likelihood of dying when you contract covid in Ghana
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where Location = 'Ghana'
order by 1, 2 

--Looking at Total Cases v Population
--Shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From CovidDeaths$
Where Location = 'Ghana'
order by 1, 2 


--What countries have the highest infection rates
Select Location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Group by location, population
order by 4 desc

--Showing Countries with Highest Death Count per Population
Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null
Group by location
order by 2 desc


--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing continents with highest death count

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
Where continent is not null
Group by continent
order by 2 desc


-- GLOBAL NUMBERS

select date , SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
Group By date
Order by 1, 2


--Total Population vs Vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.Location Order BY dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac. location
	and dea.date = vac. date
where dea.continent is not null
order by 2, 3

 --USE CTE

 With PopsvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.Location Order BY dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac. location
	and dea.date = vac. date
where dea.continent is not null
--order by 2, 3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopsvsVac


--TEMP TABLE 

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.Location Order BY dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac. location
	and dea.date = vac. date
where dea.continent is not null
--order by 2, 3
  

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.Location Order BY dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac. location
	and dea.date = vac. date
where dea.continent is not null
--order by 2, 3

 