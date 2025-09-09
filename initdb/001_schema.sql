-- initdb/001_schema.sql
CREATE DATABASE IF NOT EXISTS mydatabase;

USE mydatabase;

DROP TABLE IF EXISTS Score;

DROP TABLE IF EXISTS Club;

DROP TABLE IF EXISTS Student;

DROP TABLE IF EXISTS School;

-- 学校
CREATE TABLE School (
    SchoolID VARCHAR(10) NOT NULL COMMENT '学校ID',
    SchoolLocation VARCHAR(50) NOT NULL COMMENT '学校所在地',
    District VARCHAR(50) NOT NULL COMMENT '地区',
    SchoolName VARCHAR(100) NOT NULL COMMENT '学校名',
    PRIMARY KEY (SchoolID)
);

-- 生徒
-- 文字化け防止（セッション）。可能なら最初に実行
SET NAMES utf8mb4;

CREATE TABLE Student (
    StudentID VARCHAR(20) NOT NULL COMMENT '学籍番号',
    Name VARCHAR(100) NOT NULL COMMENT '名前',
    Gender ENUM('男', '女') NOT NULL COMMENT '性別',
    Address VARCHAR(100) NOT NULL COMMENT '住所',
    Grade TINYINT NOT NULL COMMENT '学年',
    Class VARCHAR(5) NOT NULL COMMENT 'クラス',
    Teacher VARCHAR(50) NOT NULL COMMENT '担任',
    EnrollmentDate DATE NOT NULL COMMENT '入学年月日',
    SchoolID VARCHAR(10) NOT NULL COMMENT '学校ID',
    PRIMARY KEY (StudentID),
    KEY idx_student_school (SchoolID),
    CONSTRAINT FK_Student_School FOREIGN KEY (SchoolID) REFERENCES School (SchoolID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 部活
CREATE TABLE Club (
    ID VARCHAR(20) NOT NULL COMMENT 'ID',
    StudentID VARCHAR(20) NOT NULL COMMENT '学籍番号',
    ClubName VARCHAR(100) NOT NULL COMMENT '部活',
    PRIMARY KEY (ID),
    CONSTRAINT FK_Club_Student FOREIGN KEY (StudentID) REFERENCES Student (StudentID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 成績
CREATE TABLE Score (
    StudentID VARCHAR(20) NOT NULL COMMENT '学籍番号',
    Subject VARCHAR(20) NOT NULL COMMENT '科目',
    Score INT NOT NULL COMMENT '点数',
    PRIMARY KEY (StudentID, Subject),
    CONSTRAINT FK_Score_Student FOREIGN KEY (StudentID) REFERENCES Student (StudentID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ★インデックスは最小限（PK/FK）のみ。改善は実践で追加予定。