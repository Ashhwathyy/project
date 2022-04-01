--Covid-19 Data Exploration
--Skills Used: Aggregate functions,Joins, CTE, Views, User-defined Function,Window functions,Rank, Converting Data Types


Select * from covid_death where continent is not null order by 3,4

--Total cases Vs ICU patients 

Select location,date,total_cases,icu_patients,(icu_patients/total_cases)*100 as ICU_percentage from covid_death

--Total Cases Vs Death

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercent 
from covid_death where continent is not null order by 4 desc

--Highest number of  total deaths according to continents

Select location, max(total_deaths)
from covid_death where location in ('Asia','Africa','North America',
'South America','Antarctica','Europe','oceannia' ) group by location
 
--Ranking continets (using cte)

with  continents 
as (select location, total_deaths,date from covid_death where location in ('Asia','Africa','North America',
'South America','Antarctica','Europe','oceannia'  )) 
Select location, total_deaths, DENSE_RANK() over( order by total_deaths desc ) as Rank
from continents where cast(date as date) = '2021-05-10' and total_deaths is not null

--Selecting data from tables (using Joins)

Select d.location,d.date,d.total_cases, d.new_cases,d.new_deaths,d.total_deaths,v.population from covid_death as d 
join covid_vac as v on d.location =v.location and d.date=v.date where d.continent is not null
order by 1,2

--Percentage of population affected with covid

Select d.location,d.date,d.total_cases, d.new_cases,d.new_deaths,d.total_deaths,v.population,
(d.total_cases/v.population)*100 as PercentPopulationInfected
from covid_death as d 
join covid_vac as v on d.location =v.location and d.date=v.date where d.continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select d.Location, v.Population, MAX(d.total_cases) as HighestInfectionCount, 
Max((d.total_cases/v.population)*100) as PercentPopulationInfected
From Covid_Death as d 
join covid_vac as v on d.location =v.location and d.date=v.date where d.continent is not null
Group by d.Location, v.Population
order by PercentPopulationInfected desc


--  Top 10 Countries with Highest Death Count per Population

Select  top 10 d.Location, max(v.population) as Totalpopulation, max(cast(d.total_deaths as int))  as TotalDeathCount
From Covid_Death as d 
join covid_vac as v on d.location =v.location and d.date=v.date where d.continent is not null
Group by d.Location
order by TotalDeathCount desc

-- Total Population, Total deaths and  Vaccinations 
-- Percentage of Population that has recieved at least one Covid Vaccine

Select d.continent, d.location, d.date, v.population,d.total_deaths, v.new_vaccinations
, SUM(Cast(v.new_vaccinations as numeric)) 
OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From Covid_Death as d 
join covid_vac as v on d.location =v.location and d.date=v.date where d.continent is not null 


---- Creating View to store data of fully vaccinated population 

Create view fully_vaccinated 
as
(Select d.continent, d.location, d.date, v.population,d.total_deaths, v.people_fully_vaccinated
, SUM(Cast(v.people_fully_vaccinated as numeric)) 
OVER (Partition by d.Location Order by d.location, d.Date) as PeopleVaccinated
From Covid_Death as d 
join covid_vac as v on d.location =v.location and d.date=v.date where d.continent is not null)

Select * from fully_vaccinated 


--User defined function

Create function vaccineinfo( @location varchar(25) )
returns table
as return( select continent,location, date,total_vaccinations,
people_vaccinated,people_fully_vaccinated,total_boosters from covid_vac where covid_vac.location=@location)

Select* from vaccineinfo('India')






