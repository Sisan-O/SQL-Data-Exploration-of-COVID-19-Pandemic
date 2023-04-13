select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..Covidvac1$
--order by 3,4

-- Select Data that we're going to be using.

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


-- Looking at the Total Cases VS Total Deaths.
-- Shows the likelihood of dying if you contract Covid in your Country.

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%Nigeria%'
order by 1,2


-- Looking at the Total Cases VS Population.
-- Shows what percentage of population got Covid.
select location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Countries with the Highest Infection rate compared to Population.
select location, population, max(total_cases), max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
-- where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with the Highest death count per Population.

select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- LET' BREAK THINGS DOWN BY CONTINENT


-- Showing continent with the highest death count per population

select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as Total_Deaths,
SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..Covidvac1$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
-- Shows the Percentage of people vaccinated.

with PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..Covidvac1$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 as Percentageofpeoplevaccinated
from PopvsVac