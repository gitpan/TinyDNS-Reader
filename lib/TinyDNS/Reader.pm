
=head1 NAME

TinyDNS::Reader - Read TinyDNS files.

=head1 DESCRIPTION

This module allows the parsing of a TinyDNS data-file, or individual records
taken from one.

=cut

=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 Steve Kemp <steve@steve.org.uk>.

This code was developed for an online Git-based DNS hosting solution,
which can be found at:

=over 8

=item *
https://dns-api.com/

=back

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut


use strict;
use warnings;

package TinyDNS::Reader;

use TinyDNS::Record;

our $VERSION = '0.5';


=begin doc

Constructor.  We should be given either a "file" or "text" parameter.

=end doc

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );

    if ( $supplied{ 'file' } )
    {
        $self->{ 'data' } = $self->_readFile( $supplied{ 'file' } );
    }
    elsif ( $supplied{ 'text' } )
    {
        $self->{ 'data' } = $supplied{ 'text' };
    }
    else
    {
        die "Missing 'text' or 'file' argument.";
    }

    return $self;

}


=begin doc

Read the contents of the specified file.

Invoked by the constructor if it was passed a C<file> argument.

=end doc

=cut

sub _readFile
{
    my ( $self, $file ) = (@_);

    open( my $handle, "<", $file ) or
      die "Failed to read $file - $!";

    my $text = "";

    while ( my $line = <$handle> )
    {
        $text .= $line;
    }
    close($handle);

    return ($text);
}


=begin doc

Process and return an array of L<TinyDNS::Records> from the data.

=end doc

=cut

sub parse
{
    my ($self) = (@_);

    my $records;

    foreach my $line ( split( /[\n\r]/, $self->{ 'data' } ) )
    {
        chomp($line);
        next if ( !$line || !length($line) );

        #
        #  Ignore comments
        #
        next if ( $line =~ /^\s*#/ );

        #
        #  Ignore "." + ":" records
        #
        next if ( $line =~ /^\s*[:.]/ );

        #
        #  Construct a new object, and add it to the list.
        #
        my $rec = TinyDNS::Record->new($line);
        push( @$records, $rec ) if ($rec);
    }

    return ($records);
}


1;
