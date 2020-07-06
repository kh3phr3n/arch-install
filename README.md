##### Information

Email: kh3phr3n@nixsys.fr  
PGP Key: [0xF185DC316E659F24](https://pgp.mit.edu/pks/lookup?op=vindex&search=0xF185DC316E659F24)  
Licence: GPLv3 GNU General Public License  

##### Important

- You can consider `conf/core.conf` as your primary machine, if you want override some settings for another one.  
You have to create a new configuration file in `conf/` (Ex: `dm3.conf` where `dm3` is the future hostname).  
When `ali.sh` is executed, `core.conf` is loaded and if `${PC}.conf` is found, extra settings override core settings.

    In real life:  
    - My primary machine is `l380`, the variable `PC` in `ali.sh` is `l380`. So only `core.conf` is loaded because `l380.conf` does not exists.
    - My secondary machine is `dm3`, the variable `PC` in `ali.sh` is `dm3`. So `core.conf` is loaded and then `dm3.conf`.

- Swap is managed by ZRam through zram-generator (Improves SSD lifetime).
- Only simple partition layout with LUKS is supported.
- Only GRUB is supported (i386-pc and x86_64-efi).
- UEFI and dual-boot windows are not supported yet.

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
curl -O https://codeload.github.com/kh3phr3n/arch-install/tar.gz/master
tar xzf master && mv arch-install-master/ali /root
cd ali && chmod +x ali
```

- Edit `USERPASS`, `ROOTPASS`, `LUKSPASS` and `PC` in `ali.sh` (You can use `vim` or `nano`).

```
./ali.sh -i
```

