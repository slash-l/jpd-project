#!/bin/sh
#
# ---------------------------------------------------------------------
# JFrog Connect Agent installation script.
# ---------------------------------------------------------------------

abort() {
	echo >&2 '
***************
*** ABORTED ***
***************
'
	echo "An error occurred. Exiting..." >&2
	echo "Please contact us via JFrog Connect chat for help, in some cases you may need a different installation setup" >&2
	exit 1
}

trap 'abort' 0

set -e

CONNECT_CLOUD_DASHBOARD_URL=https://app.connect.jfrog.io
DASHBOARD_URL=https://app.connect.jfrog.io
TAR_PATH_NAME=/tmp/connect.tar.gz
CA_FILE_PATH=/etc/ssl/certs/ca-certificates.crt
SYSV_URL=/etc/init.d/connect
CONNECT_MAIN_DIR=/etc/connect
CONNECT_MAIN_SERVICE_DIR="${CONNECT_MAIN_SERVICE_DIR:-${CONNECT_MAIN_DIR}/service}"
SETTINGS_PATH="${CONNECT_MAIN_SERVICE_DIR}/settings.json"
CONNECT_AGENT_BIN="${CONNECT_MAIN_SERVICE_DIR}/ConnectAgent"
SYSTEMD_SERVICE=/etc/systemd/system
SYSTEMD_OVERRIDE_DIR="${SYSTEMD_SERVICE}/connect.service.d"
INITD_SERVICE=/etc/init.d/
BUSYBOX=/bin/busybox

# Initialize variables
DEVICE_NAME=""
DEVICE_GROUP=""
SOFTWARE_VERSION=""
AGENT_VERSION=""
INSTALL_AS_USER=""
USER_TOKEN=""
PROJECT_ID=""
PAIRING_TOKEN=""
APP_VERSION=""
APP_NAME=""

# Parse the arguments
for arg in "$@"; do
    case $arg in
        -n=* | --device_name=*)
            DEVICE_NAME="${arg#*=}"
            ;;
        -g=* | --device_group=*)
            DEVICE_GROUP="${arg#*=}"
            ;;
        -s=* | --software_version=*)
            SOFTWARE_VERSION="${arg#*=}"
            ;;
        --agent_version=*)
            AGENT_VERSION="${arg#*=}"
            ;;
        -u=* | --install_as_user=*)
            INSTALL_AS_USER="${arg#*=}"
            if ! id -u "$INSTALL_AS_USER" >/dev/null 2>&1; then
                echo "User $INSTALL_AS_USER does not exist" >&2
                exit 1
            fi
            ;;
        -p=* | --pairing_token=*)
            PAIRING_TOKEN="${arg#*=}"
            ;;
        -an=* | --app_name=*)
            APP_NAME="${arg#*=}"
            ;;
        -av=* | --app_version=*)
            APP_VERSION="${arg#*=}"
            ;;
        -*)
            echo "Invalid option: $arg" >&2
            exit 1
            ;;
        *)
            if [ -z "$USER_TOKEN" ]; then
                USER_TOKEN="$arg"
            elif [ -z "$PROJECT_ID" ]; then
                PROJECT_ID="$arg"
            else
                echo "Unexpected argument: $arg" >&2
                exit 1
            fi
            ;;
    esac
done

# Check if APP_NAME is provided and APP_VERSION is not, or vice versa
if { [ -n "$APP_NAME" ] && [ -z "$APP_VERSION" ]; } || { [ -z "$APP_NAME" ] && [ -n "$APP_VERSION" ]; }; then
    echo "Error: both app name (-an) and app version (-av) must be provided together." >&2
    exit 1
fi


ValidateInputs() {
  IS_VALID=false
  # Check if PAIRING_TOKEN exists
  if [ -n "$PAIRING_TOKEN" ]; then
    IS_VALID=true
  fi
  # Check if $USER_TOKEN and $PROJECT_ID exists
  if [ "$IS_VALID" = false ] && [ -n "$USER_TOKEN" ] && [ -n "$PROJECT_ID" ]; then
    IS_VALID=true
  fi

  if [ "$IS_VALID" = false ]; then
    echo "Error: missing input variables." >&2
    exit 1
  fi
}

DownloadApp() {
  if [ -z "$PAIRING_TOKEN" ]; then
      GeneratePairingToken
  fi
	HW=$(uname -m)

	case "$HW" in
	"x86_64")
		architecture="x86_64a"
		;;
	"x86")
		architecture="x86"
		;;
	"armv5"*)
		architecture="armv5"
		;;
	"armv6"*)
		architecture="armv6"
		;;
	"armv7"*)
		architecture="armv0"
		;;
	"aarch64"*)
		architecture="arm64"
		;;
	"arm64"*)
		architecture="arm64"
		;;
	"armv8"*)
		architecture="armv0"
		;;

	*)
		echo "Error while trying to find hardware architecture type: $HW, please contact us via JFrog Connect chat"
		exit 1
		;;
	esac

  url="$DASHBOARD_URL/download_connect?arch=${architecture}"
	wget --header="Authorization: Bearer $PAIRING_TOKEN" "$url" -O $TAR_PATH_NAME || /bin/busybox wget --header="Authorization: Bearer $PAIRING_TOKEN" "$url" -O $TAR_PATH_NAME
}

Extract_SYSTEMD() {

	mv /etc/connect/service/connect.service "$SYSTEMD_SERVICE/connect.service"
	chmod 644 "$SYSTEMD_SERVICE/connect.service"
  if [ -d $SYSTEMD_OVERRIDE_DIR ]; then
     rm -r $SYSTEMD_OVERRIDE_DIR
  fi
	if [ -n "$INSTALL_AS_USER" ]; then
    mkdir -p $SYSTEMD_OVERRIDE_DIR && printf "[Service]\nUser=$INSTALL_AS_USER" | tee "$SYSTEMD_OVERRIDE_DIR/override.conf" > /dev/null
  fi
}

Extract_INITD() {

	url="$DASHBOARD_URL/download_upswift?arch=connect.sh"
	wget --header="Authorization: Bearer $PAIRING_TOKEN" "$url" -O $SYSV_URL || /bin/busybox wget --header="Authorization: Bearer $PAIRING_TOKEN" "$url" -O $SYSV_URL

	chmod a+x /etc/init.d/connect

	echo "* * * * * root ps aux | grep -v grep | grep ConnectAgent || /etc/init.d/connect start" >>/etc/crontab

}

ExtractApp() {

	if [ -f $TAR_PATH_NAME ]; then
		echo "Installing..."
        if [ -d $CONNECT_MAIN_DIR ]; then
           rm -r $CONNECT_MAIN_DIR
        fi

        tar -zxf $TAR_PATH_NAME -C /etc
        chmod 600 $CONNECT_MAIN_DIR

        chmod a+x $CONNECT_AGENT_BIN

        rm $TAR_PATH_NAME

		if [ "$DASHBOARD_URL" = "$CONNECT_CLOUD_DASHBOARD_URL" ]; then
			if [ ! -f $CA_FILE_PATH ]; then
				echo "ca-certificates.crt file is missing, you can not do HTTPS requests. Trying to download a ca-certificates.crt file for you..."

				if [ ! -d /etc/ssl/certs ]; then
					mkdir /etc/ssl/certs/
				fi

				if [ ! -d /etc/ssl/ ]; then
					mkdir /etc/ssl/
					mkdir /etc/ssl/certs/
				fi

				if [ ! -d /etc/ssl/certs ]; then
					mkdir /etc/ssl/certs/
				fi

				cd /etc/ssl/certs/
				url="$DASHBOARD_URL/download_ca_certificate"
				wget --header="Authorization: Bearer $PAIRING_TOKEN" "$url" -O "ca-certificates.crt" || /bin/busybox wget --header="Authorization: Bearer $PAIRING_TOKEN" "$url" -O "ca-certificates.crt"
			fi

		fi
	fi
}

GeneratePairingToken() {
  ERROR_MESSAGE="Error: generating pairing token - failed - missing pairing token..."
  #Version is less than 7.0 and user token is provided
  if [ -n "$USER_TOKEN" ] && [ -n "$PROJECT_ID" ]; then
	url="$DASHBOARD_URL/v2/agent_device_pairing_token?project=$PROJECT_ID"
	RESPONSE=$(wget --header="Authorization: Bearer $USER_TOKEN" "$url" -q -O - || /bin/busybox wget --header="Authorization: Bearer $USER_TOKEN" "$url" -q -O -)
  PAIRING_TOKEN=$(echo "$RESPONSE" | grep -o '"pairing_token":[[:space:]]*"[^"]*' | sed 's/"pairing_token":[[:space:]]*"//')
	if [ -n "$PAIRING_TOKEN" ]; then
          USER_TOKEN=""
    else
      echo $ERROR_MESSAGE
      exit 1
    fi
  fi
}

InstallApp() {
  echo '{"device_token":"", "device_name":"${d}", "device_group":"${c}", "software_version":"${e}", "pairing_token":"${f}", "app_name":"${g}", "app_version":"${h}"}' > $SETTINGS_PATH
  sed -i  -e "s/\${d}/$DEVICE_NAME/" -e "s/\${c}/$DEVICE_GROUP/" -e "s/\${e}/$SOFTWARE_VERSION/" -e "s/\${f}/$PAIRING_TOKEN/" -e "s/\${g}/$APP_NAME/" -e "s/\${h}/$APP_VERSION/" $SETTINGS_PATH

	chmod -R 755 $CONNECT_MAIN_DIR || :
	if [ -n "$INSTALL_AS_USER" ]; then
	  chown -R $INSTALL_AS_USER $CONNECT_MAIN_DIR
	fi
}

RunApp() {

	echo "Starting Connect service..."
	systemctl start connect || :
	systemctl restart connect || :
	systemctl enable connect
}

RunApp_I() {

	echo "Starting Connect service..."
	/etc/init.d/connect start || :
	update-rc.d connect defaults || :
}

InstallSSHD() {
	if [ -z "$(which sshd)" ]; then
		echo ""
		echo "Sshd is required in order to use the Remote Connection & Remote Access features."
		message="failed to install openssh-server"
    url="$DASHBOARD_URL/agent_installation_error?message="$message
		if [ -n "$(which apt-get)" ]; then
			# AskSSHPermission
			echo "Installing openssh-server"
			apt-get install -y openssh-server || wget --header="Authorization: Bearer $PAIRING_TOKEN" "$url" >/dev/null 2>&1 || :
			if systemctl is-active --quiet sshd; then
				systemctl stop sshd || :
				systemctl disable sshd || :
			fi

		elif [ -n "$(which apt)" ]; then
			# AskSSHPermission
			echo "Installing openssh-server"

			apt install -y openssh-server || wget --header="Authorization: Bearer $PAIRING_TOKEN" "$url" >/dev/null 2>&1 || :
			if systemctl is-active --quiet sshd; then
				systemctl stop sshd || :
				systemctl disable sshd || :
			fi

		else
			echo "Please install openssh-server on your device."
			wget --header="Authorization: Bearer $PAIRING_TOKEN" "$url" >/dev/null 2>&1 || :
		fi
	fi
}

#### main ####

if [ "$(which systemctl)" ]; then
	ValidateInputs
	DownloadApp
	ExtractApp
	Extract_SYSTEMD
	InstallApp
	wget --header="Authorization: Bearer $PAIRING_TOKEN" -qO - "$DASHBOARD_URL/download_upswift_done" || /bin/busybox wget --header="Authorization: Bearer $PAIRING_TOKEN" -qO - "$DASHBOARD_URL/download_upswift_done" || :
	echo ""
	RunApp
	echo ""
	echo "Installation successful - your device will appear in the JFrog Connect dashboard in a minute"

	InstallSSHD || :
	ssh-keygen -A || :
	trap : 0

else
	ValidateInputs
	DownloadApp
	ExtractApp
	Extract_INITD
	InstallApp
	wget --header="Authorization: Bearer $PAIRING_TOKEN" -qO - "$DASHBOARD_URL/download_upswift_done" || /bin/busybox wget --header="Authorization: Bearer $PAIRING_TOKEN" -qO - "$DASHBOARD_URL/download_upswift_done" || :
	echo ""
	RunApp_I
	echo ""
	echo "Installation successful - your device will appear in the JFrog Connect dashboard in a minute"

	InstallSSHD || :
	ssh-keygen -A || :
	trap : 0
fi
