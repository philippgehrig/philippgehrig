#!/usr/bin/env bash
# CFD host: single-node Slurm (controller + compute on this machine, 1 GPU) for
# STAR-CCM+ / OpenFOAM jobs. The cfd-toolchain repo itself is cloned in 70-user.

NODE=slurm-gpu

log "Slurm + munge + headless X"
apt_install slurm-wlm munge xvfb

log "munge key"
[ -f /etc/munge/munge.key ] || sudo /usr/sbin/mungekey --create
sudo systemctl enable --now munge

log "Slurm config (CPU/RAM detected from this machine)"
# slurmd -C prints e.g. "NodeName=host CPUs=16 Boards=1 ... RealMemory=31869"
hw=$(slurmd -C | head -n1 | sed -E 's/^NodeName=[^ ]+ //')
[ -f /etc/slurm/slurm.conf ] && sudo cp -a /etc/slurm/slurm.conf "/etc/slurm/slurm.conf.bak-$(date +%Y%m%d%H%M%S)"
write_root /etc/slurm/slurm.conf 0644 <<EOF
ClusterName=cluster
SlurmctldHost=$(hostname -s)
ReturnToService=1
SlurmUser=slurm
SlurmctldPort=6817
SlurmdPort=6818
SlurmctldPidFile=/var/run/slurmctld.pid
SlurmdPidFile=/var/run/slurmd.pid
SlurmdSpoolDir=/var/spool/slurmd
StateSaveLocation=/var/spool/slurmctld
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdLogFile=/var/log/slurm/slurmd.log
SlurmctldDebug=info
SlurmdDebug=info
TaskPlugin=task/affinity
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core_Memory
GresTypes=gpu
JobCompType=jobcomp/none
JobAcctGatherFrequency=30
InactiveLimit=0
KillWait=30
MinJobAge=300
SlurmctldTimeout=120
SlurmdTimeout=300
Waittime=0
NodeName=$NODE NodeHostname=$(hostname -s) NodeAddr=127.0.0.1 $hw Gres=gpu:rtx3060ti:1
PartitionName=debug Nodes=ALL Default=YES MaxTime=INFINITE State=UP
EOF
sudo install -m 0644 "$FILES_DIR/slurm/gres.conf" /etc/slurm/gres.conf

# slurmd must register under the logical node name, not the hostname.
sudo install -D -m 0644 "$FILES_DIR/slurm/slurmd-override.conf" \
  /etc/systemd/system/slurmd.service.d/override.conf

sudo install -d -o slurm -g slurm -m 0755 /var/log/slurm /var/spool/slurmctld
sudo install -d -o root -g root -m 0755 /var/spool/slurmd
sudo systemctl daemon-reload
sudo systemctl enable --now slurmctld slurmd

log "STAR-CCM+ (Siemens, proprietary)"
if compgen -G '/opt/Siemens/*/STAR-CCM+*/star/bin' >/dev/null; then
  echo "found: $(ls -d /opt/Siemens/*/STAR-CCM+*/star/bin | head -n1)"
else
  warn "STAR-CCM+ not installed. Put the installer in startup/installers/ and run: ./install.sh starccm"
fi
