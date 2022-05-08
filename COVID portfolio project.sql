select *
from portfolio_project..['covid-deaths$']
where continent is not null 
--select *
--from portfolio_project..['covid-vaccinations$']

-- select Data that we are doing be using 

select location,date,total_cases,new_cases,total_deaths,population 
from portfolio_project..['covid-deaths$']
where continent is not null 
order by 1,2 

--looking at total death vs totla cases 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage 
from portfolio_project..['covid-deaths$']
where continent is not null 
order by 1,2

--looking at total cases vs population

select location,date,total_cases,population, (total_cases/population)*100 as population_get_covid
from portfolio_project..['covid-deaths$']
where location like '%states%'
and continent is not null 
order by 1,2

-- looking at a Highest infection rate	vs population 
select location,population,max(total_cases) as highest_cases ,max((total_cases/population))*100 as highest_infection_rate
from portfolio_project..['covid-deaths$']
group by location,population
order by highest_infection_rate desc

--looking a highest death countries per population 
select location ,max(cast(total_deaths as int)) as total_death_count
from portfolio_project..['covid-deaths$']
where continent is not null 
group by location
order by total_death_count desc

--looking to totaldeath by continent  
select continent ,max(cast(total_deaths as int)) as total_death_count
from portfolio_project..['covid-deaths$']
where continent is not null 
group by continent
order by total_death_count desc

--Global Numbers 
select  sum(new_cases) as total_new_cases,max(cast(new_deaths as int)) as total_new_death
,sum(cast(new_deaths as int))/sum(new_cases)*100 as new_death_percentage
from portfolio_project..['covid-deaths$']
where continent is not null 

--looking at total population vs vaccisination

select dea.continent , dea.location ,dea.date , dea.population , vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int ))
over(partition by dea.location order by dea.location,dea.date) rolling_people_vaccinations
--(rolling_people_vaccinations/dea.population)*100
from portfolio_project..['covid-deaths$'] dea 
join portfolio_project..['covid-vaccinations$'] vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null 
order by 2,3


--using CTA
with popvsvac (continent , location ,date ,population ,new_vaccinations,rolling_people_vaccinations)
as 
(
select dea.continent , dea.location ,dea.date , dea.population , vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int ))
over(partition by dea.location order by dea.location,dea.date) rolling_people_vaccinations
--(rolling_people_vaccinations/dea.population)*100
from portfolio_project..['covid-deaths$'] dea 
join portfolio_project..['covid-vaccinations$'] vac
on dea.date=vac.date
and dea.location=vac.location
where dea.continent is not null 
)
select * ,(rolling_people_vaccinations/population)*100
from popvsvac


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
from portfolio_project..['covid-deaths$'] dea 
join portfolio_project..['covid-vaccinations$'] vac
on dea.date=vac.date
and dea.location=vac.location
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
