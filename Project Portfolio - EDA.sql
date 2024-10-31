-- Exploratory Data Analysis

SELECT *
FROM layoffs_new_2;

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_new_2
WHERE percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off 
SELECT *
FROM layoffs_new_2
WHERE percentage_laid_off=1;
-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT*
FROM layoffs_new_2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;
-- BritishVolt looks like an EV company, Quibi! I recognize that company - wow raised like 2 billion dollars and went under - ouch

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_new_2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;

SELECT MIN(`date`), MAX(`date`) FROM layoffs_new_2;

SELECT industry, SUM(total_laid_off) FROM layoffs_new_2
GROUP BY industry  ORDER BY SUM(total_laid_off) DESC;

SELECT country, SUM(total_laid_off) FROM layoffs_new_2
GROUP BY country ORDER BY SUM(total_laid_off) DESC;

SELECT `date`, SUM(total_laid_off) FROM layoffs_new_2
GROUP BY `date` ORDER BY `date` DESC;

SELECT monthname(`date`) `MONTH`, SUM(total_laid_off) FROM layoffs_new_2
GROUP BY monthname(`date`) ORDER BY SUM(total_laid_off) DESC;

SELECT YEAR(`date`), SUM(total_laid_off) FROM layoffs_new_2
GROUP BY YEAR(`date`) ORDER BY YEAR(`date`) DESC;


-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(`date`,1,7) `MONTH`, SUM(total_laid_off) FROM layoffs_new_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH` ORDER BY `MONTH` ASC;


-- now use it in a CTE so we can query off of it
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) `MONTH`, SUM(total_laid_off) total_off FROM layoffs_new_2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH` ORDER BY `MONTH` ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_new_2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_new_2
GROUP BY company, YEAR(`date`)
ORDER BY SUM(total_laid_off) DESC;

WITH Company_Year(company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_new_2
GROUP BY company, YEAR(`date`)
)
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC; 

WITH Company_Year(company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_new_2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT*
FROM Company_Year_Rank
WHERE Ranking<=5;
;
 