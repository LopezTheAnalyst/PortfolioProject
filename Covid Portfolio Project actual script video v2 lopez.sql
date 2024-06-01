SELECT *
FROM PortfolioProject..CovidDeaths1
Where continent is not null

--SELECT *
--FROM PortfolioProject..CovidVaccinations

-- Select Data that we are giong to be using
Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths1
Where continent is not null
Order By 1,2


-- Looking at Total cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths1
-- Where Location = 'Europe'
Where continent is not null
Order By 1,2

-- Looking at Total cases vs Population
-- Show what percentage of population got covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths1
-- Where Location like '%states%'
Where continent is not null
Order By 1,2

-- Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfestionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths1
-- Where Location like '%states%'
Where continent is not null
Group By Location, Population
Order By PercentPopulationInfected DESC

-- Showing countries with the highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths1
-- Where Location like '%states%'
Where continent is not null
Group By Location
Order By TotalDeathCount DESC


-- Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths1
-- Where Location like '%states%'
Where continent is not null
Group By continent
Order By TotalDeathCount DESC

-- Global numbers
Select sum(total_cases) as total_cases, sum(cast(total_deaths as int)) as total_deaths, sum(cast(total_deaths as int))/SUM
(total_cases)*100  as DeathPercentage
FROM PortfolioProject..CovidDeaths1
-- Where Location = 'Europe'
Where continent is not null
--Group by date
Order By 1,2

-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths1 dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
		And dea.date = vac.date
Where dea.continent is not null
Order By 2,3

--Use CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths1 dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
		And dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths1 dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
		And dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3
Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths1 dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
		And dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *
From PercentPopulationVaccinated

