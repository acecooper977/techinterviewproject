#/usr/bin/ruby -w

require 'rubygems'
require 'net/ldap'

ldap = Net::LDAP.new :host => '127.0.0.1',
	             :port => 389,
		     :auth => {
			:method => :simple,
			:username => "cn=root,dc=techinterview,dc=local",
			:password => "secret"
		     }

dn = "cn= Teste08,dc=techinterview,dc=local"
	attr = {
		:cn => "Teste08",
		:objectclass => "Person",
		:sn => 'Teste08',
		:userpassword => "123456",
		:description => "Test account 08",
		}
ldap.add( :dn => dn, :attributes => attr )
