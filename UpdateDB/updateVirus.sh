SERVER=ftp.ncbi.nlm.nih.gov
USER=anonymous
PASSW=anonymous

ftp -v -n $SERVER <<END_OF_SESSION
user $USER $PASSW
$FILETYPE
cd /genomes/Viruses
mget all.fna.tar.gz
bye
END_OF_SESSION

mv all.fna.tar.gz virus.all.fna.tar.gz
mv virus.all.fna.tar.gz Virus/

cd Virus
tar zxvf virus.all.fna.tar.gz



