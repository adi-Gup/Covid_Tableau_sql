drop table if exists coviddeaths;
CREATE TABLE coviddeaths
(iso_code varchar(255),
continent varchar(255),	
location varchar(255),	
population int,	
date date,	
total_cases int,	
new_cases int,	
total_deaths int,	
new_deaths int
);
SET SESSION sql_mode = '';
 load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CovidDeaths1.csv' into table coviddeaths
 fields terminated by ','
 ignore 1 rows;
 
 
 create table covidvaccinations
 (
 iso_code varchar(255),
 continent varchar(255),
 location varchar(255),
 date date,
 new_tests int,
 total_tests int,
 total_vaccinations int,
 people_vaccinated	int,
 people_fully_vaccinated int,
 new_vaccinations int
 );
 select * from covidvaccinations;
 load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CovidVaccinations.csv' into table covidvaccinations
 fields terminated by ','
 optionally enclosed by '"'
 ignore 1 lines;
 drop table if exists covidvaccinations;
 create table covidvaccinations
 (
 iso_code varchar(255),
 continent varchar(255),
 location varchar(255),
 date date,
 new_tests numeric,
 total_tests numeric,
 total_vaccinations numeric,
 people_vaccinated	numeric,
 people_fully_vaccinated numeric,
 new_vaccinations numeric
 );
 SET SESSION sql_mode = '';
 load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CovidVaccination1s.csv' into table covidvaccinations
 fields terminated by ','
 -- optionally enclosed by '"'
 ignore 1 rows;
 
 
 select @@secure_file_priv;
 
 
















SELECT * FROM covidvaccinations;
SELECT * 
FROM coviddeaths
order by 3,4;

-- Selecting the appropriate columns for our calculations
select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths
order by 1,2;

-- Total cases vs total death percentage
-- Likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,population, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
order by 1,2;

-- Looking at total cases vs population
-- What percentage of population has got covid
select location,date,population,total_cases,total_deaths, (total_cases/population)*100 as percent_pop_infected
from coviddeaths
order by  1,3;

-- Looking at countries with highest infection rate compared to population
select location,population,MAX(total_cases) as highest_infected_count, MAX((total_cases/population))*100 as percent_pop_infected
from coviddeaths
group by population,location
order by percent_pop_infected desc;

-- Looking at countries with highest death counts as per population
select continent,location, population, MAX(cast(total_deaths as float)) as highest_death_count
from coviddeaths
where continent is not null
group by location
order by highest_death_count desc;

-- Looking at continents with highest death counts as per population
select continent, population, MAX(cast(total_deaths as float)) as highest_death_count
from coviddeaths
where continent is not null
group by continent
order by highest_death_count desc;

-- Global numbers
select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as global_death_percent
from coviddeaths
where continent is not null
order by 1,2;

-- Looking at total population vs total vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_ppl_vaccinated
from coviddeaths as dea
join covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

-- Using CTE to find Total population vs people vaccinated

with pop_vs_vac ( continent, location, date, population, new_vaccinations, rolling_ppl_vaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_ppl_vaccinated
from coviddeaths as dea
join covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (rolling_ppl_vaccinated/population)*100 as ppl_vaccinated_percent
from pop_vs_vac;

-- Temp table
drop table if exists percent_ppl_vaccinated;
Create table percent_ppl_vaccinated
(
continent char(255),
location char(255),
date char(255),
population int,
new_vaccinations int,
rolling_ppl_vaccinated int
);

insert into percent_ppl_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_ppl_vaccinated
from coviddeaths as dea
join covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
-- order by 2,3;

select *, (rolling_ppl_vaccinated/population)*100 as ppl_vaccinated_percent
from percent_ppl_vaccinated;

-- Creating view for further visualizations
create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_ppl_vaccinated
from coviddeaths as dea
join covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

create view  global_death_percentage as
select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as global_death_percent
from coviddeaths
where continent is not null
order by 1,2;


     
      












