config_data = configuration_data()
config_data.set('GETTEXT_PACKAGE', gettext_name)

install_data ('io.elementary.switchboard.services.helper',
  install_mode: 'r-xr--r--',
  install_dir: '/usr/bin'
)

gettext_declaration = configure_file(
  configuration: config_data,
  input: 'io.elementary.switchboard.services.policy.in.in',
  output: '@BASENAME@'
)

i18n.merge_file (
  input: gettext_declaration,
  output: '@BASENAME@',
  po_dir: join_paths (meson.source_root (), 'po'),
  install: true,
  install_dir: polkit_dep.get_pkgconfig_variable ('policydir')
)
