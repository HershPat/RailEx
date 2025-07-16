CREATE DATABASE IF NOT EXISTS trainDB;
USE trainDB;

-- 2.1 Train Data
CREATE TABLE Train (
  trainId INT PRIMARY KEY
);

-- 2.2 Station Data
CREATE TABLE Station (
  stationId INT AUTO_INCREMENT PRIMARY KEY,
  stationName VARCHAR(100),
  city VARCHAR(50),
  state CHAR(50)
);

-- 2.3 Train Schedule Data
CREATE TABLE TrainSchedule (
  lineId INT AUTO_INCREMENT PRIMARY KEY,
  lineName VARCHAR(100),
  trainId INT NOT NULL,
  fare FLOAT,
  origin INT NOT NULL,
  destination INT NOT NULL,
  arrivalTime DATETIME,
  departureTime DATETIME,
  FOREIGN KEY (trainId) REFERENCES Train(trainId)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (origin) REFERENCES Station(stationId)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (destination) REFERENCES Station(stationId)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE StopsAt (
  stopId INT AUTO_INCREMENT UNIQUE,
  stopLine INT NOT NULL,
  stopStation INT NOT NULL,
  stopArrivalTime DATETIME NOT NULL,
  stopDepartureTime DATETIME NOT NULL,
  PRIMARY KEY (stopId, stopStation, stopLine),
  FOREIGN KEY (stopLine) REFERENCES TrainSchedule(lineId)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (stopStation) REFERENCES Station(stationId)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- 2.5 Customer Data
CREATE TABLE Customer (
  customerId INT AUTO_INCREMENT PRIMARY KEY,
  firstName VARCHAR(50) NOT NULL,
  lastName VARCHAR(50) NOT NULL,
  user VARCHAR(15) UNIQUE NOT NULL,
  pass VARCHAR(20) NOT NULL,
  email VARCHAR(150) NOT NULL
);

-- 2.6 Employee Data
CREATE TABLE Employee (
  employeeId INT AUTO_INCREMENT PRIMARY KEY,
  SSN CHAR(11) UNIQUE,
  firstName VARCHAR(50) NOT NULL,
  lastName VARCHAR(50) NOT NULL,
  user VARCHAR(15) UNIQUE NOT NULL,
  pass VARCHAR(20) NOT NULL,
  isManager BOOLEAN NOT NULL
);

CREATE TABLE CustomerService (
  questionId INT AUTO_INCREMENT PRIMARY KEY,
  customerId INT NOT NULL,
  employeeId INT NOT NULL,
  questionMessage TEXT NOT NULL,
  questionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  replyMessage TEXT,
  replyDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customerId) REFERENCES Customer(customerId)
    ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (employeeId) REFERENCES Employee(employeeId)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- 2.4 Reservation Data
CREATE TABLE Reservation (
  reservationNumber INT AUTO_INCREMENT PRIMARY KEY,
  reservationDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fareDiscount INT NOT NULL,
  isRound BOOLEAN NOT NULL,
  totalFare FLOAT NOT NULL,
  customerId INT NOT NULL,
  ScheduleLineId INT NOT NULL,
  originStopId INT NOT NULL,
  destinationStopId INT NOT NULL,
  FOREIGN KEY (customerId) REFERENCES Customer(customerId)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (ScheduleLineId) REFERENCES TrainSchedule(lineId)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (originStopId) REFERENCES StopsAt(stopId)
    ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (destinationStopId) REFERENCES StopsAt(stopId)
    ON DELETE CASCADE ON UPDATE CASCADE
);
