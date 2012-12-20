package WebService::DataDog::Dashboard;

use strict;
use warnings;

use base qw( WebService::DataDog );

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
#	my $verbose = $self->verbose();
	
	return $self->_send_request(
		command => 'dash',
		data    => { '' => [] }
	);
}

1;
