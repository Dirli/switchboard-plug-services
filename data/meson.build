config_data = configuration_data()
bin_path = join_paths (get_option ('prefix'), get_option ('bindir'))
config_data.set('PKGDATADIR', bin_path)

install_data('io.elementary.switchboard.services.helper',
    install_mode: 'rwxr-xr-x',
    install_dir: bin_path
)

configure_file(
    input: 'io.elementary.switchboard.services.policy.in',
    output: '@BASENAME@',
    install_mode: 'rw-r--r--',
    configuration: config_data,
    install_dir: polkit_dep.get_pkgconfig_variable ('policydir')
)
