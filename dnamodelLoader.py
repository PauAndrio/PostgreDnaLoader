'''
Created on Oct 17, 2013

@author: pau
'''
import sys
import os
import psycopg2
from psycopg2.extensions import adapt
import numpy
from MDAnalysis import Universe

def listTrajectories(dir):
    trajList=[]
    for root, dirs, filenames in os.walk(dir):
        trajectory=""
        topology=""
        for f in filenames:
            filename, fileExtension = os.path.splitext(f)
            if str.lower(fileExtension) == ".trj" or str.lower(fileExtension)== ".mdcrd" or  str.lower(fileExtension)== ".netcdf":
                trajectory = os.path.join(root, f)
            elif str.lower(fileExtension) == ".top" or str.lower(fileExtension)== ".prmtop" or str.lower(fileExtension)== ".pdb": 
                topology = os.path.join(root, f)
        if trajectory and topology:
            trajList.append((topology, trajectory))
    return trajList



    
class numpy_float32_adapter(object):
    """Adapt numpy's float32 type to PostgreSQL's float."""

    def __init__(self, f):
        self._f = f

    def prepare(self, conn):
        pass

    def getquoted(self):
        return str(self._f)

    __str__ = getquoted

psycopg2.extensions.register_adapter(numpy.float32, numpy_float32_adapter)  # @UndefinedVariable


def nthLetter(cont):
    return str(chr(ord('A') + cont))
    
def simulationInsert(con, totalTime, timeStep, samplingTime, totalSnapsNumber, description):
    sql_insert_simulation="INSERT INTO dnamodeltest.simulation (totalTime, timeStep, samplingTime, totalSnapsNumber, description) VALUES (%s, %s, %s, %s, %s) RETURNING simulationId;"
    cur = con.cursor()
    cur.execute(sql_insert_simulation, (totalTime, timeStep, samplingTime, totalSnapsNumber, description))
    simulationId = cur.fetchone()[0]
    cur.close()
    return simulationId

def referenceInsert(con, simulationId, pdbCode, chainCode):
    sql_insert_simulationReference="INSERT INTO dnamodeltest.reference (simulationId, pdbCode, chainCode) VALUES (%s, %s, %s) RETURNING referenceId;"
    cur = con.cursor()
    cur.execute(sql_insert_simulationReference, (simulationId, pdbCode, chainCode))
    referenceId = cur.fetchone()[0]
    cur.close()
    return referenceId

def snapshotInsert(con, simulationId, snapNumber):
    sql_insert_snapshot="INSERT INTO dnamodeltest.snapshot (simulationId, snapNumber) VALUES (%s, %s) RETURNING snapshotId;"
    cur = con.cursor()
    cur.execute(sql_insert_snapshot, (simulationId, snapNumber))
    snapshotId = cur.fetchone()[0]
    cur.close()
    return snapshotId

def topologyInsert(con, simulationId, atomNum, atomName, atomType, residueCode, residueNumber, chainCode, description):
    sql_insert_topology="INSERT INTO dnamodeltest.topology (simulationId, atomNum, atomName, atomType, residueNum, residueCode, chainCode, description) VALUES (%s, %s, %s, %s, %s, %s, %s, %s) RETURNING topologyId;"
    cur = con.cursor()
    cur.execute(sql_insert_topology, (simulationId, atomNum, adapt(atomName), adapt(atomType), residueNumber, adapt(residueCode), adapt(chainCode), adapt(description)))
    topologyId = cur.fetchone()[0]
    cur.close()
    return topologyId

def atomInsert(con, topologyId, snapshotId, x, y, z):
    sql_insert_atom="INSERT INTO dnamodeltest.atom VALUES (%s, %s, %s, %s, %s);"
    cur = con.cursor()
    cur.execute(sql_insert_atom, (con, topologyId, snapshotId, x, y, z))
    cur.close()
    
def trajectoryToDB(uni, con, simulationId):
    cur = con.cursor()
    firstSnapshot = True
    sqlAtom= "INSERT INTO dnamodeltest.atom VALUES "
    topologyBuffer = "INSERT INTO dnamodeltest.topology VALUES " 
    atNumTopId = {}
    for ts in uni.trajectory:
        snapshotId = snapshotInsert(con, simulationId, ts.frame)
        atomBuffer = ''
        atomCont = 0
        
        if ((ts.frame % 100000) == 0) or (ts.frame == 1): 
            print 'Frame: '+str(ts.frame)
            #break;
        if firstSnapshot:
            firstSnapshot= False           
            oldResidue = 0
            chainCont= 0
            chainError = False
            for at in uni.atoms:
                #Chain
                if len(at.segid.upper()) > 1:
                    segid = 'A'
                else:
                    segid = at.segid.upper()
        
                if chainError:
                    currentChain = nthLetter(chainCont)
                else: 
                    currentChain = segid
                #Residue
                currentResidue = at.resid
                if currentResidue < oldResidue: 
                    chainError = True
                    chainCont += 1
                    currentChain = nthLetter(chainCont)
                oldResidue = currentResidue
                
                ###Canviar
                #topologyBuffer = '%s (%s, %s, %s, %s, %s, %s, %s),' % (topologyBuffer, simulationId, at.number, adapt(at.name), adapt(at.type), adapt(at.resname), currentResidue,  adapt(currentChain))
                topologyId = topologyInsert(con, simulationId, at.number, adapt(at.name), adapt(at.type), adapt(at.resname), currentResidue, adapt(currentChain), "")
                atNumTopId[str(at.number)]=topologyId
                atomBuffer = '%s (%s, %s, %s, %s, %s),' % (atomBuffer, topologyId, snapshotId, at.position[0], at.position[1], at.position[2])
                #print str(simulationId) +' ' + str(at.number) +' ' + at.name +' ' + at.type+' ' + at.resname +' ' + str(currentResidue)+ ' ' + currentChain + ''
                #topologyInsert(con, simulationId, at.number, at.name, at.type, at.resname, currentResidue, currentChain, '')                                        
            atomBuffer= '%s %s ;' % (sqlAtom, atomBuffer[:-1])
            #topologyBuffer = '%s ;' % (topologyBuffer[:-1])
            #cur.execute(topologyBuffer)
            cur.execute(atomBuffer)
                
        else:
            for at in uni.atoms:
                atomCont += 1
                atomBuffer = '%s (%s, %s, %s, %s, %s),' % (atomBuffer, atNumTopId[str(at.number)], snapshotId, at.position[0], at.position[1], at.position[2])
                if atomCont == 100000:
                    atomCont = 0 
                    atomBuffer= '%s %s ;' % (sqlAtom, atomBuffer[:-1])
                    cur.execute(atomBuffer)
                    atomBuffer = ''
            atomBuffer= '%s %s ;' % (sqlAtom, atomBuffer[:-1])
            cur.execute(atomBuffer)
            atomBuffer = ''
        
    con.commit()
    cur.close()
    
     
def main(dir):                 
 
    try:
        #con = psycopg2.connect(database='postgres', user='postgres', host='localhost', port=5432, password='post')
        con = psycopg2.connect(database='postgres', user='postgres', host='localhost', port=5433, password='post')
        #con = psycopg2.connect(database='postgres', user='postgres', host='mmb00.local', port=5433, password='post')
    except psycopg2.DatabaseError, e:
        print 'Error %s' % e    
        sys.exit(1)
    
    trajList = listTrajectories(dir)
    totalTrajNumber = len(trajList)
    cont = 0
    for topologyPath, trajectoryPath in trajList:
        cont +=1
        print "Trajectory "+str(cont)+"/"+str(totalTrajNumber)+" "+topologyPath
        #canviar parametres simulationId
        simulationId = simulationInsert(con, 225000, 1, 1, 225000, topologyPath+" "+trajectoryPath)
        referenceInsert(con, simulationId, 'DNA ', 'X')    
        try:
            #uniTraj = Universe(topologyPath, format='PRMTOP')
            uniTraj = Universe(topologyPath)
        except:
            print "Error: Could not load topology file"
            return 100
               
        try:
	    filename, fileExtension = os.path.splitext(trajectoryPath)
	    if str.lower(fileExtension)== ".netcdf":
            	uniTraj.load_new(trajectoryPath, format='NCDF')
	    else:
            	uniTraj.load_new(trajectoryPath)
        except:
            print "Error: Could not load trajectory file"
            return 100
        
        print "Inserting trajectory"
        trajectoryToDB(uniTraj, con, simulationId)
    #print len(structIdArray)
            
        
    if con:
        con.close()
    
    print "The program successfully finished"
           
    return 0

if __name__ ==  "__main__":
    if len(sys.argv) == 2:
        dir = sys.argv[1]
        sys.exit(main(dir))
    else:
        print "usage: topologyPath trajectoryPath"
        print "    topologyPath --> Path to the to the PRMTOP file." 
        print "    trajectoryPath --> Path to the NETCDF trajectory file."
        
