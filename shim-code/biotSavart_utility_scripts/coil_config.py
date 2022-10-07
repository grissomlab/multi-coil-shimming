import numpy as np
import numpy.linalg as lin
import pprint
import copy

def generate_current_supply_str(coil_dict):
    """
    Returns a string representing the current supply for each coil element
    """
    current_str = "Current {\nname {Current}\nsupplies{\n"
    current_Amps = str(0)

    for coil in coil_dict.items():
        coil_name = str(coil[0])
        coil_current = '\t{ {' + coil_name + '} {' + current_Amps + '} }\n'
        current_str += coil_current
    
    current_str += '}\n}'
    return current_str


def generate_single_element_str(element_tuple, coil_diam):
    """
    Returns a string representing a single coil element
    """
    element_name = str(element_tuple[0])
    posX = str(element_tuple[1]['Center'][0][0])
    posY = str(element_tuple[1]['Center'][1][0])
    posZ = str(element_tuple[1]['Center'][2][0])

    thetaZ0 = str(element_tuple[1]['Euler Angle'][0])
    thetaX = str(element_tuple[1]['Euler Angle'][1])
    thetaZ1 = str(element_tuple[1]['Euler Angle'][2])

    diameter = str(coil_diam)

    units = 'cm'

    string = "Loop {\nname {" + element_name + '}\n'
    string += 'color 19660 45874 45874\n'
    string += 'positionX ' + posX + ' ' + units + '\n'
    string += 'positionY ' + posY + ' ' + units + '\n'
    string += 'positionZ ' + posZ + ' ' + units + '\n'
    string += 'eulerPhi ' + thetaZ0 + '\n'
    string += 'eulerTheta ' + thetaX + '\n'
    string += 'eulerPsi ' + thetaZ1 + '\n'
    string += 'currentSupply ' + element_name
    string += """
wireDiameter 3 mm
winding 1
    thetaZ0 30
loops {
	{{"""
    string += diameter

    string +=""" cm} {0} {1}}
}
nZeta 10
flu thetaZ0Steps 16
}\n
"""
    return string
    

def generate_biot_loops_string(coil_dict, coil_diam):
    '''
    Returnes a string with all of the coil elements in coil_dict formatted according to .biot file format
    '''
    loops_string = ''
    for coil in coil_dict.items():
        element_str = generate_single_element_str(coil, coil_diam)
        loops_string += element_str
    
    return loops_string


def rotation_matrix_from_vectors(vec1, vec2):
    """ Find the rotation matrix that aligns vec1 to vec2
    :param vec1: A 3d "source" vector
    :param vec2: A 3d "destination" vector
    :return mat: A transform matrix (3x3) which when applied to vec1, aligns it with vec2.
    """
    a, b = (vec1 / np.linalg.norm(vec1)).reshape(3), (vec2 / np.linalg.norm(vec2)).reshape(3)
    v = np.cross(a, b)
    c = np.dot(a, b)
    s = np.linalg.norm(v)
    kmat = np.array([[0, -v[2], v[1]], [v[2], 0, -v[0]], [-v[1], v[0], 0]])
    rotation_matrix = np.eye(3) + kmat + kmat.dot(kmat) * ((1 - c) / (s ** 2))
    return rotation_matrix


def get_loop_center(line):
    # Accepts comma delimeted string and returns array of x y z coordinates

    try:
        x,y,z = line.split(',')
    except:
        x,y,z = line.split()

    x = float(x.strip())
    y = float(y.strip())
    z = float(z.strip())

    scale_factor = 0
    mag = np.sqrt(x**2 + y**2 + z**2)
    unit_x = x / mag
    unit_y = y / mag
    unit_z = z / mag

    x += unit_x*scale_factor
    y += unit_y*scale_factor
    z += unit_z*scale_factor

    print('loop center')
    print([x,y,z])
    return [[x],[y], [z]]
    

def get_loop_angle(line):
    # Accepts comma delimeted string and returns array of the thetaZ0 (about z), thetaX (about x), thetaZ1 (about y) angles
    
    x_axis = np.array([[1],[0],[0]])
    y_axis = np.array([[0],[1],[0]])
    z_axis = np.array([[0],[0],[1]]) 

    normal_vector = np.array(get_loop_center(line)) # use get_loop_angle to extract coordinates of normal vector

    rot_matrix = rotation_matrix_from_vectors(z_axis,normal_vector)

    
    # https://www.geometrictools.com/Documentation/EulerAngles.pdf
    # https://mino-git.github.io/rtcw-wet-blender-model-tools/publications/EulerToMatrix.pdf
    
    if ( rot_matrix[2][2] < 1):
        if(rot_matrix[2][2] > -1):
            thetaX = np.arccos(rot_matrix[2][2])
            thetaZ0 = np.arctan2(rot_matrix[0][2], -1*rot_matrix[1][2] )
            thetaZ1 = np.arctan2(rot_matrix[2][0], rot_matrix[2][1] )
        else:
            thetaX = np.pi;
            thetaZ0 = -1* np.arctan2(-1*rot_matrix[0][1], rot_matrix[0][0])
            thetaZ1 = 0;
    else:
        thetaX = 0
        thetaZ0 = np.arctan2(-1*rot_matrix[0][1], rot_matrix[0][0])
        thetaZ1 = 0

    
    print('Rotation Matrix')
    print(rot_matrix)
    
    #np.testing.assert_allclose( np.dot(rot_matrix,z_axis), (normal_vector / np.linalg.norm(normal_vector)), rtol=1e-09) # Check to make sure the rotation matrix is correct

    return np.array([thetaZ0, thetaX, thetaZ1]) * (180 / np.pi)


if __name__ == '__main__':

    
    #path = r"Martinos_Shim\coil_field_maps\generate_coil_field_maps\48ch\array_circle48.txt"
    #path = r"C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\Martinos_Shim\coil_field_maps\generate_coil_field_maps\39ch_hybrid\array_circle32_plus_faceloops.txt"
    path = r"C:\Users\griss\Desktop\Antonio\AC_DC_NHP_Coil\ellipse.txt"

    coil_elements = {}
    number_of_elements = 12;
    for i in range(number_of_elements):
        coil_elements[i] = {}

    element_number = 0
    with open(path,'r') as f:
        for index, line in enumerate(f.readlines()):
            print(str(index) + " : " + line)
            if( (index % 2) == 0): # if even then its a loop center since index starts at 0 
                coil_elements[element_number]['Center'] = get_loop_center(line)
            elif( (index % 2) == 1): # if odd then normal vector
                coil_elements[element_number]['Euler Angle'] = get_loop_angle(line)
                element_number += 1
            print(element_number)

    # Generates the duplicated row of coils for the the elliptical shim array    
    duplicate_coil = 11    
    coil_elements_copy = copy.deepcopy(coil_elements)
    for coil in coil_elements_copy.values():
        new_coil = {}
        new_coil['Center'] = coil['Center']
        new_coil['Center'][0][0] = 6
        new_coil['Euler Angle'] = coil['Euler Angle']
        coil_elements[duplicate_coil] = new_coil
        duplicate_coil += 1

  
    with open('delete.biot','w+') as f:
        coil_radius = 3
        text = generate_biot_loops_string(coil_elements, coil_radius)
        text += generate_current_supply_str(coil_elements)
        f.write(text)
    
    pprint.pprint(coil_elements)
