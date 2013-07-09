z5llToXML
=========

Tools for converting ZipInfo.com z5ll.txt files to Demandware Geolocation XML format files.

Usage
-----

To convert a file from ZipInfo.com's CSV format into an importable Demandware Geolocation 
XML file is as simple as running the following command:

    $ ./z5llToXML.rb /path/to/z5ll.txt

You can also convert multiple files at once:

    $ ./z5llToXML.rb /path/to/z5ll.txt /path/to/another/z5ll.txt

Roadmap
-------

1. Currently the script can use several megabytes of RAM and ideally will be converted to
  perform progressive writes to the output file rather than storing the entire XML document
  in system memory. One way it currently attempts to deal with this issue is to (in bad form)
  trigger garbage collection after every 1000 rows processed. This helps keep the program from
  eating up too much RAM and causing severe slowdowns.
