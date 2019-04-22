node 'ip-172-31-4-204.sa-east-1.compute.internal' {

class { 'openldap::server': }
openldap::server::database { 'dc=techinterview,dc=local':
 ensure => present,
 directory => '/var/lib/ldap',
 rootdn => 'cn=root,dc=techinterview,dc=local',
 rootpw => 'secret',
}

}
node default {}
