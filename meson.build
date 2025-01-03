project('aegis-pam', 'cpp',
  version : '0.1.0',
  default_options : [
    'warning_level=3',
    'cpp_std=c++20'
  ]
)

# Zależności
pam_dep = meson.get_compiler('cpp').find_library('pam')
thread_dep = dependency('threads')

# Konfiguracja trybu dev
if get_option('buildtype') == 'debug'
  add_project_arguments('-DDEV_BUILD', language : 'cpp')
endif

# Moduł PAM
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

# Instalacja plików konfiguracyjnych
install_data('config/aegis_pam_agent.conf',
  install_dir : '/etc/aegis'
)
