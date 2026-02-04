#!/usr/bin/env fish

set -l conflict_files \
        "/usr/share/dbus-1/system-services/net.hadess.PowerProfiles.service" \
        "/usr/share/dbus-1/system-services/org.freedesktop.UPower.PowerProfiles.service" \
        "/usr/share/dbus-1/system.d/net.hadess.PowerProfiles.conf" \
        "/usr/share/dbus-1/system.d/org.freedesktop.UPower.PowerProfiles.conf"

    for file in $conflict_files
        if test -f $file
            echo "🗑️  Deleting orphaned/conflicting file: $file"
            rm -f $file
        end
    end
