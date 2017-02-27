#!/usr/bin/python3 -tt
"""Read inventory INI and generate Netfilter rules."""
import collections
import configparser
import ipaddress
import sys


def mkisdasranges(filename):
    """
    Read inventory INI file and create mappings between ISD-ASes and IP ranges

    Returns four dictionaries: IP address to ISD-AS, ISD-AS to set of IP
    ranges, IP address to owner, and IP address to FQDN.
    """
    ip2isdas = {}
    ip2owner = {}
    isdas2ranges = collections.defaultdict(set)
    ip2fqdn = {}
    fqdn2isdas = {}
    parser = configparser.ConfigParser()
    parser.read(filename)
    for section in parser.sections():
        if section == "machine_types" or ":mgmt:" in section:
            continue

        if ":iface:" in section:
            fqdn = section.split(":")[0]
            ipaddr = parser[section]['ipmask_ext']
            ip2fqdn[ipaddr] = fqdn
        elif "isd_as" in parser[section]:
            fqdn2isdas[section] = parser[section]["isd_as"]

    for ipaddr, fqdn in ip2fqdn.items():
        owner = fqdn.split(".")[2]
        ip2owner[ipaddr] = owner
        if fqdn in fqdn2isdas:
            isdas = fqdn2isdas[fqdn]
            ip2isdas[ipaddr] = isdas
            isdas2ranges[isdas].add((ipaddr, owner))

    return ip2isdas, dict(isdas2ranges), ip2owner, ip2fqdn


def mk_rules(ranges):
    """Take a list of address, owner tuples and make ACCEPT rules."""
    ret = []
    for addr, comment in sorted(ranges):
        ret.append("# %s" % (comment))
        ret.append("-A site -s %18s -j ACCEPT" % (addr))
    return "\n".join(ret)


def main():
    """Main program"""
    ip2isdas, isdas2ranges, ip2owner, ip2fqdn = mkisdasranges(sys.argv[1])
    with open("rulesets/minimal") as f:
        defaultrules = f.read()
    with open("rulesets/base") as f:
        template = f.read()

    for ipaddr in ip2owner.keys():
        isdas = ip2isdas.get(ipaddr)
        fqdn = ip2fqdn[ipaddr]
        with open("gen/%s" % (fqdn), "w") as f:
            if not isdas:
                tvars = {
                    "IPADDR": ipaddr,
                    "FQDN": fqdn,
                }
                f.write(defaultrules % tvars)
            else:
                tvars = {
                    "SITELOOP": mk_rules(isdas2ranges[isdas]),
                    "ISDAS": isdas,
                    "IPADDR": ipaddr,
                    "FQDN": fqdn,
                }
                f.write(template % tvars)


if __name__ == "__main__":
    main()
