function erlang_tarball() {
  if [ -z $erlang_tarball ]; then
      echo "OTP-${erlang_version}.tar.gz"
  else
    echo "${erlang_tarball}"
  fi
}

function download_erlang() {
  if [ -z $erlang_package_url ]; then
    erlang_package_url="https://s3.amazonaws.com/s3.hex.pm/builds/erlang/cedar-14"
  fi
  erlang_package_url="${erlang_package_url}/$(erlang_tarball)"

  # If a previous download does not exist, then always re-download
  if [ ! -f ${cache_path}/$(erlang_tarball) ]; then
    clean_erlang_downloads

    # Set this so elixir will be force-rebuilt
    erlang_changed=true

    output_section "Fetching Erlang ${erlang_version}"
    curl -s ${erlang_package_url} -o ${cache_path}/$(erlang_tarball) || exit 1
  else
    output_section "Using cached Erlang ${erlang_version}"
  fi
}

function clean_erlang_downloads() {
  rm -rf ${cache_path}/OTP-*.tar.gz
}

function install_erlang() {
  output_section "Installing Erlang ${erlang_version} $(erlang_changed)"

  rm -rf $(erlang_build_path)
  mkdir -p $(erlang_build_path)
  tar zxf ${cache_path}/$(erlang_tarball) -C $(erlang_build_path) --strip-components=${erlang_strip_components:-1}

  rm -rf /app/.platform_tools/erlang
  mkdir -p /app/.platform_tools
  ln -s $(erlang_build_path) /app/.platform_tools/erlang
  $(erlang_build_path)/Install -minimal /app/.platform_tools/erlang

  cp -R $(erlang_build_path) $(erlang_path)
  PATH=$(erlang_path)/bin:$PATH
}

function erlang_changed() {
  if [ $erlang_changed = true ]; then
    echo "(changed)"
  fi
}
