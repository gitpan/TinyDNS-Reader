
=head1 NAME

TinyDNS::Record - Parse a single TinyDNS Record.

=head1 DESCRIPTION

This module provides an object API to a single TinyDNS record/line.

It is not quite valid because:

=over 8

=item *
We ignore NS and SOA records, which Amazon would handle for us.

=item *
Our TXT records handling uses "T" not ":".

=item *
Our MX record handling allows a name to be set with no IP.

=back

There are probably other differences.

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

package TinyDNS::Record;


use Carp;


#
#  Allow our object to treated as a string.
#
use overload'""' => 'stringify';



=begin doc

Constructor.

Set the type of the object.

=end doc

=cut

sub new
{
    my ( $proto, $line ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );

    #
    #  The record-type is the first character.
    #
    my $rec = substr( $line, 0, 1 );

    #
    #  Remove the record-type from the line
    #
    $line = substr( $line, 1 );

    #
    # Tokenize - NOTE This is ignored for TXT records,
    # (because a TXT record used for SPF might have an embedded
    # ":" for example.)
    #
    my @data = split( /:/, $line );

    #
    #  Nasty parsing for each record type..
    #
    #  We should do better.
    #
    #
    if ( ( $rec eq '+' ) || ( $rec eq '=' ) )
    {
        # name : ipv4 : ttl
        $self->{ 'type' }  = "A";
        $self->{ 'name' }  = $data[0];
        $self->{ 'value' } = $data[1];
        $self->{ 'ttl' }   = $data[2] || 300;
    }
    elsif ( $rec eq '6' )
    {
        # name : ipv6 : ttl
        $self->{ 'type' }  = "AAAA";
        $self->{ 'name' }  = $data[0];
        $self->{ 'ttl' } = $data[2] || 300;

        #
        #  Convert an IPv6 record of the form:
        #     "200141c8010b01010000000000000010"
        #  to the expected value:
        #     "2001:41c8:010b:0101:0000:0000:0000:0010".
        #
        my $ipv6 = $data[1];
        my @tmp  = ( $ipv6 =~ m/..../g );
        $self->{'value'} = join( ":", @tmp );
    }
    elsif ( $rec eq '@' )
    {
        #
        # @xxx:name:ttl
        # @xxx:[ip]:name:ttl
        #
        if ( scalar(@data) == 4 )
        {
            $self->{ 'type' }     = "MX";
            $self->{'name'} = $data[0];
            $self->{ 'priority' } = $data[3] || "15";
            $self->{ 'ttl' }      = $data[4] || 300;
            $self->{ 'value' }    = $self->{'priority'} . " " . $data[2];
        }
        if ( scalar(@data) == 3 )
        {
            $self->{ 'type' }     = "MX";
            $self->{'name'} = $data[0];
            $self->{ 'priority' } = $data[2] || "15";
            $self->{ 'ttl' }      = $data[3] || 300;
            $self->{ 'value' }    = $self->{'priority'} . " " . $data[1];
        }
    }
    elsif ( ( $rec eq 'c' ) || ( $rec eq 'C' ) )
    {
        #
        # name :  dest : [ttl]
        #
        $self->{ 'type' }  = "CNAME";
        $self->{ 'name' }  = $data[0];
        $self->{ 'value' } = $data[1];
        $self->{ 'ttl' }   = $data[2] || 300;
    }
    elsif ( ( $rec eq 't' ) || ( $rec eq 'T' ) )
    {
        #
        # name : "data " : [TTL]
        #
        if ( $line =~ /([^:]+):"([^"]+)":([0-9]+)$/ )
        {
            $self->{'type'} = "TXT";
            $self->{'name'} = $1;
            $self->{'value'} ="\"$2\"";
            $self->{'ttl'} =$3;
        }
        else
        {
            die "Invalid TXT record - $line\n";
        }
    }
    elsif ( $rec eq '^' )
    {
        #
        #  ptr : "rdns " : [TTL]
        #
        $self->{'type'} = "PTR";
        $self->{ 'name' }  = $data[0];
        $self->{ 'value' } = $data[1];
        $self->{ 'ttl' }   = $data[2] || 300;
    }
    else
    {
        carp "Unknown record type [$rec]: $line";
        return undef;
    }
    return $self;

}


=begin doc

Is the given record valid?  If it has a type then it must be.

=end doc

=cut

sub valid
{
    my ($self) = (@_);

    return ( $self->{ 'type' } ? 1 : 0 );
}


=begin doc

Get the type of record this object holds.

=end doc

=cut

sub type
{
    my ($self) = (@_);

    return ( $self->{ 'type' } );
}


=begin doc

Get the TTL of this object.

=end doc

=cut

sub ttl
{
    my ($self) = (@_);
    return ( $self->{ 'ttl' } || 300 );
}


=begin doc

Get the name of this record.

=end doc

=cut

sub name
{
    my ($self) = (@_);
    return ( $self->{ 'name' } );
}


=begin doc

Get the value of this record.

=end doc

=cut

sub value
{
    my ($self) = (@_);

    return ( $self->{ 'value' } );
}


=begin doc

Add a new value to the existing record.

This is added by the L<TinyDNS::Reader::Merged> module.

=end doc

=cut

sub add
{
    my ( $self, $addition ) = (@_);

    my $value = $self->{ 'value' };
    if ( ref \$value eq "SCALAR" )
    {
        my $x;
        push( @$x, $value );
        push( @$x, $addition );
        $self->{ 'value' } = $x;
    }
    else
    {
        push( @$value, $addition );
        $self->{ 'value' } = $value;
    }
}


=begin doc

Conver the record to a string, suitable for printing.

=end doc

=cut

sub stringify
{
    my ($self) = (@_);
    my $txt = "";

    $txt .= ( "Type " . $self->type() . "\n" )    if ( $self->type() );
    $txt .= ( " Name:" . $self->name() . "\n" )   if ( $self->name() );
    $txt .= ( " Value:" . $self->value() . "\n" ) if ( $self->value() );
    $txt .= ( " TTL:" . $self->ttl() . "\n" )     if ( $self->ttl() );

}


1;
