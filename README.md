z5llToXML
=========

Tools for converting ZipInfo.com `z5ll.txt` and `zcugoem.txt` files to Salesforce Commerce 
Cloud\* (SFCC) Geolocation XML format files. (\*formerly known as Demandware)

Dependencies
------------

* (for OSX) [XCode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12) & Command Line Utilites
* [Bundler](http://bundler.io/) gem

Usage
-----

To setup dependencies you must run the following command:

    $ bundle install

To convert a file from ZipInfo.com's CSV format into an importable SFCC Geolocation 
XML file is as simple as running the following command:

    $ ./z5llToXML.rb /path/to/z5ll.txt

You can also convert multiple files at once:

    $ ./z5llToXML.rb /path/to/z5ll.txt /path/to/another/z5ll.txt

Some files contain multiple country postal codes. If your file contains multiple codes 
such as the `zcugoem.txt` file that contains both US & CA postal codes. Simply use the 
`-c` or `--country` flag to specify the country codes that are in the file(s). Currently 
z5llToXML supports only US & CA.

    $ ./z5llToXML.rb -c US,CA /path/to/zcugoem.txt

If You Have Trouble Executing
-----------------------------
If you're having issues running this script in your native environment, I 
recommend using (`rvm`)[https://rvm.io/] with Ruby version 2.1.2 which this 
script was written against. Here's an example of the commands to run once 
you've installed rvm.

    $ rvm install ruby-2.1.2
    $ rvm use ruby-2.1.2
    $ gem install bundler
    $ bundle install
    $ ruby ./z5llToXML.rb /path/to/z5ll.txt

This should resolve any issues you're having with mismatched Ruby, gems, or 
problems requiring specific gems.

Roadmap
-------

1. ~~Currently the script can use several megabytes of RAM and ideally will be converted to
  perform progressive writes to the output file rather than storing the entire XML document
  in system memory. One way it currently attempts to deal with this issue is to (in bad form)
  trigger garbage collection after every 1000 rows processed. This helps keep the program from
  eating up too much RAM and causing severe slowdowns.~~
  
  **Update:** This was resolved in 1.1a when we switched to libxml-ruby rather than using 
  REXML for XML writing.
