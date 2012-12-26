package WebService::DataDog::Event;

use strict;
use warnings;

use base qw( WebService::DataDog );
use Carp qw( carp croak );
use Data::Dumper;


=head1 NAME

WebService::DataDog::Event - Interface to Event functions in DataDog's API.

=head1 VERSION

Version 0.2.0

=cut

our $VERSION = '0.2.0';


=head1 SYNOPSIS
This module allows you interact with the Event endpoint of the DataDog API.

Per DataDog: "The events service allows you to programatically post events to
the stream and fetch events from the stream."


=head1 METHODS

=head2 search()
Search the event stream using specified parameters.

	my $event = $datadog->build('Event');
	my $event_list = $event->search(
		start     => $start_time,
		end       => $end_time, # Optional - default 'now'
		priority  => $priority, # Optional - low|normal
		sources   => $sources,  # Optional - list of sources. Ex: Datadog, Github, Pingdom, Webmetrics
		tags      => $tag_list, # Optional - list of tags associated with the event
	);
	
	Examples:
	+ Find all events in the last 48 hours.
	my $event_list = $event->search(
		start => time() - ( 48 * 60 * 60 ),
	);
	
	+ Find all events in the last 24 hours tagged with 'env:prod'.
	my $event_list = $event->search(
		start => time() - ( 24 * 60 * 60 ),
		end   => time(),
		tags  => [ 'env:prod' ],
	);
	
Parameters:

=over 4

=item * start

The start of the date/time range to be searched. UNIX/Epoch/POSIX time.

=item * end

Optional. The end of the date/time range to be searched. UNIX/Epoch/POSIX time.
Default = now.

=item * priority

Optional. Event priority level. Accepted values: low, normal.

=item * sources

Optional. List of sources that generated events.

=item * tags

Optional. List of tags associated with the events.

=back

=cut

sub search
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();

	# Perform various error checks before attempting to search events
	$self->_error_checks( %args );
	
	my $url = $WebService::DataDog::API_ENDPOINT . 'events' . '?';
		
	$url .= 'start=' . $args{'start'};
	$url .= '&end=' . ( defined $args{'end'} ? $args{'end'} : time() );
	
	if ( defined( $args{'priority'} ) )
	{
		$url .= '&priority=' . $args{'priority'};
	}
	
	if ( defined( $args{'tags'} ) )
	{
		$url .= '&tags=' . ( join( ',', @{ $args{'tags'} } ) );
	}
	
	if ( defined( $args{'sources'} ) )
	{
		$url .= '&sources=' . ( join( ',', @{ $args{'sources'} } ) );
	}
	
	my $response = $self->_send_request(
		method => 'GET',
		url    => $url,
		data   => { '' => [] }
	);
	
	if ( !defined($response) || !defined($response->{'events'}) )
	{
		croak "Fatal error. No response or 'events' missing from response.";
	}
	
	return $response->{'events'};
}


=head1 INTERNAL FUNCTIONS

=head2 _error_checks()

=cut

sub _error_checks
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	# Check for mandatory parameters
	foreach my $arg ( qw( start ) )
	{
		croak "Argument '$arg' is required for search()"
			if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
	}
	
	# Check that 'start' is valid
	croak "ERROR - invalid value >" . $args{'start'} . "< for argument 'start'. Must be POSIX/Unixtime"
		unless ( $args{'start'} =~ /^\d{10,}$/ ); #min 10 digits, allowing for older data back to 1/1/2000
	
	# Check that 'end' is valid
	if ( defined $args{'end'} )
	{
		croak "ERROR - invalid value >" . $args{'end'} . "< for argument 'end'. Must be POSIX/Unixtime"
		unless ( $args{'end'} =~ /^\d{10,}$/ ); #min 10 digits, allowing for older data back to 1/1/2000
	}
	
	# Check that 'priority' is valid
	if ( defined $args{'priority'} )
	{
		croak "Invalid value >" . $args{'priority'} . "< for argument 'priority'. Allowed values: low, normal."
			unless ( lc( $args{'priority'} ) eq "low" || lc( $args{'priority'} ) eq "normal" );
	}
	
	# Check that 'tags' is valid
	if ( defined( $args{'tags'} ) )
	{
		if ( !Data::Validate::Type::is_arrayref( $args{'tags'} ) )
		{
			croak "Tag list is invalid. Must be an arrayref.";
		}
	}
	
	# Check that 'sources' is valid
	if ( defined( $args{'sources'} ) )
	{
		if ( !Data::Validate::Type::is_arrayref( $args{'sources'} ) )
		{
			croak "Sources list is invalid. Must be an arrayref.";
		}
	}
	
	return;
}

=head1 AUTHOR

Jennifer Pinkham, C<< <jpinkham at cpan.org> >>.


=head1 BUGS

Please report any bugs or feature requests to C<bug-WebService-DataDog at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-DataDog>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc WebService::DataDog::Event


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-DataDog>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-DataDog>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-DataDog>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-DataDog/>

=back


=head1 COPYRIGHT & LICENSE

Copyright 2012 Jennifer Pinkham.

This program is free software; you can redistribute it and/or modify it
under the terms of the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut


1;
