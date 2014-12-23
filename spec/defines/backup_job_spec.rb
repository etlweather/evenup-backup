require 'spec_helper'

describe 'backup::job', :types=> :define do
  let(:facts) { {
    :concat_basedir => '/var/lib/puppet/concat',
    :fqdn => 'testhost.foo.com',
    :domain => 'foo.com',
    :osfamily => 'RedHat',
    :id => 'root',
    :path => '/bin:/sbin:/usr/sbin:/usr/bin',
    :kernel => 'Linux'
  } }
  let(:pre_condition) { 'include backup' }
  let(:title) { 'job1' }

  describe 'validations' do
    context 'bad ensure' do
      let(:params) { {
        :ensure         => 'foo',
        :types          => 'archive',
        :add            => '/here',
        :storage_type   => 'local',
        :path           => '/backups'
      } }
      it { expect { is_expected.to compile }.to raise_error }
    end

    context 'bad utilities' do
      let(:params) { {
        :utilities         => 'foo',
        :types          => 'archive',
        :add            => '/here',
        :storage_type   => 'local',
        :path           => '/backups'
      } }
      it { expect { is_expected.to compile }.to raise_error }
    end

    context 'bad type (string)' do
      let(:params) { {
        :types          => 'foo',
        :add            => '/here',
        :storage_type   => 'local',
        :path           => '/backups'
      } }
      it { expect { is_expected.to compile }.to raise_error }
    end

    context 'bad type (array)' do
      let(:params) { {
        :types          => ['archive', 'foo'],
        :add            => '/here',
        :storage_type   => 'local',
        :path           => '/backups'
      } }
      it { expect { is_expected.to compile }.to raise_error }
    end

    context 'archive' do
      context 'archive type with nothing to backup' do
        let(:params) { {
          :types          => 'archive',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'archive type with bad add' do
        let(:params) { {
          :types          => 'archive',
          :add            => { 'a' => 'b'},
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'archive type with bad exclude' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :exclude        => { 'a' => 'b' },
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end
    end

    context 'generic db' do
      context 'bad database port' do
        let(:params) { {
          :types          => 'mongodb',
          :dbname         => 'foo',
          :port           => 'foo',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'database without name' do
        let(:params) { {
          :types          => 'mongodb',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'database username without password' do
        let(:params) { {
          :types          => 'mongodb',
          :dbname         => 'foo',
          :username       => 'foo',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end
    end

    context 'mongodb' do
      context 'mongodb with bad collections' do
        let(:params) { {
          :types          => 'mongodb',
          :dbname         => 'foo',
          :collections    => { 'a' => 'b' },
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'bad mongodb lock' do
        let(:params) { {
          :types          => 'mongodb',
          :dbname         => 'foo',
          :lock           => 'foo',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end
    end # mongodb

    context 'generic storage' do
      context 'bad storage type' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'foo',
          :path           => '/backups'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'bad keep interval' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :keep           => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'bad split_into' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :split_into     => 'foo',
        } }

        it { expect { is_expected.to compile }.to raise_error }
      end
    end # generic storage

    context 'local' do
      context 'missing path' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local'
        } }

        it { expect { is_expected.to compile }.to raise_error }
      end
    end #local

    context 's3' do
      context 'missing aws_access_key' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 's3',
          :aws_secret_key => 'foo',
          :bucket         => 'bucket'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'missing aws_secret_key' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 's3',
          :aws_access_key => 'foo',
          :bucket         => 'bucket'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'missing bucket' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 's3',
          :aws_access_key => 'foo',
          :aws_secret_key => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'invalid region' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 's3',
          :aws_access_key => 'foo',
          :aws_secret_key => 'foo',
          :bucket         => 'bucket',
          :aws_region     => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end
    end

    context 'encryptor generic' do
      context 'bad encryptor' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :encryptor      => 'foo',
        } }

        it { expect { is_expected.to compile }.to raise_error }
      end
    end

    context 'openssl' do
      context 'missing openssl_password' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :encryptor      => 'openssl'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end
    end

    context 'generic compressor' do
      context 'invalid compressor' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :compressor     => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'invalid compressor level' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :compressor     => 'bzip2',
          :level          => 33
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end
    end

    context 'email notifications' do
      context 'invalid email_success' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :email_enable   => true,
          :email_to       => 'foo@foosome.com',
          :email_success  => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'invalid email_warning' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :email_enable   => true,
          :email_to       => 'foo@foosome.com',
          :email_warning  => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'invalid email_failure' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :email_enable   => true,
          :email_to       => 'foo@foosome.com',
          :email_failure  => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'invalid email_from' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :email_enable   => true,
          :email_to       => 'foo@foosome.com',
          :email_from     => 'bob'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'missing email_to' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :email_enable   => true
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'invalid email_to' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :email_enable   => true,
          :email_to       => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'invalid relay_port' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :email_enable   => true,
          :email_to       => 'foo@foosome.com',
          :relay_port     => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end
    end

    context 'hipchat notifications' do
      context 'invalid hc_success' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :hc_enable      => true,
          :hc_token       => 'abcde',
          :hc_notify      => 'Room',
          :hc_success     => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'invalid hc_warning' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :hc_enable      => true,
          :hc_token       => 'abcde',
          :hc_notify      => 'Room',
          :hc_warning     => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'invalid hc_failure' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :hc_enable      => true,
          :hc_token       => 'abcde',
          :hc_notify      => 'Room',
          :hc_failure     => 'foo'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'missing hc_token' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :hc_enable      => true,
          :hc_notify      => 'Room'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'missing hc_notify' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :hc_enable      => true,
          :hc_token       => 'abcde'
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'invalid hc_notify' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :hc_enable      => true,
          :hc_token       => 'abcde',
          :hc_notify      => { 'a' => 'b' }
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end

      context 'hc_notify as empty array' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :hc_enable      => true,
          :hc_token       => 'abcde',
          :hc_notify      => []
        } }
        it { expect { is_expected.to compile }.to raise_error }
      end
    end
  end #validations

  describe 'resources' do
    context 'default' do
      let(:params) { {
        :types          => 'archive',
        :add            => '/here',
        :storage_type   => 'local',
        :path           => '/backups'
      } }
      it { should contain_concat('/etc/backup/models/job1.rb').with(:ensure => 'present') }
      it { should contain_concat__fragment('job1_footer') }
      it { should contain_cron('job1-backup').with(:ensure => 'present') }
    end

    context 'ensure => absent' do
      let(:params) { {
        :ensure         => 'absent',
        :types          => 'archive',
        :add            => '/here',
        :storage_type   => 'local',
        :path           => '/backups'
      } }
      it { should contain_concat('/etc/backup/models/job1.rb').with(:ensure => 'absent') }
      it { should contain_cron('job1-backup').with(:ensure => 'absent') }
    end
  end # resources

  describe 'utilities' do
    context 'default' do
      let(:params) { {
        :utilities      => {'tar' => '/bin/tar', 'riak-admin' => '/usr/sbin/riak-admin' },
        :types          => 'archive',
        :add            => '/here',
        :storage_type   => 'local',
        :path           => '/backups'
      } }
      it { should contain_concat__fragment('job1_utilities').with(:content => /tar\s+'\/bin\/tar'/)}
      it { should contain_concat__fragment('job1_utilities').with(:content => /riak-admin\s+'\/usr\/sbin\/riak-admin'/)}
    end

    context 'set utilities' do
    end
  end # utilities

  describe 'templates' do
    context 'header' do
      context 'name and description' do
        let(:params) { {
          :types          => 'archive',
          :description    => 'My backup',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { should contain_concat__fragment('job1_header').with(:content => /Backup::Model.new\(:job1, "My backup"\)/)}
      end

      context 'translated name, no description' do
        let(:title) { 'job.1/2' }
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { should contain_concat__fragment('job_1_2_header').with(:content => /Backup::Model.new\(:job_1_2, "job.1\/2 backup"\)/)}
      end
    end

    context 'archive' do
      context 'string add, no exclude' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { should contain_concat__fragment('job1_archive').with(:content => /archive\.add\s+'\/here'/) }
        it { should_not contain_concat__fragment('job1_archive').with(:content => /archive\.exclude/) }
      end

      context 'array add, string exclude' do
        let(:params) { {
          :types          => 'archive',
          :add            => ['/here', '/there'],
          :exclude        => '/everywhere',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { should contain_concat__fragment('job1_archive').with(:content => /archive\.add\s+'\/here'/) }
        it { should contain_concat__fragment('job1_archive').with(:content => /archive\.add\s+'\/there'/) }
        it { should contain_concat__fragment('job1_archive').with(:content => /archive\.exclude\s+'\/everywhere'/)}
      end

      context 'string add, array exclude' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :exclude        => ['/there', '/everywhere'],
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { should contain_concat__fragment('job1_archive').with(:content => /archive\.add\s+'\/here'/) }
        it { should contain_concat__fragment('job1_archive').with(:content => /archive\.exclude\s+'\/there'/) }
        it { should contain_concat__fragment('job1_archive').with(:content => /archive\.exclude\s+'\/everywhere'/)}
      end
    end

    context 'mongodb' do
      context 'minimal config' do
        let(:params) { {
          :types          => 'mongodb',
          :dbname         => 'mydb',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { should contain_concat__fragment('job1_mongodb').with(:content => /db.name\s+=\s+"mydb"/) }
        it { should_not contain_concat__fragment('job1_mongodb').with(:content => /db\.username/) }
        it { should_not contain_concat__fragment('job1_mongodb').with(:content => /db\.password/) }
        it { should_not contain_concat__fragment('job1_mongodb').with(:content => /db\.port/) }
        it { should_not contain_concat__fragment('job1_mongodb').with(:content => /db\.lock/) }
        it { should_not contain_concat__fragment('job1_mongodb').with(:content => /db\.only_collections/) }
      end

      context 'with u:p, host, port, lock, string collections' do
        let(:params) { {
          :types          => 'mongodb',
          :dbname         => 'mydb',
          :username       => 'foo',
          :password       => 'mypass',
          :port           => 1234,
          :lock           => true,
          :collections    => 'abcde',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { should contain_concat__fragment('job1_mongodb').with(:content => /db\.username\s+=\s+"foo"/) }
        it { should contain_concat__fragment('job1_mongodb').with(:content => /db\.password\s+=\s+"mypass"/) }
        it { should contain_concat__fragment('job1_mongodb').with(:content => /db\.port\s+=\s+"1234"/) }
        it { should contain_concat__fragment('job1_mongodb').with(:content => /db\.lock\s+=\s+true/) }
        it { should contain_concat__fragment('job1_mongodb').with(:content => /db\.only_collections\s+=\s+\['abcde'\]/) }
      end

      context 'array collections' do
        let(:params) { {
          :types          => 'mongodb',
          :dbname         => 'mydb',
          :collections    => ['a','b','c','d'],
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { should contain_concat__fragment('job1_mongodb').with(:content => /db\.only_collections\s+=\s+\['a', 'b', 'c', 'd'\]/) }
      end
    end #mongodb

    context 'riak' do
      context 'default node and cookie' do
        let(:params) { {
          :types          => 'riak',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { should contain_concat__fragment('job1_riak').with(:content => /db\.node\s+=\s+"riak@testhost\.foo\.com"/) }
        it { should contain_concat__fragment('job1_riak').with(:content => /db\.cookie\s+=\s+"riak"/) }
      end

      context 'set node and cookie' do
        let(:params) { {
          :types          => 'riak',
          :node           => 'nosql@host.internal',
          :cookie         => 'supersecret',
          :storage_type   => 'local',
          :path           => '/backups'
        } }
        it { should contain_concat__fragment('job1_riak').with(:content => /db\.node\s+=\s+"nosql@host\.internal"/) }
        it { should contain_concat__fragment('job1_riak').with(:content => /db\.cookie\s+=\s+"supersecret"/) }
      end
    end # riak

    context 'compressors' do
      context 'bzip2' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :compressor     => 'bzip2'
        } }
        it { should contain_concat__fragment('job1_bzip2').with(:content => /Bzip2/) }
        it { should_not contain_concat__fragment('job1_bzip2').with(:content => /level/) }
      end

      context 'bzip2 with level' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :compressor     => 'bzip2',
          :level          => 3
        } }
        it { should contain_concat__fragment('job1_bzip2').with(:content => /Bzip2/) }
        it { should contain_concat__fragment('job1_bzip2').with(:content => /compression\.level\s+=\s+3/) }
      end

      context 'gzip' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :compressor     => 'gzip'
        } }
        it { should contain_concat__fragment('job1_gzip').with(:content => /Gzip/) }
        it { should_not contain_concat__fragment('job1_gzip').with(:content => /level/) }
      end

      context 'gzip with level' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :compressor     => 'gzip',
          :level          => 3
        } }
        it { should contain_concat__fragment('job1_gzip').with(:content => /Gzip/) }
        it { should contain_concat__fragment('job1_gzip').with(:content => /compression\.level\s+=\s+3/) }
      end
    end # compressors

    context 'openssl encryptor' do
      let(:params) { {
        :types            => 'archive',
        :add              => '/here',
        :storage_type     => 'local',
        :path             => '/backups',
        :encryptor        => 'openssl',
        :openssl_password => 'foopass'
      } }
      it { should contain_concat__fragment('job1_openssl').with(:content => /encryption\.password\s+=\s+"foopass"/)}
    end # openssl encryptor

    context 'splitter' do
      let(:params) { {
        :types        => 'archive',
        :add          => '/here',
        :storage_type => 'local',
        :path         => '/backups',
        :split_into   => 512
      } }
      it { should contain_concat__fragment('job1_split').with(:content => /split_into_chunks_of 512/) }
    end #splitter

    context 'local' do
      context 'configured' do
        let(:params) { {
          :types        => 'archive',
          :add          => '/here',
          :storage_type => 'local',
          :path         => '/backups',
          :keep         => 2
        } }
        it { should contain_concat__fragment('job1_local').with(:content => /local.path\s+=\s+"\/backups"/) }
        it { should contain_concat__fragment('job1_local').with(:content => /local.keep\s+=\s+2/) }
      end
    end # local

    context 's3' do
      context 'minimum settings' do
        let(:params) { {
          :types            => 'archive',
          :add              => '/here',
          :storage_type     => 's3',
          :aws_access_key   => 'foo',
          :aws_secret_key   => 'bar',
          :bucket           => 'bucket'
        } }
        it { should contain_concat__fragment('job1_s3').with(:content => /s3\.access_key_id\s+=\s+"foo"/) }
        it { should contain_concat__fragment('job1_s3').with(:content => /s3\.secret_access_key\s+=\s+"bar"/) }
        it { should contain_concat__fragment('job1_s3').with(:content => /s3\.path\s+=\s+"testhost.foo.com"/) }
        it { should contain_concat__fragment('job1_s3').with(:content => /s3\.bucket\s+=\s+"bucket"/) }
        it { should_not contain_concat__fragment('job1_s3').with(:content => /s3\.region/) }
        it { should_not contain_concat__fragment('job1_s3').with(:content => /s3\.keep/) }
      end

      context 'all params' do
        let(:params) { {
          :types            => 'archive',
          :add              => '/here',
          :storage_type     => 's3',
          :aws_access_key   => 'foo',
          :aws_secret_key   => 'bar',
          :bucket           => 'bucket',
          :aws_region       => 'us-east-1',
          :keep             => 3
        } }
        it { should contain_concat__fragment('job1_s3').with(:content => /s3\.access_key_id\s+=\s+"foo"/) }
        it { should contain_concat__fragment('job1_s3').with(:content => /s3\.secret_access_key\s+=\s+"bar"/) }
        it { should contain_concat__fragment('job1_s3').with(:content => /s3\.path\s+=\s+"testhost.foo.com"/) }
        it { should contain_concat__fragment('job1_s3').with(:content => /s3\.bucket\s+=\s+"bucket"/) }
        it { should contain_concat__fragment('job1_s3').with(:content => /s3\.region\s+=\s+"us-east-1"/) }
        it { should contain_concat__fragment('job1_s3').with(:content => /s3\.keep\s+=\s+3/) }
      end
    end #s3

    context 'email' do
      context 'minimal settings' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :enable_email   => true,
          :email_to       => 'foo@foobar.com'
        } }
        it { should contain_concat__fragment('job1_email').with(:content => /mail\.from\s+=\s+"backup@foo\.com"/)}
        it { should contain_concat__fragment('job1_email').with(:content => /mail\.to\s+=\s+"foo@foobar\.com"/)}
        it { should contain_concat__fragment('job1_email').with(:content => /mail\.address\s+=\s+"localhost"/)}
        it { should contain_concat__fragment('job1_email').with(:content => /mail\.port\s+=\s+25/)}
      end

      context 'set everything but the booleans' do
        let(:params) { {
          :types          => 'archive',
          :add            => '/here',
          :storage_type   => 'local',
          :path           => '/backups',
          :enable_email   => true,
          :email_to       => 'foo@foobar.com',
          :email_from     => 'bar@foobar.com',
          :relay_host     => 'mail.foobar.com',
          :relay_port     => 123
        } }
        it { should contain_concat__fragment('job1_email').with(:content => /mail\.from\s+=\s+"bar@foobar\.com"/)}
        it { should contain_concat__fragment('job1_email').with(:content => /mail\.to\s+=\s+"foo@foobar\.com"/)}
        it { should contain_concat__fragment('job1_email').with(:content => /mail\.port\s+=\s+123/)}
        it { should contain_concat__fragment('job1_email').with(:content => /mail\.address\s+=\s+"mail.foobar.com"/)}
      end
    end #email

    context 'hipchat' do
      let(:params) { {
        :types          => 'archive',
        :add            => '/here',
        :storage_type   => 'local',
        :path           => '/backups',
        :enable_hc      => true,
        :hc_token       => 'ABCDE',
        :hc_notify      => 'Room1'
      } }
      it { should contain_concat__fragment('job1_hipchat').with(:content => /hipchat\.token\s+=\s+'ABCDE'/)}
      it { should contain_concat__fragment('job1_hipchat').with(:content => /hipchat\.rooms_notified\s+=\s+\['Room1'\]/)}
    end #hipchat

  end # templates

  context 'multiple types' do
    context 'riak and archive' do
      let(:params) { {
        :types          => ['archive', 'riak'],
        :add            => '/here',
        :storage_type   => 'local',
        :path           => '/backups'
      } }
      it { should contain_concat__fragment('job1_archive') }
      it { should contain_concat__fragment('job1_riak') }
    end
  end

end
