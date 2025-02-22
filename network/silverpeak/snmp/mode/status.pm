#
# Copyright 2022 Centreon (http://www.centreon.com/)
#
# Centreon is a full-fledged industry-strength solution that meets
# the needs in IT infrastructure and application monitoring for
# service performance.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package network::silverpeak::snmp::mode::status;

use base qw(centreon::plugins::templates::counter);

use strict;
use warnings;
use centreon::plugins::templates::catalog_functions qw(catalog_status_threshold_ng);

sub custom_status_output {
    my ($self, %options) = @_;

    return "Operational state: '" . $self->{result_values}->{operStatus} . "' ";
}

sub set_counters {
    my ($self, %options) = @_;

    $self->{maps_counters_type} = [
        { name => 'global', type => 0 }
    ];

    $self->{maps_counters}->{global} = [
        { label => 'status', type => 2, critical_default => '%{operStatus} !~ /(Normal)/', set => {
                key_values => [ { name => 'operStatus' } ],
                closure_custom_output => $self->can('custom_status_output'),
                closure_custom_perfdata => sub { return 0; },
                closure_custom_threshold_check => \&catalog_status_threshold_ng
            }
        }
    ];
}

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(package => __PACKAGE__, %options);
    bless $self, $class;

    $options{options}->add_options(arguments => {});

    return $self;
}

sub manage_selection {
    my ($self, %options) = @_;

    my $oid_spsOperStatus = '.1.3.6.1.4.1.23867.3.1.1.1.3.0';
    my $result = $options{snmp}->get_leef(
        oids => [ $oid_spsOperStatus ],
        nothing_quit => 1
    );

    $self->{global} = { operStatus => $result->{$oid_spsOperStatus}};
}

1;

__END__

=head1 MODE

Check operational state of the Silverpeak appliance.

=item B<--warning-status>

Trigger warning on %{operStatus} values

=item B<--critical-status>

Trigger critical on %{operStatus} values
(Default: '%{operStatus} !~ /(Normal)/')

=back

=cut
