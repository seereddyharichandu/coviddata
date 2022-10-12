

----Covid 19 Data Exploration



select * 
from  portfolioproject..coviddeathdata
order by 3,4


-- Select Data that we are going to be starting with

select * 
from  portfolioproject..COVIDvaccination
where continent is not null
order by 3,4




---total cases vs total deaths
---shows the likelihood of dying if you contract in india
SELECT location , date , total_cases , total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from  portfolioproject..coviddeathdata
where location like '%india%'
order by 1,2




---looking at the totalcasesvs population
--- shows what percentage of population got covid

SELECT location , date , total_cases ,population, (total_cases/population)*100 as deathpercentage
from  portfolioproject..coviddeathdata
--where location like '%india%'
order by 1,2


-- looking at countries with highest infection rate compared to population
SELECT location ,max(total_cases) as highestinfectioncount  ,population, max(total_cases/population)*100 as ipercentpopulationinfection
from  portfolioproject..coviddeathdata
--where location like '%india%'
group by location, population
order by ipercentpopulationinfection desc
--

-- looking at people died of covid
SELECT location ,max (cast (total_deaths as int ) ) as totaldeathscount 
from  portfolioproject..coviddeathdata
--where location like '%india%'
where continent is not null

group by location
order by totaldeathscount desc

-- breaking the data by continent



-- the continents with highest death count

SELECT continent ,max (cast (total_deaths as int ) ) as totaldeathscount 
from  portfolioproject..coviddeathdata
--where location like '%india%'
where continent is not null

group by continent
order by totaldeathscount desc

--global numbers of deaths and deathpercentage

SELECT   sum( new_cases ) as total_cases,sum (cast (new_deaths as int ))as total_deaths,sum (cast (new_deaths as int ))/sum( new_cases )*100 as deathpercentage
from  portfolioproject..coviddeathdata
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that recived vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeathdata dea
Join PortfolioProject..COVIDvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeathdata dea
Join PortfolioProject..COVIDvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--- creating a temp table



DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated int
)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as rollingpeoplevaccinated
--, (RollingPeopleVaccinated/population)*100
from portfolioproject..coviddeathdata as dea
join portfolioproject..COVIDvaccination as vac
	On dea.location = vac.location
	and dea.date = vac.date
 
--order by 2,3

Select *, (rollingpeoplevaccinated/Population)*100
From #PercentPopulationVaccinated

---creat view to store data for  visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeathdata dea
Join PortfolioProject..COVIDvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * 
from PercentPopulationVaccinated 




