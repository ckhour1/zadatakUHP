set -eu
printf 'CLEANFRAME_HOME_INSPECT_BEGIN\n'
/usr/bin/dotnet /home/owner/share/tmp/sdk_tools/CleanFrameHomeControl.dll apply /home/owner/share/tmp/sdk_tools/CleanFrameHomeOriginal.json
printf 'CLEANFRAME_HOME_INSPECT_END\n'
