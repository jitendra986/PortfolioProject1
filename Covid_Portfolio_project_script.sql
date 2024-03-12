SELECT *
FROM PortfolioProject1.dbo.CovidDeaths
where continent is not null
ORDER by 3,4

----SELECT *
----FROm PortfolioProject1.dbo.CovidVaccinations
----ORDER by 3,4
-- select the 6 attributes  based on Location and date in asscending order.
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.dbo.CovidDeaths
where continent is not null
ORDER by 1,2

-- Looking at total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in ur country.
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
where continent is not null and Location like '%china%'
ORDER by 1,2

--Looking at total cases Vs Population
--Shows what percentage of Population got Covid
SELECT Location, date, population, (total_cases/population)*100 as CovidCasePercentage
FROM PortfolioProject1.dbo.CovidDeaths
Where Location like '%china%' and continent is not null
ORDER by 1,2

--Loking at Countries with Highest Infection Rate compared to Population
SELECT Location,  population, MAx(total_cases) as HighestInfectionCount, (MAx(total_cases)/population)*100 as PercentPopulationInfected
FROM PortfolioProject1.dbo.CovidDeaths
--Where Location like '%India%'
where continent is not null 
Group by Location, Population
ORDER by 4 DESC


-- Let's break things down by countries
--- Showing the countries the heighest death count per population
SELECT Location,   MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
--Where Location like '%India%'
where continent is not null
Group by Location
ORDER by TotalDeathCount DESC
/*
total_deaths attribute gas an issue with data type. It just has to do with how 
the data type is read when you use this aggregate function. we need to convert it or cast it. This
is what we are actually doing, we need to Cast this as an Integer so that's read as a numeric. Why?
I can not give you a perfect explanation for it but this happens all the time. You just need to
look at the data and realize oh it's probably because of this data type. Let's try something 
else and then it will work so now we are taking this and varchar255 over here and 
then we are converting it to an integer 
*/

-- Let's break things down by continents
SELECT location,   MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
--Where Location like '%India%'
where continent is  null
Group by location
ORDER by TotalDeathCount DESC

-- Showing the continent with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.dbo.CovidDeaths
--Where Location like '%India%'
where continent is not null
Group by continent
ORDER by TotalDeathCount DESC
/*
Drill down effect: It's like clicking on North America and then when you bring up north america
then it shows all the countries in north america. So If you look on africa and then there is all 
the african countries. That's what drilling down means.
*/
-- Global Numbers
SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject1.dbo.CovidDeaths
where continent is not null 
-- and where Location like '%states%
--group by date
ORDER by 1,2  

---- Looking at total population vs Vaccinations

--use CTE
With PopvsVac (continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int, vacc.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100

FROM PortfolioProject1.dbo.CovidDeaths as dea
join PortfolioProject1.dbo.CovidVaccinations as vacc
	on dea.location =vacc.location
    and  dea.date = vacc.date	
where dea.continent is not null 
--ORDER by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent	nvarchar(255),
Location	nvarchar(255),
Date		datetime,
Population	numeric,
New_vaccination	numeric,
RollingPeopleVaccinated	numeric
)
INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int, vacc.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100

FROM PortfolioProject1.dbo.CovidDeaths as dea
join PortfolioProject1.dbo.CovidVaccinations as vacc
	on dea.location =vacc.location
    and  dea.date = vacc.date	
--where dea.continent is not null 
--ORDER by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating View to Store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(convert(int, vacc.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1.dbo.CovidDeaths as dea
join PortfolioProject1.dbo.CovidVaccinations as vacc
	on dea.location =vacc.location
    and  dea.date = vacc.date	
where dea.continent is not null 
--ORDER by 2,3

SELECT *
FROM PercentPopulationVaccinated
