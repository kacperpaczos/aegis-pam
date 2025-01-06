project('aegis-pam', 'cpp',
  version : '0.1.0',
  default_options : [
    'warning_level=3',
    'cpp_std=c++20'
  ]
)

# Dependencies
pam_dep = meson.get_compiler('cpp').find_library('pam')
thread_dep = dependency('threads')

# Configuration data
conf_data = configuration_data()
conf_data.set_quoted('VERSION', meson.project_version())
if get_option('buildtype') == 'debug'
    conf_data.set('DEV_BUILD', true)
else
    conf_data.set('DEV_BUILD', false)
endif

configure_file(
    output : 'config.h',
    configuration : conf_data
)

# PAM module
pam_module = shared_library('pam_aegis',
  'src/aegis_pam_module.cpp',
  name_prefix : '',
  dependencies : [pam_dep],
  install : true,
  install_dir : '/lib/security'
)

# Agent
aegis_pam_agent = executable('aegis_pam_agent',
  'src/aegis_pam_agent.cpp',
  dependencies : [thread_dep],
  install : true,
  install_dir : '/usr/local/bin'
)

# Install config files
install_data(['config/aegis_pam_agent.conf', 'config/aegis_pam_module.conf'],
  install_dir : '/etc/aegis'
)
