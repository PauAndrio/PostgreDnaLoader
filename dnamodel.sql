-- Schema: dnamodel

-- DROP SCHEMA dnamodel;

CREATE SCHEMA dnamodel
  AUTHORIZATION postgres;

GRANT ALL ON SCHEMA dnamodel TO postgres;

ALTER DEFAULT PRIVILEGES IN SCHEMA dnamodel
    GRANT INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLES
    TO postgres WITH GRANT OPTION;

-- -----------------------------------------------------
-- Table dnamodel.simulation
-- -----------------------------------------------------
CREATE SEQUENCE dnamodel.simulation_simulationId_seq;
CREATE  TABLE IF NOT EXISTS dnamodel.simulation (
  simulationId INT NOT NULL DEFAULT NEXTVAL('dnamodel.simulation_simulationId_seq'),
  totalTime INT NULL ,
  timeStep INT NULL ,
  samplingTime INT NULL ,
  totalSnapsNumber INT NULL ,
  description TEXT NULL ,
  PRIMARY KEY (simulationId));

-- -----------------------------------------------------
-- Table dnamodel.reference
-- -----------------------------------------------------
CREATE SEQUENCE dnamodel.reference_referenceId_seq;
CREATE  TABLE IF NOT EXISTS dnamodel.reference (
  referenceId INT NOT NULL DEFAULT NEXTVAL('dnamodel.reference_referenceId_seq'),
  simulationId INT NOT NULL ,
  pdbCode VARCHAR(4) NULL ,
  chainCode CHAR NULL ,
  description TEXT NULL ,
  PRIMARY KEY (referenceId));


-- -----------------------------------------------------
-- Table dnamodel.topology
-- -----------------------------------------------------
CREATE SEQUENCE dnamodel.topology_topologyId_seq;
CREATE  TABLE IF NOT EXISTS dnamodel.topology (
  topologyId INT NOT NULL DEFAULT NEXTVAL('dnamodel.topology_topologyId_seq'),
  simulationId INT NOT NULL ,
  atomNum INT NOT NULL ,
  atomName VARCHAR(4) NULL ,
  atomType VARCHAR(3) NULL ,
  residueCode VARCHAR(3) NULL ,
  residueNum INT NULL , 
  chainCode CHAR NULL ,
  description TEXT NULL ,
  PRIMARY KEY (topologyId));

-- -----------------------------------------------------
-- Table dnamodel.snapshot
-- -----------------------------------------------------
CREATE SEQUENCE dnamodel.snapshot_snapshotId_seq;
CREATE  TABLE IF NOT EXISTS dnamodel.snapshot (
  snapshotId INT NOT NULL DEFAULT NEXTVAL('dnamodel.snapshot_snapshotId_seq'),
  simulationId INT NOT NULL ,
  snapNumber INT NOT NULL ,
  PRIMARY KEY (snapshotId));

-- -----------------------------------------------------
-- Table dnamodel.atom
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS dnamodel.atom (
  topologyId INT NOT NULL ,
  snapshotId INT NOT NULL ,
  x REAL NOT NULL ,
  y REAL NOT NULL ,
  z REAL NOT NULL ,
  PRIMARY KEY (snapshotId, topologyId));

