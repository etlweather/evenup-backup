require 'spec_helper'
 
describe 'backups', :type => :class do
  let(:facts) { { :hostname => 'test.mydomain.com' } }

  describe "class with default parameters" do

    it { should create_class('backups') }
    it { should include_class('ruby') }
    it { should include_class('ruby::mail')}
    
    [ 'rubygem-backup', 'rubygem-httparty', 'rubygem-fog'].each do |package|
      it { should create_package(package).with_ensure('latest') }
    end
    it { should contain_package('rubygem-excon') }

    [ '/etc/backup', '/etc/backup/models', '/var/log/backup' ].each do |directory|
      it { should contain_file(directory).with(
        'ensure'  => 'directory',
        'owner'   => 'root',
        'group'   => 'admin'
      ) }
    end
    
    it { should create_file('/etc/backup/config.rb').with(
      'owner'   => 'root',
      'group'   => 'admin',
      'mode'    => '0440'
    ) }
         
  end

end

#  $aws_access_key = hiera('backups::aws_access_key')
#  $aws_secret_key = hiera('backups::aws_secret_key')
#  $password = hiera('backups::password')
#  $backup_node = regsubst($::hostname, '-', '_')

