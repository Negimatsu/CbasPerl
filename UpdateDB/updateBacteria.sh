SERVER=ftp.ncbi.nlm.nih.gov
USER=anonymous
PASSW=anonymous

ftp -v -n $SERVER <<END_OF_SESSION
user $USER $PASSW
$FILETYPE
cd /genomes/Bacteria
mget all.fna.tar.gz
bye
END_OF_SESSION

mv all.fna.tar.gz bacteria.all.fna.tar.gz

mv bacteria.all.fna.tar.gz Bacteria/
cd Bacteria
tar zxvf bacteria.all.fna.tar.gz


