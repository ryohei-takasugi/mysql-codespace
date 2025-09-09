-- initdb/002_seed.sql
USE mydatabase;

-- 0..9 の桁テーブルを組み合わせて 0..99999 を生成（再帰CTEに依存しない）
WITH
d0 AS (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
        UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9),
d1 AS (SELECT a.n + b.n*10 AS n FROM d0 a, d0 b),
d2 AS (SELECT a.n + b.n*100 AS n FROM d1 a, d0 b),
d3 AS (SELECT a.n + b.n*1000 AS n FROM d2 a, d0 b),
d4 AS (SELECT a.n + b.n*10000 AS n FROM d3 a, d0 b)

-- 学校：200件（District 10区、Locationはプレフィックス＋番号）
INSERT INTO School (SchoolID, SchoolLocation, District, SchoolName)
SELECT
  LPAD(n+1, 4, '0'),
  CONCAT('所在地', n+1),
  CONCAT('第', (n % 10) + 1, '学区'),
  CONCAT('サンプル高校', n+1)
FROM (SELECT n FROM d4 WHERE n < 200) s;

-- 生徒：20,000件（Grade 1..3、Class=A..H、Teacher=担任1..200）
INSERT INTO Student (
  StudentID, Name, Gender, Address, Grade, Class, Teacher, EnrollmentDate, SchoolID
)
SELECT
  CONCAT('S', LPAD(n+1, 6, '0')),
  CONCAT('生徒', n+1),
  IF((n % 2)=0, '男', '女'),
  CONCAT('住所', n+1),
  (n % 3) + 1,                                   -- 学年 1..3
  CHAR(65 + (n % 8)),                             -- A..H
  CONCAT('担任', (n % 200) + 1),
  DATE_SUB(CURDATE(), INTERVAL (n % 1200) DAY),
  LPAD(((n % 200) + 1), 4, '0')
FROM (SELECT n FROM d4 WHERE n < 20000) s;

-- 部活：~ 2/3 所属
INSERT INTO Club (ID, StudentID, ClubName)
SELECT
  CONCAT('C', LPAD(n+1, 7, '0')),
  CONCAT('S', LPAD(n+1, 6, '0')),
  ELT((n % 10) + 1, 'サッカー','野球','バスケ','テニス','吹奏楽',
                     '美術','陸上','囲碁','将棋','水泳')
FROM (SELECT n FROM d4 WHERE n < 20000) s
WHERE (n % 3) <> 0;

-- 成績：各生徒に5教科（国語/数学/英語/理科/社会）= 20,000 * 5 = 100,000 行（最大）
-- 教科名は集計要件に合わせて固定セット
DROP TEMPORARY TABLE IF EXISTS subjects5;
CREATE TEMPORARY TABLE subjects5 (subject VARCHAR(20) PRIMARY KEY);
INSERT INTO subjects5 VALUES ('国語'),('数学'),('英語'),('理科'),('社会');

INSERT INTO Score (StudentID, Subject, Score)
SELECT
  CONCAT('S', LPAD(s.n+1, 6, '0')) AS StudentID,
  subj.subject,
  50 + (s.n % 50) + (ASCII(SUBSTRING(subj.subject,1,1)) % 5) -- 50〜99に散らす簡易乱数
FROM (SELECT n FROM d4 WHERE n < 20000) s
JOIN subjects5 subj;
