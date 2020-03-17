project (
    'services',
    'vala', 'c',
    version: '0.9.0'
)

gnome = import ('gnome')

add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

switchboard_dep = dependency ('switchboard-2.0')
polkit_dep = dependency ('polkit-gobject-1')

plug_files = files (
    'src/Plug.vala',
    'src/Utils.vala',
    'src/Widgets/MainView.vala',
    'src/Widgets/ServicesView.vala'
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
    install_dir : join_paths (switchboard_dep.get_pkgconfig_variable('plugsdir'), 'system')
)

subdir ('data')
