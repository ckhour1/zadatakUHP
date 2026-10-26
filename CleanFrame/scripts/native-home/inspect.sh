set -u
printf 'CLEANFRAME_HOME_INSPECT_BEGIN\n'
id
uname -m
sed -n '/^Version=/p;/^Model=/p' /etc/prd_info.ini
cat /etc/tizen-release
printf '\nDOTNET\n'
ls -d /usr/share/dotnet/shared/Microsoft.NETCore.App/* 2>/dev/null || true
printf '\nHOME_PREFERENCES\n'
for k in db/appfw/home_appid db/appfw/startup_appid db/appfw/booting_appid_backup db/first_screen/type db/menu/smart_hub/ontvsetting/auto_start; do vconftool get "$k"; done
printf '\nNATIVE_LIBRARIES\n'
ls -l /usr/lib/libapp-context-manager-common.so /usr/lib/libcapi-appfw-app-operation-tv.so.0 /usr/lib/libvconf.so.0 2>/dev/null || true
printf 'CLEANFRAME_HOME_INSPECT_END\n'
