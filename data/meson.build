config_data = configuration_data()
config_data.set('GETTEXT_PACKAGE', gettext_name)

install_data ('io.elementary.switchboard.services.helper',
    install_mode: 'rwxr-xr-x',
    install_dir: '/usr/bin'
)

configure_file (
    input: 'io.elementary.switchboard.services.policy.in',
    output: '@BASENAME@',
    configuration: config_data,
    install_mode: 'rw-r--r--',
    install_dir: polkit_dep.get_pkgconfig_variable ('policydir')
)
