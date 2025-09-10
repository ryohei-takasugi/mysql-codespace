-- initdb/002_seed.sql
USE mydatabase;

-- =========================================
-- 0) 連番テーブル（0..22999 = 2.3万）を用意
-- =========================================
DROP TEMPORARY TABLE IF EXISTS tmp_seq;

CREATE TEMPORARY TABLE tmp_seq ( n INT NOT NULL, PRIMARY KEY (n) );

INSERT INTO
    tmp_seq (n)
SELECT t.n
FROM (
        SELECT d0.n + d1.n * 10 + d2.n * 100 + d3.n * 1000 + d4.n * 10000 AS n
        FROM (
                SELECT 0 n
                UNION ALL
                SELECT 1
                UNION ALL
                SELECT 2
                UNION ALL
                SELECT 3
                UNION ALL
                SELECT 4
                UNION ALL
                SELECT 5
                UNION ALL
                SELECT 6
                UNION ALL
                SELECT 7
                UNION ALL
                SELECT 8
                UNION ALL
                SELECT 9
            ) d0
            CROSS JOIN (
                SELECT 0 n
                UNION ALL
                SELECT 1
                UNION ALL
                SELECT 2
                UNION ALL
                SELECT 3
                UNION ALL
                SELECT 4
                UNION ALL
                SELECT 5
                UNION ALL
                SELECT 6
                UNION ALL
                SELECT 7
                UNION ALL
                SELECT 8
                UNION ALL
                SELECT 9
            ) d1
            CROSS JOIN (
                SELECT 0 n
                UNION ALL
                SELECT 1
                UNION ALL
                SELECT 2
                UNION ALL
                SELECT 3
                UNION ALL
                SELECT 4
                UNION ALL
                SELECT 5
                UNION ALL
                SELECT 6
                UNION ALL
                SELECT 7
                UNION ALL
                SELECT 8
                UNION ALL
                SELECT 9
            ) d2
            CROSS JOIN (
                SELECT 0 n
                UNION ALL
                SELECT 1
                UNION ALL
                SELECT 2
                UNION ALL
                SELECT 3
                UNION ALL
                SELECT 4
                UNION ALL
                SELECT 5
                UNION ALL
                SELECT 6
                UNION ALL
                SELECT 7
                UNION ALL
                SELECT 8
                UNION ALL
                SELECT 9
            ) d3
            CROSS JOIN (
                SELECT 0 n
                UNION ALL
                SELECT 1
                UNION ALL
                SELECT 2
                UNION ALL
                SELECT 3
                UNION ALL
                SELECT 4
                UNION ALL
                SELECT 5
                UNION ALL
                SELECT 6
                UNION ALL
                SELECT 7
                UNION ALL
                SELECT 8
                UNION ALL
                SELECT 9
            ) d4
    ) AS t
WHERE
    t.n < 23000;

-- =========================================
-- 1) 学校：200件
-- =========================================
INSERT INTO
    School (
        SchoolID,
        SchoolLocation,
        District,
        SchoolName
    )
SELECT LPAD(n + 1, 4, '0'), CONCAT('所在地', n + 1), CONCAT('第', (n % 10) + 1, '学区'), CONCAT('サンプル高校', n + 1)
FROM tmp_seq
WHERE
    n < 200;

-- =========================================
-- 2) 生徒
--   A) 在学:   0..19999 (2万)
--   B) 入学前: 20000..20999 (1000) → Grade=0, Score/Clubは作らない
--   C) 卒業:   21000..21999 (1000) → Grade=9, GraduationDate=YYYY-03-31
-- =========================================

-- 共通: 入学月を決める（5% だけ 5〜3 月、それ以外は 4 月）
-- ELT(1..11,'05','06','07','08','09','10','11','12','01','02','03')
-- ※使う場所で同じ式を展開します

-- A) 在学（2万）
INSERT INTO
    Student (
        StudentID,
        Name,
        Gender,
        Address,
        Grade,
        Class,
        Teacher,
        EnrollmentDate,
        GraduationDate,
        SchoolID
    )
SELECT
    CONCAT('S', LPAD(n + 1, 6, '0')),
    CONCAT('生徒', n + 1),
    IF((n % 2) = 0, '男', '女'),
    CONCAT('住所', n + 1),
    (n % 3) + 1 AS Grade, -- 1..3
    CHAR(65 + (n % 8)) AS Class, -- A..H
    CONCAT('担任', (n % 200) + 1) AS Teacher,
    /* EnrollmentDate: 年=現在年-(学年-1), 月=4 or (稀に 5..3), 日=1 */
    STR_TO_DATE(
        CONCAT(
            YEAR(CURDATE()) - ((n % 3)),
            '-',
            CASE
                WHEN (n % 20) = 0 THEN ELT(
                    (n % 11) + 1,
                    '05',
                    '06',
                    '07',
                    '08',
                    '09',
                    '10',
                    '11',
                    '12',
                    '01',
                    '02',
                    '03'
                )
                ELSE '04'
            END,
            '-01'
        ),
        '%Y-%m-%d'
    ) AS EnrollmentDate,
    NULL AS GraduationDate,
    LPAD(((n % 200) + 1), 4, '0') AS SchoolID
FROM tmp_seq
WHERE
    n < 20000;

-- B) 入学前（1000）: Grade=0, 入学日は将来（概ね来年4/1、稀に5〜3月の1日）
INSERT INTO
    Student (
        StudentID,
        Name,
        Gender,
        Address,
        Grade,
        Class,
        Teacher,
        EnrollmentDate,
        GraduationDate,
        SchoolID
    )
SELECT
    CONCAT('S', LPAD(n + 1, 6, '0')),
    CONCAT('入学前', n - 20000 + 1),
    IF((n % 2) = 0, '男', '女'),
    CONCAT('住所', n + 1),
    0 AS Grade,
    CHAR(65 + (n % 8)) AS Class,
    CONCAT('担任', (n % 200) + 1) AS Teacher,
    STR_TO_DATE(
        CONCAT(
            YEAR(CURDATE()) + 1,
            '-',
            CASE
                WHEN (n % 20) = 0 THEN ELT(
                    (n % 11) + 1,
                    '05',
                    '06',
                    '07',
                    '08',
                    '09',
                    '10',
                    '11',
                    '12',
                    '01',
                    '02',
                    '03'
                )
                ELSE '04'
            END,
            '-01'
        ),
        '%Y-%m-%d'
    ) AS EnrollmentDate,
    NULL AS GraduationDate,
    LPAD(((n % 200) + 1), 4, '0') AS SchoolID
FROM tmp_seq
WHERE
    n BETWEEN 20000 AND 20999;

-- C) 卒業（1000）: Grade=9, 卒業日は 3/31。就学年数は 3 年が大半、稀に 4〜6 年
INSERT INTO
    Student (
        StudentID,
        Name,
        Gender,
        Address,
        Grade,
        Class,
        Teacher,
        EnrollmentDate,
        GraduationDate,
        SchoolID
    )
SELECT
    CONCAT('S', LPAD(n + 1, 6, '0')),
    CONCAT('卒業生', n - 21000 + 1),
    IF((n % 2) = 0, '男', '女'),
    CONCAT('住所', n + 1),
    9 AS Grade,
    CHAR(65 + (n % 8)) AS Class,
    CONCAT('担任', (n % 200) + 1) AS Teacher,
    -- EnrollmentDate = (GraduationYear - 就学年数)-MM-01
    STR_TO_DATE(
        CONCAT(
            -- 就学年数: 3年が大半、稀に 4/5/6 年（ごく小数）
            (YEAR(CURDATE()) - (n % 3)) -- 卒業年を直近3年に分散
            - CASE
                WHEN (n % 40) = 0 THEN 6
                WHEN (n % 25) = 0 THEN 5
                WHEN (n % 10) = 0 THEN 4
                ELSE 3
            END,
            '-',
            CASE
                WHEN (n % 20) = 0 THEN ELT(
                    (n % 11) + 1,
                    '05',
                    '06',
                    '07',
                    '08',
                    '09',
                    '10',
                    '11',
                    '12',
                    '01',
                    '02',
                    '03'
                )
                ELSE '04'
            END,
            '-01'
        ),
        '%Y-%m-%d'
    ) AS EnrollmentDate,
    -- GraduationDate = 卒業年の3/31
    STR_TO_DATE(
        CONCAT(
            YEAR(CURDATE()) - (n % 3),
            '-03-31'
        ),
        '%Y-%m-%d'
    ) AS GraduationDate,
    LPAD(((n % 200) + 1), 4, '0') AS SchoolID
FROM tmp_seq
WHERE
    n BETWEEN 21000 AND 21999;

-- =========================================
-- 3) 部活（在学 + 卒業生のみ、2/3 が所属）
--    入学前(Grade=0)は対象外
-- =========================================
INSERT INTO
    Club (ID, StudentID, ClubName)
SELECT CONCAT('C', LPAD(n + 1, 7, '0')) AS ID, CONCAT('S', LPAD(n + 1, 6, '0')) AS StudentID, ELT(
        (n % 10) + 1, 'サッカー', '野球', 'バスケ', 'テニス', '吹奏楽', '美術', '陸上', '囲碁', '将棋', '水泳'
    ) AS ClubName
FROM tmp_seq
WHERE (
        n < 20000
        OR (n BETWEEN 21000 AND 21999)
    )
    AND (n % 3) <> 0;

-- =========================================
-- 4) 成績（在学 + 卒業生のみ。入学前は作らない）
-- =========================================
DROP TEMPORARY TABLE IF EXISTS subjects5;

CREATE TEMPORARY TABLE subjects5 ( subject VARCHAR(20) PRIMARY KEY );

INSERT INTO subjects5 VALUES ('国語'), ('数学'), ('英語'), ('理科'), ('社会');

INSERT INTO
    Score (StudentID, Subject, Score)
SELECT CONCAT('S', LPAD(s.n + 1, 6, '0')) AS StudentID, subj.subject AS Subject, LEAST(
        99, 50 + (s.n % 50) + (
            ASCII(SUBSTRING(subj.subject, 1, 1)) % 5
        )
    ) AS Score
FROM tmp_seq s
    JOIN subjects5 subj
WHERE (
        s.n < 20000
        OR (s.n BETWEEN 21000 AND 21999)
    );

-- （任意の後片付け）
DROP TEMPORARY TABLE IF EXISTS subjects5;

DROP TEMPORARY TABLE IF EXISTS tmp_seq;