/*
Covid-19 Data Exploration

Skills used: Joins, CTE's Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Order by 4

Select *
From PortfolioProjectCovid..CovidVaccinations
Order by 3,4


-- Formatting Data Types

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases NUMERIC
GO

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths NUMERIC
GO


-- Select Data that we will start with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Order by 1,2



-- Total Cases vs. Total Deaths
-- Displays likelihood of death if COVID is contracted in specified country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
Where total_cases is not NULL
--AND location like '%states%'
Order by 1,2


-- Total Cases vs Population
-- Displays percentage of population infected with COVID

Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProjectCovid..CovidDeaths
Where continent is not NULL 
	--AND location like '%states%'
Order by 1,2


--Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as
	PercentPopulationInfected
FROM PortfolioProjectCovid..CovidDeaths
Where continent is not NULL 
	--AND location like '%states%'
GROUP BY continent, Location, Population
Order by 3 desc


--Countries with Highest Death Count per Population
Select location, MAX(Total_Deaths) as TotalDeathCount
FROM PortfolioProjectCovid..CovidDeaths
Where continent is not null
GROUP BY continent, location
Order by TotalDeathCount desc


--Continents with the highest death count per population
Select continent, MAX(Total_Deaths) as TotalDeathCount
FROM PortfolioProjectCovid..CovidDeaths
Where continent is not null
	--AND location like '%states%'
GROUP BY continent
Order by TotalDeathCount desc



--Global Numbers

Select date, total_cases, total_deaths, total_deaths/total_cases*100 as TotalDeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
Where location like 'world'
	AND total_cases is not NULL
Order by 1,2


--Current Global Number

Select MAX(total_cases) as TotalCases, MAX(total_deaths) as TotalDeaths, MAX(total_deaths/total_cases*100) as TotalDeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
Where location like 'world'
	AND total_cases is not NULL
Order by 1,2



--Total Population vs. Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated



--Total Population vs. Tests

Select dea.continent, dea.location, dea.date, dea.population, vac.new_tests
, SUM(CONVERT(BIGINT,vac.new_tests)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleTested
--, (RollingPeopleTested/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3


--USE CTE

With PopvsTest (Continent, Location, Date, Population, New_Tests, RollingPeopleTested)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_tests
, SUM(CONVERT(BIGINT,vac.new_tests)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleTested
--, (RollingPeopleTested/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3
)
Select *, (RollingPeopleTested/Population)*100 as PercentTestsVsPopulation
From PopvsTest



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not NULL
--Order by 2,3

Create View GlobalNumbers as 
Select date, total_cases, total_deaths, total_deaths/total_cases*100 as TotalDeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
Where location like 'world'
	AND total_cases is not NULL
--Order by 1,2