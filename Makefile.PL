
use strict;

use ExtUtils::MakeMaker;

my %prereq_pm = ( # solely for the test-suite.
                  'Test::More'       => undef,
                  'Test::Pod'        => undef,
                  'Test::NoTabs'     => undef,
                );

WriteMakefile(
    NAME         => 'TinyDNS::Reader',
    VERSION_FROM => 'lib/TinyDNS/Reader.pm',
    PREREQ_PM    => \%prereq_pm,
    ABSTRACT     => 'Parser for TinyDNS records.',
    AUTHOR       => 'Steve Kemp <steve@steve.org.uk>',
    LICENSE      => 'perl_5',

    META_MERGE => {
        resources => {
            license    => 'http://dev.perl.org/licenses/',
            homepage   => 'https://github.com/skx/TinyDNS--Reader/',
            bugtracker => 'https://github.com/skx/TinyDNS--Reader/issues',
            repository => 'https://github.com/skx/TinyDNS--Reader.git',
                     },
                  },
             );


package MY;

sub metafile {
        my $self    = shift;
        my $meta    = $self->SUPER::metafile_target(@_);
        my ($extra) = $self->echo('license: perl_5', 'MYMETA.yml', 1);
        return "$meta\t$extra\n";
}
