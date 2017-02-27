# Netfilter generation script

The files in this directory can generate netfilter rules (to be used with
`iptables-restore` through ansible) using input from the hardware inventory.

- `mkrules.py` is the main script. It must be supplied with the file name of the
  inventory INI file. It will then generate the packetfilter rules as files
  (named by the host they're for) in `gen/`.
- `rulesets/` contains two files: `minimal` is the minimum ruleset every machine
  in the deployment should have if it is not part of an ISD-AS. `base` is the
  standard ruleset file for machines with ISD-AS assigned.
- `gen/` is a subdirectory that will hold the generated files.

## Inventory file format

The basic file format is that of an INI file as understood by the Python
`configparser` module. The constraints and syntax as documented for that module
apply.

### Sections

The invenotry file contains four types of section: the statically named
`machine_types` section and three types of machine-specific sections. The
latter have names that start with the machine's FQDN and either have no suffix
(the machine section), the suffix `:iface:<#>`, or the suffix `:mgmt:<#>`, with
 # being a non-negative integer.

The packetfilter generating script does not care about the machine type section
or the `mgmt` sections.

### Machine section

Machine sections are those that are not the `machine_types` section above and
whose name does not contain the tokens `iface` or `mgmt`. The name of the
section is the FQDN of the machine.

Example:

```
[scn01.foo.bar.example.com]
isd_as = AS23-42
...more fields...
```

The Netfilter generation script only cares about the section name (the FQDN) and
the `isd_as` field. The other fields are ignored. The ISD-AS is used as a means
to group machines that should have full access to each other. That is, they can
all talk to the consistency service and various SCION services that the outside
world does not need access to.

To facilitate comments in the resulting Netfilter rulesets, the third token of
the FQDN (`bar` in the example above) is used as a comment for the ISD-AS
specific rules.

### Interface section

The interface section associates network configuration information with the
FQDN. It is named `<fqdn>:iface:<#>`, where # is an non-negative integer that
has no particular meaning aside from distinguishing multiple interfaces on the
same machine. 

Example:

```
[scn01.foo.bar.example.com:iface:0]
ipmask_ext = 203.0.113.0/27
... more fields ...
```

Again, the additional fields are irrelevant to the generator script. The script
uses the interface section to map IP address ranges to FQDNs (and thus to
ISD-ASes).
