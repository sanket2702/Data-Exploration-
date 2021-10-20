-- checking the number of cases, new cases and total deaths 
select location, date, total_cases, new_cases, total_deaths, population from coviddeaths
order by 1,2;
select * from covidvaccinations;


-- looking at total cases vs total deaths shows the likelyhood of dying if you contract covid in your country ;

select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage from coviddeaths
where location like '%India%'
order by 1,2
;

-- total cases vs population
select location, date, Population, total_cases, (total_cases/Population)*100 as PercentagePopulationInfected from coviddeaths
order by 1,2;

-- total cases vs total deaths
select location, Population, MAX(total_cases) as InfectionCount, MAX((total_cases/total_deaths))*100 as PercentagePopulationInfected from coviddeaths
`where location like '%India%'`	
group by location, population
order by PercentagePopulationInfected desc;

-- Counting number of deaths from maximum deaths 
select location, Max(total_deaths) as total_death_count
from coviddeaths
where continent is not null
group by location
order by total_death_count desc
;

-- Global number of cases
select date, sum(new_cases) as total_cases,  sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from coviddeaths
where continent is not null
group by date
order by 1,2;

-- Total vaccinations vs population
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) from coviddeaths dea 
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 1,2,3;

-- Using cte to perform calculation on PARTITION BY in previous query
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from coviddeaths dea 
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/Population)*100 as PeopleVaccinated_percentage from PopvsVac;


-- Temp table 
drop table if exists percentpopulation_vaccinated;
CREATE table PercentPopulation_Vaccinated
(
 Continent varchar(255),
 Location varchar(255),
 date varchar(255),
 Population numeric,
 New_vaccinations char(255),
 RollingPeopleVaccinated numeric
);
Insert into PercentPopulation_Vaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from coviddeaths dea 
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date;
-- where dea.continent is not null;

select *, (RollingPeopleVaccinated/Population)*100 as PeopleVaccinated_percentage from PercentPopulation_Vaccinated;

-- creating views for later visualisations

create view PercentPopulationVaccinated as 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from coviddeaths dea 
join covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;