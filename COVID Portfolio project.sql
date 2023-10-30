/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from Portfolioproject..CovidDeaths$
order by 3,4

---select *
---from Portfolioproject..CovidVaccinations$
---order by 3,4

 -- Select Data that we are going to be starting with
 
select location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject..CovidDeaths$
order by 1,2

 
 -- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths$
where location like '%states%'
order by 1,2

 
 -- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfected
from Portfolioproject..CovidDeaths$
where location like '%states%'
order by 1,2

 
 -- Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as PercentPopulationInfected
from Portfolioproject..CovidDeaths$
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

 
 -- Countries with Highest Death Count per Population

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths$
where continent is null
Group by location
order by TotalDeathCount desc


 
-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

 
-- GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by date
order by 1,2


 
-- Looking at Total Population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations))OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2,


 
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations))OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
-- order by 2,3
 )
 select*, (RollingPeopleVaccinated/Population)*100
 From PopvsVac


 
-- Using Temp Table to perform Calculation on Partition By in previous query


 drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

 Insert  into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations))OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
-- order by 2,3

select*, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated


 
 --creating view to store data for visualizations

 Create view PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations))OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
-- order by 2,3

select *
from PercentPopulationVaccinated 
