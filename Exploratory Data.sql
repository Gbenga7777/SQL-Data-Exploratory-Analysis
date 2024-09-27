-- Exploratory Data Analysis.
SELECT * 
FROM world_layoff.layoffs_staging2;

SELECT  MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoff.layoffs_staging2;

SELECT * 
FROM world_layoff.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off) 
FROM world_layoff.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`) 
FROM world_layoff.layoffs_staging2;

SELECT industry, SUM(total_laid_off) 
FROM world_layoff.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off) 
FROM world_layoff.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off) 
FROM world_layoff.layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off) 
FROM world_layoff.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT company, SUM(percentage_laid_off) 
FROM world_layoff.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`, 1, 7) AS 'MONTH', SUM(total_laid_off)
FROM world_layoff.layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1;

WITH ROLLING_TOTAL AS
(
SELECT SUBSTRING(`date`, 1, 7) AS 'MONTH', SUM(total_laid_off) AS total_off
FROM world_layoff.layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1
)
SELECT MONTH, total_off,
SUM(total_off) OVER(ORDER BY MONTH) AS rolling_total
FROM ROLLING_TOTAL;

SELECT company, SUM(total_laid_off) 
FROM world_layoff.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) 
FROM world_layoff.layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH COMPANY_YEAR AS 
(
SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
FROM world_layoff.layoffs_staging2
GROUP BY company, YEAR(`date`)
),
COMPANY_YEAR_RANK AS 
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM COMPANY_YEAR
WHERE years IS NOT NULL
)
SELECT *
FROM COMPANY_YEAR_RANK
WHERE Ranking <= 5;










