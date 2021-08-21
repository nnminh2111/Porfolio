/***

DATA EXPLORATION BY SQL
Skills used: JOIN, TEMP TABLE, CTE, CREATING VIEWS, CONVERT

***/

--*Students info base on code_presentation, region, gender:
--*By final_result:

SELECT final_result, COUNT(*) AS total_students
FROM studentInfo
GROUP BY final_result
ORDER BY Total_students DESC

--*By region:

SELECT region, COUNT(DISTINCT id_student) AS total_students
FROM studentInfo
GROUP BY region
ORDER BY region, total_students DESC

--*By gender and percentage of each:

WITH g AS
	(
	SELECT gender, COUNT(DISTINCT id_student) AS total_students
	FROM studentInfo
	GROUP BY gender
	)
SELECT g.gender,g.total_students, (g.total_students / CONVERT(float, COUNT(s.id_student))) * 100 AS percentage
FROM g, studentInfo s
GROUP BY g.gender, g.total_students


--*Students info base on result, percentage of disability and age_band
--*By age_band and their final result:

SELECT age_band, COUNT(*) AS total_students, final_result
FROM studentInfo
GROUP BY age_band, final_result
ORDER BY age_band, total_students DESC

--*Students have disabilities and their percentage in courses:

WITH d AS
	(
	SELECT disability, COUNT(*) AS total_students
	FROM studentInfo
	GROUP BY disability
	)
SELECT d.disability, d.total_students, (d.total_students / CONVERT(float, COUNT(s.id_student))) * 100 AS percentage
FROM d, studentInfo s
GROUP BY d.disability, d.total_students

--*Then, I want to know how many percent of students with disabibities complete the courses they attended
--*Percentage of students with disabilities complete the course they attended (with result: pass or distinction):

WITH d AS (
	SELECT disability, final_result, COUNT(*) AS total_students
	FROM studentInfo
	WHERE disability = 'Y'
	GROUP BY disability, final_result
	), t AS (
	SELECT COUNT(*) AS total
	FROM studentInfo
	WHERE disability = 'Y'
	)
SELECT d.disability, d.final_result, d.total_students,(CONVERT(float, d.total_students) / CONVERT(float, t.total)) * 100 as percentage
FROM d, t
WHERE d.final_result IN ('Distinction','Pass')

--*The number of students in each code_module and code_presentation:

SELECT code_module, code_presentation, COUNT(id_student) AS Total_students
FROM studentRegistration
WHERE date_registration IS NOT NULL
GROUP BY code_module, code_presentation
ORDER BY code_module, code_presentation

--*In this query, I want to know about the relation between pass/distinction of students and their interaction in VLE
--sum_lick: number of times students interact with the course materials

SELECT v.code_module, v.code_presentation, v.id_student, SUM(CONVERT(int, v.sum_click)) AS total_interact, i.final_result
FROM studentInfo i
	JOIN studentVle v
	ON i.id_student = v.id_student AND i.code_module = v.code_module AND i.code_presentation = v.code_presentation
GROUP BY v.code_module, v.code_presentation, v.id_student, i.final_result
ORDER BY total_interact DESC

--*After that, I would like to know which type of activity that attract more students interact base on sum_click:

SELECT vle.activity_type, SUM(CONVERT(int, v.sum_click)) AS total_interact
FROM vle
	JOIN studentVle v
	ON vle.id_site = v.id_site
GROUP BY vle.activity_type
ORDER BY total_interact DESC

--*In this query, I want to create the table about the total interacts for each students and their result:
--*Creating view for further viz and analyze:

CREATE VIEW interactvsfinalresult AS
	SELECT v.code_module, v.code_presentation, v.id_student, SUM(CONVERT(int, v.sum_click)) AS total_interact, i.final_result
	FROM studentInfo i
		JOIN studentVle v
		ON i.id_student = v.id_student AND i.code_module = v.code_module AND i.code_presentation = v.code_presentation
	GROUP BY v.code_module, v.code_presentation, v.id_student, i.final_result