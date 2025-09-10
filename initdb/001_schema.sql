-- initdb/001_schema.sql
CREATE DATABASE IF NOT EXISTS mydatabase DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

USE mydatabase;

-- 依存順に削除
DROP TABLE IF EXISTS Score;

DROP TABLE IF EXISTS Club;

DROP TABLE IF EXISTS Student;

DROP TABLE IF EXISTS School;

-- 文字化け防止（セッション）
SET NAMES utf8mb4;

-- 学校
CREATE TABLE School (
    SchoolID VARCHAR(10) NOT NULL COMMENT '学校ID',
    SchoolLocation VARCHAR(50) NOT NULL COMMENT '学校所在地',
    District VARCHAR(50) NOT NULL COMMENT '地区',
    SchoolName VARCHAR(100) NOT NULL COMMENT '学校名',
    PRIMARY KEY (SchoolID)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 生徒
-- 学年: 0=入学前, 1..3=在学, 9=卒業
CREATE TABLE Student (
    StudentID VARCHAR(20) NOT NULL COMMENT '学籍番号',
    Name VARCHAR(100) NOT NULL COMMENT '名前',
    Gender ENUM('男', '女') NOT NULL COMMENT '性別',
    Address VARCHAR(100) NOT NULL COMMENT '住所',
    Grade TINYINT NOT NULL COMMENT '学年(0=入学前,1..3=在学,9=卒業)',
    Class VARCHAR(5) NOT NULL COMMENT 'クラス',
    Teacher VARCHAR(50) NOT NULL COMMENT '担任',
    EnrollmentDate DATE NOT NULL COMMENT '入学年月日',
    GraduationDate DATE NULL COMMENT '卒業年月日(卒業生のみ)',
    SchoolID VARCHAR(10) NOT NULL COMMENT '学校ID',
    PRIMARY KEY (StudentID),
    CONSTRAINT FK_Student_School FOREIGN KEY (SchoolID) REFERENCES School (SchoolID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 部活（学習用に索引は最小限）
CREATE TABLE Club (
    ID VARCHAR(20) NOT NULL COMMENT 'ID',
    StudentID VARCHAR(20) NOT NULL COMMENT '学籍番号',
    ClubName VARCHAR(100) NOT NULL COMMENT '部活',
    PRIMARY KEY (ID),
    CONSTRAINT FK_Club_Student FOREIGN KEY (StudentID) REFERENCES Student (StudentID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 成績（在学・卒業生のみ）
CREATE TABLE Score (
    StudentID VARCHAR(20) NOT NULL COMMENT '学籍番号',
    Subject VARCHAR(20) NOT NULL COMMENT '科目',
    Score INT NOT NULL COMMENT '点数',
    PRIMARY KEY (StudentID, Subject),
    CONSTRAINT FK_Score_Student FOREIGN KEY (StudentID) REFERENCES Student (StudentID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- ★インデックスは最小限（PK/FK）のみ