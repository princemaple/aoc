import re

rf = ['byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid']

byr = lambda x: x and (1920 <= int(x) <= 2002)
iyr = lambda x: x and (2010 <= int(x) <= 2020)
eyr = lambda x: x and (2020 <= int(x) <= 2030)

def hgt(x):
    m = re.match(r'(\d+)(in|cm)', x)
    if m:
        if m.group(2) == 'in':
            return 59 <= int(m.group(1)) <= 76
        elif m.group(2) == 'cm':
            return 150 <= int(m.group(1)) <= 193
        else:
            return False
    else:
        return False

def hcl(x):
    return re.match(r'^#[0-9a-f]{6}$', x) != None

def ecl(x):
    return x in ['amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth']

def pid(x):
    return re.match('^\d{9}$', x) != None

byr(x.get('byr')) and iyr(x.get('iyr')) and eyr(x.get('eyr')) and hgt(x.get('hgt')) and hcl(x.get('hcl')) and ecl(x.get('ecl')) and pid(x.get('pid'))
