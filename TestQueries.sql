DO $$
DECLARE trajId INT;
DECLARE db TEXT;
BEGIN
	trajId := 'foobar' ;
	db := 'foobar' ;

	-- Get 10 snapshots
	select at.x, at.y, at.z  
	from db.atom as at, db.topology as tp, db.snapshot as ss, db.simulation as sm where 
	sm.simulationid = trajId  and   
	sm.simulationid = ss.simulationid and 
	ss.snapshotid = at.snapshotid and 
	sm.simulationid = tp.simulationid and 
	tp.topologyid = at.topologyid and
	ss.snapNumber in (1,500,1000,1500,2000,2500,3000,3500,4000,4500);
	
	-- Get 10 snapshots of the dry trajectory
	select at.x, at.y, at.z  
	from db.atom as at, db.topology as tp, db.snapshot as ss, db.simulation as sm where 
	sm.simulationid = trajId and   
	sm.simulationid = ss.simulationid and 
	ss.snapshotid = at.snapshotid and 
	sm.simulationid = tp.simulationid and 
	tp.topologyid = at.topologyid and
	ss.snapNumber in (1,500,1000,1500,2000,2500,3000,3500,4000,4500) and
	tp.residueCode not in ('WAT','Na+','Cl-');

	-- Get all the alpha carbons of all the trajectory
	select at.x, at.y, at.z  
	from db.atom as at, db.topology as tp, db.snapshot as ss, db.simulation as sm where 
	sm.simulationid = trajId and   
	sm.simulationid = ss.simulationid and 
	ss.snapshotid = at.snapshotid and 
	sm.simulationid = tp.simulationid and 
	tp.topologyid = at.topologyid and
	tp.atomName = 'CA';
	
	-- Get 1 residue across all the trajectory
	select at.x, at.y, at.z
	from db.atom as at, db.topology as tp, db.snapshot as ss, db.simulation as sm where 
	sm.simulationid = trajId  and  
	sm.simulationid = ss.simulationid and 
	ss.snapshotid = at.snapshotid and 
	sm.simulationid = tp.simulationid and 
	tp.topologyid = at.topologyid and 
	tp.residueNum in (20);

	-- Get the first and 20th residue of the first snapshot across all the DB
	select at.x, at.y, at.z
	from db.atom as at, db.topology as tp, db.snapshot as ss, db.simulation as sm where 
	ss.snapshotid = 1  and  
	sm.simulationid = ss.simulationid and 
	ss.snapshotid = at.snapshotid and 
	sm.simulationid = tp.simulationid and 
	tp.topologyid = at.topologyid and 
	tp.residueNum in (1, 20);
	
	-- Get all the alpha carbons of the first snapshot across all the DB
	select at.x, at.y, at.z  
	from db.atom as at, db.topology as tp, db.snapshot as ss, db.simulation as sm where
	ss.snapshotid = 1  and
	sm.simulationid = ss.simulationid and 
	ss.snapshotid = at.snapshotid and 
	sm.simulationid = tp.simulationid and 
	tp.topologyid = at.topologyid and
	tp.atomName = 'CA';

END $$;



