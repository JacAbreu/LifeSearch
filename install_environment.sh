
#!/bin/bash
 
\curl -L http://install.perlbrew.pl | bash
 
source ~/perl5/perlbrew/etc/bashrc
 
perlbrew install perl-5.20.1
 
perlbrew switch perl-5.20.1
 
cpan Carton

carton install

carton exec -- ./bin/app.pl 
  

