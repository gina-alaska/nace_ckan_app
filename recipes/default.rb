#
# Cookbook:: nace_ckan_app
# Recipe:: default
#
# The MIT License (MIT)
#
# Copyright:: 2017, UAF GINA
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

include_recipe 'chef-vault'

apt_update 'system' do
  action :periodic
  frequency 86_400
end

users = search(:users, 'group:nace_admin AND !action:remove')
usernames = users.map(&:id)

group 'www-data' do
  action :modify
  members usernames
  append true
  only_if { usernames }
end

solr_nodes = search(:node, "chef_environment:#{node.chef_environment} AND tags:solr", filter_result: { 'ip' => [ 'ipaddress' ] }) || []
node.default['ckan']['config']['solr_url'] = "http://#{solr_nodes.first['ip']}:8983/solr" unless solr_nodes.empty?
# node.default['ckan']['enable_s3filestore'] = true

appconfig = chef_vault_item_for_environment('apps', 'nace_ckan')
pgconfig = appconfig['postgresql']
postgresql_url = "postgresql://#{pgconfig['username']}:#{pgconfig['password']}@#{pgconfig['address']}/#{pgconfig['name']}"

%w( site_url mapbox_id mapbox_token googleanalytics ).each do |name|
  node.default['ckan']['config'][name] = appconfig[name]
end

include_recipe 'nace-ckan::default'

edit_resource :ckan_config, '/etc/ckan/default/production.ini' do
  s3filestore appconfig['s3filestore']
  session_secret appconfig['session_secret']
  instance_uuid appconfig['instance_uuid']
  database({
    'postgresql_url' => postgresql_url,
    'postgresql_datastore_write_url' => postgresql_url,
    'postgresql_datastore_read_url' => postgresql_url
  })
end
