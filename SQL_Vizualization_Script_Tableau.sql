-- 1
select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as global_death_percent
from coviddeaths
where continent is not null
order by 1,2;

-- 2
Select continent, SUM(new_deaths) as TotalDeathCount
From coviddeaths
-- Where location like '%states%'
Where continent is not null
and location not in ('World', 'European Union', 'International')
Group by continent
order by TotalDeathCount desc;

-- 3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;

-- 4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
-- Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;