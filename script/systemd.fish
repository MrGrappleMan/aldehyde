#!/usr/bin/env fish

# ⚜️ System-D: The core of Linux for its functioning and handling essential system functions, beside being just an init system

timedatectl set-ntp true --no-ask-password

# 🫥 Mask - never run
  systemctl mask \
   systemd-rfkill systemd-rfkill.socket power-profiles-daemon \
   tlp \
   rpm-ostreed-automatic rpm-ostreed-automatic.timer rpm-ostree-countme rpm-ostree-countme.timer

# 🙂 Unmask - allow to run
  systemctl unmask \
   shutdown.target reboot.target poweroff.target halt.target

# Issues regarding below: https://chatgpt.com/share/695bf356-8140-800b-af74-448ee16bedb2
# If any unit in the batch:
# does not exist
# is masked
# has invalid install info

# 👉 the commit phase becomes partial or skipped
# This is intentional, to avoid half-applied boot states.
# ⚠️ systemd does not roll back, and does not warn which units were skipped.

#reenable ensures that precedence set by Systemd's developers is followed in the [Install] section, but can cause issues if the top file as by precedence does not contain an [Install] section

# The functions are mainly for opportunistic enablement of units, in case some units fail to activate - invalid units poison the rest of the targetted batch

# 🟢 Enable - Run at startup

function sysdOnPerUnit
	# Join multiline string into a clean list
	set units (string split ' ' -- (string replace -ar '\s+' ' ' -- $argv))

	set failed_units
	set failed_reasons

	for unit in $units
		set log (mktemp)

		# Enable per unit with full debug
		env SYSTEMD_LOG_LEVEL=debug \
			systemctl enable $unit &> $log

		if test $status -ne 0
			set failed_units $failed_units $unit
			set failed_reasons $failed_reasons (cat $log)
		end

		rm -f $log
	end

	# ----- Report -----
	if test (count $failed_units) -gt 0
		echo
		echo "❌ sysdOnPerUnit — failures detected:"
		echo "────────────────────────────────────"

		for i in (seq (count $failed_units))
			echo
			echo "▶ Unit: $failed_units[$i]"
			echo "────────────────────────"
			echo $failed_reasons[$i]
		end
	else
		echo "✅ sysdOnPerUnit — all units enabled successfully"
	end
end

sysdOnPerUnit "boinc-client \
   systemd-timesyncd \
   gdm \
   docker docker.socket \
   podman podman.socket podman-auto-update.timer \
   auto-cpufreq \
   uupd uupd.timer bootc-fetch-apply-updates bootc-fetch-apply-updates.timer fyn-sysfresh fyn-sysfresh.timer podman-auto-update podman-auto-update.timer \
   fstrim fstrim.timer beesd@var-home \
   systemd-bsod \
   sshd tailscaled tor \
   hblock hblock.timer \
   preload"

# 🟥 Disable - Do not run at startup

function sysdOffPerUnit
	set units (string split ' ' -- (string replace -ar '\s+' ' ' -- $argv))

	set failed_units
	set failed_reasons

	for unit in $units
		set log (mktemp)

		env SYSTEMD_LOG_LEVEL=debug \
			systemctl disable $unit &> $log

		if test $status -ne 0
			set failed_units $failed_units $unit
			set failed_reasons $failed_reasons (cat $log)
		end

		rm -f $log
	end

	if test (count $failed_units) -gt 0
		echo
		echo "❌ sysdOffPerUnit — failures detected:"
		echo "────────────────────────────────────"

		for i in (seq (count $failed_units))
			echo
			echo "▶ Unit: $failed_units[$i]"
			echo "────────────────────────"
			echo $failed_reasons[$i]
		end
	else
		echo "✅ sysdOffPerUnit — all units disabled successfully"
	end
end

sysdOffPerUnit "tlp"
