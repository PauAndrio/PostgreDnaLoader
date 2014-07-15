ALTER TABLE dnamodel.reference
ADD CONSTRAINT reference_simulation
    FOREIGN KEY (simulationId )
    REFERENCES dnamodel.simulation (simulationId )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

ALTER TABLE dnamodel.topology
ADD CONSTRAINT topology_simulation
    FOREIGN KEY (simulationId )
    REFERENCES dnamodel.simulation (simulationId )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

ALTER TABLE dnamodel.snapshot
ADD CONSTRAINT snapshot_simulation
    FOREIGN KEY (simulationId )
    REFERENCES dnamodel.simulation (simulationId )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

ALTER TABLE dnamodel.atom
ADD CONSTRAINT atom_topology
    FOREIGN KEY (topologyId)
    REFERENCES dnamodel.topology (topologyId)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

ALTER TABLE dnamodel.atom
ADD CONSTRAINT atom_snapshot
    FOREIGN KEY (snapshotId)
    REFERENCES dnamodel.snapshot (snapshotId )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

ALTER TABLE dnamodel.desc_topology
ADD CONSTRAINT topology_desc
    FOREIGN KEY (topologyId)
    REFERENCES dnamodel.topology (topologyId)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
