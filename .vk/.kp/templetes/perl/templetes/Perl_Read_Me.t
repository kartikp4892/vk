============================================================
Instructions :
============================================================
Only for Windows:
  1. The script requires perl installed on you system. To check if perl installed properly on your system use the following command:
     $ perl -v
     Here '$' sign should not be typed with the command. It's the representation of the command. 
  
     If the perl is not installed on your machine please install it from the below mentioned site.
     http://strawberryperl.com/
  
Windows & Linux:
  2. The script requires CPAN module to be installed.
       
       1. Web::Scraper;
       2. Text::CSV_PP;
       3. WWW::Mechanize;
       4. DateTime;
       5. Getopt::Std;
       6. CGI;

     To install a module the following command in the MS-DOS prompt must be given.
       $ cpan <Module Name>

       For example: $ cpan Web::Scraper

  3. Run the script by giving the following command in the MS-DOS prompt:
       $ perl airbnb_scrape.pl <Options> <Argument>

     To print help about the script to know the valid options and argument please use the following command:
       $ perl airbnb_scrape.pl -h

     After running the script will start scraping the information from the site for a zip code.
