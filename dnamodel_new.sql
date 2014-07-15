-- Schema: dnamodel

-- DROP SCHEMA dnamodel;

CREATE SCHEMA dnamodel
  AUTHORIZATION postgres;

GRANT ALL ON SCHEMA dnamodel TO postgres;

ALTER DEFAULT PRIVILEGES IN SCHEMA dnamodel
    GRANT INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLES
    TO postgres WITH GRANT OPTION;

-- ----------------------------------------------------
-- Types 
-- ----------------------------------------------------
CREATE TYPE residue AS ENUM ('ALA','ARG','ASN','ASP','CYS','GLN','GLU','GLY','HID','HIE','HIP','ILE','LEU','LYS','MET','PHE','PRO','SER','THR','TRP','TYR','VAL');
CREATE TYPE typeatom AS ENUM ('N','H','S','O','C','P');

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
  PRIMARY KEY (simulationId)
WITH (FILLFACTOR=100));

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
  PRIMARY KEY (referenceId)
WITH (FILLFACTOR=100));


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
  residueCode CHAR(3) NULL ,  -- Changed from varchar
  residueNum smallint NULL ,  -- Changed from int 
  chainCode CHAR NULL ,
--  description TEXT NULL ,   -- formalized in desc_topology
  PRIMARY KEY (topologyId)
WITH (FILLFACTOR=100));

-- -----------------------------------------------------
-- Table dnamodel.desc_topology
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS dnamodel.desc_topology (
  topologyId int NOT NULL,
  description text NULL)
WITH (FILLFACTOR=100);

-- -----------------------------------------------------
-- Table dnamodel.snapshot
-- -----------------------------------------------------
CREATE SEQUENCE dnamodel.snapshot_snapshotId_seq;
CREATE  TABLE IF NOT EXISTS dnamodel.snapshot (
  snapshotId INT NOT NULL DEFAULT NEXTVAL('dnamodel.snapshot_snapshotId_seq'),
  simulationId INT NOT NULL ,
  snapNumber INT NOT NULL ,
  PRIMARY KEY (snapshotId)
WITH (FILLFACTOR=100));

-- -----------------------------------------------------
-- Table dnamodel.atom
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS dnamodel.atom (
  topologyId INT NOT NULL ,
  snapshotId INT NOT NULL ,
  x REAL NOT NULL ,
  y REAL NOT NULL ,
  z REAL NOT NULL ,
  PRIMARY KEY (snapshotId, topologyId)
WITH (FILLFACTOR=100));

