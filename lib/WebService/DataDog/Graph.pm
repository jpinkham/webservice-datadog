package WebService::DataDog::Graph;

use strict;
use warnings;

use base qw( WebService::DataDog );
use Carp qw( carp croak );
use Data::Dumper;
use Try::Tiny;


=head1 NAME

WebService::DataDog::Graph - Interface to Graph functions in DataDog's API.

=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';


=head1 SYNOPSIS

This module allows you interact with the graph endpoint of the DataDog API.

Per DataDog: "You can take graph snapshots using the API.."


=head1 METHODS

=head2 snapshot()

Take a graph snapshot.
	
	my $graph = $datadog->build('Graph');
	$graph->snapshot(
		metric_query => $metric_query,
		start        => $start_timestamp,
		end          => $end_timestamp,
		event_query  => $event_query, # optional -- default=None
	);
	
	Example:
	$graph->snapshot(
		metric_query => "system.load.1{*}",
		start        => 1388632282
		end          => 1388718682,
		event_query  => 
	
Parameters:

=over 4

=item * metric_query



=back

=cut

sub snapshot 
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	# Check for mandatory parameters
	foreach my $arg ( qw( metric_query start end ) )
	{
		croak "ERROR - Argument '$arg' is required for snapshot()."
			if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
	}
	
	if ( defined $args{'emails'} )
	{
		if ( !Data::Validate::Type::is_arrayref( $args{'emails'} ) )
		{
			croak "ERROR - invalid 'emails' value. Must be an arrayref.";
		}
		
	}

	my $url = $WebService::DataDog::API_ENDPOINT . 'invite_users';
	
	my $data = {
		emails => $args{'emails'},
	};
	
	my $response = $self->_send_request(
		method => 'POST',
		url    => $url,
		data   => $data,
	);
	
	if ( !defined($response) )
	{
		croak "Fatal error. No response";
	}
	
	return $response;
}


1;
