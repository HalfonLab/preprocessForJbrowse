#!/bin/bash


#check number of arguments
if [ "$#" -ne 7 ]; then
	echo "Usage: $0 s1geneName s1GFF_file s1FASTA_file s2geneName s2GFF_file s2FASTA_file word_size"
	exit 1
fi	
s1geneName=$1
s1GFF_file=$2
s1FASTA_file=$3

s2geneName=$4
s2GFF_file=$5
s2FASTA_file=$6
wordsize=$7
if [ ! -f "$s1GFF_file" ];then
	echo  "$s1GFF_file not a file"
	exit 1
fi

if [ ! -f "$s1FASTA_file" ];then
	echo  "$s1FASTA_file not a file"
	exit 1
fi

if [ ! -f "$s2GFF_file" ];then
	echo  "$s2GFF_file not a file"
	exit 1
fi

if [ ! -f "$s2FASTA_file" ];then
	echo  "$s2FASTA_file not a file"
	exit 1
fi






echo $s1geneName
s1gene_coords_file=$s1geneName"_coords.bed"
s1gene_fasta_file=$s1geneName".fa"
#grep $'\tgene\t' $s1GFF_file | grep $s1geneName | cut -f 1,4,5,6,3,7 | tr '\n' '\t'> $s1gene_coords_file
grep $'\tgene\t' $s1GFF_file | grep $s1geneName | awk -v OFS='\t' '{print $1,$4,$5,$6,$8,$7}' | tr '\n' '\t'> $s1gene_coords_file
echo -ne $s1geneName >> $s1gene_coords_file


bedtools getfasta -s -fi $s1FASTA_file -bed $s1gene_coords_file -fo $s1gene_fasta_file

#exit 0
#same for species 2

echo $s2geneName
s2gene_coords_file=$s2geneName"_coords.bed"
s2gene_fasta_file=$s2geneName".fa"
#grep $'\tgene\t' $s2GFF_file | grep $s2geneName | cut -f 1,4,5 | tr '\n' '\t'> $s2gene_coords_file
grep $'\tgene\t' $s2GFF_file | grep $s2geneName | awk -v OFS='\t' '{print $1,$4,$5,$6,$8,$7}'| tr '\n' '\t'> $s2gene_coords_file

echo -ne $s2geneName >> $s2gene_coords_file


bedtools getfasta -s -fi $s2FASTA_file -bed $s2gene_coords_file -fo $s2gene_fasta_file

blast_outfile='blastnOut.txt'
#Run blast
blastn -task blastn -query $s1gene_fasta_file -subject $s2gene_fasta_file -outfmt 6 -out $blast_outfile -word_size $wordsize


#output no.1 paf file

./blastnOutToPaf.py $blast_outfile


#STEP 2: 
#slimming fasta sp1

s1chr=$(cut -f 1 $s1gene_coords_file)

echo $s1chr

s1slimfastafile=$s1chr'_chrsp1.fa'
seqkit grep -i -r -p "^${s1chr}+$" $s1FASTA_file > $s1slimfastafile

#output #2 a for species 1
bgzip -i $s1slimfastafile
samtools faidx $s1slimfastafile'.gz'



#slimming fasta sp2

s2chr=$(cut -f 1 $s2gene_coords_file)

echo $s2chr

s2slimfastafile=$s2chr'_chrsp2.fa'
seqkit grep -i -r -p "^${s2chr}+$" $s2FASTA_file > $s2slimfastafile

#output #2 b for species 2
bgzip -i $s2slimfastafile
samtools faidx $s2slimfastafile'.gz'

  
#step 3: GFF indexing
#sp 1
./gff3sort.pl $s1GFF_file > $s1GFF_file'_sorted.gff3'
#output # 3a for species 1
bgzip $s1GFF_file'_sorted.gff3'
tabix $s1GFF_file'_sorted.gff3.gz'

#sp 2
./gff3sort.pl $s2GFF_file > $s2GFF_file'_sorted.gff3'
#output # 3b for species 2
bgzip $s2GFF_file'_sorted.gff3'
tabix $s2GFF_file'_sorted.gff3.gz'




mkdir final
mv *.gz* final/
mv *.paf final/
mv blastnOut.txt final/







