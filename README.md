# ansible-role-argus-radium

Configures `radium(8)` in `argus-clients` as a daemon.

## Missing Ubuntu support

`deb` packages for our targeted Ubuntu releases are version 2.x, which has been
officially discouraged.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `argus_radium_user` | user of `radium` | `{{ __argus_radium_user }}` |
| `argus_radium_user_home` | home of the `argus_radium_user` | `{{ __argus_radium_user_home }}` |
| `argus_radium_user_shell` | shell of `argus_radium_user` | `{{ __argus_radium_user_shell }}` |
| `argus_radium_user_comment` | GECOS of `argus_radium_user` | `argus radium daemon` |
| `argus_radium_group` | group of `radium` | `{{ __argus_radium_group }}` |
| `argus_radium_package` | package name that includes `radium` | `{{ __argus_raduim_package }}` |
| `argus_radium_log_dir` | log directory | `/var/log/argus` |
| `argus_radium_log_dir_owner` | owner of log directory. useful when `argus` daemon writes data to the `argus_radium_log_dir` and `radium` daemon reads from it | `{{ argus_radium_user }}` |
| `argus_radium_log_dir_group` | group of log directory. useful when `argus` daemon writes data to the `argus_radium_log_dir` and `radium` daemon reads from it | `{{ argus_radium_group }}` |
| `argus_radium_log_dir_mode` | permission of log directory | `0755` |
| `argus_radium_service` | service name of `radium` | `radium` |
| `argus_radium_conf_dir` | path to directory where ``argus_radium_conf_file` resides | `{{ __argus_radium_conf_dir }}` |
| `argus_radium_conf_file` | path to `radium.conf(5)` | `{{ __argus_radium_conf_dir }}/radium.conf` |
| `argus_radium_flags` | command line flags of `radium(8)` | `{{ __argus_radium_flags }}` |
| `argus_radium_config` | a dict of `radium.conf(5)` (see below) | `{}` |

## `argus_radium_config`

This is a dict where key is config name of `radium.conf(5)` and value of the
config. An example:

```yaml
argus_radium_config:
  RADIUM_DAEMON: "{% if ansible_os_family == 'OpenBSD' %}yes{% else %}no{% endif %}"
  RADIUM_MONITOR_ID: "localhost"
  RADIUM_MAR_STATUS_INTERVAL: 5
  RADIUM_ARGUS_SERVER: argus://localhost:561
  RADIUM_FILTER: "ip"
  RADIUM_USER_AUTH: "foo@reallyenglish.com/foo@reallyenglish.com"
  RADIUM_AUTH_PASS: "password"
  RADIUM_ACCESS_PORT: 562
  RADIUM_BIND_IP: 127.0.0.1
  RADIUM_OUTPUT_FILE: /var/log/argus/radium.out
  RADIUM_SETUSER_ID: "{{ argus_radium_user }}"
  RADIUM_SETGROUP_ID: "{{ argus_radium_group }}"
```
## FreeBSD

| Variable | Default |
|----------|---------|
| `__argus_radium_user` | `raidum` |
| `__argus_radium_user_home` | `/var/log/argus` |
| `__argus_radium_user_shell` | `/usr/sbin/nologin` |
| `__argus_radium_group` | `argus` |
| `__argus_raduim_package` | `net-mgmt/argus3-clients` |
| `__argus_radium_conf_dir` | `/usr/local/etc` |
| `__argus_radium_conf_file` | `{{ __argus_radium_conf_dir }}/radium.conf` |
| `__argus_radium_flags` | `-f {{ __argus_radium_conf_file }}` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__argus_radium_user` | `_radium` |
| `__argus_radium_user_home` | `/nonexistent` |
| `__argus_radium_user_shell` | `/sbin/nologin` |
| `__argus_radium_group` | `_argus` |
| `__argus_raduim_package` | `argus-clients` |
| `__argus_radium_conf_dir` | `/etc` |
| `__argus_radium_conf_file` | `{{ __argus_radium_conf_dir }}/radium.conf` |
| `__argus_radium_flags` | `""` |

## RedHat

| Variable | Default |
|----------|---------|
| `__argus_radium_user` | `radium` |
| `__argus_radium_user_home` | `/var/log/argus` |
| `__argus_radium_user_shell` | `/sbin/nologin` |
| `__argus_radium_group` | `argus` |
| `__argus_raduim_package` | `argus-clients` |
| `__argus_radium_conf_dir` | `/etc` |
| `__argus_radium_conf_file` | `{{ __argus_radium_conf_dir }}/radium.conf` |
| `__argus_radium_flags` | `-f {{ __argus_radium_conf_file }}` |

# Dependencies

* `reallyenglish.redhat-repos` (RedHat only)

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - reallyenglish.argus
    - reallyenglish.argus-clients
    - { role: reallyenglish.cyrus-sasl, when: ansible_os_family == 'FreeBSD' or ansible_os_family == 'RedHat' }
    - ansible-role-argus-radium
  vars:
    argus_radium_log_dir_owner: "{{ argus_user }}"
    argus_radium_log_dir_mode: "0775"
    argus_radium_config:
      RADIUM_DAEMON: "{% if ansible_os_family == 'OpenBSD' %}yes{% else %}no{% endif %}"
      RADIUM_MONITOR_ID: "localhost"
      RADIUM_MAR_STATUS_INTERVAL: 5
      RADIUM_ARGUS_SERVER: argus://localhost:561
      RADIUM_FILTER: "ip"
      RADIUM_USER_AUTH: "foo@reallyenglish.com/foo@reallyenglish.com"
      RADIUM_AUTH_PASS: "password"
      RADIUM_ACCESS_PORT: 562
      RADIUM_BIND_IP: 127.0.0.1
      RADIUM_OUTPUT_FILE: /var/log/argus/radium.out
      RADIUM_SETUSER_ID: "{{ argus_radium_user }}"
      RADIUM_SETGROUP_ID: "{{ argus_radium_group }}"

    redhat_repo:
      epel:
        mirrorlist: "http://mirrors.fedoraproject.org/mirrorlist?repo=epel-{{ ansible_distribution_major_version }}&arch={{ ansible_architecture }}"
        gpgcheck: yes
        enabled: yes
    cyrus_sasl_config:
      argus:
        pwcheck_method: auxprop
        auxprop_plugin: sasldb
        mech_list: DIGEST-MD5
    cyrus_sasl_saslauthd_enable: no
    cyrus_sasl_user:
      foo:
        domain: reallyenglish.com
        appname: "argus"
        password: password
        state: present
    cyrus_sasl_sasldb_group: "{{ argus_user }}"
    cyrus_sasl_sasldb_file_permission: "0640"
    argus_log_dir_mode: "0775"
    argus_config:
      ARGUS_CHROOT: "{{ argus_log_dir }}"
      ARGUS_FLOW_TYPE: Bidirectional
      ARGUS_FLOW_KEY: CLASSIC_5_TUPLE
      ARGUS_DAEMON: "yes"
      ARGUS_MONITOR_ID: "{{ ansible_fqdn }}"
      ARGUS_ACCESS_PORT: 561
      ARGUS_BIND_IP: 127.0.0.1
      ARGUS_INTERFACE: "ind:{{ ansible_default_ipv4.interface }}"
      ARGUS_SETUSER_ID: "{{ argus_user }}"
      ARGUS_SETGROUP_ID: "{{ argus_group }}"
      ARGUS_OUTPUT_FILE: "{{ argus_log_dir }}/argus.ra"
      ARGUS_FLOW_STATUS_INTERVAL: 5
      ARGUS_MAR_STATUS_INTERVAL: 5
      ARGUS_DEBUG_LEVEL: 0
      ARGUS_GENERATE_RESPONSE_TIME_DATA: "yes"
      ARGUS_GENERATE_PACKET_SIZE: "yes"
      ARGUS_GENERATE_APPBYTE_METRIC: "yes"
      ARGUS_GENERATE_TCP_PERF_METRIC: "yes"
      ARGUS_GENERATE_BIDIRECTIONAL_TIMESTAMPS: "yes"
      ARGUS_FILTER: ip
      ARGUS_TRACK_DUPLICATES: "yes"
      ARGUS_SET_PID: "yes"
      ARGUS_PID_PATH: "{{ argus_pid_dir }}"
      ARGUS_MIN_SSF: 40
      ARGUS_MAX_SSF: 128

    # XXX the default in rc.d script assumes the file name is "argus.pid", which is
    # not always the case
    argus_pid_file: "{{ argus_pid_dir }}/argus.em0.*.pid"
    argus_clients_config:
      RA_MIN_SSF: 40
      RA_MAX_SSF: 128
      RA_USER_AUTH: "foo@reallyenglish.com/foo@reallyenglish.com"
      RA_AUTH_PASS: "password"
```

# License

```
Copyright (c) 2017 Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>

This README was created by [qansible](https://github.com/trombik/qansible)
