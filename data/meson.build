config_data = configuration_data()
config_data.set('PKGDATADIR', join_paths (get_option ('prefix'), get_option ('bindir')))

configure_file(
    input: 'io.elementary.switchboard.services.policy.in',
    output: '@BASENAME@',
    configuration: config_data,
    install_dir: polkit_dep.get_pkgconfig_variable ('policydir')
)
