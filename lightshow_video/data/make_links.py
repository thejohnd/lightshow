#!/usr/bin/env python

from __future__ import division
import math
import optparse
import sys


#-------------------------------------------------------------------------------
# command line

parser = optparse.OptionParser(description='''
Creates a cylinder along the z-axis extending from -height/2 to height/2.
n_tall is optional; it will default to a value that creates square pixels.
You can also create circles by setting height to 0.
''')
parser.add_option('--radius', dest='radius', default=1,
                  action='store', type='float',
                  help='radius of reso circle (default 1)')
parser.add_option('--density', dest='density', default=30,
                 action='store', type='float',
                  help='number of LEDs on each strip')
parser.add_option('--n_around', dest='n_around', default=32,
                  action='store', type='int',
                  help='number of pixels around the circumference (default 32)')
parser.add_option('--n_tall', dest='n_tall',
                  action='store', type='int',
                  help='number of pixels from top to bottom (optional)')
options, args = parser.parse_args()

# figure out how many pixels are needed around the cylinder
# in order to get square pixels
#if not options.n_tall:
#    circumference = options.radius * 2 * math.pi
#    options.n_tall = int(options.n_around * options.height / circumference)

#options.n_tall = max(1, options.n_tall)

#-------------------------------------------------------------------------------
# make cylinder

result = ['[']
#z_min = -0.5*options.height
#z_inc = options.height / max(options.n_tall - 1, 1)
theta = [
math.radians(0),
math.radians(45),
math.radians(90),
math.radians(135),
math.radians(180),
math.radians(225),
math.radians(270),
math.radians(315)
]
y = 0

# 0.72,0

for t in theta:
	for j in range(1,options.density,1):
		dist = j*(options.radius/options.density)
		x = (math.cos(t) * dist) #+ (dist * math.sin(t))#cos(t)*.72 + 0*sin(t)
		z = math.sin(t) * (dist * -1) # + (dist * math.cos(t))#-.72*sin(t) + 0*cos(t)
		result.append('  {"point": [%.8f, %.8f, %.8f]},' % (x, y, z))

# trim off last comma
result[-1] = result[-1][:-1]

result.append(']')
print('\n'.join(result))

sys.stderr.write('\nradius = %s\n' % options.radius)
sys.stderr.write('density = %s\n' % options.density)
sys.stderr.write('total = %s\n\n' % (options.density*8))

