##### Information

PGP Key ID: [0x170FFC6CB3D12B30](https://pgp.mit.edu/pks/lookup?op=vindex&search=0x170FFC6CB3D12B30)  
Email: rc[dot]dev[at]tuxico[dot]com  
Licence : GPLv3 GNU General Public License  

##### Important

- If you want override some options, you have to create an additional configuration file (same name as $PC variable)
- Swap is managed by ZRam through systemd-swap (Improves SSD lifetime)
- Only simple partition layout with LUKS is supported

```
+--------------------+--------------------------------------+----------------------------------------------+
|Boot partition      |LUKS encrypted system partition       |Optional free space for additional partitions |
|/dev/sdaY           |/dev/sdaX                             |or swap to be setup later                     |
+--------------------+--------------------------------------+----------------------------------------------+
```

##### FHS Installation

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
\* Check/Update settings -- \*\* File not required

