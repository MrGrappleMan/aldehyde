#!/usr/bin/env fish
echo "🚩 --- Run 'systemd.fish' ---"

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

# 🫥 Mask - never run
systemctl mask \
  power-profiles-daemon \
  tlp tlp-pd \
  auto-cpufreq \
  wpa_supplicant

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

# 🟥 No run at startup
sysdOff "gdm"

# 🟢 Run at startup + Unmask
sysdOn \
    "systemd-timesyncd \
    greetd \
    podman podman.socket podman-auto-update.timer \
    libvirtd libvirtd.socket \
    tuned tuned-ppd systemd-rfkill systemd-rfkill.socket iwd \
    uupd.timer bootc-fetch-apply-updates.timer \
    fstrim.timer beesd@var-home \
    systemd-bsod scx_loader \
    sshd tailscaled tor hblock.timer"
