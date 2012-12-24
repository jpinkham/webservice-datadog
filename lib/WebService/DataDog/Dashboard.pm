package WebService::DataDog::Dashboard;

use strict;
use warnings;

use base qw( WebService::DataDog );
use Carp qw( carp croak );
use Try::Tiny;
use Data::Dumper;

=head1 NAME

WebService::DataDog::Dashboard - Interface to Dashboard functions in DataDog's API.

=head1 VERSION

Version 0.1.0

=cut

our $VERSION = '0.1.0';


=head1 SYNOPSIS
This module allows you interact with the Dashboard endpoint of the DataDog API.

Per DataDog: "The Dashboards end point allow you to programmatically create,
update delete and query dashboards."


=head1 METHODS

=head2 get_all_dashboards()

Retrieve details for all user-created dashboards ( does not include
system-generated or integration dashboards ).

	my $dashboard = $datadog->build('Dashboard');
	my $dashboard_list = $dashboards->get_all_dashboards();
	
Parameters: None

=cut

sub get_all_dashboards
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	my $url = $WebService::DataDog::API_ENDPOINT . 'dash';
	
	my $response = $self->_send_request(
		method => 'GET',
		url    => $url,
		data   => { '' => [] }
	);
	
	if ( !defined($response) || !defined($response->{'dashes'}) )
	{
		croak "Fatal error. No response or 'dashes' missing from response.";
	}
	
	return $response->{'dashes'};
}


=head2 get_dashboard()

Retrieve details for specified user-created dashboards ( does not work for
system-generated or integration dashboards ).

	my $dashboard = $datadog->build('Dashboard');
	my $dashboard_data = $dashboards->get_dashboard( id => $dash_id );
	
Parameters: 

=over 4

=item * id
Id of dashboard you want to retrieve the details for.

=over

=cut

sub get_dashboard
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	# Check for mandatory parameters
	foreach my $arg ( qw( id ) )
	{
		croak "ERROR - Argument '$arg' is required."
			if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
	}
	
	# Check that id specified is a number
	croak "ERROR - Dashboard id must be a number. You specified >" . $args{'id'} . "<"
		unless $args{'id'} =~ /^\d+$/;
	
	my $url = $WebService::DataDog::API_ENDPOINT . 'dash' . '/' . $args{'id'};
	my $response;
	try
	{
		$response = $self->_send_request(
			method => 'GET',
			url    => $url,
			data   => { '' => [] }
		);
	}
	catch
	{
		croak "Unknown dashboard id >" . $args{'id'} . "<";
	};
	
	if ( !defined($response) || !defined($response->{'dash'}) )
	{
		croak "Fatal error. No response or 'dash' missing from response.";
	}
	
	return $response;
}


=head2 update_dashboard()

Update details for specified user-created dashboard ( does not work for
system-generated or integration dashboards ).
Supply at least one of the arguments 'title', 'description', 'graphs'.
Any argument not supplied will remain unchanged within the dashboard.

WARNING: If you only specify a new graph to add to the dashboard, you WILL
LOSE ALL EXISTING GRAPHS.  Your 'graphs' section must include ALL graphs
that you want to be part of a dashboard.

	my $dashboard = $datadog->build('Dashboard');
	$dashboards->update_dashboard(
		id          => $dash_id,
		title       => $dash_title,
		description => $dash_description,
		graphs      => $graphs,
	);
	
Parameters: 

=over 4

=item * id
Id of dashboard you want to update.

=item * title
Optional. Specify updated title for specified dashboard.

=item * description
Optional. Specify updated description for specified dashboard.

=item * graphs
Optional. Specify updated graph definition for specified dashboard.

=over

=cut

sub update_dashboard
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	# Check for mandatory parameters
	foreach my $arg ( qw( id ) )
	{
		croak "ERROR - Argument '$arg' is required."
			if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
	}
	
	# Check that id specified is a number
	croak "ERROR - Dashboard id must be a number. You specified >" . $args{'id'} . "<"
		unless $args{'id'} =~ /^\d+$/;
	
	# Check that one update field was supplied
	if ( !defined( $args{'title'} ) && !defined( $args{'description'} ) && !defined( $args{'graphs'} ) )
	{
		croak "ERROR - you must supply at least one of the following arguments: title, description, graphs";
	}
	
	if ( defined( $args{'title'} ) && $args{'title'} eq '' )
	{
		croak "ERROR - you cannot have a blank dashboard title.";
	}
	
	#TODO extensive graph error checking
	# ?? disallow any 'graph' section changes without additional config/force/etc?
	# - compare new definition vs existing. warn if any graphs are removed. print old definition
	# - make sure all graph fields are specified: 
	#  title,
	#  definition: events, requests
	#  viz
	
	my $url = $WebService::DataDog::API_ENDPOINT . 'dash' . '/' . $args{'id'};
	
	my $response;
	# Try to pull up details on specified dashboard before attempting updates
	try
	{
		$response = $self->_send_request(
			method => 'GET',
			url    => $url,
			data   => { '' => [] }
		);
	}
	catch
	{
		croak "Error retrieving details on dashboard id >" . $args{'id'} . "<";
	};
	
	if ( !defined($response) || !defined($response->{'dash'}) )
	{
		croak "Fatal error. No response or 'dash' missing from response.";
	}
	
	my $dash_original_details = $response->{'dash'};
	
	$response = undef;
	
	my $data = 
	{
		id => $args{'id'}
	};
	
	# Build required API arguments, using original details for anything that user
	#   has not supplied
	$data->{'title'} = defined $args{'title'}
		? $args{'title'} 
		: $dash_original_details->{'title'};
	
	$data->{'description'} = defined $args{'description'}
		? $args{'description'}
		: $dash_original_details->{'description'};
		
	$data->{'graphs'} = defined $args{'graphs'}
		? $args{'graphs'} 
		: $dash_original_details->{'graphs'};
	
	#do requested update
	$response = $self->_send_request(
			method => 'PUT',
			url    => $url,
			data   => $data,
		);
	
	#TODO check that each intended change is reflected in response
	
	return;
}



1;
