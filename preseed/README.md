To generate an autoinstall image for ubuntu 14.04 (Trusty):
- In the `preseed/` directory, create these files:
  - `root.passwd` - the contents should be a plaintext password that will be
    used for the root account. (An MD5 hash of the password is stored on the
    image, not the password itself). If this file doesn't exist, the root
    password will be disabled.
  - `root.ssh` - this gets installed as `/root/.ssh/authorized_keys`, so it
    should contain public keys for ssh identities that should be able to access
    the root account. If this file doesn't exist, no `authorized_keys` file is
    installed.
  - `scion.passwd` - same as `root.passwd`, for the scion user account.
  - `scion.ssh` - installed as `/home/scion/.ssh/authorized_keys`, just like
    for root.
- Run the build script in the `preseed/` directory:

  `./mkmini.sh`

- This will generate `build/scion.iso`. This image can be burnt to a CD, or
  directly dd'd onto a usb drive:

  `sudo dd if=build/scion.iso of=/dev/sde bs=16M conv=nocreat`
  (this example assumes the usb drive is at `/dev/sde`).
- The installer will automatically boot after 15s (configurable via
  `timeout` in `txt.cfg`), and will pause at the end for the install media to
  be removed.
- If you want to test the installer inside VirtualBox, you can create a vbox
  image with this command:
  `VBoxManage internalcommands createrawvmdk -rawdisk $PWD/build/scion.iso -filename build/scion.vmdk`
  The resulting `build/scion.vmdk` image can be attached to any vbox instance.
  Note that it refers to `scion.iso` as the underlying 'block' device, so any
  changes to `scion.iso` will be seen by virtualbox.
