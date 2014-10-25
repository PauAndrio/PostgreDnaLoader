CREATE OR REPLACE FUNCTION get_atoms
(v_simulationid int,
snapshot_interval int)
returns setof atom as $$
declare
	r_snapid int;
	snapshot_cursor cursor for
		SELECT snapshotid
		FROM snapshot
		INNER JOIN simulation ON (snapshot.simulationid = simulation.simulationid)
		WHERE simulation.simulationid = v_simulationid
		ORDER BY snapshot.snapshotid, snapshot.simulationid;
begin
	open snapshot_cursor;
	fetch from snapshot_cursor into r_snapid;
	while found loop
		RETURN QUERY SELECT atom.topologyid, atom.snapshotid, atom.x, atom.y, atom.z
						FROM atom
						INNER JOIN snapshot ON (atom.snapshotid = snapshot.snapshotid)
						WHERE snapshot.snapshotid = r_snapid;
		move forward snapshot_interval - 1 in snapshot_cursor;
		fetch from snapshot_cursor into r_snapid;
	end loop;
end;
$$ language plpgsql strict;
