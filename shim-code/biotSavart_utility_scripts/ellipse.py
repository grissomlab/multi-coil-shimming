import numpy as np
import matplotlib.pyplot as plt
import coil_config as biot
import pprint

def ellipse_points(a,b,n):
    """
    a is the square of the x coordinate at the x axis
    b is the square of the y coordinate at the y axis
    n is the number of points to generate
    """
    thetas = np.arange(0, 360, (360/n)) * (np.pi / 180)
    x_points = []
    y_points = []
    for i in thetas:
        x = a * np.cos(i)
        y = b * np.sin(i)
        x_points.append(x)
        y_points.append(y)

    return x_points, y_points, thetas

def martinos_text_file(coil_coordinates):
    """
    Generates a text file with even rows being the coil center and odd rows being the normal vector of that coil
    """
    with open("ellipse.txt", 'w+') as f:
        for i in list(range(12)):
            f.write(coil_coordinates[i])
            f.write('\n')
            f.write(coil_coordinates[i])
            f.write('\n')
        

if __name__ == "__main__":

    a = 20/2 # units in cm minor diameter
    b = 26/2 # units in cm major diameter
    number_of_elements = 12
    x,y, thetas = ellipse_points(a, b, number_of_elements)
    z = 0
  
    coil_elements = {}
    for i in range(number_of_elements):
        coil_elements[i] = {}
        coil_elements[i]['Center'] = [[z0],[x[i]],[y[i]]]
        #coil_elements[i]['Euler Angle'] = [90, thetas[i] * (180/np.pi), 0]
        coil_elements[i]['Euler Angle'] = [0,  thetas[i] * (180/np.pi), 0]


'''
    with open('ellipse.biot','w+') as f:
        coil_diam = 5 # cm
        text = biot.generate_biot_loops_string(coil_elements,coil_diam)
        text += biot.generate_current_supply_str(coil_elements)
        f.write(text)
    #pprint.pprint(coil_elements)
'''

    # Generate martinos coil formatted text file with coordinates and normal vector
    x_string = [str(i) for i in x]
    #x_string += x_string
    y_string = [str(i) for i in y]
    #y_string += y_string
    z_string = [str(0) for i in range(number_of_elements)]
    #z_string += [str(9) for i in range(number_of_elements)]
    coil_coordinates = [' , '.join(i) for i in zip(z_string,x_string, y_string)]
    pprint.pprint(coil_coordinates)
    martinos_text_file(coil_coordinates)
    
