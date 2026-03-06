#!/usr/bin/env fish
echo "🚩 --- Run 'systemd.fish' ---"

# ⚜️ System-D: The core of Linux for its functioning and handling essential system functions, beside being just an init system

## Functions

function sysdOn
	# Join multiline string into a clean list
	set units (string split ' ' -- (string replace -ar '\s+' ' ' -- $argv))

	set failed_units
	set failed_reasons

	for unit in $units
		set log (mktemp)

        # Unmask unit first
        systemctl unmask $unit

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
		echo "❌ sysdOn — failures detected:"
		echo "────────────────────────────────────"

		for i in (seq (count $failed_units))
			echo
			echo "▶ Unit: $failed_units[$i]"
			echo "────────────────────────"
			echo $failed_reasons[$i]
		end
	else
		echo "✅ sysdOn — all units enabled successfully"
	end
end

function sysdOff
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
		echo "❌ sysdOff — failures detected:"
		echo "────────────────────────────────────"

		for i in (seq (count $failed_units))
			echo
			echo "▶ Unit: $failed_units[$i]"
			echo "────────────────────────"
			echo $failed_reasons[$i]
		end
	else
		echo "✅ sysdOff — all units disabled successfully"
	end
end

timedatectl set-ntp true --no-ask-password

# 🫥 Mask - never run
systemctl mask \
  power-profiles-daemon \
  tlp tlp-pd \
  auto-cpufreq \
  rpm-ostreed-automatic rpm-ostreed-automatic.timer rpm-ostree-countme rpm-ostree-countme.timer

# 🙂 Unmask - allow to run
  systemctl unmask \
   shutdown.target reboot.target poweroff.target halt.target

# Issues regarding below: https://chatgpt.com/share/695bf356-8140-800b-af74-448ee16bedb2
# If any unit in the batch does not exist, is masked or has invalid install info,
# 👉 the commit phase becomes partial or skipped
# That move by systemd is intentional, to avoid half-applied states to a batch of units requested to do a specific action.
# invalid units poison the rest of the targetted batch
# ⚠️ systemd does not roll back, and does not warn which units were skipped.

# The functions to opportunistically modify unit characteristics, if a unit fails to do so, its ignored and reported

# 🟥 Disable - Do not run at startup
sysdOff "gdm"

# 🟢 Enable (+Unmask) - Run at startup
sysdOn "boinc-client \
        systemd-timesyncd \
        greetd \
        podman podman.socket podman-auto-update podman-auto-update.timer \
        libvirtd libvirtd.socket \
        tuned tuned-ppd systemd-rfkill systemd-rfkill.socket \
        uupd uupd.timer bootc-fetch-apply-updates bootc-fetch-apply-updates.timer \
        fstrim fstrim.timer beesd@var-home \
        systemd-bsod \
        sshd tailscaled tor hblock hblock.timer \
        preload"

plymouth-set-default-theme bgrt
