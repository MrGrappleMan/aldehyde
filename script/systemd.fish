#!/usr/bin/env fish
echo "🚩 --- Run 'systemd.fish' ---"

# ⚜️ System-D: The core of Linux for its functioning and handling essential system functions, beside being just an init system

## Functions

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

timedatectl set-ntp true --no-ask-password

# 🫥 Mask - never run
  systemctl mask \
   systemd-rfkill systemd-rfkill.socket power-profiles-daemon auto-cpufreq \
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

# The functions to opportunistically modify unit characteristics, if a unit fails to do so, its ignored - invalid units poison the rest of the targetted batch

# 🟢 Enable - Run at startup

sysdOnPerUnit "boinc-client \
   systemd-timesyncd \
   gdm \
   podman podman.socket podman-auto-update.timer \
   tlp tlp-pd \
   uupd.timer bootc-fetch-apply-updates.timer \
   fstrim.timer beesd@var-home \
   systemd-bsod \
   sshd tailscaled tor \
   hblock.timer \
   preload"

# 🟥 Disable - Do not run at startup

sysdOffPerUnit "auto-cpufreq"

echo "🏁 --- Run 'build.fish' ---"
