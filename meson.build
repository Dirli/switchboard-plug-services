project (
    'services',
    'vala', 'c',
    version: '1.0.1'
)

gettext_name = meson.project_name () + '-plug'
gnome = import ('gnome')
i18n = import ('i18n')

add_global_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format (gettext_name),
    language:'c'
)

switchboard_dep = dependency ('switchboard-2.0')
polkit_dep = dependency ('polkit-gobject-1')

plug_files = files (
    'src/Plug.vala',
    'src/Utils.vala',
    'src/Widgets/FilterBox.vala',
    'src/Widgets/HelpBox.vala',
    'src/Widgets/MainView.vala',
    'src/Widgets/ServiceStatus.vala',
    'src/Widgets/ServicesView.vala',
    'src/Widgets/WaitingView.vala'
)

shared_module (
    meson.project_name (),
    plug_files,
    dependencies: [
        dependency ('gtk+-3.0'),
        dependency ('gee-0.8'),
        dependency ('granite'),
        switchboard_dep,
        polkit_dep,
        meson.get_compiler ('vala').find_library ('posix')
    ],
    install: true,
    install_dir : join_paths (switchboard_dep.get_pkgconfig_variable ('plugsdir'), 'system')
)

subdir ('data')
subdir ('po')
