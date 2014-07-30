TinyDNS::Reader
===============

This repository contains the source for the perl module `TinyDNS::Reader` and
`TinyDNS::Record`.

They allow the reading and parsing of tinydns data-files, like so:

    my $reader = TinyDNS::Reader->new( file => "zones/steve.co" );
    my $records = $reader->parse();

    foreach my $record ( @$records )
    {
        print $record;
    }

Further details are available in the test-cases, or the POD.

Notes
-----

This module was put together for the [Git-based DNS hosting service](https://dns-api.com/), and
shouldn't be uploaded to CPAN, and indeed I did not do so, because the name
implies it can parse real/genuine/complete TinyDNS records,
however that is not the case:

* We ignore SOA records.
* We ignore NS records.
* Our TXT record (which should have a `:`-prefix) is non-standard/weird.
   * We use `T:name:value[:ttl]` instead.  Which is cleaner.


Utility Script
--------------

Contained within the distribution is a simple `dump-zones` script,
which will allow you to see how a file would be parsed by the 
[DNS-hosting service](https://dns-api.com/).

Usage:

    ./dump-records file1 file2 .. fileN



Steve
--
