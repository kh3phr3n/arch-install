##### Information

Email: rc.dev@tuxico.com  
PGP Key: [0x170FFC6CB3D12B30](https://pgp.mit.edu/pks/lookup?op=vindex&search=0x170FFC6CB3D12B30)  
Licence: GPLv3 GNU General Public License  

##### Important

- You can consider `conf/core.conf` as your primary machine, if you want override some settings for another one.  
You have to create a new configuration file in `conf/` (Ex: `hp.conf` where `hp` is the future hostname).  
When `ali.sh` is executed, `core.conf` is loaded and if `${PC}.conf` is found, extra settings override core settings.

    In real life:  
    - The name of my primary machine is `msi`, the variable `PC` in `ali.sh` is `msi`. So only `core.conf` is loaded because `msi.conf` does not exists.
    - The name of my secondary machine is `hp`, the variable `PC` in `ali.sh` is `hp`. So `core.conf` is loaded and then `hp.conf`.

- Swap is managed by ZRam through systemd-swap (Improves SSD lifetime).
- Only simple partition layout with LUKS is supported.

```
+----------------------+-----------------------------------+-----------------------------------------------+
| Boot partition       | LUKS encrypted system partition   | Optional free space for additional partitions |
| /dev/sdaY (BOOTFS)   | /dev/sdaX (ROOTFS)                | or swap to be setup later                     |
+----------------------+-----------------------------------+-----------------------------------------------+
```

##### Installation

- Boot on your fresh [Arch Linux image](https://www.archlinux.org/download)
- Set your [keyboard layout](https://wiki.archlinux.org/index.php/Installation_guide#Set_the_keyboard_layout) (Default: us)

```
wget https://github.com/kh3phr3n/arch-install/archive/master.tar.gz
tar xzf arch-install-master.tar.gz
mv arch-install-master/ali /root
cd ali && chmod +x ali
```

- Edit `USERPASS`, `ROOTPASS`, `LUKSPASS` and `PC` in `ali.sh` (You can use `vim` or `nano`).

```
./ali.sh -i
```

##### Arch Linux Install files

    ali/
    ├── ali.sh               *
    ├── conf
    │   ├── apps.conf        *
    │   ├── core.conf        *
    │   └── hp.conf          **
    ├── libs
    │   ├── lib-core.sh
    │   ├── lib-desktop.sh
    │   ├── lib-install.sh
    │   ├── lib-users.sh
    │   ├── lib-utils.sh
    │   └── lib-xorg.sh
    └── utils                **
        ├── aur.sh           **
        └── wipe.sh          **

***
\* Check settings -- \*\* Not required

