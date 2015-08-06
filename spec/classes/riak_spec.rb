require 'spec_helper'

shared_examples_for "class required behavior" do
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_class('riak') }
  it { is_expected.to contain_class('riak::params') }
  it { is_expected.to contain_class('riak::service').that_subscribes_to('riak::config') }
  it { is_expected.to contain_file('/etc/riak/riak.conf').with_content(/nodename = riak@/) }
end

describe 'riak' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "riak class without any parameters" do
          let(:params) {{ }}

          it_behaves_like "class required behavior"

          it { is_expected.to contain_class('riak::install') }
          it { is_expected.to contain_class('riak::config') }
          it { is_expected.to contain_package('riak').with_ensure('present') }
          it { is_expected.to contain_service('riak') }
          case facts[:osfamily]
          when 'RedHat'
            it { is_expected.to contain_class('riak::repository::el') }
            it { is_expected.to contain_yumrepo('basho_riak') }
          when 'Debian'
            case facts[:operatingsystem]
            when 'ubuntu'
              it { is_expected.to contain_class('riak::repository::ubuntu') }
            else
              it { is_expected.to contain_class('riak::repository::debian') }
            end 
            it { is_expected.to contain_apt__source('riak') }
          end
        end
        context "riak class with repositories disabled" do
          let(:params) {{
            :manage_repo => false
          }}

          it_behaves_like "class required behavior"

          it { is_expected.to contain_class('riak::install') }
          it { is_expected.to contain_class('riak::config') }
          it { is_expected.to contain_package('riak').with_ensure('present') }
          it { is_expected.to contain_service('riak') }
          case facts[:osfamily]
          when 'RedHat'
            it { is_expected.to_not contain_class('riak::repository::el') }
            it { is_expected.to_not contain_yumrepo('basho_riak') }
          when 'Debian'
            case facts[:operationsystem]
            when 'ubuntu'
              it { is_expected.to_not contain_class('riak::repository::ubuntu') }
            else
              it { is_expected.to_not contain_class('riak::repository::debian') }  
            end
            it { is_expected.to_not contain_apt__source('riak') }
          end
        end
        context "riak class with package set to specific version" do
          let(:params) {{
            :version => '2.0.5'
          }}
          it_behaves_like "class required behavior"
          it { is_expected.to contain_package('riak').with_ensure('2.0.5') }
        end
        context "riak class with package install disabled" do
          let(:params) {{
            :manage_package => false
          }}
          it_behaves_like "class required behavior"
          it { is_expected.to_not contain_package('riak') }
          it { is_expected.to_not contain_class('riak::install') }
        end
        context "riak class with custom package name" do
          let(:params) {{
            :package_name => 'ermongo'
          }}
          it_behaves_like "class required behavior"
          it { is_expected.to contain_package('ermongo') }
        end
        context "riak class with custom service name" do
          let(:params) {{
            :service_name => 'ermongo'
          }}
          it_behaves_like "class required behavior"
          it { is_expected.to contain_service('ermongo') }
        end
        context "riak class with custom config settings" do
          let(:params) {{
            :settings => {
              'foo'    => 'bar',
              'dtrace' => 'on',
            }
          }}
          it_behaves_like "class required behavior"
          it { is_expected.to contain_file('/etc/riak/riak.conf').with_content(/foo = bar/) }
          it { is_expected.to contain_file('/etc/riak/riak.conf').with_content(/dtrace = on/) }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'riak class without any parameters on Plan9' do
      let(:facts) {{
        :osfamily        => 'plan9',
        :operatingsystem => 'plan9',
      }}

      it { expect { is_expected.to contain_package('riak') }.to raise_error(Puppet::Error, /plan9 not supported/) }
    end
  end

end
