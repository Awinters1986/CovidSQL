Select *
From Covid..CovidDeaths
Order By 3,4

Select *
From Covid..CovidVaccinations
Order By 3,4

--Data--
Select Location, date, total_cases, new_cases, total_deaths, population
From Covid..CovidDeaths
Order By 1,2

--Total Cases vs Total Deaths--
Select Location, date, total_cases, total_deaths, (CAST(total_deaths AS Float)/total_cases)*100 AS Death_Percentage
From Covid..CovidDeaths
Where Location like '%states%' AND continent is not null
Order By 2

--Total Cases vs Total Deaths 
--Filtered by the United States--
Select Location, date, total_cases, total_deaths, (CAST(total_deaths AS Float)/total_cases)*100 AS Death_Percentage
From Covid..CovidDeaths
Where Location like '%states%' AND continent is not null
Order By 2

--Totals Cases vs Population--
--Filtered by United States--
Select Location, date, population, total_cases, (total_cases/population)*100 AS Case_Percentage
From Covid..CovidDeaths
Where Location like '%states%' AND continent is not null
Order By 2

--Highest Infection Rates By Country--
Select Location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Population_Infected_Percentage
From Covid..CovidDeaths
Where continent is not null
Group By Location,Population
Order By Population_Infected_Percentage desc


--Highest Death Count by Country--
Select Location, MAX(total_deaths) AS Total_Death_Count
From Covid..CovidDeaths
Where continent is not null
Group By Location
Order By Total_Death_Count desc

--Highest Death Count by Continent--
Select location, MAX(total_deaths) AS Total_Death_Count
From Covid..CovidDeaths
Where continent is null AND location <> 'World'
Group By location
Order By Total_Death_Count desc

--Global Numbers--
--Death Percentage by Date--
Select date, SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Cases, (SUM(new_deaths)/SUM(new_cases))*100 AS Death_Percentage
From Covid..CovidDeaths
Where continent is not null
Group By date
Order By 1,2

--Total Death Percentage--
Select SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Cases, (CAST(SUM(new_deaths) AS float)/SUM(new_cases))*100 AS Death_Percentage
From Covid..CovidDeaths
Where continent is not null
Order By 1,2


--Joining CovidVaccinations and CovidDeaths--
Select *
From Covid..CovidVaccinations vac
Join Covid..CovidDeaths dea
On vac.location = dea.location
and vac.date = dea.date

--Total Population vs Vaccinations--
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order By 1, 2, 3

--Rolling Vaccinations by Location and Date--
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition By dea.location Order By CONVERT(nvarchar(75), dea.location), dea.date) AS Vaccination_Total
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order By 2, 3

--Rolling Vaccinations by Location and Date with Percentages--
--CTE PopsvsVac--
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Vaccination_Total)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition By dea.location Order By CONVERT(nvarchar(75), dea.location), dea.date) AS Vaccination_Total
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

Select *, (Vaccination_Total/Population)*100
From PopvsVac

--Rolling Vaccinations by Location and Date with Percentages--
--CTE PopsvsVacLoc--
With PopvsVacLoc (Continent, Location, Population, New_Vaccinations, Vaccination_Total)
AS
(
Select dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition By dea.location Order By CONVERT(nvarchar(75), dea.location)) AS Vaccination_Total
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

Select *, (Vaccination_Total/Population)*100
From PopvsVacLoc



--TEMP TABLE--
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar(75),
Date datetime,
Population numeric,
New_vaccinations numeric,
Vaccination_Total numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition By dea.location Order By CONVERT(nvarchar(75), dea.location), dea.date) AS Vaccination_Total
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

--Select From Temp Table--
Select *, (Vaccination_Total/Population)*100
From #PercentPopulationVaccinated

--Views to Store Data--
Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition By dea.location Order By CONVERT(nvarchar(75), dea.location), dea.date) AS Vaccination_Total
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

--Select from View--
Select *
From PercentPopulationVaccinated
