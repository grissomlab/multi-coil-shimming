# -*- coding: utf-8 -*-
"""
Created on Thu Feb 11 16:57:13 2021

@author: griss

"""
import pyparsing as pp
'''
Parses the .biot configuration files from Biot Savart software to extract the coil elements and probes for importing 
into matlab

Format of configuration file:
    
type { 
name {the name} 
...further commands... 
}

The OBJECT type should be one of the recognized object types 
- Current
- Loop
- Solenoid
- Revolved
- Wire
- Racetrack
- Linear
- Planar
- Volumetric

Commands common to all objects
name {the name} set object name 
comment {notes...} the contents of the Notes tab 
positionX x origin of object coordinate frame 
positionY y   
positionZ z   
eulerPhi phi Euler angles (degrees) 
eulerPsi psi   
eulerTheta theta   
visible b 
'''

OBJECTS = ['Current','Loop','Wire','Volumetric']

class Volume_Probe():
    
    def __init__(self, position, grid, size):
        """
        Input:
            position - dictionary specifying x,y,z positions of probe
            grid - array specifying number of grids along each axis
            size - dictionary specifying length of grid along each dimension
        """
        self.position = position 
        self.grid = grid
        self.size = size
        




file_name = '3_element_NHP_coil.biot'
types = open(file_name).read()
#.read().split('\n\n') # Isolate each item type


line = pp.Word(alpha) + pp.ZeroOrMore('{') + OneOrMore(pp.Word(num) + pp.Word(char))


if __name__ == "__main__":
    
    pass