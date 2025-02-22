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

package cloud::nutanix::snmp::plugin;

use strict;
use warnings;
use base qw(centreon::plugins::script_snmp);

sub new {
    my ($class, %options) = @_;
    my $self = $class->SUPER::new(package => __PACKAGE__, %options);
    bless $self, $class;

    $self->{version} = '1.0';
    $self->{modes} = {
        'cluster-usage'      => 'cloud::nutanix::snmp::mode::clusterusage',
        'container-usage'    => 'cloud::nutanix::snmp::mode::containerusage',
        'discovery'          => 'cloud::nutanix::snmp::mode::discovery',
        'disk-usage'         => 'cloud::nutanix::snmp::mode::diskusage',
        'hypervisor-usage'   => 'cloud::nutanix::snmp::mode::hypervisorusage',
        'list-containers'    => 'cloud::nutanix::snmp::mode::listcontainers',
        'list-disks'         => 'cloud::nutanix::snmp::mode::listdisks',
        'list-hypervisors'   => 'cloud::nutanix::snmp::mode::listhypervisors',
        'list-storage-pools' => 'cloud::nutanix::snmp::mode::liststoragepools',
        'list-vms'           => 'cloud::nutanix::snmp::mode::listvms',
        'storage-pool-usage' => 'cloud::nutanix::snmp::mode::storagepoolusage',
        'vm-usage'           => 'cloud::nutanix::snmp::mode::vmusage'
    };

    return $self;
}

1;

__END__

=head1 PLUGIN DESCRIPTION

Check Nutanix in SNMP.

=cut
