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

Version 0.2.0

=cut

our $VERSION = '0.2.0';


=head1 SYNOPSIS
This module allows you interact with the Dashboard endpoint of the DataDog API.

Per DataDog: "The Dashboards end point allow you to programmatically create,
update delete and query dashboards."


=head1 METHODS

=head2 get_all_dashboards()

Retrieve details for all user-created dashboards ( does not include
system-generated or integration dashboards ).

	my $dashboard = $datadog->build('Dashboard');
	my $dashboard_list = $dashboard->get_all_dashboards();
	
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
	my $dashboard_data = $dashboard->get_dashboard( id => $dash_id );
	
Parameters: 

=over 4

=item * id
Id of dashboard you want to retrieve the details for.

=back

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
	croak "ERROR - invalid 'id' >" . $args{'id'} . "<. Dashboard id must be a number."
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
		if ( /404/ )
		{
			croak "Unknown dashboard id >" . $args{'id'} . "<";
		}
		else
		{
			croak "Error occurred while trying to retrieve details of dashboard  >" . $args{'id'} . "<. Error: $_";
		}
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
	$dashboard->update_dashboard(
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

=back

=cut

sub update_dashboard
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	$self->_error_checks(
		mode => 'update',
		data => \%args,
	);

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
		croak "Error retrieving details on dashboard id >" . $args{'id'} . "<. Are you sure this is the correct dashboard id?";
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
	
	$response = $self->_send_request(
			method => 'PUT',
			url    => $url,
			data   => $data,
		);
	
	return;
}


=head2 create()

Create new DataDog dashboard with 1+ graphs.
If successful, returns created dashboard id.

	my $dashboard = $datadog->build('Dashboard');
	my $dashboard_id = $dashboard->create(
		title       => $dash_title,
		description => $dash_description,
		graphs      => $graphs,
	);
	
Parameters:

=over 4

=item * title
Specify title for new dashboard.

=item * description
Specify description for new dashboard.

=item * graphs
Specify graph definition for new dashboard.

=back

=cut

sub create
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	$self->_error_checks(
		mode => 'create',
		data => \%args,
	);

	my $url = $WebService::DataDog::API_ENDPOINT . 'dash';
	
	my $data = 
	{
		title       => $args{'title'},
		description => $args{'description'},
		graphs      => $args{'graphs'},
	};
	
	my $response = $self->_send_request(
			method => 'POST',
			url    => $url,
			data   => $data,
		);
	
	if ( !defined($response) || !defined($response->{'dash'}) )
	{
		croak "Fatal error. No response or 'dash' missing from response.";
	}
	
	return $response->{'dash'}->{'id'};
}


=head2 delete_dashboard()

Delete specified dashboard.

=cut

sub delete_dashboard
{
	my ( $self, %args ) = @_;
	
	my $verbose = $self->verbose();
	
	# Check for mandatory parameters
	foreach my $arg ( qw( id ) )
	{
		croak "ERROR - Argument '$arg' is required for delete_dashboard()."
			if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
	}
	
	# Check that id specified is a number
	croak "ERROR - invalid 'id' >" . $args{'id'} . "<. Dashboard id must be a number."
		unless $args{'id'} =~ /^\d+$/;
	
	my $url = $WebService::DataDog::API_ENDPOINT . 'dash' . '/' . $args{'id'};
	
	
	# NOTE: no response is returned when request is succesful
	my $response;
	try
	{
		$response = $self->_send_request(
			method => 'DELETE',
			url    => $url,
			data   => { '' => [] }
		);
	}
	catch
	{
		if ( /404/ )
		{
			croak "Error 404 deleting dashboard id >" . $args{'id'} . "<. Are you sure this is the correct dashboard id?";
		}
	};
	
	return;
}


=head1 INTERNAL FUNCTIONS

=head2 _error_checks()

Common error checking for creating/updating dashboards.

=cut

sub _error_checks
{
	my ( $self, %arguments ) = @_;
	my $verbose = $self->verbose();
	
	my $mode = $arguments{'mode'};
	my %args = %{ $arguments{'data'} };
	
	if ( $mode eq "update" )
	{
		# Check for mandatory parameters
		foreach my $arg ( qw( id ) )
		{
			croak "ERROR - Argument '$arg' is required for update_dashboard()."
				if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
		}
		
		# Check that id specified is a number
		croak "ERROR - invalid 'id' >" . $args{'id'} . "<. Dashboard id must be a number."
			unless $args{'id'} =~ /^\d+$/;
		
		# Check that one update field was supplied
		if ( !defined( $args{'title'} ) && !defined( $args{'description'} ) && !defined( $args{'graphs'} ) )
		{
			croak "ERROR - you must supply at least one of the following arguments: title, description, graphs";
		}
	}
	elsif ( $mode eq "create" )
	{
		# Check for mandatory parameters
		foreach my $arg ( qw( title description graphs ) )
		{
			croak "ERROR - Argument '$arg' is required for create()."
				if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
		}
	}
	
	if ( defined( $args{'title'} ) && $args{'title'} eq '' )
	{
		croak "ERROR - you cannot have a blank dashboard title.";
	}
	
	# Check that title is <= 80 characters. Per Carlo @DDog. Undocumented?
	croak( "ERROR - invalid 'title' >" . $args{'title'} . "<. Title must be 80 characters or less." )
		if ( defined( $args{'title'} ) && length( $args{'title'} ) > 80 );
	
	# Check that description is <= 4000 characters. Per Carlo @DDog. Undocumented?
	croak( "ERROR - invalid 'description' >" . $args{'description'} . "<. Description must be 4000 characters or less." )
		if ( defined( $args{'description'} ) && length( $args{'description'} ) > 4000 );
	
	#TODO extensive graph error checking
	# ?? disallow any 'graph' section changes without additional config/force/etc?
	# - compare new definition vs existing. warn if any graphs are removed. print old definition
	# - make sure all graph fields are specified: 
	#  title,  (255 char limit)
	#  definition: events, requests   (4000 char limit)
	#  viz?? (docs show it included in example, but not listed in fields, required or optional)
	if ( defined ( $args{'graphs'} ) )
	{
		croak "ERROR - 'graphs' argument must be an arrayref"
			if !Data::Validate::Type::is_arrayref( $args{'graphs'} );
		
		croak "ERROR - at least one graph definition is required for create()"
			if scalar( @{ $args{'graphs'} } == 0 );
			
		foreach my $graph_item ( @{ $args{'graphs'} } )
		{
			# Check for mandatory parameters
			foreach my $argument ( qw( title definition ) )
			{
				croak "ERROR - Argument '$argument' is required within each graph for create()."
					if !defined( $graph_item->{$argument} ) || ( $graph_item->{$argument} eq '' );
			}
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

	perldoc WebService::DataDog::Dashboard


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
