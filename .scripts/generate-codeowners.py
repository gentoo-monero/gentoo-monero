#!/usr/bin/env python3

from glob import glob
import xml.etree.ElementTree as et

CODEOWNERS = 'CODEOWNERS'
GLOBAL_CODEOWNERS = ['matt@offtopica.uk']

def get_maintainer_emails(xmlPath):
    "Get a list of maintainer emails from a package's metadata XML file"
    tree = et.parse(xmlPath)
    return [node.find('email').text for node in tree.iter('maintainer')
            if node.attrib.get('type', 'unknown') == 'person'
            and node.find('email') != None]

def get_codeowners(xmlPath):
    "Get a package's atom and list of maintainers from metadata XML file"
    atom = xmlPath[:xmlPath.rindex('/')]
    maintainers = get_maintainer_emails(xmlPath)
    return ('/' + atom + '/', maintainers)

def codeowner_line(atom, maintainers):
    return '%s %s' % (atom.ljust(24), ' '.join(maintainers))

all_codeowners = [get_codeowners(path)
                  for path in sorted(glob('*/*/metadata.xml'))]

with open(CODEOWNERS, 'w') as handle:
    handle.write('# auto-generated, do not modify by hand\n\n')
    handle.write(codeowner_line('*', GLOBAL_CODEOWNERS) + '\n')
    for codeowners in all_codeowners:
        handle.write(codeowner_line(*codeowners) + '\n')
