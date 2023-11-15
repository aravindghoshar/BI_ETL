CREATE TABLE DimUserAgent(
UserAgent nvarchar(max),
Browser nvarchar(max),
ClientOS varchar(50))

CREATE TABLE DimVisitType(
[FileName] nvarchar(max),
VisitType varchar(50))

CREATE TABLE DimStatus(
[StatusCode] nvarchar(50),
StatusType nvarchar(50))

--SELECT * FROM OutFact1
--SELECT * FROM OutFact2

---------------------------------------USER AGENT--------------------------------------------

DROP TABLE IF EXISTS #TempUserAgent

SELECT DISTINCT
	UserAgent 
INTO #TempUseragent 
FROM OutFact1 

DROP TABLE IF EXISTS #Temp2
SELECT
	UserAgent		= T.UserAgent,
	Browser			= CASE		
						WHEN T.UserAgent LIKE '%bot%' THEN 'bots'
						WHEN T.UserAgent LIKE '%Firefox%' THEN 'Firefox'
						WHEN T.UserAgent LIKE '%Chrome%' THEN 'Chrome'
						WHEN T.UserAgent LIKE '%Safari%' THEN 'Safari'
						WHEN T.UserAgent LIKE '%Baiduspider%' THEN 'Baiduspider'
						WHEN T.UserAgent LIKE '%Opera%' THEN 'Opera'
						WHEN T.UserAgent LIKE '%Yandex%' THEN 'Yandex'
						ELSE 'Other'
					 END,
	ClientOS		= CASE			
						WHEN T.UserAgent LIKE '%Windows%' THEN 'Windows'
						WHEN T.UserAgent LIKE '%Macintosh%' OR T.UserAgent LIKE '%Mac%' THEN 'Macintosh'
						WHEN T.UserAgent LIKE '%Linux%' THEN 'Linux'
						ELSE 'Other'
					  END
INTO #Temp2
FROM #TempUseragent T

INSERT INTO DimUserAgent
SELECT 
	UserAgent	= T.UserAgent,
	Browser		= T.Browser,
	ClientOS	= T.ClientOS	
FROM #Temp2 T



--------------------------------FILE DIMENSION-------------------------------

DROP TABLE IF EXISTS #TempFileName
DROP TABLE IF EXISTS #Temp3

SELECT 
	DISTINCT [FileName] AS [FileName] 
INTO #TempFileName
FROM OutFact1 

SELECT
	[FileName]	= F.FileName,
	VisitType	= CASE		
					WHEN F.FileName LIKE '%robots.txt%' THEN 'Web Crawler'
					ELSE 'Real Visit'
				  END
INTO #Temp3
FROM #TempFileName F

INSERT INTO DimVisitType
SELECT 
	[FileName]		= T.FileName,
	VisitType		= T.VisitType
FROM #Temp3 T

------------------------STATUS DIMENSION----------------------------------------------

DROP TABLE IF EXISTS #TempStatus
DROP TABLE IF EXISTS #Temp4

SELECT DISTINCT StatusCode INTO #TempStatus FROM OutFact2


SELECT
	StatusCode			= E.StatusCode,
	StatusType			= CASE			
							WHEN E.StatusCode BETWEEN '200' AND '299' THEN 'Successful Response'
							WHEN E.StatusCode BETWEEN '300' AND '399' THEN 'Redirection Messages'
							WHEN E.StatusCode BETWEEN '400' AND '499' THEN 'Client Error Response'
							WHEN E.StatusCode BETWEEN '500' AND '599' THEN 'Server Error Response'							
							ELSE 'Other'
						 END
INTO #Temp4
FROM #TempStatus E

INSERT INTO DimStatus
SELECT 
	StatusCode				= T.StatusCode,
	StatusType				= T.StatusType
FROM #Temp4 T


	









