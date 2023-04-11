#Looking dataset

select Location, date, total_cases, new_cases, total_deaths, population
from `Crona.Coviddeath`
order by 1, 2

#Looking at total cases vs total deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from `Crona.Coviddeath`
order by 1, 2

#Looking at total cases vs population

select Location, date, total_cases, population, (total_deaths/population)*100 as population_percentage
from `Crona.Coviddeath`
order by 1, 2

#Looking at country wuith hightst infected rate

select Location, population, Max(total_cases) as highestinfectioncount, Max((total_deaths/population))*100 as Infectionrate
from `Crona.Coviddeath`
GROUP BY Location, Population
order by Infectionrate desc

#Shpwing countries with hightest death count per population

select Location, MAX(total_deaths) AS totaldeathcount
from `Crona.Coviddeath`
GROUP BY Location
order by totaldeathcount desc

#Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From `Crona.Coviddeath`
Where continent is not null 
Group by continent
order by TotalDeathCount desc

#GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From `Crona.Coviddeath`
where continent is not null 
order by 1,2

#Total Population vs Vaccinations
#Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From `Crona.Coviddeath` dea
Join `Crona.CovidVacc` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

#Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
         SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
  FROM `Crona.Coviddeath` dea
  JOIN `Crona.CovidVacc` vac
    ON dea.location = vac.location AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL 
  ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac;

#Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From `Crona.Coviddeath` dea
Join `Crona.CovidVacc` vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

#Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From `Crona.Coviddeath` dea
Join `Crona.CovidVacc` vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
