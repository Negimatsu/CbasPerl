SERVER=ftp.ncbi.nlm.nih.gov
USER=anonymous
PASSW=anonymous

ftp -v -n $SERVER <<END_OF_SESSION
user $USER $PASSW
$FILETYPE
cd /genomes/Plasmids
mget plasmids.all.fna.tar.gz
bye
END_OF_SESSION
mv plasmids.all.fna.tar.gz Plasmid/

cd Plasmid
tar zxvf plasmids.all.fna.tar.gz



