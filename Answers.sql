/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- ¿Cuál es la distribución de las horas diarias promedio de uso de redes sociales según el género de los estudiantes?

WITH All_freq AS (
    SELECT Gender,
        CASE
            WHEN Avg_Daily_Usage_Hours BETWEEN 1.0 AND 2.9 THEN '1-2'
            WHEN Avg_Daily_Usage_Hours BETWEEN 3.0 AND 4.9 THEN '3-4'
            WHEN Avg_Daily_Usage_Hours BETWEEN 5.0 AND 6.9 THEN '5-6'
            WHEN Avg_Daily_Usage_Hours BETWEEN 7.0 AND 8.9 THEN '7-8'
            ELSE '8+'
        END AS range_hours
    FROM stu_smedia_addiction
    WHERE Gender IN ('Male', 'Female')
)
SELECT range_hours,
    COUNT(CASE WHEN Gender = 'Female' THEN 1 END) AS freq_female,
    COUNT(CASE WHEN Gender = 'Male' THEN 1 END) AS freq_male
FROM All_freq
GROUP BY range_hours
ORDER BY range_hours;

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- ¿Cómo varía el puntaje de adicción a redes sociales (Addicted_Score) por nivel académico (High School, Undergraduate, Graduate)?

SELECT Academic_Level, AVG(Addicted_Score) AS Mean, ROUND(VAR_SAMP(Addicted_Score),3) AS var_muestral
FROM stu_smedia_addiction
GROUP BY Academic_Level;

-- Con respecto a la media de cada nivel academico la varianza muestral presenta valores mas agrupados a su media

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- ¿Qué países presentan los mayores promedios de horas diarias de uso de redes sociales entre los estudiantes?

SELECT Country, ROUND(AVG(Avg_Daily_Usage_Hours),2) AS avg_per_country
FROM stu_smedia_addiction
GROUP BY Country
ORDER BY avg_per_country DESC;

-- Los paises con promedios mas altos de usos de redes sociales por sus estudiantes
-- Estados Unidos: 6,89 - Emiratos Arabes: 6,72 - Mexico: 6,42

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- ¿Existe alguna diferencia significativa en el puntaje de salud mental (Mental_Health_Score) entre estudiantes de diferentes edades?

SELECT Age, ROUND(AVG(Mental_Health_score),2) AS mean_per_age
FROM stu_smedia_addiction
GROUP BY Age
ORDER BY mean_per_age DESC;

-- de 1 a 10 donde 1 es malo y 10 excelente
-- el promedio de salud mental por cada edad es de 6 puntos aprox
-- donde las personas de 23 tienen una mejor salud mental frente a personas de 18 años

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- ¿Cuál es la plataforma de redes sociales más utilizada entre los estudiantes y cómo se distribuye su uso por país?

SELECT Most_Used_Platform, COUNT(Most_Used_Platform) AS platform_count
FROM stu_smedia_addiction
GROUP BY Most_Used_Platform
ORDER BY platform_count DESC;

-- R/ Instagram es la red mas usada de todos los estudiantes
WITH Distribution_per_academicLevel AS (
SELECT Country, Academic_Level, COUNT(Most_Used_Platform) as cnt
FROM stu_smedia_addiction
WHERE Most_Used_Platform = 'Instagram'
GROUP BY Country, Academic_Level, Most_Used_Platform
),

Result AS (

SELECT Country,
CASE
	WHEN Academic_Level = 'Undergraduate' THEN cnt
    END AS undergraduate,
CASE
    WHEN Academic_Level = 'Graduate' THEN cnt
    END AS graduate,
CASE
    WHEN Academic_Level = 'High School' THEN cnt
    END AS highschool
    
FROM Distribution_per_academicLevel
)


-- Los estudiantes que aun no se graduan usan mas la app de Instagram frente a estudiantes de secundaria y graduados

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- ¿Qué proporción de estudiantes que usan TikTok como su plataforma principal reportan un impacto negativo en su rendimiento académico?
SELECT 
		ROUND(SUM(CASE
			WHEN Affects_Academic_Performance = 'Yes' THEN 1
			END) * 100 / (SELECT COUNT(*) FROM stu_smedia_addiction WHERE Most_Used_Platform = 'TikTok'),2) AS percentage_Yes,
			
		ROUND(SUM(CASE
			WHEN Affects_Academic_Performance = 'No' THEN 1 
			END) * 100 / (SELECT COUNT(*) FROM stu_smedia_addiction WHERE Most_Used_Platform = 'TikTok'),2) AS percentage_No
    
FROM stu_smedia_addiction
WHERE Most_Used_Platform = 'TikTok';

-- El 6,49% de estudiantes reporta que usar tiktok tiene concecuencias negativas en sus estudios 

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Cómo se distribuyen las horas diarias promedio de uso de redes sociales entre 
-- los estudiantes que reportan conflictos relacionados con redes sociales?

WITH conflict_freq AS (
    SELECT Conflicts_Over_Social_Media,
        CASE
            WHEN Avg_Daily_Usage_Hours BETWEEN 1.0 AND 2.9 THEN '1-2'
            WHEN Avg_Daily_Usage_Hours BETWEEN 3.0 AND 4.9 THEN '3-4'  -- Definimos rango de horas
            WHEN Avg_Daily_Usage_Hours BETWEEN 5.0 AND 6.9 THEN '5-6'
            WHEN Avg_Daily_Usage_Hours BETWEEN 7.0 AND 8.9 THEN '7-8'
            ELSE '8+'
        END AS range_hours
    FROM stu_smedia_addiction
    
)
SELECT range_hours,
    SUM(CASE WHEN Conflicts_Over_Social_Media = 1 THEN 1 
			   WHEN Conflicts_Over_Social_Media = 2 THEN 1
               WHEN Conflicts_Over_Social_Media = 3 THEN 1  -- cuenta casos de entre 1 a 5 personas
               WHEN Conflicts_Over_Social_Media = 4 THEN 1
               WHEN Conflicts_Over_Social_Media = 5 THEN 1 
               ELSE 0 END) AS freq_conflicts
FROM conflict_freq
GROUP BY range_hours                                        -- agrupa por rango de horas y ordena
ORDER BY range_hours;


-- Estudiantes que usan las redes sociales de 3-4 horas o 5-6 tienden a tener mas problemas en sus relaciones personales

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Qué plataformas de redes sociales están asociadas con los mayores puntajes de adicción (Addicted_Score ≥ 8)?

SELECT Most_Used_Platform, COUNT(Addicted_Score) as puntaje_adiccion
FROM stu_smedia_addiction
WHERE Addicted_Score >= 8
GROUP BY Most_Used_Platform
ORDER BY puntaje_adiccion DESC;

-- TikTok es Reportada como la app con mayor recuento de score de adiccion  mayor a 7 puntos

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Cuál es la relación entre las horas diarias de uso de redes sociales y el reporte de impacto negativo en el rendimiento académico?

WITH academic_p AS (
    SELECT Affects_Academic_Performance,
        CASE
            WHEN Avg_Daily_Usage_Hours BETWEEN 1.0 AND 2.9 THEN '1-2'
            WHEN Avg_Daily_Usage_Hours BETWEEN 3.0 AND 4.9 THEN '3-4'  -- Definimos rango de horas
            WHEN Avg_Daily_Usage_Hours BETWEEN 5.0 AND 6.9 THEN '5-6'
            WHEN Avg_Daily_Usage_Hours BETWEEN 7.0 AND 8.9 THEN '7-8'
            ELSE '8+'
        END AS range_hours
    FROM stu_smedia_addiction
    
)
SELECT range_hours,
    SUM(CASE WHEN Affects_Academic_Performance = 'Yes' THEN 1 
			 ELSE 0 END) AS perfor_Yes,
	SUM(CASE WHEN Affects_Academic_Performance = 'No' THEN 1 
			 ELSE 0 END) AS perfor_No
FROM academic_p
GROUP BY range_hours                                        -- agrupa por rango de horas y ordena
ORDER BY range_hours;

-- Existe una relacion positiva entre las horas y el impacto negativo en el rendimiento académico
-- Entre mas horas se usen las redes sociales mas reporte se obtienen de impacto negativo en el rendimiento

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Los estudiantes con un puntaje de salud mental bajo (Mental_Health_Score ≤ 5) 
-- tienen un promedio de horas de sueño por noche significativamente menor que aquellos con puntajes más altos?

SELECT 'score <= 5' AS score, ROUND(AVG(Sleep_Hours_Per_Night),2) AS mean_sleep
FROM stu_smedia_addiction
WHERE Mental_Health_Score <= 5
UNION
SELECT 'score >= 5' AS score, ROUND(AVG(Sleep_Hours_Per_Night),2) AS mean_sleep
FROM stu_smedia_addiction
WHERE Mental_Health_Score >= 5;

-- Se confirma que quienes reportan un score menor igual a 5 en promedio duermen 5 a 6 horas 
-- que estudiantes con un score mayor a 5 que duermen 6 a 7 horas

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Qué proporción de estudiantes que reportan un impacto negativo en su rendimiento académico 
-- también tienen un puntaje de adicción alto (Addicted_Score ≥ 7)?

WITH proportion AS (
SELECT Addicted_Score, Affects_Academic_Performance
FROM stu_smedia_addiction
WHERE Addicted_Score >= 7
)
SELECT COUNT(*) * 100 / (SELECT COUNT(*) FROM proportion) AS proportions
FROM proportion;

-- el 100% de estudiantes que tienen un puntaje de accion >=7 reportan impacto negativo en su rendimiento academico

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Cómo varía el puntaje de salud mental (Mental_Health_Score) entre los estudiantes que reportan conflictos relacionados con 
-- redes sociales y aquellos que no?

SELECT FLOOR(AVG(Mental_Health_Score)) mean_score, 'Si' AS reporte_conflicts
FROM stu_smedia_addiction
WHERE Conflicts_Over_Social_Media > 0
UNION 
SELECT FLOOR(AVG(Mental_Health_Score)), 'No'
FROM stu_smedia_addiction
WHERE Conflicts_Over_Social_Media = 0;

-- El score_mental_health para estudiantes que no tienen problemas en sus relaciones personales es de 8
-- para quienes tienen problemas en sus relaciones su score es de 6 

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Los estudiantes en una relación reportan un mayor número de conflictos relacionados 
-- con redes sociales en comparación con los solteros (Single) 

SELECT Relationship_Status, AVG(Conflicts_Over_Social_Media) AS mean_conflict
FROM stu_smedia_addiction
GROUP BY Relationship_Status;

-- En promedio estudiantes en una relacion tienen menor numero de conflictos personales que estudiantes solteros

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Existe una correlación entre el puntaje de adicción a redes sociales (Addicted_Score) 
-- y el número de conflictos relacionados con redes sociales (Conflicts_Over_Social_Media)?

SELECT Addicted_Score,
SUM(CASE
	WHEN Conflicts_Over_Social_Media  BETWEEN 0 AND 5 THEN 1
    END) AS frequency
FROM stu_smedia_addiction
GROUP BY Addicted_Score
ORDER BY Addicted_Score ASC;
-- Existe una correlacion positiva en donde los estudiantes con un mayor score de adiccion 
-- tienden a tener mas conflictos en sus relaciones personales

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Cómo se distribuye el puntaje de adicción a redes sociales (Addicted_Score) según el estado de relación (Relationship_Status)?

SELECT Addicted_Score,
SUM(CASE 
	WHEN Relationship_Status = 'In Relationship' THEN 1
    ELSE 0
    END) AS en_relacion,
SUM(CASE 
	WHEN Relationship_Status = 'Single' THEN 1
    ELSE 0
    END) AS Soltero,
SUM(CASE 
	WHEN Relationship_Status = 'Complicated' THEN 1
    ELSE 0
    END) AS Complicado
FROM stu_smedia_addiction
GROUP BY Addicted_Score
ORDER BY Addicted_Score ASC;

-- Se Evidencia mucha friccion donde el Score de adiccion es de 7 y el status es SOLTERO
-- Para status EN RELACION se ven muchos menos casos cuando el score es de 7, pero hay una alza significativa en un score de 5
-- Para el status COMPLICADO es mucho menor la friccion cuando el score es de 7 y se mantiene la friccion por debajo de estos 2 ultimos status

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Cuál es el promedio de horas de sueño por noche (Sleep_Hours_Per_Night) para los estudiantes con un puntaje de adicción alto 
-- (Addicted_Score ≥ 8) en comparación con aquellos con un puntaje bajo (Addicted_Score ≤ 4)?

WITH clasificacion AS (SELECT Sleep_Hours_Per_Night, IF(Addicted_Score >= 8, 'mayor igual 8', 'menor igual 4') AS clasif
FROM stu_smedia_addiction)

SELECT clasif, ROUND(AVG(Sleep_Hours_Per_Night),2) AS Mean
FROM clasificacion
GROUP BY clasif;

-- Se evidencia que para score de adiccion altos las horas que pasan durmiendo en promedio son de 5 a 6 horas
-- Mientras que para estudiantes con score bajo de adiccion duermen 7h aprox

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Qué proporción de estudiantes con un puntaje de salud mental bajo (Mental_Health_Score ≤ 5) duermen menos de 6 horas por noche?

WITH calc_prop AS (
SELECT COUNT(Mental_Health_Score) AS proportion, 
(SELECT COUNT(Mental_Health_Score) FROM stu_smedia_addiction WHERE Mental_Health_Score <= 5) AS total
FROM stu_smedia_addiction
WHERE Mental_Health_Score <= 5 AND Sleep_Hours_Per_Night < 6)

SELECT ROUND(proportion * 100 / total,2) AS proportion_stu_mental_5
FROM calc_prop;

-- De los estudiantes que tienen un score de salud mental por debajo o igual a 5 el 48.02% duermen menos de 6 horas por noche

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- ¿Existen estudiantes con valores atípicos en las horas diarias de uso de redes sociales (> 8 horas) 
-- y cómo se comparan sus puntajes de salud mental y adicción con el resto?

SELECT ROUND(AVG(Mental_Health_Score),2)AS MScore, ROUND(AVG(Addicted_Score),2) AS MAscore, 
IF(Avg_Daily_Usage_Hours >= 8, 'Atypical', 'Typical') AS clasification
FROM stu_smedia_addiction
GROUP BY clasification;

-- El promedio de score mental y adiccion para esos outliers son de 5 y 9 respectivamente
-- Frente al promedio que es de 6.24 y 6.41 

/*---------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- ¿Qué características demográficas (edad, género, país) son más comunes entre los estudiantes con el puntaje de adicción más alto 
-- (Addicted_Score = 9)

CREATE TEMPORARY TABLE IF NOT EXISTS temporal AS (
		SELECT Age, Gender, Country
		FROM stu_smedia_addiction
		WHERE Addicted_Score = 9);
        
SELECT Age, ROUND(COUNT(Age) * 100 / (SELECT COUNT(*) FROM stu_smedia_addiction WHERE Addicted_Score = 9),2) AS Proportion_age
FROM temporal
GROUP BY Age
ORDER BY Proportion_age DESC;

SELECT Gender, ROUND(COUNT(Gender) * 100 / (SELECT COUNT(*) FROM stu_smedia_addiction WHERE Addicted_Score = 9),2) AS Proportion_Gender
FROM temporal
GROUP BY Gender
ORDER BY Proportion_Gender DESC;

SELECT Country, ROUND(COUNT(Country) * 100 / (SELECT COUNT(*) FROM stu_smedia_addiction WHERE Addicted_Score = 9),2) AS Proportion_Country
FROM temporal
GROUP BY Country
ORDER BY Proportion_Country DESC;

-- para el grupo de estudiantes con score = 9:
-- El 58.18% recide en USA, en cuanto su genero el 85.45% es representado por el genero mujer y de esa poblacion el 56.36% tiene 19 años








