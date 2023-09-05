USE KN302_Agafonov
GO

IF OBJECT_ID('GetStudentsCountWhoGotMoreThanXPoints') IS NOT NULL
    DROP FUNCTION GetStudentsCountWhoGotMoreThanXPoints
GO

IF OBJECT_ID('GetAveragePointsBySubjectWhenGotMoreThanXInOther') IS NOT NULL
    DROP FUNCTION GetAveragePointsBySubjectWhenGotMoreThanXInOther
GO

IF OBJECT_ID('GetStudentNameByScoreRegionAndSubject') IS NOT NULL
    DROP FUNCTION GetStudentNameByScoreRegionAndSubject
GO

IF OBJECT_ID('GetParticipantsListThatGotMoreThanXPointsInTwo����2$') IS NOT NULL
    DROP PROCEDURE GetParticipantsListThatGotMoreThanXPointsInTwo����2$
GO

IF OBJECT_ID('ScoreSum') IS NOT NULL
	DROP VIEW ScoreSum

IF OBJECT_ID('GetStudentList') IS NOT NULL
    DROP PROCEDURE GetStudentList
GO

IF OBJECT_ID('GetNameByID') IS NOT NULL
    DROP FUNCTION GetNameByID
GO

IF OBJECT_ID('Transform') IS NOT NULL
    DROP FUNCTION Transform
GO

IF OBJECT_ID('CombineMinAndMax2') IS NOT NULL
    DROP FUNCTION CombineMinAndMax2
GO

IF OBJECT_ID('GetCombinations') IS NOT NULL
    DROP FUNCTION GetCombinations
GO

--a

	
GO
CREATE FUNCTION GetStudentsCountWhoGotMoreThanXPoints(@x INT, @firstSubject NVARCHAR(250), @secondSubject NVARCHAR(250), @thirdSubject NVARCHAR(250))
RETURNS INT
AS BEGIN
	DECLARE @count INT;
	
	WITH Fixed AS (
		SELECT s.����������, [����� ���������], �����
		FROM ����3$ as f
		LEFT JOIN ����2$ as s ON f.���������� = s.�����
		WHERE s.���������� IN (@firstSubject, @secondSubject, @thirdSubject)
	)
	SELECT @count = COUNT(*) FROM (
		SELECT [����� ���������]
		FROM Fixed
		GROUP BY [����� ���������]
		HAVING SUM(�����) > @x
	) AS _


    RETURN @count
END

GO

--����� ��� �

PRINT(dbo.GetStudentsCountWhoGotMoreThanXPoints(0, '������� ����', '����������', '�����������'))

PRINT(dbo.GetStudentsCountWhoGotMoreThanXPoints(400, '������� ����', '����������', '�����������'))

PRINT(dbo.GetStudentsCountWhoGotMoreThanXPoints(200, '', '', ''))



--b	

GO
CREATE FUNCTION GetAveragePointsBySubjectWhenGotMoreThanXInOther(@targetSubject NVARCHAR(250), @secondSubject NVARCHAR(250), @secondSubjectScore INT)
RETURNS FLOAT
AS BEGIN
	DECLARE @avg FLOAT;
	
	WITH Numbers AS (
		SELECT [����� ���������]
		FROM ����3$ as f
		LEFT JOIN ����2$ as s ON f.���������� = s.�����
		WHERE s.���������� = @secondSubject AND ����� > @secondSubjectScore
	), TEMP AS (
		SELECT �����
		FROM ����3$ as f
		LEFT JOIN ����2$ as s ON f.���������� = s.�����
		WHERE s.���������� = @targetSubject AND [����� ���������] IN (SELECT * FROM Numbers)
	)
	SELECT @avg = AVG(�����) FROM TEMP


    RETURN @avg
END

GO

--����� ��� b


PRINT(dbo.GetAveragePointsBySubjectWhenGotMoreThanXInOther('������� ����', '������� ����', 0))

PRINT(dbo.GetAveragePointsBySubjectWhenGotMoreThanXInOther('������� ����', '������� ����', 99))


--c

GO

CREATE PROCEDURE GetStudentList
	@score INT
AS
BEGIN
	DECLARE @FullName NVARCHAR(255), @ID INT, @Subjects NVARCHAR(2500), @Line NVARCHAR(255)
	DECLARE helper cursor local for
		SELECT ������� + ' ' + ��� + ' ' + ��������, ����3$.[����� ���������], STRING_AGG(����2$.����������, ', ') AS [����������, �� ������� �����  ������]
		FROM ����3$
		JOIN ����2$ ON ����3$.���������� = ����2$.�����
		JOIN ����1$ ON ����3$.[����� ���������] = ����1$.�����
		WHERE ����� >90
		GROUP BY ����3$.[����� ���������]
		HAVING COUNT(*) >= 2


	OPEN helper
		FETCH NEXT FROM helper INTO @FullName, @ID, @Subjects
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @Line = @FullName + ' ' + @Subjects
				PRINT @Line
				FETCH NEXT FROM helper INTO @FullName, @ID, @Subjects
			END
	CLOSE helper
	DEALLOCATE helper
END
GO


--����� ��� c

EXEC dbo.GetStudentList 90


--d
GO

CREATE VIEW ScoreSum AS (
	SELECT marks.[����� ���������], SUM(marks.�����) AS [����� ������]
	FROM ����3$ marks
	GROUP BY marks.[����� ���������]
)
GO

SELECT marks.[����� ������], COUNT(marks.[����� ���������]) AS [���������� ���������]
FROM dbo.ScoreSum as marks
GROUP BY marks.[����� ������]
ORDER BY marks.[����� ������] DESC
GO

Select * FROM dbo.����3$
--e

GO

CREATE FUNCTION GetStudentNameByScoreRegionAndSubject(@subject NVARCHAR(250), @score INT, @region NVARCHAR(250))
RETURNS NVARCHAR(250)
AS BEGIN
	DECLARE @name NVARCHAR(250);
	
	SELECT TOP 1 @name = (������� + ' ' +  ��� + ' ' + ��������)
	FROM ����3$
	INNER JOIN ����2$ ON ����3$.���������� = ����2$.�����
	INNER JOIN ����1$ ON ����3$.[����� ���������] = ����1$.�����
	INNER JOIN ����4$ ON ����1$.����� = ����4$.[����� ���������] AND ����4$.���������� = ����3$.����������
	WHERE ����� = @region AND ����� = @score AND ����2$.���������� = @subject


    RETURN @name
END

GO

WITH TEMP AS (
	SELECT DISTINCT �������, ���, ��������, ����2$.����������, �����, �����
	FROM ����3$
	INNER JOIN ����2$ ON ����3$.���������� = ����2$.�����
	INNER JOIN ����1$ ON ����3$.[����� ���������] = ����1$.�����
	INNER JOIN ����4$ ON ����1$.����� = ����4$.[����� ���������] AND ����4$.���������� = ����3$.����������
)
SELECT �����, ����������, AVG(�����) AS [������� ����], MIN(�����) AS [����������� ����], MAX(�����) AS [������������ ����],
	dbo.GetStudentNameByScoreRegionAndSubject(����������, MAX(�����), �����) AS [��������, ���������� ������������ ����]
FROM TEMP
GROUP BY �����, ����������
ORDER BY �����

GO



--f

CREATE FUNCTION GetCombinations()
RETURNS @res TABLE(First_ INT, Second_ INT, Third_ INT) 
AS 
BEGIN
	DECLARE @UsedDisciplines TABLE(discipline INT)

	INSERT INTO @UsedDisciplines
	SELECT marks.���������� FROM ����3$ marks GROUP BY marks.����������

	DECLARE @f int = 1
	DECLARE @count int = 0
	SELECT @count = COUNT(disciplines.�����) FROM ����2$ disciplines
	WHILE @f <= @count - 2 BEGIN
		IF (EXISTS(SELECT * FROM @UsedDisciplines ud WHERE ud.discipline = @f)) BEGIN
			DECLARE @s int = @f + 1
			WHILE @s <= @count - 1 BEGIN
				IF (EXISTS(SELECT * FROM @UsedDisciplines ud WHERE ud.discipline = @s)) BEGIN
					DECLARE @t int = @s + 1
					WHILE @t <= @count BEGIN
						IF (EXISTS(SELECT * FROM @UsedDisciplines ud WHERE ud.discipline = @t))
							INSERT @res VALUES (@f, @s, @t)
						SET @t = @t + 1
					END
				END
				SET @s = @s + 1
			END
		END
		SET @f = @f + 1
	END
RETURN
END

GO

CREATE FUNCTION GetNameByID(@first INT, @second INT, @third INT)
RETURNS varchar(500) AS BEGIN
	DECLARE @result varchar(500) = ''

	SELECT @result = @result + disciplines.���������� + ' '
	FROM ����2$ disciplines
	WHERE disciplines.����� = @first OR disciplines.����� = @second OR disciplines.����� = @third

	RETURN @result
END

GO

CREATE FUNCTION Transform(@first INT, @second INT, @third INT)
RETURNS @res TABLE(dId int) 
	AS BEGIN
		INSERT @res VALUES(@first)
		INSERT @res VALUES(@second)
		INSERT @res VALUES(@third)
	RETURN
END	

GO

CREATE FUNCTION CombineMinAndMax2()
RETURNS @res TABLE(marks varchar(500), minScore int, maxScore int) AS BEGIN
	DECLARE @first INT = 0
	DECLARE @second INT = 0
	DECLARE @third INT = 0
	DECLARE db_cursor CURSOR FOR
	SELECT
		cmb.First_, cmb.Second_, cmb.Third_
	FROM
		dbo.GetCombinations() cmb

	OPEN db_cursor
	FETCH NEXT FROM db_cursor INTO
		@first, @second, @third

	WHILE @@FETCH_STATUS = 0 BEGIN
		INSERT INTO @res(marks, minScore, maxScore)
		SELECT dbo.GetNameByID(@first, @second, @third), SUM(marks.�����), SUM(marks.�����)
		FROM ����3$ marks
		RIGHT JOIN dbo.Transform(@first, @second, @third) tr ON tr.dId = marks.����������
		GROUP BY marks.[����� ���������]

		FETCH NEXT FROM db_cursor INTO
		@first, @second, @third
	END

	CLOSE db_cursor
	DEALLOCATE db_cursor
RETURN
END
GO

SELECT TEMP.marks AS [����������], MIN(temp.minScore) AS [����������� ����� ������], MAX(temp.maxScore) AS [������������ ����� ������]
FROM dbo.CombineMinAndMax2() TEMP
GROUP BY TEMP.marks
GO