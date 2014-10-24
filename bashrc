# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export readonly UBIENV_ROOT="$(cd -P ${BASH_SOURCE[0]%/*}; pwd)"
export readonly UBIENV_OS="$(uname -s)"
export readonly UBIENV_HOST="$(hostname -s)"

source "${UBIENV_ROOT}/bashrc-utils"
if [ -f "${UBIENV_ROOT}/bashrc-${UBIENV_OS}" ]; then
  source "${UBIENV_ROOT}/bashrc-${UBIENV_OS}"
fi

UBIENV_INSTALLED_MODULES=()
UBIENV_LOADED_MODULES=()
UBIENV_MODULES_DIRS+=("${UBIENV_ROOT}/modules")

# Looks up a module full path given its name ($1).
ubienv::lookup_module() {
  local mod_root
  for mod_root in ${UBIENV_MODULES_DIRS[@]}; do
    if [ -d "${mod_root}/$1" ]; then
      echo "${mod_root}/$1"
      return 0
    fi
  done
  return 1
}

# Perform the install tasks (recursing as needed) on a module.
# In practice this recurses first in its deps, installing the specified system
# and python package, and then runs the module's install.sh (if any).
ubienv::install_single_module() {
  local mod_name="$1"
  if in_array UBIENV_INSTALLED_MODULES "$mod_name"; then
    return 0
  fi
  UBIENV_INSTALLED_MODULES+=("${mod_name}")
  local mod_path="$(ubienv::lookup_module "${mod_name}")"
  if [ "${mod_path}" == "" ]; then
    ubienv::err "Could not find the module ${mod_name}"
    return 1
  fi

  if [ -x "${mod_path}/install.sh" ]; then
    ubienv::msg "Running ${mod_path}/install.sh"
    "${mod_path}/install.sh"
    if [ $? -ne 0 ]; then
      ubienv::err "Install FAILED"
    fi
  fi
}

ubienv::load_single_module() {
  local mod_name="$1"
  if in_array UBIENV_LOADED_MODULES "$mod_name"; then
    return 0
  fi

  UBIENV_LOADED_MODULES+=("${mod_name}")
  local mod_path="$(ubienv::lookup_module "${mod_name}")"
  if [ "${mod_path}" == "" ]; then
    ubienv::err "Could not find the module ${mod_name}"
    return 1
  fi

  local dotdir="${mod_path}/dotconfigs"
  if [ -d "${dotdir}" ]; then
    local fname
    for fname in $(/bin/ls -A "${dotdir}"); do
      ubienv::symlink_if_changed "${dotdir//""${HOME}""\//}/${fname}" \
                                 "$HOME/$fname"
    done
  fi

  if [ -f "${mod_path}/bin" ]; then
    export PATH="$PATH:${mod_path}/bin"
  fi

  if [ -f "${mod_path}/bashrc" ]; then
    ubienv::msg "Loading ${mod_path//""${HOME}""\//}/bashrc"
    source "${mod_path}/bashrc"
  fi
}

ubienv::load_module() {
  ubienv::recurse_in_module_deps "load" "$1"
}

ubienv::install_module() {
  ubienv::recurse_in_module_deps "install" "$1"
}

ubienv::recurse_in_module_deps() {
  local line
  local phase="$1"  # either "load" or "install"
  local mod_name="$2"
  local mod_path="$(ubienv::lookup_module "${mod_name}")"
  local sub_mod_name
  local sys_pkgs_to_install=()
  local pip_pkgs_to_install=()
  local subdeps=()
  local includes=()

  if [ "${mod_path}" == "" ]; then
    ubienv::err "Could not find the module ${mod_name}"
    return 1
  fi

  if [ -f "${mod_path}/deps" ]; then
    while read line; do
      if [[ "${line:0:1}" == "#" || "${line}" == "" ]]; then
        continue
      fi
      local arr=(${line//:/ })
      local dep_type="${arr[0]}"
      local dep_name="${arr[1]}"
      if [ "${dep_type}" == "mod" ]; then
        subdeps+=("${dep_name}")
      elif [ "${dep_type}" == "inc" ]; then
        includes+=("${dep_name}")
      elif [ "${dep_type}" == "sys" ]; then
        sys_pkgs_to_install+=("${dep_name}")
      elif [ "${dep_type}" == "pip" ]; then
        pip_pkgs_to_install+=("${dep_name}")
      else
        ubienv::err "Unknown dep '${line}' in ${mod_path}/deps"
      fi
      unset dep_name
      unset dep_type
      unset arr
    done < ${mod_path}/deps
  fi

  if [ "${phase}" == "install" ]; then
    if [ ${#sys_pkgs_to_install[@]} -ne 0 ]; then
      ubienv::install_system_packages "${sys_pkgs_to_install[@]}"
    fi
    if [ ${#pip_pkgs_to_install[@]} -ne 0 ]; then
      ubienv::install_python_packages "${pip_pkgs_to_install[@]}"
    fi
  fi

  # Recursevely load/install dependent modules
  for sub_mod_name in ${subdeps[@]}; do
    if [ "${phase}" == "install" ]; then
      ubienv::install_module "${sub_mod_name}"
    elif [ "${phase}" == "load" ]; then
      ubienv::load_module "${sub_mod_name}"
    fi
  done

  # Load this module.
  if [ "${phase}" == "install" ]; then
    ubienv::install_single_module "${mod_name}"
  elif [ "${phase}" == "load" ]; then
    ubienv::load_single_module "${mod_name}"
  fi

  # Recursevely load/install included modules
  for sub_mod_name in ${includes[@]}; do
    if [ "${phase}" == "install" ]; then
      ubienv::install_module "${sub_mod_name}"
    elif [ "${phase}" == "load" ]; then
      ubienv::load_module "${sub_mod_name}"
    fi
  done
}

ubienv::load() {
  UBIENV_LOADED_MODULES=()
  ubienv::load_module "_default_"
  if ubienv::lookup_module "_${UBIENV_OS}_" >/dev/null; then
    ubienv::load_module "_${UBIENV_OS}_"
  fi
  if ubienv::lookup_module "_${UBIENV_HOST}_" >/dev/null; then
    ubienv::load_module "_${UBIENV_HOST}_"
  fi
  ubienv::msg "Initialized. Run ubienv::install to run modules install hooks."
}

ubienv::install() {
  local mod_name
  UBIENV_INSTALLED_MODULES=()
  ubienv::msg "Beginning installation of: ${UBIENV_LOADED_MODULES[@]}"
  for mod_name in ${UBIENV_LOADED_MODULES[@]}; do
    ubienv::install_module "${mod_name}"
  done
  ubienv::msg "Installation complete"
}

ubienv::load

###############################################################################
# Anything below this line (lines added by moronic installers) will be ignored
# and reported during the prompt
AFTER_EOF=$(grep -A99 '# \-\-\-EOF\-\-\-' ${BASH_SOURCE[0]}| tail -n +2)
if [ "${AFTER_EOF}" != "" ]; then
  echo "Spurious content detected in ${BASH_SOURCE[0]}. Cleanup required"
  echo "--------------------------"
  echo "${AFTER_EOF}"
  echo "--------------------------"
fi
unset AFTER_EOF
return
# ---EOF---

