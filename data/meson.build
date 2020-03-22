install_data('io.elementary.switchboard.services.helper',
    install_mode: 'rwxr-xr-x',
    install_dir: '/usr/bin'
)

install_data ('io.elementary.switchboard.services.policy',
    install_mode: 'rw-r--r--',
    install_dir: polkit_dep.get_pkgconfig_variable ('policydir')
)
