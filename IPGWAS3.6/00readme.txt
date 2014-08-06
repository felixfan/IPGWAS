Note: these scripts are distributed under a GNU general public licence

Note: IPGWAS is distributed "AS IS" WITHOUT WARRANTY of any kind.

1. Title: "IPGWAS: An Integrated Pipeline for Genome-Wide Association Studies."

2. Install IPGWAS

Windows:
	(1) Download and install activeperl from http://www.activestate.com/activeperl/downloads
	(2) Open an MS-DOS window and type the following commands to install Perl/Tk and other Perl modules.
		ppm install Tk
		cpan
		install Math::CDF
	
Linux (Ubuntu): Open a terminal and type the following commands to install Perl/Tk and other Perl modules.
		sudo apt-get install libx11-dev
		sudo apt-get install libgd2-xpm-dev
		sudo cpan 
		install Tk
		install Math::CDF
		install Archive::Extract
		install Archive::Tar
		install LWP::Simple
		install GD::Graph::histogram

MAC OS X: Refer to the manual (manual/IPGWAS_Manual.pdf) for details.
You may need to install Adobe Reader (http://get.adobe.com/reader/) first.

3. Run IPGWAS

For Windows OS, you can just double click "ipgwas_win.bat" to run IPGWAS or open an MS-DOS window and go to the bin directory
and type "perl ipgwas_win.pl" to run IPGWAS. 

For Linux OS, open a terminal and go to the ipgwas directory:
chmod +x ipgwas_linux.sh
./ipgwas_linux.sh

for MAC OS, open a terminal and go to the ipgwas directory:
chmod +x ipgwas_mac.sh
./ipgwas_mac.sh
