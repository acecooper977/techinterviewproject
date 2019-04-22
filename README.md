# Installing openLDAP in a CentOS using puppet
##### Author: Fernando Palmeira
##### Any Questions? lfernandobpalmeira@gmail.com

## Configuring puppet environment

### On the Puppet Server machine:

1. First, install puppet repository

`yum install -y https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm`

2.  Then you install puppet packages and set the PATH

`yum install -y puppet-agent puppetserver`

`export PATH=/opt/puppetlabs/bin:$PATH`

`echo "export PATH=/opt/puppetlabs/bin:\$PATH" >> /etc/bashrc`


3.Check Puppet version using the command below (we used Puppet 6.4.1 for this lab) 

`puppet –version`

4.Now configure the puppet.conf file in /etc/puppetlabs/puppet/puppet.conf
Append these lines to the end of the file, changing names according to your environment

```
[main]
certname = puppetserver.domain.com.br
server = puppetserver.domain.com.br
environment = production

[agent]
report = true
pluginsync = true
```

5. Restart puppetserver service

`service puppetserver restart`

### On the Puppet Agent Node (openLDAP Server/AWS CentOS 7 machine)

1. First, install puppet repository

`yum install -y https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm`

2. Next, install the puppet agent package and set the PATH
`yum -y install puppet-agent`

`export PATH=/opt/puppetlabs/bin:$PATH`

`echo "export PATH=/opt/puppetlabs/bin:\$PATH" >> /etc/bashrc`


3.Check Puppet version using the command below (we used Puppet 6.4.1 for this lab)

`puppet –version`

4. edit the /etc/puppetlabs/puppet/puppet.conf file as below (changing names according to your environment)
* In this lab we’re using a AWS instance.

```
[main]
certname = ip-172-31-4-204.sa-east-1.compute.internal
server = zenon.local
environment = production

[agent]
report = true
pluginsync = true
```

5.In this lab our Puppet Server machine does not have a public DNS entry, so it was necessary to put into /etc/resolv.conf the following entry:

`xxx.xxx.xxx.xxx zenon.local`

6. Now we can start the puppet agent service, a certificate will be generated and the sign request will be sent to the puppet server.

`puppet agent -t`

7. Go to the Puppet server machine and sign the certificate

`puppetserver ca sign --certname ip-172-31-4-204.sa-east-1.compute.internal`

8. Run the command below again on the Agent machine, this time the certificate is signed and the agent will be able to communicate with the server

 `puppet agent -t`

## Installing openLDAP using puppet

1. Go to the puppet server machine to install openldap puppet module

`puppet module install camptocamp-openldap --version 1.17.0`

2. Create a site.pp file

`vi /etc/puppetlabs/code/environments/production/manifests/site.pp`

Use the code below:

```
node ‘ip-172-31-4-204.sa-east-1.compute.internal’

class { ‘openldap::server’: }
openldap::server::database { ‘dc=techinterview,dc=local’:
	ensure => present,
	directory => ‘/var/lib/ldap’,
	rootdn => ‘cn=root,dc=techinterview,dc=local’,
	rootpw => ‘xxx’,
	}
}

node default {}
```

3. Now go to the node machine (  ip-172-31-4-204.sa-east-1.compute.internal) and run the following command:

`puppet agent -t`

openLDAP will be installed on the node machine and the techinterview.local domain will be configured.

4. To start openLDAP

`systemctl start slapd`

## Installing Ruby ldap library

1. Go to the node machine (  ip-172-31-4-204.sa-east-1.compute.internal) and run:

`gem install ruby-net-ldap`

This library will allow you to access LDAP servers databases.


## Developing Ruby code

1. For this lab a script named ldapuseradd.rb was created and placed in /root/:

```ruby
/usr/bin/ruby -w

require 'rubygems'
require 'net/ldap'

ldap = Net::LDAP.new :host => '127.0.0.1',
                     :port => 389,
                     :auth => {
                        :method => :simple,
                        :username => "cn=root,dc=techinterview,dc=local",
                        :password => "xxx"
                     }

dn = "cn= TesteRuby,dc=techinterview,dc=local"
        attr = {
                :cn => "TesteRuby",
                :objectclass => "Person",
                :sn => 'TesteRuby',
                }
ldap.add( :dn => dn, :attributes => attr )
```

To check if the script is working it is necessary to use the ldapsearch command:

`ldapsearch -x -b "dc=techinterview,dc=local"`

To run the script use:

`ruby ldapuseradd.rb`

This script will add the “dn” entry to the ldap database with the selected attributes (cn, objectclass and sn), by changing these attributes it is possible to add other types of entries like machines, groups, organization units and so on.


That`s it. Now you have a Puppet Server running and a puppet node with openLDAP installed and running able to add entries to the LDAP database.


