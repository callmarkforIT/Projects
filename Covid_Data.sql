/****** SQL Exploratory Data Analysis  ******/
/****** Using Covid Data  ******/

SELECT *
FROM dbo.[Covid-Data]
;


--Select all data (250,384 rows)
	SELECT 
		*
	FROM
		dbo.[Covid-Data]
	ORDER BY 
		3,
		4
;


--Shows only rows with the LATEST data on each country () & save it as a temp table called #latest_data
	SELECT
		a.*
	INTO #latest_data
	FROM
		dbo.[Covid-Data] a
	JOIN	(
			SELECT 
				DISTINCT location, 
				MAX(date) AS updated_date
			FROM
				dbo.[Covid-Data]
			WHERE 
				iso_code NOT LIKE '%OWID%' 
				AND location IS NOT NULL --this is to exclude subtotal per continent and subtotal per income status
			GROUP BY 
				location
			)
			b on a.location = b.location AND a.date = b.updated_date
	ORDER BY 
		location
;

--Show all data for temp table #latest_data
	SELECT
		*
	FROM
		#latest_data
;


--Looking at Total Cases vs. Total Deaths
--Shows the likelihood of dying if you contract COVID-19
	SELECT 
		location, 
		date, 
		total_cases, 
		new_cases, 
		total_deaths, 
		--(total_deaths/total_cases)*100 AS death_percentage
		CONCAT(ROUND((total_deaths/total_cases)*100,2), '%') AS death_percentage 
		--the ROUND function is used to round the death_percentage column to 2 decimal places, 
		--and then the CONCAT function is used to concatenate the '%' symbol to the end of the number.
	FROM
		#latest_data
	ORDER BY 
		death_percentage DESC,
		location
	;

--Looking at the Total Infections vs. Population
	SELECT
		location AS 'Country',
		total_cases AS 'Total Infections',
		population AS 'Total Population',
		CONCAT(ROUND((total_cases/population)*100,2), '%') AS '% of Infected Pop'
	FROM
		#latest_data
	ORDER BY
		'% of Infected Pop' DESC,
		location
	;

--Show stats per continent
	SELECT 
		continent AS 'Continent',
		SUM(population) AS 'Population',
		ROUND(SUM(total_cases_per_million),2) AS 'Cases per Million', 
		SUM(total_cases) AS 'Total Cases',
		--CONCAT(ROUND((total_cases/population)*100,2), '%') AS '% of Infected Pop',
		ROUND(SUM(total_deaths_per_million),2) AS 'Total Deaths per Million',
		SUM(total_deaths) AS 'Total Deaths'
		--CONCAT(ROUND((total_deaths/population)*100,2), '%') AS '% of Deaths Pop'
	FROM 
		#latest_data
	GROUP BY 
		continent
	ORDER BY
		'Total Cases' DESC
	;

--Is there a correlation between GDP per capita and total deaths?
	--this can be answered by using a programming language
	;


--Creating temp table named #hosp_icu_data to find the most recent data 
	--with value that is not null for hospitalization and ICU rates columns
	SELECT
		a.*
	INTO #hosp_icu_data
	FROM
		dbo.[Covid-Data] a
	JOIN	(
			SELECT 
				DISTINCT location, 
				MAX(date) AS updated_date
			FROM
				dbo.[Covid-Data]
			WHERE 
				iso_code NOT LIKE '%OWID%' 
				AND location IS NOT NULL --this is to exclude subtotal per continent and subtotal per income status
				AND hosp_patients IS NOT NULL 
				AND icu_patients IS NOT NULL
			GROUP BY 
				location
			)
			b on a.location = b.location AND a.date = b.updated_date
	ORDER BY 
		location
	;
	SELECT 
		* 
	FROM 
		#hosp_icu_data --Show temp table #hosp_icu_data (34 rows only due to missing hosp & icu data)
	;

--How do hospitalization rates and ICU rates vary by country? (34 rows only due to missing hosp & icu data)
	SELECT
		location,
		SUM(hosp_patients) AS 'Hospitalized',
		SUM(icu_patients) AS 'ICU Patients',
		MAX(total_cases) AS 'Total Infected',
		CONCAT(ROUND(MAX(CONVERT(decimal(20,2),ISNULL(hosp_patients,0))) 
		/ MAX(CONVERT(float,total_cases))*100,2), '%') AS 'Percentage of Hosp Infections'
	FROM
		#hosp_icu_data
	GROUP BY
		location
	ORDER BY
		5 DESC
	;

--What is the impact of population density on the number of new cases?
	--this can be answered by using a programming language
	;

--Show the percentage of the population that has been fully vaccinated
	SELECT
		location,
		MAX(people_fully_vaccinated) AS 'Total Vaccinated',
		MAX(population) AS 'Population',
		CONCAT(ROUND(MAX(CONVERT(decimal(20,2),ISNULL(people_fully_vaccinated,0))) 
		/ MAX(CONVERT(float,population))*100,2), '%') AS 'Percentage of Vac Pop'
	FROM
		dbo.[Covid-Data]
	WHERE 
		continent IS NOT NULL
	GROUP BY 
		location
	ORDER BY
		'Percentage of Vac Pop' DESC
	;

--Show the percentage of the population that has been fully vaccinated
	SELECT
		location,
		MAX(total_cases) AS 'Total Cases',
		MAX(population) AS 'Population',
		CONCAT(ROUND(MAX(CONVERT(decimal(20,2),ISNULL(people_fully_vaccinated,0))) 
		/ MAX(CONVERT(float,population))*100,2), '%') AS 'Percentage of Vac Pop'
	FROM
		dbo.[Covid-Data]
	WHERE 
		continent IS NOT NULL
	GROUP BY 
		location
	ORDER BY
		'Population' DESC
	;