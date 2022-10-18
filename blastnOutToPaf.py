#!/usr/bin/env python


import os 
import sys

file=sys.argv[1]

outfileName='paf_'+file.strip('.txt')+'.paf'
open(outfileName,'w')
with open(file,'r') as infile, open(outfileName,'a') as outfile:
	for line in infile:
		cols=line.split('\t')
		queryCoords=cols[0]#2:228128257-228350158(-)
		queryChr=queryCoords.split(':')[0] #2
		queryCoordsStrand=queryCoords.split(':')[1]#228128257-228350158(-)
		queryCoords=queryCoordsStrand.split('(')[0]
		queryStrand=queryCoordsStrand.split('(')[1].strip(')')
		queryStart=int(queryCoords.split('-')[0])
		queryEnd=int(queryCoords.split('-')[1])


		subjCoords=cols[1]
		subjChr=subjCoords.split(':')[0]
		#subjStart=int(subjCoords.split(':')[1].split('-')[0])
		#subjEnd=int(subjCoords.split(':')[1].split('-')[1])
		subjChr=subjCoords.split(':')[0] #2
		subjCoordsStrand=subjCoords.split(':')[1]#228128257-228350158(-)
		subjCoords=subjCoordsStrand.split('(')[0]
		subjStrand=subjCoordsStrand.split('(')[1].strip(')')
		subjStart=int(subjCoords.split('-')[0])
		subjEnd=int(subjCoords.split('-')[1])
		
		qAlignStart=int(cols[6])
		qAlignEnd=int(cols[7])
	
		sAlignStart=int(cols[8])
		sAlignEnd=int(cols[9])
		
		#check strands
		if queryStrand==subjStrand:
			strand='+'
			#print('same strands')
			
		else:
			strand='-'
			#print(queryStrand)
			#print(queryStrand)
		
		if sAlignEnd>sAlignStart:
			alignmentLength= int(sAlignEnd-sAlignStart)

			outfile.write(subjChr+'\t'+str(subjEnd-subjStart)+'\t'+str(subjStart+sAlignStart)+'\t'+str(subjStart+sAlignEnd)+'\t'+strand+'\t'+queryChr+'\t'+str(queryEnd-queryStart)+'\t'+str(queryStart+qAlignStart)+'\t'+str(queryStart+qAlignEnd)+'\t'+str(alignmentLength)+'\t'+'-'+'\t'+str(0)+'\n')

		elif (sAlignEnd<sAlignStart):
			alignmentLength= int(sAlignStart-sAlignEnd)

			outfile.write(subjChr+'\t'+str(subjEnd-subjStart)+'\t'+str(subjStart+sAlignEnd)+'\t'+str(subjStart+sAlignStart)+'\t'+strand+'\t'+queryChr+'\t'+str(queryEnd-queryStart)+'\t'+str(queryStart+qAlignStart)+'\t'+str(queryStart+qAlignEnd)+'\t'+str(alignmentLength)+'\t'+'-'+'\t'+str(0)+'\n')

		