project('aegis-pam', 'cpp',
  version : '0.1.0',
  default_options : [
    'warning_level=3',
    'cpp_std=c++20'
  ]
)

cpp = meson.get_compiler('cpp')

# Zależności
pam_dep = cpp.find_library('pam')
thread_dep = dependency('threads')

# Zależności POCO
poco_deps = []
poco_libs = ['PocoFoundation', 'PocoNet', 'PocoJSON']

foreach lib : poco_libs
    poco_deps += cpp.find_library(lib, required: true)
endforeach

# Konfiguracja
conf_data = configuration_data()
conf_data.set_quoted('VERSION', meson.project_version())
conf_data.set_quoted('API_ENDPOINT', 'http://localhost:8443/api/v1/pam/record')
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
  dependencies : [pam_dep] + poco_deps,
  install : true,
  install_dir : '/lib/security'
)

# Agent
aegis_pam_agent = executable('aegis_pam_agent',
  'src/aegis_pam_agent.cpp',
  dependencies : [thread_dep] + poco_deps,
  install : true,
  install_dir : '/usr/local/bin'
)

# Install config files
install_data(['config/aegis_pam_agent.conf', 'config/aegis_pam_module.conf'],
  install_dir : '/etc/aegis'
)
