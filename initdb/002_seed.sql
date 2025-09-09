-- initdb/002_seed.sql
USE mydatabase;

-- 連番をためる一時テーブル
DROP TEMPORARY TABLE IF EXISTS tmp_seq;

CREATE TEMPORARY TABLE tmp_seq (
    n INT NOT NULL,
    PRIMARY KEY (n)
);

-- 0..99999 を桁テーブル×5で生成し、0..19999 だけ格納
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
    t.n < 20000;

-- 学校：200件（District 10区、Locationはプレフィックス＋番号）
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

-- 生徒：20,000件（Grade 1..3、Class=A..H、Teacher=担任1..200）
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
        SchoolID
    )
SELECT
    CONCAT('S', LPAD(n + 1, 6, '0')) AS StudentID,
    CONCAT('生徒', n + 1) AS Name,
    IF((n % 2) = 0, '男', '女') AS Gender,
    CONCAT('住所', n + 1) AS Address,
    (n % 3) + 1 AS Grade, -- 1..3
    CHAR(65 + (n % 8)) AS Class, -- A..H
    CONCAT('担任', (n % 200) + 1) AS Teacher,
    DATE_SUB(
        CURDATE(),
        INTERVAL(n % 1200) DAY
    ) AS EnrollmentDate,
    LPAD(((n % 200) + 1), 4, '0') AS SchoolID
FROM tmp_seq
WHERE
    n < 20000;

-- 部活：~ 2/3 所属
INSERT INTO
    Club (ID, StudentID, ClubName)
SELECT CONCAT('C', LPAD(n + 1, 7, '0')) AS ID, CONCAT('S', LPAD(n + 1, 6, '0')) AS StudentID, ELT(
        (n % 10) + 1, 'サッカー', '野球', 'バスケ', 'テニス', '吹奏楽', '美術', '陸上', '囲碁', '将棋', '水泳'
    ) AS ClubName
FROM tmp_seq
WHERE
    n < 20000
    AND (n % 3) <> 0;

-- 成績：各生徒に5教科（国語/数学/英語/理科/社会）= 最大 100,000 行
DROP TEMPORARY TABLE IF EXISTS subjects5;

CREATE TEMPORARY TABLE subjects5 ( subject VARCHAR(20) PRIMARY KEY );

INSERT INTO subjects5 VALUES ('国語'), ('数学'), ('英語'), ('理科'), ('社会');

INSERT INTO
    Score (StudentID, Subject, Score)
SELECT CONCAT('S', LPAD(s.n + 1, 6, '0')) AS StudentID, subj.subject AS Subject, LEAST(
        99, 50 + (s.n % 50) + (
            ASCII(SUBSTRING(subj.subject, 1, 1)) % 5
        )
    ) AS Score -- 50〜99
FROM tmp_seq s
    JOIN subjects5 subj
WHERE
    s.n < 20000;

-- 後片付け（任意）
DROP TEMPORARY TABLE IF EXISTS subjects5;

DROP TEMPORARY TABLE IF EXISTS tmp_seq;