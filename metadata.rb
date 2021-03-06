name 'nace_ckan_app'
maintainer 'UAF GINA'
maintainer_email 'support+chef@gina.alaska.edu'
license 'mit'
description 'Installs/Configures nace_ckan_app'
long_description 'Installs/Configures nace_ckan_app'
version '0.2.2'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/nace_ckan_app/issues' if respond_to?(:issues_url)

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/nace_ckan_app' if respond_to?(:source_url)

depends 'nace-ckan'
depends 'chef-vault'
